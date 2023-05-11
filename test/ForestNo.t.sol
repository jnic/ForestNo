// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/ForestNo.sol";

contract ForestNoTest is Test {
    ForestNo public forestNo;
    address constant tester = address(1);

    function setUp() public {
        forestNo = new ForestNo();
        forestNo.transferOwnership(tester);
    }

    function testMint() public {
        // Give test user some ether
        vm.deal(tester, 10 ether);
        assertEq(forestNo.balanceOf(tester), 0);

        // Become test user
        vm.startPrank(tester);

        // Mint should fail (not live yet)
        vm.expectRevert("Contract is not live yet, please try again later!");
        forestNo.mint();

        // Make contract live
        forestNo.setLiveState();

        // Mint should fail (not whitelisted)
        vm.expectRevert("Address not whitelisted during presale");
        forestNo.mint();

        // Whitelist user
        forestNo.addToWhitelist(tester);

        // Mint should succeed
        forestNo.mint();
        assertEq(forestNo.balanceOf(tester), 1);

        // Next mint should fail (max per address during presale)
        vm.expectRevert("Max NFTs per address reached");
        forestNo.mint();
    }
}
