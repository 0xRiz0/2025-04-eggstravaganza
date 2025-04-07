Notes:
    - 1. NFT must be transfered to vault before deposit as it requires for the vault to own the NFT. The issue is if the game contract privilges mints an nft to the vault anyone can run the depositEgg function and claim it as their own by giving their own address as the depositor. As issue arrises when a user mints a NFT then approves/transfers that NFT to the vault anyone can claim that NFT as their own by providing their address as the depositor. Given that The NFT must already have been transferred to the vault we need to have a way to keep track of NFTs transfered in so that only thoses addresses that transfered the NFT are the correct depositor for the parameter in depositEgg.

Questions:
    - 1.
Answers:
    - 1.

Findings:
    - 1. Unauthorized Depositor Spoofing/FrontRunning via Public depositEgg() Function