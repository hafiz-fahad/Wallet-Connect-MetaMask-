// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFTAuction
 * @dev Complete NFT Auction Contract with bidding, withdrawals, and auction management
 */
contract NFTAuction is ReentrancyGuard, Ownable {
    
    struct Auction {
        address seller;           // NFT owner who created the auction
        address nftContract;      // Address of the NFT contract
        uint256 tokenId;          // NFT token ID
        uint256 startPrice;       // Starting price for the auction
        uint256 highestBid;       // Current highest bid
        address highestBidder;    // Address of the highest bidder
        uint256 endTime;          // Auction end timestamp
        bool ended;               // Whether the auction has been finalized
        bool cancelled;           // Whether the auction was cancelled
    }
    
    // Mapping from auction ID to Auction
    mapping(uint256 => Auction) public auctions;
    
    // Mapping to track pending withdrawals
    mapping(address => uint256) public pendingWithdrawals;
    
    // Counter for auction IDs
    uint256 public auctionCounter;
    
    // Platform fee percentage (e.g., 250 = 2.5%)
    uint256 public platformFeePercentage = 250;
    
    // Accumulated platform fees
    uint256 public platformFees;
    
    // Events
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        address nftContract,
        uint256 tokenId,
        uint256 startPrice,
        uint256 endTime
    );
    
    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );
    
    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 amount
    );
    
    event AuctionCancelled(uint256 indexed auctionId);
    
    event Withdrawal(address indexed user, uint256 amount);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Create a new NFT auction
     * @param _nftContract Address of the NFT contract
     * @param _tokenId Token ID of the NFT
     * @param _startPrice Starting price for the auction
     * @param _duration Duration of the auction in seconds
     */
    function createAuction(
        address _nftContract,
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _duration
    ) external nonReentrant returns (uint256) {
        require(_nftContract != address(0), "Invalid NFT contract");
        require(_startPrice > 0, "Start price must be greater than 0");
        require(_duration >= 1 hours, "Duration must be at least 1 hour");
        require(_duration <= 30 days, "Duration cannot exceed 30 days");
        
        // Transfer NFT to this contract
        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "You don't own this NFT");
        require(
            nft.getApproved(_tokenId) == address(this) || 
            nft.isApprovedForAll(msg.sender, address(this)),
            "Contract not approved to transfer NFT"
        );
        
        nft.transferFrom(msg.sender, address(this), _tokenId);
        
        uint256 auctionId = auctionCounter++;
        uint256 endTime = block.timestamp + _duration;
        
        auctions[auctionId] = Auction({
            seller: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            startPrice: _startPrice,
            highestBid: 0,
            highestBidder: address(0),
            endTime: endTime,
            ended: false,
            cancelled: false
        });
        
        emit AuctionCreated(
            auctionId,
            msg.sender,
            _nftContract,
            _tokenId,
            _startPrice,
            endTime
        );
        
        return auctionId;
    }
    
    /**
     * @dev Place a bid on an auction
     * @param _auctionId ID of the auction
     */
    function placeBid(uint256 _auctionId) external payable nonReentrant {
        Auction storage auction = auctions[_auctionId];
        
        require(!auction.ended, "Auction has ended");
        require(!auction.cancelled, "Auction was cancelled");
        require(block.timestamp < auction.endTime, "Auction time has expired");
        require(msg.sender != auction.seller, "Seller cannot bid");
        require(msg.value > 0, "Bid amount must be greater than 0");
        
        // First bid must meet start price
        if (auction.highestBid == 0) {
            require(msg.value >= auction.startPrice, "Bid below start price");
        } else {
            require(msg.value > auction.highestBid, "Bid not high enough");
        }
        
        // Refund previous highest bidder
        if (auction.highestBidder != address(0)) {
            pendingWithdrawals[auction.highestBidder] += auction.highestBid;
        }
        
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }
    
    /**
     * @dev End an auction and transfer NFT to winner
     * @param _auctionId ID of the auction
     */
    function endAuction(uint256 _auctionId) external nonReentrant {
        Auction storage auction = auctions[_auctionId];
        
        require(!auction.ended, "Auction already ended");
        require(!auction.cancelled, "Auction was cancelled");
        require(
            block.timestamp >= auction.endTime,
            "Auction has not ended yet"
        );
        
        auction.ended = true;
        
        IERC721 nft = IERC721(auction.nftContract);
        
        // If there were no bids, return NFT to seller
        if (auction.highestBidder == address(0)) {
            nft.transferFrom(address(this), auction.seller, auction.tokenId);
        } else {
            // Transfer NFT to winner
            nft.transferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenId
            );
            
            // Calculate platform fee
            uint256 platformFee = (auction.highestBid * platformFeePercentage) / 10000;
            uint256 sellerAmount = auction.highestBid - platformFee;
            
            platformFees += platformFee;
            pendingWithdrawals[auction.seller] += sellerAmount;
            
            emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
        }
    }
    
    /**
     * @dev Cancel an auction (only if no bids have been placed)
     * @param _auctionId ID of the auction
     */
    function cancelAuction(uint256 _auctionId) external nonReentrant {
        Auction storage auction = auctions[_auctionId];
        
        require(msg.sender == auction.seller, "Only seller can cancel");
        require(!auction.ended, "Auction already ended");
        require(!auction.cancelled, "Auction already cancelled");
        require(auction.highestBidder == address(0), "Cannot cancel with active bids");
        
        auction.cancelled = true;
        
        // Return NFT to seller
        IERC721 nft = IERC721(auction.nftContract);
        nft.transferFrom(address(this), auction.seller, auction.tokenId);
        
        emit AuctionCancelled(_auctionId);
    }
    
    /**
     * @dev Withdraw pending funds
     */
    function withdraw() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");
        
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Withdraw platform fees (only owner)
     */
    function withdrawPlatformFees() external onlyOwner nonReentrant {
        uint256 amount = platformFees;
        require(amount > 0, "No platform fees to withdraw");
        
        platformFees = 0;
        
        (bool success, ) = payable(owner()).call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    /**
     * @dev Update platform fee percentage (only owner)
     * @param _newFee New fee percentage (e.g., 250 = 2.5%)
     */
    function updatePlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Fee cannot exceed 10%");
        platformFeePercentage = _newFee;
    }
    
    /**
     * @dev Get auction details
     * @param _auctionId ID of the auction
     */
    function getAuction(uint256 _auctionId) external view returns (
        address seller,
        address nftContract,
        uint256 tokenId,
        uint256 startPrice,
        uint256 highestBid,
        address highestBidder,
        uint256 endTime,
        bool ended,
        bool cancelled
    ) {
        Auction storage auction = auctions[_auctionId];
        return (
            auction.seller,
            auction.nftContract,
            auction.tokenId,
            auction.startPrice,
            auction.highestBid,
            auction.highestBidder,
            auction.endTime,
            auction.ended,
            auction.cancelled
        );
    }
    
    /**
     * @dev Check if auction is active
     * @param _auctionId ID of the auction
     */
    function isAuctionActive(uint256 _auctionId) external view returns (bool) {
        Auction storage auction = auctions[_auctionId];
        return !auction.ended && 
               !auction.cancelled && 
               block.timestamp < auction.endTime;
    }
    
    /**
     * @dev Get time remaining for an auction
     * @param _auctionId ID of the auction
     */
    function getTimeRemaining(uint256 _auctionId) external view returns (uint256) {
        Auction storage auction = auctions[_auctionId];
        if (block.timestamp >= auction.endTime) {
            return 0;
        }
        return auction.endTime - block.timestamp;
    }
}

