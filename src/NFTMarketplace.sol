// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin-contracts/contracts/utils/Counters.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";
import "@openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

/// @title Marketplace Contract
/// @notice A smart contract for listing and purchasing NFTs on a marketplace
contract Marketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter public listCounts;
    uint256 public listingPrice = 0.0025 ether;

    /// @title MarketItem
    /// @dev Represents an item listed on a marketplace.
    struct MarketItem {
        uint256 tokenId; // Represents the ID of the NFT being listed or purchased.
        address seller; // Represents the address of the seller.
        address nftContractAddress; // Represents the address of the ERC721 contract for the NFT.
        uint256 price; // Represents the price of the NFT in wei.
        bool active; // Represents whether the listing is active or not.
    }

    event listingNft(address nftContractAddress , uint256 tokenId , uint256 price);
    event purchasedNft(uint256 tokenId, address buyer, uint256 price);

    mapping(uint256 => mapping(address => MarketItem)) public idToMarketItem;
    mapping(uint256 => mapping(address => address)) public ownerOfItem;

    /// @notice Lists an NFT for sale on the marketplace
    /// @param _nftContractAddress The address of the ERC721 contract for the NFT
    /// @param _tokenId The ID of the NFT being listed
    /// @param _price The price of the NFT in wei
    function listNft(address _nftContractAddress, uint256 _tokenId, uint256 _price) external payable nonReentrant {
        require(msg.value >= listingPrice, "Insufficient Balance");
        require(IERC721(_nftContractAddress).ownerOf(_tokenId) == msg.sender, "You don't own this token");
        IERC721(_nftContractAddress).transferFrom(msg.sender, address(this), _tokenId);
        listCounts.increment();
        idToMarketItem[_tokenId][_nftContractAddress] =
            MarketItem(_tokenId, msg.sender, _nftContractAddress, _price, true);
        ownerOfItem[_tokenId][_nftContractAddress] = msg.sender;
        if (msg.value > listingPrice) {
            uint256 remainingAmount = msg.value - listingPrice;
            (bool sent,) = msg.sender.call{value: remainingAmount}("");
            require(sent, "Ethers Can't sent");
        }
        emit listingNft(_nftContractAddress,_tokenId,_price);
    }

    /// @notice Purchases an NFT from the marketplace
    /// @param tokenId The ID of the NFT being purchased
    /// @param _nftContractAddress The address of the ERC721 contract for the NFT
    function purchaseNft(uint256 tokenId, address _nftContractAddress) external payable nonReentrant {
        require(idToMarketItem[tokenId][_nftContractAddress].active == true, "Listing is not active");
        require(msg.value >= idToMarketItem[tokenId][_nftContractAddress].price, "Insufficient funds");
        (bool sent,) = payable(idToMarketItem[tokenId][_nftContractAddress].seller).call{value: msg.value}("");
        require(sent, "Ethers Can't sent");
        IERC721(idToMarketItem[tokenId][_nftContractAddress].nftContractAddress).transferFrom(
            address(this), msg.sender, tokenId
        );
        // if (msg.value > idToMarketItem[tokenId][_nftContractAddress].price) {
        //     uint256 remainingAmount = msg.value - idToMarketItem[tokenId][_nftContractAddress].price;
        //     (bool sentRemainingAmount,) = msg.sender.call{value: remainingAmount}("");
        //     require(sentRemainingAmount, "Ethers Can't sent");
        // }
        listCounts.decrement();

        idToMarketItem[tokenId][_nftContractAddress].active = false;
        idToMarketItem[tokenId][_nftContractAddress].seller = msg.sender;
        ownerOfItem[tokenId][_nftContractAddress] = msg.sender;
        emit purchasedNft(tokenId,msg.sender, idToMarketItem[tokenId][_nftContractAddress].price);
    }

    /// @notice Allows the contract owner to withdraw the balance of the contract
    function withdrawAmount() public onlyOwner nonReentrant {
        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "Ethers Can't sent");
    }
}
