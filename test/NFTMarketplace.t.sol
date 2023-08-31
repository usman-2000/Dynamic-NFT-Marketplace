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

    // minting nfts for a marketplace
    function testMintNft() public {
        nft.safeMint(address(1),1,"audi");
        assertEq(nft.balanceOf(address(1)),1);
        console.log(address(this));
        console.log(address(nft));
        console.log(address(marketplace));
    }

    // liting the nft to the marketplace, which required approvals
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

    // Any addresses can purchases nft from the marketplace
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

    // Reselling the nft which bought from the marketplace
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

    // minting and listing multiple nfts
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

    // If nft is not active for selling , can't buy it
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

    // Tries to list nft without approvals but fails
    function testFailListingNftWithoutApproval() public{
        nft.safeMint(address(1),1,"audi");
        vm.deal(address(1),2 ether);
        vm.prank(address(1));
        marketplace.listNft{value : 1 ether}(0x2e234DAe75C793f67A35089C9d99245E1C58470b,1,1);
        assertEq(marketplace.listCounts(),1);
    }

    // Only owner can list his nft
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
