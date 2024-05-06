// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BlogToEarnNFT is
    ERC721Enumerable,
    ReentrancyGuard,
    Ownable(msg.sender)
{
    using Strings for uint256;

    uint256 public constant TOTAL_SUPPLY = 100000;
    uint256 public constant COMMON_SUPPLY = 50000;
    uint256 public constant UNCOMMON_SUPPLY = 20000;
    uint256 public constant RARE_SUPPLY = 10000;
    uint256 public constant LEGENDARY_SUPPLY = 10000;
    uint256 public constant EPIC_SUPPLY = 10000;

    uint256 public constant COMMON_PRICE = 0.00001 ether;
    uint256 public constant UNCOMMON_PRICE = 0.00002 ether;
    uint256 public constant RARE_PRICE = 0.00003 ether;
    uint256 public constant LEGENDARY_PRICE = 0.00004 ether;
    uint256 public constant EPIC_PRICE = 0.00005 ether;

    uint256 public commonMinted = 0;
    uint256 public uncommonMinted = 0;
    uint256 public rareMinted = 0;
    uint256 public legendaryMinted = 0;
    uint256 public epicMinted = 0;

    mapping (address => bool) public minters;

    string private baseURI;

    constructor() ERC721("BlogToEarnNFT", "BTE") {}

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            ownerOf(tokenId) != address(0),
            "URI query for nonexistent token"
        );
        string memory baseURIString = _baseURI();
        return
            bytes(baseURIString).length > 0
                ? string(
                    abi.encodePacked(baseURIString, tokenId.toString(), ".json")
                )
                : "";
    }

    function commonMint(uint256 amount) public payable nonReentrant {
        require(!minters[msg.sender], "Already reached limit of 1 token per wallet");
        require(
            commonMinted + amount <= COMMON_SUPPLY,
            "Common supply exceeded"
        );
        require(msg.value == amount * COMMON_PRICE, "Incorrect ether value");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = commonMinted + i + 1;
            _safeMint(msg.sender, tokenId);
        }

        commonMinted += amount;
    }

    function uncommonMint(uint256 amount) public payable nonReentrant {
        require(!minters[msg.sender], "Already reached limit of 1 token per wallet");
        require(
            uncommonMinted + amount <= UNCOMMON_SUPPLY,
            "Uncommon supply exceeded"
        );
        require(msg.value == amount * UNCOMMON_PRICE, "Incorrect ether value");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = uncommonMinted + i + 1 + COMMON_SUPPLY;
            _safeMint(msg.sender, tokenId);
        }

        uncommonMinted += amount;
    }

    function rareMint(uint256 amount) public payable nonReentrant {
        require(!minters[msg.sender], "Already reached limit of 1 token per wallet");
        require(rareMinted + amount <= RARE_SUPPLY, "Rare supply exceeded");
        require(msg.value == amount * RARE_PRICE, "Incorrect ether value");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = rareMinted +
                i +
                1 +
                COMMON_SUPPLY +
                UNCOMMON_SUPPLY;
            _safeMint(msg.sender, tokenId);
        }

        rareMinted += amount;
    }

    function legendaryMint(uint256 amount) public payable nonReentrant {
        require(!minters[msg.sender], "Already reached limit of 1 token per wallet");
        require(
            legendaryMinted + amount <= LEGENDARY_SUPPLY,
            "Legendary supply exceeded"
        );
        require(msg.value == amount * LEGENDARY_PRICE, "Incorrect ether value");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = legendaryMinted +
                i +
                1 +
                COMMON_SUPPLY +
                UNCOMMON_SUPPLY +
                RARE_SUPPLY;
            _safeMint(msg.sender, tokenId);
        }
        legendaryMinted += amount;
    }

    function epicMint(uint256 amount) public payable nonReentrant {
        require(!minters[msg.sender], "Already reached limit of 1 token per wallet");
        require(epicMinted + amount <= EPIC_SUPPLY, "Epic supply exceeded");
        require(msg.value == amount * EPIC_PRICE, "Incorrect ether value");

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = epicMinted +
                i +
                1 +
                COMMON_SUPPLY +
                UNCOMMON_SUPPLY +
                RARE_SUPPLY +
                LEGENDARY_SUPPLY;
            _safeMint(msg.sender, tokenId);
        }

        epicMinted += amount;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
