// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleNFT
 * @dev Simple ERC721 NFT contract for testing the auction platform
 */
contract SimpleNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    
    constructor() ERC721("AuctionNFT", "ANFT") Ownable(msg.sender) {}
    
    /**
     * @dev Mint a new NFT
     * @param _to Address to mint the NFT to
     * @param _tokenURI Metadata URI for the NFT
     */
    function mintNFT(address _to, string memory _tokenURI)
        public
        returns (uint256)
    {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        _mint(_to, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        
        return newTokenId;
    }
    
    /**
     * @dev Batch mint NFTs for testing
     * @param _to Address to mint the NFTs to
     * @param _count Number of NFTs to mint
     */
    function batchMint(address _to, uint256 _count) external {
        for (uint256 i = 0; i < _count; i++) {
            mintNFT(_to, "ipfs://QmTest/");
        }
    }
    
    // Override required functions
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

