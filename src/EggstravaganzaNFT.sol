// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EggstravaganzaNFT is ERC721, Ownable {
    /// @notice The only allowed contract to mint eggs (e.g. the EggHuntGame)
    address public gameContract;

    /// @notice Tracks the total number of minted eggs.
    uint256 public totalSupply;

    /// @notice Constructor initializes the ERC721 token with a name and symbol.
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) Ownable(msg.sender) {}

    /// @notice Only the owner can set the game contract allowed to mint eggs.
    function setGameContract(address _gameContract) external onlyOwner {
        require(_gameContract != address(0), "Invalid game contract address");
        gameContract = _gameContract;
    }

    /// @notice Public function to mint a new Eggstravaganza NFT.
    /// Only the approved game contract can mint eggs.
    function mintEgg(address to, uint256 tokenId) external returns (bool) {
        require(msg.sender == gameContract, "Unauthorized minter");
        _mint(to, tokenId);
        totalSupply += 1;
        return true;
    }
}
