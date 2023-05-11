// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract ForestNo is Initializable, ERC721Upgradeable, PausableUpgradeable, OwnableUpgradeable {

    event Minted(address indexed to, uint256 indexed tokenId);

    uint256 private constant MAX_NFTS_PER_ADDRESS = 5;
    bool private _presale = true;
    bool private _contractLive = false;
    uint256 private TOKEN_MAX_CAP = 328;
    uint256 private _tokenCount = 0;
    uint256 private _mintPrice = 0;
    string public URI;

    mapping(address => bool) private _whitelist;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    mapping(address => CountersUpgradeable.Counter) private _mintedNFTs;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() 
    {
        _disableInitializers();
        
        _transferOwnership(msg.sender);
        URI = "https://www.mymetadata.com/token/";
    }

    function initialize() initializer public 
    {
        __ERC721_init("Forest, No", "FRSTNO");
        __Pausable_init();
        __Ownable_init();

    }

    function setMintPrice(uint256 newPrice) public onlyOwner
    {
        _mintPrice = newPrice;
    }

    function setURI (string calldata _uri) external onlyOwner 
    {
        URI = _uri;
    }

    function togglePresale() public onlyOwner 
    {
        _presale = !_presale;
    }

    function setLiveState() public onlyOwner
    {
        require(!_contractLive);
        _contractLive = true;
    }

    function pause() public onlyOwner 
    {
        _pause();
    }

    function unpause() public onlyOwner 
    {
        _unpause();
    }
    function addToWhitelist(address account) public onlyOwner {
        _whitelist[account] = true;
    }

    function addBatchToWhitelist(address[] memory accounts) public onlyOwner 
    {
        for (uint256 i = 0; i < accounts.length; i++) 
        {
            _whitelist[accounts[i]] = true;
        }
    }

    function removeBatchFromWhitelist(address[] memory accounts) public onlyOwner
    {
        for(uint256 i = 0; i < accounts.length; i++)
        {
            _whitelist[accounts[i]] = false;
        }
    }


    function removeFromWhitelist(address account) public onlyOwner {
        _whitelist[account] = false;
    }

    function getRemainingMints() public view returns(uint256)
    {
        return TOKEN_MAX_CAP - _tokenCount;
    }

    function mint() external payable
    {
        require(_contractLive, "Contract is not live yet, please try again later!");
        require(msg.value >= _mintPrice, "You need to pay more than the mint price to be able to mint!");
        require(_mintedNFTs[_msgSender()].current() < MAX_NFTS_PER_ADDRESS, "MyToken: Max NFTs per address reached");
        require(_tokenCount < TOKEN_MAX_CAP);

        if (_presale) {
            require(_whitelist[msg.sender], "MyToken: Address not whitelisted during presale");
            require(_mintedNFTs[_msgSender()].current() < 1, "MyToken: Max NFTs per address reached");
        }
        
        _tokenCount = _tokenCount + 1;
        _safeMint(_msgSender(), _tokenCount);
        _mintedNFTs[_msgSender()].increment();
        emit Minted(_msgSender(), _tokenCount);
    }

    function safeMint(address to) public onlyOwner 
    {
        require(_contractLive, "Contract is not live yet, please try again later!");
        require(_mintedNFTs[to].current() < MAX_NFTS_PER_ADDRESS, "MyToken: Max NFTs per address reached");
        require(_tokenCount < TOKEN_MAX_CAP);
        // if (_presale) {
        //     require(_whitelist[msg.sender], "MyToken: Address not whitelisted during presale");
        //     require(_mintedNFTs[to].current() < 1, "MyToken: Max NFTs per address reached");
        // }
        _tokenCount = _tokenCount + 1;
        _safeMint(to, _tokenCount);
        _mintedNFTs[to].increment();
        emit Minted(to, _tokenCount);
    }


    function withdraw() public onlyOwner 
    {
        uint256 balance = address(this).balance;
        require(balance > 0, "MyToken: No funds available for withdrawal");
        payable(msg.sender).transfer(balance);
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) 
    {
        require(_exists(tokenId), "MyToken: URI query for nonexistent token");
        return string(abi.encodePacked(URI, _toString(tokenId), ".json"));
    }

// function tokenURI(uint tokenId) public view override(ERC721Upgradeable) returns (string memory) {
//     require(tokenId > 0 && tokenId <= config.supply, "15");
//     if (bytes(config.base).length > 0) {
//       return string(abi.encodePacked(config.base, _toString(tokenId), ".json"));
//     } else {
//       return bytes(config.placeholder).length > 0 ?  config.placeholder : "ipfs://bafkreieqcdphcfojcd2vslsxrhzrjqr6cxjlyuekpghzehfexi5c3w55eq";
//     }
//   }


    function _toString(uint value) internal pure returns (string memory) 
    {
        uint temp = value;
        uint digits;

        while (temp != 0) 
        {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) 
        {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint(value % 10)));
            value /= 10;
        }

        return string(buffer);
  }
}
