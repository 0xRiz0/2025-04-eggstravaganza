// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import {EggstravaganzaNFT} from "./EggstravaganzaNFT.sol";
import {EggVault} from "./EggVault.sol";

contract EggHuntGame is Ownable {
    /// @notice Minimum game duration in seconds.
    uint256 public constant MIN_GAME_DURATION = 60;

    uint256 public startTime;
    uint256 public endTime;
    bool public gameActive;

    /// @notice References to the EggstravaganzaNFT and EggVault contracts.
    EggstravaganzaNFT public eggNFT;
    EggVault public eggVault;

    /// @notice Tracks the number of eggs found per participant.
    mapping(address => uint256) public eggsFound;
    /// @notice Global counter for minted egg token IDs.
    uint256 public eggCounter;

    /// @notice Chance (in percent) to find an egg on each search attempt.
    uint256 public eggFindThreshold = 20; // Default is a 20% chance

    event GameStarted(uint256 startTime, uint256 endTime);
    event EggFound(address indexed player, uint256 tokenId, uint256 totalEggsFound);
    event GameEnded(uint256 endTime);

    /// @notice Initializes the game with deployed contract addresses.
    constructor(address _eggNFTAddress, address _eggVaultAddress) Ownable(msg.sender) {
        require(_eggNFTAddress != address(0), "Invalid NFT address");
        require(_eggVaultAddress != address(0), "Invalid vault address");
        eggNFT = EggstravaganzaNFT(_eggNFTAddress);
        eggVault = EggVault(_eggVaultAddress);
    }

    /// @notice Starts the egg hunt game for a specified duration.
    function startGame(uint256 duration) external onlyOwner {
        require(!gameActive, "Game already active");
        require(duration >= MIN_GAME_DURATION, "Duration too short");
        startTime = block.timestamp;
        endTime = block.timestamp + duration;
        gameActive = true;
        emit GameStarted(startTime, endTime);
    }

    /// @notice Ends the egg hunt game.
    function endGame() external onlyOwner {
        require(gameActive, "Game not active");
        gameActive = false;
        emit GameEnded(block.timestamp);
    }

    /// @notice Allows the owner to adjust the egg-finding chance.
    function setEggFindThreshold(uint256 newThreshold) external onlyOwner {
        require(newThreshold <= 100, "Threshold must be <= 100");
        eggFindThreshold = newThreshold;
    }

    /// @notice Participants call this function to search for an egg.
    /// A pseudo-random number is generated and, if below the threshold, an egg is found.
    function searchForEgg() external {
        require(gameActive, "Game not active");
        require(block.timestamp >= startTime, "Game not started yet");
        require(block.timestamp <= endTime, "Game ended");

        // Pseudo-random number generation (for demonstration purposes only)
        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, eggCounter))) % 100;

        if (random < eggFindThreshold) {
            eggCounter++;
            eggsFound[msg.sender] += 1;
            eggNFT.mintEgg(msg.sender, eggCounter);
            emit EggFound(msg.sender, eggCounter, eggsFound[msg.sender]);
        }
    }

    /// @notice Allows a player to deposit their egg NFT into the Egg Vault.
    function depositEggToVault(uint256 tokenId) external {
        require(eggNFT.ownerOf(tokenId) == msg.sender, "Not owner of this egg");
        // The player must first approve the transfer on the NFT contract.
        eggNFT.transferFrom(msg.sender, address(eggVault), tokenId);
        eggVault.depositEgg(tokenId, msg.sender);
    }

    /// @notice Returns a human-readable status of the game.
    function getGameStatus() external view returns (string memory) {
        if (gameActive) {
            if (block.timestamp < startTime) {
                return "Game not started yet";
            } else if (block.timestamp >= startTime && block.timestamp <= endTime) {
                return "Game is active";
            } else {
                return "Game time elapsed";
            }
        } else {
            return "Game is not active";
        }
    }

    /// @notice Returns the number of seconds remaining in the game.
    function getTimeRemaining() external view returns (uint256) {
        return block.timestamp >= endTime ? 0 : endTime - block.timestamp;
    }
}
