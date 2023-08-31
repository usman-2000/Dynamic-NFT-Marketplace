// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin-contracts/contracts/utils/Counters.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";
import "@openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";



contract Marketplace is Ownable,ReentrancyGuard{

    using Counters for Counters.Counter;
    Counters.Counter private listCounts;
    uint256 public listingPrice = 0.0025 ether;

    struct MarketItem{
        uint256 tokenId;
        address seller;
        address nftContractAddress;
        uint256 price;
        bool active;
    }

    mapping(uint256 =>mapping (address => MarketItem)) public idToMarketItem;
    mapping (uint256=> mapping (address => address)) public ownerOfItem;

    function listNft(address _nftContractAddress, uint256 _tokenId, uint256 _price) external payable nonReentrant  {
        require(msg.value >= listingPrice,"Insufficient Balance");
        require(IERC721(_nftContractAddress).ownerOf(_tokenId) == msg.sender, "You don't own this token");
        IERC721(_nftContractAddress).transferFrom(msg.sender, address(this), _tokenId);
        listCounts.increment();
        idToMarketItem[_tokenId][_nftContractAddress] = MarketItem(_tokenId, msg.sender,_nftContractAddress, _price, true );
        ownerOfItem[_tokenId][_nftContractAddress] = msg.sender;
        if(msg.value > listingPrice){
            uint256 remainingAmount = msg.value - listingPrice;
            (bool sent,) = msg.sender.call{value : remainingAmount}("");
            require(sent,"Ethers Can't sent");
        }
    }

    function purchaseNft(uint256 tokenId, address _nftContractAddress) external payable nonReentrant{
        require(idToMarketItem[tokenId][_nftContractAddress].active== true, "Listing is not active");
        require(msg.value>= idToMarketItem[tokenId][_nftContractAddress].price,"Insufficient funds");
        (bool sent,) = payable(idToMarketItem[tokenId][_nftContractAddress].seller).call{value : msg.value}("");
        require(sent,"Ethers Can't sent");
        IERC721(idToMarketItem[tokenId][_nftContractAddress].nftContractAddress).transferFrom( address(this), msg.sender, tokenId);
        idToMarketItem[tokenId][_nftContractAddress].active = false;
        idToMarketItem[tokenId][_nftContractAddress].seller = msg.sender;
        ownerOfItem[tokenId][_nftContractAddress] = msg.sender;
    }

    function withdrawAmount() public onlyOwner nonReentrant{
        (bool sent,) = payable(msg.sender).call{value : address(this).balance}("");
        require(sent,"Ethers Can't sent");
    }

}