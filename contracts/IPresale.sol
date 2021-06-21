// SPDX-License-Identifier: UNLICENSED
// Author: The Defi Network
// Copyright 2021

pragma solidity ^0.8.4;

interface IPresale {
  //
  // ENUMS
  //

  //
  // VIEW FUNCTIONS
  //

  /**
   * @notice The address owning the project being presold
   * @return address The project owner address
   */
  function tokenAddress() external view returns (address);

  /**
   * @notice The amount of tokens to be pre-sold
   * @return uint256 The amount of tokens
   */
  function tokenAmount() external view returns (uint256);

  /**
   * @notice The price of tokens per ETH
   * @return uint256 The token price
   */
  function price() external view returns (uint256);

  /**
   * @notice The block when the presale begins
   * @return uint256 The block number
   */
  function startBlock() external view returns (uint256);

  /**
   * @notice The block when the presale ends
   * @return uint256 The block number
   */
  function endBlock() external view returns (uint256);

  /**
   * @notice The soft cap the project intends to hit
   * @return uint256 The amount in ETH
   */
  function softCap() external view returns (uint256);

  /**
   * @notice The hard cap the project intends to hit
   * @return uint256 The amount in ETH
   */
  function hardCap() external view returns (uint256);

  /**
   * @notice The minimum amount of ETH that could be used to buy in
   * @return uint256 The amount in ETH
   */
  function minBuy() external view returns (uint256);

  /**
   * @notice The maxmium amount of ETH that could be used to buy in
   * @return uint256 The amount in ETH
   */
  function maxBuy() external view returns (uint256);


  /**
   * @notice Returns the number of tokens bought by a wallet
   * @param _wallet The wallet address
   * @return uint256 Number of tokens
   */
  function tokensBought(address _wallet) external view returns (uint256);

  /**
   * @notice Returns the if address has claimed or not
   * @param _wallet The wallet address
   * @return bool Has wallet claimed?
   */
  function hasClaimed(address _wallet) external view returns (bool);

  //
  // FUNCTIONS
  //

  /**
   * @notice Allows a user to participate in the presale and buy the token
   * @param _tokenAmount The amount of tokens the user wants to buy
   */
  function buy(uint256 _tokenAmount) external payable;

  /**
   * @notice Allows a user to claim tokens after presale if the softcap was hit
   */
  function claimTokens() external;

  /**
   * @notice Allows a user to claim ETH if the softcap wasn't hit
   */
  function claimETH() external;

  /**
   * @notice Function to withdraw funds to the launchpad team wallet
   * @param _payee The wallet the funds are withdrawn to
   */
  function withdrawFunds(address _payee) external;

  /**
   * @notice Function to withdraw unsold tokens to the launchpad team wallet
   * @param _payee The wallet the tokens are withdrawn to
   */
  function withdrawUnsoldTokens(address _payee) external;

}