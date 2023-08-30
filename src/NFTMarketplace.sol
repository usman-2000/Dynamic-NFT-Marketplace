// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";



contract Marketplace is Ownable,ReentrancyGuard{

    using Counters for Counters.Counter;
    Counters.Counter private listCounts;
    uint256 public listingPrice = 0.0025 ether;

    struct MarketItem{
        uint256 tokenId;
        address seller;
        address tokenContract;
        uint256 price;
        bool active;
    }

    mapping(uint256 =>mapping (address => MarketItem)) public idToMarketItem;
    mapping (uint256=> mapping (address => address)) public ownerOfItem;

    function createListing(address _tokenContract, uint256 _tokenId, uint256 _price) external payable nonReentrant  {
        require(msg.value >= listingPrice,"Insufficient Balance");
        require(IERC721(_tokenContract).ownerOf(_tokenId) == msg.sender, "You don't own this token");
        IERC721(_tokenContract).transferFrom(msg.sender, address(this), _tokenId);
        listCounts.increment();
        idToMarketItem[_tokenId][_tokenContract] = MarketItem(_tokenId, msg.sender,_tokenContract, _price, true );
        ownerOfItem[_tokenId][_tokenContract] = msg.sender;
        if(msg.value > listingPrice){
            uint256 remainingAmount = msg.value - listingPrice;
            (bool sent,) = msg.sender.call{value : remainingAmount}("");
            require(sent,"Ethers Can't sent");
        }
    }

    function purchaseItem(uint256 tokenId, address _tokenContract) external payable nonReentrant{
        require(idToMarketItem[tokenId][_tokenContract].active== true, "Listing is not active");
        require(msg.value>= idToMarketItem[tokenId][_tokenContract].price,"Insufficient funds");
        (bool sent,) = payable(idToMarketItem[tokenId][_tokenContract].seller).call{value : msg.value}("");
        require(sent,"Ethers Can't sent");
        IERC721(idToMarketItem[tokenId][_tokenContract].tokenContract).transferFrom( address(this), msg.sender, tokenId);
        idToMarketItem[tokenId][_tokenContract].active = false;
        idToMarketItem[tokenId][_tokenContract].seller = msg.sender;
        ownerOfItem[tokenId][_tokenContract] = msg.sender;
    }

    function withdraw() public onlyOwner nonReentrant{
        (bool sent,) = payable(msg.sender).call{value : address(this).balance}("");
        require(sent,"Ethers Can't sent");
    }

}