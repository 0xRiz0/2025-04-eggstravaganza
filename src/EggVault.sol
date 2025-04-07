// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EggstravaganzaNFT.sol";

contract EggVault is Ownable {
    /// @notice Reference to the EggstravaganzaNFT contract.
    EggstravaganzaNFT public eggNFT;

    /// @notice Mapping to track deposited eggs (tokenId => deposited status).
    mapping(uint256 => bool) public storedEggs;
    /// @notice Mapping to record who deposited each egg.
    mapping(uint256 => address) public eggDepositors;

    event EggDeposited(address indexed depositor, uint256 tokenId);
    event EggWithdrawn(address indexed withdrawer, uint256 tokenId);

    constructor() Ownable(msg.sender) {}

    /// @notice Set the NFT contract address.
    function setEggNFT(address _eggNFTAddress) external onlyOwner {
        require(_eggNFTAddress != address(0), "Invalid NFT address");
        eggNFT = EggstravaganzaNFT(_eggNFTAddress);
    }

    /// @notice Records the deposit of an egg (NFT).
    /// The NFT must already have been transferred to the vault.
    function depositEgg(uint256 tokenId, address depositor) public {
        require(eggNFT.ownerOf(tokenId) == address(this), "NFT not transferred to vault");
        require(!storedEggs[tokenId], "Egg already deposited");
        storedEggs[tokenId] = true;
        eggDepositors[tokenId] = depositor;
        emit EggDeposited(depositor, tokenId);
    }

    /// @notice Allows the depositor to withdraw their egg from the vault.
    function withdrawEgg(uint256 tokenId) public {
        require(storedEggs[tokenId], "Egg not in vault");
        require(eggDepositors[tokenId] == msg.sender, "Not the original depositor");

        storedEggs[tokenId] = false;
        delete eggDepositors[tokenId];

        eggNFT.transferFrom(address(this), msg.sender, tokenId);
        emit EggWithdrawn(msg.sender, tokenId);
    }

    /// @notice Checks if a specific egg is currently deposited.
    function isEggDeposited(uint256 tokenId) public view returns (bool) {
        return storedEggs[tokenId];
    }
}
