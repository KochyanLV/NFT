// SPDX-License-Identifier: MIT

// ____,d888888888b,
// _________d8888888888888b_________________________,ad8ba,_
// ______d888888888888888______________________,d888888888b,
// _____I8888888888888888____________________,8888888888888b
// _____`Y88888888888888P_______________,____888888888888888
// """""""9888888888P""^_________________^""Y8888888 88888888888
// ___,d888P"888P^___________________________^"Y8888888888P'
// ____,d8888'_____________________________________^Y8888888
// _,d8888P'________________________________________I88P"^
// 88888P'__________________________________________"b,
// 88888'____________________________________________`b,
// 8888I______________________________________________`b,
// 8888'_______________________________________________`b,
// 888__________,d88888b,______________________________`b,
// 88I_________d88888888b,___________,d8888b,___________`b
// 8I________d8888888888I__________,88888888b___________8,
// 8b_______d88888888888'__________8888888888b__________8I
// 88_______Y888888888P'___________Y8888888888,________,8b
// 8b______`Y8888888^_____________`Y888888888I________d8
// 88b,______`""""^________________`Y8888888P'_______d888I
// 8888b,___________________________`Y8888P^________d888
// 88888ba,__________________________`""^________,d88888
// 88888888ba,______d88888888b_______________,ad8888888I
// 888888888888b,____^"Y888P"^__________.,ad88888888888I
// 88888888888888b,_____""______ad888888888888888888888'
// 8888888888888888b_,ad88ba,_,d88888888888888888888888
// 88888888888888888b,`"""^_d8888888888888888888888888I
// 8888888888888888888baaad888888888888888888888888888'
// 88888888888888888888888888888888888888888888888888P
// 888888888888888888888P^__^Y8888888888888888888888'
// 888888888888888888888'_____^88888888888888888888I
// 888888888888888888888_______8888888888888888888P'
// 88888888888888888888,_____,888888888888888888P'
// 88888888888888888888I_____I888888888888888888'
// 8888888888888888888I_____I88888888888888888'
// 888888888888888888b_____d8888888888888888'
// 888888888888888888,____888888888888888P'
// 888888888888888888b,___Y888888888888P^
// Y888888888888888888b___`Y8888888P"^
// "Y8888888888888888P_____`""""^
// __`"YY88888888888P'
// _______^"""

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract Pandapoldem is ERC721AQueryable, Ownable, ReentrancyGuard {

  using Strings for uint256;

  bytes32 public merkleRoot;
  mapping(address => bool) public whitelistClaimed;

  string public uriPrefix = '';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri;
  
  uint256 public cost;
  uint256 public maxSupply;
  uint256 public maxMintAmountPerTx;

  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public revealed = false;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTx,
    string memory _hiddenMetadataUri
  ) ERC721A(_tokenName, _tokenSymbol) {
    setCost(_cost);
    maxSupply = _maxSupply;
    setMaxMintAmountPerTx(_maxMintAmountPerTx);
    setHiddenMetadataUri(_hiddenMetadataUri);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  function whitelistMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

    whitelistClaimed[_msgSender()] = true;
    _safeMint(_msgSender(), _mintAmount);
  }

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');

    _safeMint(_msgSender(), _mintAmount);
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function withdraw() public onlyOwner nonReentrant {
    // This will transfer the remaining contract balance to the owner.
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}('');
    require(os);
    // =============================================================================
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }
}
