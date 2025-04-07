// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/EggstravaganzaNFT.sol";
import "../src/EggVault.sol";
import "../src/EggHuntGame.sol";

contract EggGameTest is Test {
    EggstravaganzaNFT nft;
    EggVault vault;
    EggHuntGame game;
    address owner;
    address alice;
    address bob;

    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        owner = address(this); // The test contract is the deployer/owner.
        alice = address(0x1);
        bob = address(0x2);

        // Deploy the contracts.
        nft = new EggstravaganzaNFT("Eggstravaganza", "EGG");
        vault = new EggVault();
        game = new EggHuntGame(address(nft), address(vault));

        // Set the allowed game contract for minting eggs in the NFT.
        nft.setGameContract(address(game));

        // Configure the vault with the NFT contract.
        vault.setEggNFT(address(nft));
    }

    // -----------------------------------------
    // EggstravaganzaNFT Tests
    // -----------------------------------------
    function testSetGameContract() public {
        // Ensure that the allowed game contract was set correctly.
        assertEq(nft.gameContract(), address(game));

        // Only the owner should be able to set the game contract.
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, alice));
        nft.setGameContract(alice);

        // Setting the game contract to the zero address should revert.
        vm.expectRevert("Invalid game contract address");
        nft.setGameContract(address(0));
    }

    function testMintEgg() public {
        // Mint an egg by simulating a call from the game contract.
        vm.prank(address(game));
        bool success = nft.mintEgg(alice, 1);
        assertTrue(success);
        // Check that token 1 is owned by alice.
        assertEq(nft.ownerOf(1), alice);
        // Verify that the totalSupply counter increments.
        assertEq(nft.totalSupply(), 1);

        // Attempting to mint from a non-game contract should revert.
        vm.prank(bob);
        vm.expectRevert("Unauthorized minter");
        nft.mintEgg(bob, 2);
    }

    // -----------------------------------------
    // EggVault Tests
    // -----------------------------------------
    function testVaultDepositAndWithdraw() public {
        // Mint an egg directly to the vault (using game contract privileges).
        vm.prank(address(game));
        nft.mintEgg(address(vault), 10);
        // Ensure the vault owns token 10.
        assertEq(nft.ownerOf(10), address(vault));

        // Deposit the egg into the vault.
        vault.depositEgg(10, alice);
        // The egg should now be marked as deposited.
        assertTrue(vault.isEggDeposited(10));
        // The depositor recorded should be alice.
        assertEq(vault.eggDepositors(10), alice);

        // Depositing the same egg again should revert.
        vm.expectRevert("Egg already deposited");
        vault.depositEgg(10, alice);

        // Withdrawal by someone other than the original depositor should revert.
        vm.prank(bob);
        vm.expectRevert("Not the original depositor");
        vault.withdrawEgg(10);

        // Correct withdrawal by the depositor.
        vm.prank(alice);
        vault.withdrawEgg(10);
        // After withdrawal, alice should be the owner again.
        assertEq(nft.ownerOf(10), alice);
        // The stored egg flag should be cleared.
        assertFalse(vault.isEggDeposited(10));
        // And the depositor mapping should be reset to the zero address.
        assertEq(vault.eggDepositors(10), address(0));
    }

    // -----------------------------------------
    // EggHuntGame Tests
    // -----------------------------------------
    function testGameStartAndEnd() public {
        // Only the owner can start the game.
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, alice));
        game.startGame(100);

        // Duration must be at least the minimum (60 seconds).
        vm.expectRevert("Duration too short");
        game.startGame(50);

        // Start the game properly.
        uint256 currentTime = block.timestamp;
        game.startGame(100);
        // Check that the game is active and times are set.
        assertTrue(game.gameActive());
        assertEq(game.startTime(), currentTime);
        assertEq(game.endTime(), currentTime + 100);

        // Verify game status while active.
        string memory status = game.getGameStatus();
        assertEq(status, "Game is active");

        // Warp time to after the game duration.
        vm.warp(currentTime + 101);
        status = game.getGameStatus();
        // Even though the game is still marked active, the status reflects time elapsed.
        assertEq(status, "Game time elapsed");

        // End the game.
        game.endGame();
        assertFalse(game.gameActive());
        status = game.getGameStatus();
        assertEq(status, "Game is not active");
    }

    function testSetEggFindThreshold() public {
        // Only the owner should be able to set the egg find threshold.
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, alice));
        game.setEggFindThreshold(50);

        // Setting a threshold above 100 should revert.
        vm.expectRevert("Threshold must be <= 100");
        game.setEggFindThreshold(101);

        // Valid change by the owner.
        game.setEggFindThreshold(50);
        assertEq(game.eggFindThreshold(), 50);
    }

    function testSearchForEgg() public {
        // Start the game with a duration.
        uint256 duration = 200;
        game.startGame(duration);

        // Set threshold to 100 to guarantee that an egg is always found.
        game.setEggFindThreshold(100);

        uint256 previousEggCounter = game.eggCounter();
        // Alice attempts to search for an egg.
        vm.prank(alice);
        game.searchForEgg();

        // Check that the egg counter has increased.
        assertEq(game.eggCounter(), previousEggCounter + 1);
        // Verify that alice’s egg count increased.
        assertEq(game.eggsFound(alice), 1);

        // Confirm that the NFT was minted to alice.
        uint256 tokenId = game.eggCounter();
        assertEq(nft.ownerOf(tokenId), alice);

        // After ending the game, search should revert.
        game.endGame();
        vm.prank(bob);
        vm.expectRevert("Game not active");
        game.searchForEgg();
    }

    function testDepositEggToVault() public {
        // Mint an egg to alice via the game contract.
        vm.prank(address(game));
        nft.mintEgg(alice, 20);
        assertEq(nft.ownerOf(20), alice);

        // Alice approves the game to transfer her NFT.
        vm.prank(alice);
        nft.approve(address(game), 20);

        // Alice deposits her egg into the vault via the game contract.
        vm.prank(alice);
        game.depositEggToVault(20);
        // The NFT should now be owned by the vault.
        assertEq(nft.ownerOf(20), address(vault));
        // Vault records should indicate the egg is deposited by alice.
        assertTrue(vault.isEggDeposited(20));
        assertEq(vault.eggDepositors(20), alice);
    }

    function testGetTimeRemaining() public {
        uint256 duration = 150;
        uint256 currentTime = block.timestamp;
        game.startGame(duration);

        // Immediately after starting, time remaining should equal (endTime - currentTime).
        uint256 remaining = game.getTimeRemaining();
        assertEq(remaining, game.endTime() - block.timestamp);

        // Warp to mid-game and verify remaining time.
        vm.warp(currentTime + 75);
        remaining = game.getTimeRemaining();
        assertEq(remaining, game.endTime() - block.timestamp);

        // Warp past the end time; remaining time should be zero.
        vm.warp(currentTime + 151);
        remaining = game.getTimeRemaining();
        assertEq(remaining, 0);
    }

    // -----------------------------------------
    // Additional Edge Cases
    // -----------------------------------------
    function testGameStatusBeforeStart() public {
        // When no game is active, getGameStatus should report accordingly.
        string memory status = game.getGameStatus();
        assertEq(status, "Game is not active");
    }

    function testSearchForEggBeforeStart() public {
        // If the game hasn’t been started, searching for an egg should revert.
        vm.prank(alice);
        vm.expectRevert("Game not active");
        game.searchForEgg();
    }

    function testDepositEggWithoutTransfer() public {
        // Mint an egg to alice.
        vm.prank(address(game));
        nft.mintEgg(alice, 30);
        // Attempting to deposit an egg that has not been transferred to the vault should revert.
        vm.expectRevert("NFT not transferred to vault");
        vault.depositEgg(30, alice);
    }

    function testWithdrawEggNotDeposited() public {
        // Attempting to withdraw an egg that has not been deposited should revert.
        vm.expectRevert("Egg not in vault");
        vault.withdrawEgg(40);
    }

    //AUDIT TESTS
    function testDepositEggExploit() public {
        // Mint an egg by simulating a call from the game contract.
        vm.prank(address(game));
        bool success = nft.mintEgg(alice, 1);
        assertTrue(success);
        // Check that token 1 is owned by alice.
        assertEq(nft.ownerOf(1), alice);
        // Verify that the totalSupply counter increments.
        assertEq(nft.totalSupply(), 1);

        //Transger egg to vault
        vm.prank(alice);
        nft.approve(address(vault), 1);
        vm.prank(alice);
        nft.transferFrom(address(alice), address(vault), 1);

        // Deposit the egg into the vault.
        vm.prank(bob);
        vault.depositEgg(1, bob);
        // The egg should now be marked as deposited.
        assertTrue(vault.isEggDeposited(1));
        // The depositor recorded should be alice, but the vault allows for anyone to input depositor
        assertEq(vault.eggDepositors(1), bob);

        // Depositing the same egg again should revert.
        vm.prank(alice);
        vm.expectRevert("Egg already deposited");
        vault.depositEgg(1, alice);

        // Withdrawal by someone other than the original depositor should revert.
        vm.prank(alice);
        vm.expectRevert("Not the original depositor");
        vault.withdrawEgg(1);

        // Correct withdrawal by the depositor.
        vm.prank(bob);
        vault.withdrawEgg(1);
        // After withdrawal, alice should be the owner again.
        assertEq(nft.ownerOf(1), bob);
        // The stored egg flag should be cleared.
        assertFalse(vault.isEggDeposited(1));
        // And the depositor mapping should be reset to the zero address.
        assertEq(vault.eggDepositors(1), address(0));
    }
}
