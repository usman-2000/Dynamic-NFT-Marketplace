// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {console,Test} from "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";

contract MarketplaceTestContract is Test{
    Marketplace marketplace;

    function setUp() public{
        marketplace = new Marketplace();
    }
}