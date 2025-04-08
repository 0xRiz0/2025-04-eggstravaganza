<!DOCTYPE html>
<html>
<head>
<style>
    .full-page {
        width:  100%;
        height:  100vh; /* This will make the div take up the full viewport height */
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
    .full-page img {
        max-width:  200;
        max-height:  200;
        margin-bottom: 5rem;
    }
    .full-page div{
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
</style>
</head>
<body>
<div class="full-page">
    <img src="./501stAudits.png" alt="Logo">
    <div>
    <h1> Eggstravaganza Audit Report</h1>
    <h3>Version 0.1</h2>
    <h3>Riiz0</h3>
    <h4>Date: April 8th, 2025</h4>
    </div>
    
</div>

</body>
</html>

<!-- report starts here! -->
# `Eggstravaganza Audit Report`

Prepared by:
- Shawn Rizo

Lead Auditor(s):
- Shawn Rizo

Assisting Auditors:
- None

<div style="page-break-after: always;"></div>

# Table of Contents
- [`<Name> Audit Report`](#name-audit-report)
- [Table of Contents](#table-of-contents)
- [About Shawn Rizo](#about-shawn-rizo)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
- [Protocol Summary](#protocol-summary)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H-1\] Unauthorized Depositor Spoofing/FrontRunning via Public depositEgg() Function](#h-1-unauthorized-depositor-spoofingfrontrunning-via-public-depositegg-function)
  - [Medium](#medium)
    - [\[M-1\] `<Title>&<What it does>`](#m-1-titlewhat-it-does)
  - [Low](#low)
    - [\[L-1\] `<Title>&<What it does>`](#l-1-titlewhat-it-does)
  - [Informational](#informational)
    - [\[I-1\] `<Title>&<What it does>`](#i-1-titlewhat-it-does)
  - [Gas](#gas)
    - [\[G-1\] `<Title>&<What it does>`](#g-1-titlewhat-it-does)

<div style="page-break-after: always;"></div>


# About Shawn Rizo

I am a seasoned Smart Contract Engineer, adept at utilizing agile methodologies to deliver comprehensive insights and high-level overviews of blockchain projects. Specialized in developing and deploying decentralized applications (DApps) on Ethereum and EVM compatible chains. Expertise in Solidity, and security auditing, leading to a significant reduction in vulnerabilities through the strategic use of Foundry and Security Tools like Slither and Aderyn.

# Disclaimer

The Riiz0 team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 

The findings described in this document correspond the following commit hash:
```
f83ed7dff700c4319bdfd0dff796f74db5be4538
```

## Scope 

```
src/
├── EggHuntGame.sol       // Main game contract managing the egg hunt lifecycle and minting process.
├── EggVault.sol          // Vault contract for securely storing deposited Egg NFTs.
└── EggstravaganzaNFT.sol // ERC721-style NFT contract for minting unique Egg NFTs.
```

# Protocol Summary 

EggHuntGame is a gamified NFT experience where participants search for hidden eggs to mint unique Eggstravaganza Egg NFTs. Players engage in an interactive hunt during a designated game period, and successful egg finds can be deposited into a secure Egg Vault.

## Roles

Actors:
    - Game Owner: The deployer/administrator who starts and ends the game, adjusts game parameters, and manages ownership.
    - Player: Participants who call the egg search function, mint Egg NFTs upon successful searches, and may deposit them into the vault.
    - Vault Owner: The owner of the EggVault contract responsible for managing deposited eggs.

# Executive Summary
## Issues found

| Severity | Number of issues found |
| -------- | ---------------------- |
| High     | 1                      |
| Medium   | 0                      |
| Low      | 0                      |
| Info     | 0                      |
| Gas      | 0                      |
| Total    | 0                      |

# Findings
## High
### [H-1] Unauthorized Depositor Spoofing/FrontRunning via Public depositEgg() Function

**Description:** The `EggVault` contract's `depositEgg` function allows any external user to falsely claim authorship of a deposited NFT, introducing a critical logic flaw. While the function verifies that the token has been transferred to the vault, it does not securely associate the depositor with the actual sender, allowing for spoofing and front-running attacks.

**Vulnerability Details:** The vault contract previously relied on a public `depositEgg(uint256 tokenId, address depositor)` function (or a simplified version using `msg.sender`) to track deposits. However, this introduces two core issues:

- **Spoofing**: Anyone can call the function and falsely claim to be the depositor.
- **Front-running**: A malicious actor can observe a legitimate transfer to the vault and front-run the `depositEgg` call to register themselves as the depositor.

The vault assumes that whoever calls `depositEgg` is the rightful depositor, which breaks the integrity of the ownership model and enables unauthorized users to later withdraw NFTs they do not own.

**Impact:**

- An attacker can claim ownership over NFTs they do not own or transfer.
- Legitimate NFT holders may lose withdrawal rights to their own assets.
- This enables asset theft from the vault and undermines trust in the system.

**Proof of Concept:**
```solidity
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
```

```bash
Ran 1 test for test/EggHuntGameTest.t.sol:EggGameTest
[PASS] testDepositEggExploit() (gas: 203196)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 12.78ms (2.21ms CPU time)
```

**Recommended Mitigation:** Remove the `depositEgg()` function entirely and instead implement the [ERC721 token receiver interface](https://docs.openzeppelin.com/contracts/5.x/api/token/erc721#IERC721Receiver) using the `onERC721Received` function in the `EggVault` contract.

This enables safe, atomic deposits using `safeTransferFrom`, ensuring that the depositor is always the true sender of the NFT.

```solidity
function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata
) external override returns (bytes4) {
    require(msg.sender == address(eggNFT), "Not from expected NFT");
    require(!storedEggs[tokenId], "Egg already deposited");

    storedEggs[tokenId] = true;
    eggDepositors[tokenId] = from;

    emit EggDeposited(from, tokenId);

    return this.onERC721Received.selector;
}
```
Then, users can deposit their NFTs securely via:

```solidity
eggNFT.safeTransferFrom(msg.sender, address(vault), tokenId);
```

This fix:
- Prevents spoofing and frontrunning
- Maintains atomicity between transfer and deposit registration
- Aligns the contract with ERC721 best practices

## Medium
### [M-1] `<Title>&<What it does>`

**Description:**
**Vulnerability Details:** 
**Impact:**
**Proof of Concept:**
**Recommended Mitigation:**


## Low 
### [L-1] `<Title>&<What it does>`

**Description:**
**Vulnerability Details:** 
**Impact:**
**Proof of Concept:**
**Recommended Mitigation:**


## Informational
### [I-1] `<Title>&<What it does>`

**Description:**
**Impact:**
**Recommended Mitigation:**


## Gas 
### [G-1] `<Title>&<What it does>`

**Description:**
**Impact:**
**Recommended Mitigation:**