// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TheSpot is ERC721, Ownable {
    using Strings for uint256; 
    using SafeMath for uint256;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //whitelisted
    mapping(address => bool) whitelistedAddresses;
     Counters.Counter public _whitelistedCount;
    uint256 public timeWhitelisted;

    uint256 public constant MINT_NFT_FEE = .69 ether;

    // Base URI
    string private BASE_URI_EXTENDED;
    uint256 MAX_LIMIT_PER_USER = 10;  // delete this
    uint256 _totalSupply;
    mapping(address => uint256) public NFT_MINTED_PER_USER;

    address public ADMIN_WALLET = 0x32bD2811Fb91BC46756232A0B8c6b2902D7d8763;

    constructor() ERC721("The Spot", "SPOT") {     
      timeWhitelisted=block.timestamp +  2 days;  
     
        BASE_URI_EXTENDED = "https://meta.spot/";
        _totalSupply = 610;
    }


         // whitelisted 
    function addUserWhitelist(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
      _whitelistedCount.increment();
    }
       
       //blacklisted
    function addUserblacklist(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = false;
    }
        // verify whitelisted
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }


    function baseURI() public view returns (string memory) {
        return BASE_URI_EXTENDED; 
    } 

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
         
        return string(abi.encodePacked(baseURI(), tokenId.toString()));
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        BASE_URI_EXTENDED = baseURI_;
    }

    function mintSPOT(uint256 tokenAmount) external payable returns (bool) {
        require(_tokenIds.current() + tokenAmount <= _totalSupply, "Maximum Supply Minted");
        require(msg.value == MINT_NFT_FEE.mul(tokenAmount), "Invalid Minting Fee");
        require(tokenAmount <= 10, "Max limit exceed");
        require(NFT_MINTED_PER_USER[msg.sender].add(tokenAmount) <= MAX_LIMIT_PER_USER, "Already minted the max NFT");

        payable(ADMIN_WALLET).transfer(msg.value);

        //mint whitelisted

        if(whitelistedAddresses[msg.sender] = true && block.timestamp >=timeWhitelisted ){
        require(_whitelistedCount.current() >=11,"end white listed");
           _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);

        }

        for(uint i = 0; i < tokenAmount; i++ ) {
            _tokenIds.increment();
            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
        }
        NFT_MINTED_PER_USER[msg.sender].add(tokenAmount);
        return true;
    } 

    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }
    
    function remainingSupply() external view returns(uint256){
        return _totalSupply.sub(_tokenIds.current());
    }

    function nftCount() external view returns(uint256){
        return  _tokenIds.current();
    }
    
    function withdrawEth() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}