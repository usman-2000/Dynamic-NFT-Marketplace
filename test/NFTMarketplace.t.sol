// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {console, Test} from "forge-std/Test.sol";
import "../src/NFTMarketplace.sol";
import "../src/ERC721contract.sol";

contract MarketplaceTestContract is Test {
    Marketplace marketplace;
    MyToken nft;

    function setUp() public {
        marketplace = new Marketplace();
        nft = new MyToken();
    }

    function testMintNft() public {
        nft.safeMint(address(1),1,"audi");
        assertEq(nft.balanceOf(address(1)),1);
        console.log(address(this));
        console.log(address(nft));
        console.log(address(marketplace));
    }

    function testListingNft() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);
        
    }

    function testPurchaseNft() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);

        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        marketplace.purchaseNft{value : 1 ether}(1,address(nft));
        assertEq(nft.balanceOf(address(2)),1);
    }

    function testResellNft() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);

        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        marketplace.purchaseNft{value : 1 ether}(1,address(nft));
        assertEq(nft.balanceOf(address(2)),1);

        vm.prank(address(2));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(2));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);
    }

    function testListMultipleNfts() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);


        nft.safeMint(address(2),2,"audi1");
        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(2));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(2));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,2,1);
        assertEq(marketplace.listCounts(),2);
        
    }

    function testFailPruchaseNotActiveNft() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);

        vm.deal(address(2),2 ether);
        vm.prank(address(2));
        marketplace.purchaseNft{value : 1 ether}(1,address(nft));
        assertEq(nft.balanceOf(address(2)),1);

        vm.deal(address(3),2 ether);
        vm.prank(address(3));
        marketplace.purchaseNft{value : 1 ether}(1,address(nft));
    }

    function testFailListingNftWithoutApproval() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);
    }

    function testFailNotOwnerTryingToListingNft() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(3),2 ether);
        vm.prank(address(1));
        nft.setApprovalForAll(address(nft),true);
        vm.prank(address(1));
        nft.setApprovalForAll(address(marketplace),true);
        vm.prank(address(3));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);
    }
}
