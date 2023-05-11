// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract ForestNoTest is Test {
    ForestNo public forestNo;

    function setUp() public {
        forestNo = new ForestNo();
    }

    function testMint() public {
        forestNo.mint();
    }
}
