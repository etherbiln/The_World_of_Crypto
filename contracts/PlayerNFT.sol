// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PlayerNFT is ERC721 {
    uint256 private _nextTokenId;

    // NFT'nin nadirlik seviyesi
    mapping(uint256 => uint256) public tokenRarity;

    // NFT'nin sahip olduğu özellikler (hazine avına özel)
    struct NFTAttributes {
        uint256 strength;
        uint256 agility;
        uint256 intelligence;
        uint256 luck;
    }

    mapping(uint256 => NFTAttributes) public tokenAttributes;
    mapping(uint256 => string) private _tokenURIs;

    // NFT'nin yakılıp yakılmadığı bilgisi
    mapping(uint256 => bool) public isBurned;
    mapping(uint256 => bool) private _mintedTokens;

    // Nadirlik seviyeleri
    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary
    }

    // Event'ler
    event Minted(address indexed to, uint256 tokenId, uint256 rarity);
    event Burned(uint256 tokenId);
    event AttributesUpdated(uint256 tokenId, uint256 strength, uint256 agility, uint256 intelligence, uint256 luck);
    event TokenURIUpdated(uint256 tokenId, string uri);

    constructor() ERC721("Treasure Hunter NFT", "THNFT") {
        _nextTokenId = 1; // İlk token ID'si 1'den başlar
    }

    // NFT mint etme
    function mint(address to, uint256 rarity) public {
        require(rarity <= uint256(Rarity.Legendary), "Invalid rarity level");

        uint256 newTokenId = _nextTokenId;
        _nextTokenId++;

        _safeMint(to, newTokenId);
        tokenRarity[newTokenId] = rarity;
        _mintedTokens[newTokenId] = true;

        tokenAttributes[newTokenId] = NFTAttributes({
            strength: 10,
            agility: 10,
            intelligence: 10,
            luck: 10
        });

        emit Minted(to, newTokenId, rarity);
    }

    // NFT'nin nadirlik seviyesini getir
    function getRarity(uint256 tokenId) public view returns (uint256) {
        require(_mintedTokens[tokenId], "Token does not exist");
        return tokenRarity[tokenId];
    }

    // NFT'nin özelliklerini getir
    function getAttributes(uint256 tokenId) public view returns (NFTAttributes memory) {
        require(_mintedTokens[tokenId], "Token does not exist");
        return tokenAttributes[tokenId];
    }

    // NFT'nin özelliklerini güncelle
    function updateAttributes(uint256 tokenId, uint256 strength, uint256 agility, uint256 intelligence, uint256 luck) public {
        require(_mintedTokens[tokenId], "Token does not exist");
        require(!isBurned[tokenId], "Token is burned");

        tokenAttributes[tokenId] = NFTAttributes({
            strength: strength,
            agility: agility,
            intelligence: intelligence,
            luck: luck
        });

        emit AttributesUpdated(tokenId, strength, agility, intelligence, luck);
    }

    // NFT'yi yak
    function burn(uint256 tokenId) public  {
        require(_mintedTokens[tokenId], "Token does not exist");
        require(!isBurned[tokenId], "Token is already burned");

        isBurned[tokenId] = true;
        _burn(tokenId);

        emit Burned(tokenId);
    }

    // NFT Metadata URI Güncelleme
    function setTokenURI(uint256 tokenId, string memory uri) public  {
        require(_mintedTokens[tokenId], "Token does not exist");
        require(!isBurned[tokenId], "Token is burned");

        _tokenURIs[tokenId] = uri;
        emit TokenURIUpdated(tokenId, uri);
    }

    // NFT Metadata URI Get
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_mintedTokens[tokenId], "Token does not exist");
        require(!isBurned[tokenId], "Token is burned");

        return _tokenURIs[tokenId];
    }
}
