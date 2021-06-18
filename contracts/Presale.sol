// SPDX-License-Identifier: UNLICENSED
// Author: The Defi Network
// Copyright 2021

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./IPresale.sol";

contract Presale is IPresale, Ownable {
  using SafeMath for uint256;

  //
  // GLOBAL VARS
  //
  
  // The token getting pre-sold
  address public override tokenAddress;
  // The amount of tokens getting pre-sold
  uint256 public override tokenAmount;
  // The price per ETH at presale
  uint256 public override price;
  // The starting block of the presale
  uint256 public override startBlock;
  // The ending block of the presale
  uint256 public override endBlock;
  // The softcap the project intends to hit
  uint256 public override softCap;
  // The hard cap the project intends to hit
  uint256 public override hardCap;
  // The minimum amount that could be used to buy in
  uint256 public override minBuy;
  // The maximum amount that could be used to buy in
  uint256 public override maxBuy;
  // 
  // MAPPINGS
  //

  /**
   * @notice Mapping for tokens bought by the address
   */
  mapping(address => uint256) public override tokensBought;

  /**
   * @notice Mapping for address if it has claimed or not
   */
  mapping(address => bool) public override hasClaimed;


  //
  // FUNCTIONS
  //

  /**
   * @notice Initialize a Presale contract
   * @param _tokenAddress The token getting pre-sold
   * @param _tokenAmount The amount of tokens getting pre-sold
   * @param _price The price per ETH at presale
   * @param _startBlock The starting block of the presale
   * @param _endBlock The ending block of the presale
   * @param _softCap The soft cap the project intends to hit
   * @param _hardCap The hard cap the project intends to hit
   * @param _minBuy The minimum amount that could be used to buy in
   * @param _maxBuy The maxmium amount that could be used to buy in
   */
  constructor( 
    address _tokenAddress, uint256 _tokenAmount, uint256 _price, 
    uint256 _startBlock, uint256 _endBlock, uint256 _softCap, uint256 _hardCap, 
    uint256 _minBuy, uint256 _maxBuy
  ) {
    // Initalize presale variables
    tokenAddress = _tokenAddress;
    tokenAmount = _tokenAmount;
    price = _price;
    startBlock = _startBlock;
    endBlock = _endBlock;
    softCap = _softCap;
    hardCap = _hardCap;
    minBuy = _minBuy;
  }
  
  /**
   * @notice Allows a user to participate in the presale and buy the token
   * @param _tokenAmount The amount of tokens the user wants to buy
   */
  function buy(uint256 _tokenAmount) external override payable {
    // Check if presale has began
    require(block.number >= startBlock, "Presale::buy: Presale hasn't started");
    // Check if presale has ended
    require(block.number < endBlock, "Presale::buy: Presale has ended");

    // Check if correct amount of ETH is sent
    require(msg.value == _tokenAmount.mul(price),
      "Presale::buy: Wrong amount of ETH sent");
    // Check if hardcap is hit
    require(address(this).balance.add(msg.value) < hardCap, 
      "Presale::buy: Hardcap has been hit");

    // Add to the tokens bought by the user
    tokensBought[_msgSender()] = tokensBought[_msgSender()].add(_tokenAmount);

    // Check if token amount is atleast as much as min buy
    require(tokensBought[_msgSender()] >= minBuy.mul(price), 
      "Presale::buy: Tokens bought should exceed mininum amount");
    // Check if token amount is atmost as much as max buy
    require(tokensBought[_msgSender()] <= maxBuy.mul(price), 
      "Presale::buy: Tokens bought should exceed mininum amount");
  }

  /**
   * @notice Allows a user to claim tokens after presale if the softcap was hit
   */
  function claimTokens() external override {
    require(block.number > endBlock, 
      "Presale::claimTokens: Presale hasn't ended yet");
    require(address(this).balance >= softCap, 
      "Presale::claimTokens: Soft cap wasn't hit");
    require(hasClaimed[_msgSender()] , 
      "Presale::claimTokens: Address has already claimed tokens");
    
    // Transfer the tokens bought
    IERC20(tokenAddress).transfer(_msgSender(), tokensBought[_msgSender()]);
    // User has now claimed
    hasClaimed[_msgSender()] = true;
  }

  /**
   * @notice Allows a user to claim ETH after presale if the softcap wasn't hit
   */
  function claimETH() external override {
    require(block.number >= endBlock, 
      "Presale::claimETH: Presale hasn't ended yet");
    require(address(this).balance < softCap, 
      "Presale::claimETH: Soft cap was hit");
    require(hasClaimed[_msgSender()] , 
      "Presale::claimETH: Address has already claimed stable");

    // Transfer the ETH sent
    payable(_msgSender()).transfer(tokensBought[_msgSender()].mul(price));
    // User has now claimed
    hasClaimed[_msgSender()] = true;
  }

  /**
   * @notice Function to withdraw funds to the launchpad team wallet
   * @param _payee The wallet the funds are withdrawn to
   */
  function withdrawFunds(address _payee) external override onlyOwner {
    require(block.number >= endBlock, 
      "Presale::withdrawFunds: Presale hasn't ended yet");
    require(address(this).balance >= softCap, 
      "Presale::withdrawFunds: Soft cap wasn't hit");
    require(address(this).balance > 0, 
      "Presale::withdrawFunds: No ETH in contract");
    
    // Transfer the ETH sent
    payable(_msgSender()).transfer(address(this).balance);
  }

  /**
   * @notice Function to withdraw unsold tokens to the launchpad team wallet
   * @param _payee The wallet the funds are withdrawn to
   */
  function withdrawUnsoldTokens(address _payee) external override onlyOwner {
    require(block.number >= endBlock, 
      "Presale::withdrawUnsoldTokens: Presale hasn't ended yet");
    require(IERC20(tokenAddress).balanceOf(address(this)) > 0, 
      "Presale::withdrawUnsoldTokens: No Unsold tokens in contract");
    
    IERC20(tokenAddress).transfer(
      _payee, IERC20(tokenAddress).balanceOf(address(this)));
  }

  receive() payable external {}
}