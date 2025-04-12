INFO:Detectors:
EggHuntGame.searchForEgg() (src/EggHuntGame.sol#65-80) uses a weak PRNG: "random = uint256(keccak256(bytes)(abi.encodePacked(block.timestamp,block.prevrandao,msg.sender,eggCounter))) % 100 (src/EggHuntGame.sol#71-72)"
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#weak-PRNG
INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) has bitwise-xor operator ^ instead of the exponentiation operator **:
         - inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#205)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-exponentiation
INFO:Detectors:
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse = (3 * denominator) ^ 2 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#205)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#209)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#210)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#211)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#212)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#213)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - denominator = denominator / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#190)
        - inverse *= 2 - denominator * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#214)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) performs a multiplication on the result of a division:
        - prod0 = prod0 / twos (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#193)
        - result = prod0 * inverse (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#220)
Math.invMod(uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#243-289) performs a multiplication on the result of a division:
        - quotient = gcd / remainder (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#265)
        - (gcd,remainder) = (remainder,gcd - remainder * quotient) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#267-274)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#divide-before-multiply
INFO:Detectors:
EggHuntGame.searchForEgg() (src/EggHuntGame.sol#65-80) ignores return value by eggNFT.mintEgg(msg.sender,eggCounter) (src/EggHuntGame.sol#77)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
INFO:Detectors:
EggstravaganzaNFT.constructor(string,string)._name (src/EggstravaganzaNFT.sol#15) shadows:
        - ERC721._name (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#23) (state variable)
EggstravaganzaNFT.constructor(string,string)._symbol (src/EggstravaganzaNFT.sol#15) shadows:
        - ERC721._symbol (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#26) (state variable)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#local-variable-shadowing
INFO:Detectors:
EggHuntGame.setEggFindThreshold(uint256) (src/EggHuntGame.sol#58-61) should emit an event for:
        - eggFindThreshold = newThreshold (src/EggHuntGame.sol#60)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-events-arithmetic
INFO:Detectors:
Reentrancy in EggHuntGame.searchForEgg() (src/EggHuntGame.sol#65-80):
        External calls:
        - eggNFT.mintEgg(msg.sender,eggCounter) (src/EggHuntGame.sol#77)
        Event emitted after the call(s):
        - EggFound(msg.sender,eggCounter,eggsFound[msg.sender]) (src/EggHuntGame.sol#78)
Reentrancy in EggVault.withdrawEgg(uint256) (src/EggVault.sol#38-47):
        External calls:
        - eggNFT.transferFrom(address(this),msg.sender,tokenId) (src/EggVault.sol#45)
        Event emitted after the call(s):
        - EggWithdrawn(msg.sender,tokenId) (src/EggVault.sol#46)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
INFO:Detectors:
EggHuntGame.searchForEgg() (src/EggHuntGame.sol#65-80) uses timestamp for comparisons
        Dangerous comparisons:
        - require(bool,string)(block.timestamp >= startTime,Game not started yet) (src/EggHuntGame.sol#67)
        - require(bool,string)(block.timestamp <= endTime,Game ended) (src/EggHuntGame.sol#68)
        - random < eggFindThreshold (src/EggHuntGame.sol#74)
EggHuntGame.getGameStatus() (src/EggHuntGame.sol#91-103) uses timestamp for comparisons
        Dangerous comparisons:
        - block.timestamp < startTime (src/EggHuntGame.sol#93)
        - block.timestamp >= startTime && block.timestamp <= endTime (src/EggHuntGame.sol#95)
EggHuntGame.getTimeRemaining() (src/EggHuntGame.sol#106-108) uses timestamp for comparisons
        Dangerous comparisons:
        - block.timestamp >= endTime (src/EggHuntGame.sol#107)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#block-timestamp
INFO:Detectors:
ERC721Utils.checkOnERC721Received(address,address,address,uint256,bytes) (lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#25-49) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#43-45)
Panic.panic(uint256) (lib/openzeppelin-contracts/contracts/utils/Panic.sol#50-56) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Panic.sol#51-55)
Strings.toString(uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#37-55) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#42-44)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#47-49)
Strings.toChecksumHexString(address) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#103-121) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#108-110)
Strings._unsafeReadBytesOffset(bytes,uint256) (lib/openzeppelin-contracts/contracts/utils/Strings.sol#435-440) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/Strings.sol#437-439)
Math.mulDiv(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#144-223) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#151-154)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#175-182)
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#188-197)
Math.tryModExp(uint256,uint256,uint256) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#337-361) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#339-360)
Math.tryModExp(bytes,bytes,bytes) (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#377-399) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#389-398)
SafeCast.toUint(bool) (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#1157-1161) uses assembly
        - INLINE ASM (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#1158-1160)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#assembly-usage
INFO:Detectors:
2 different versions of Solidity are used:
        - Version constraint ^0.8.20 is used by:
                -^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Panic.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#5)
                -^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
        - Version constraint ^0.8.23 is used by:
                -^0.8.23 (src/EggHuntGame.sol#2)
                -^0.8.23 (src/EggVault.sol#2)
                -^0.8.23 (src/EggstravaganzaNFT.sol#2)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#different-pragma-directives-are-used
INFO:Detectors:
Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
        - VerbatimInvalidDeduplication
        - FullInlinerNonExpressionSplitArgumentEvaluationOrder
        - MissingSideEffectsOnSelectorAccess.
It is used by:
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/access/Ownable.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#3)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Utils.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Context.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Panic.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/Strings.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/Math.sol#4)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol#5)
        - ^0.8.20 (lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#4)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#incorrect-versions-of-solidity
INFO:Detectors:
Parameter EggVault.setEggNFT(address)._eggNFTAddress (src/EggVault.sol#22) is not in mixedCase
Parameter EggstravaganzaNFT.setGameContract(address)._gameContract (src/EggstravaganzaNFT.sol#18) is not in mixedCase
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
INFO:Detectors:
EggHuntGame.eggNFT (src/EggHuntGame.sol#17) should be immutable
EggHuntGame.eggVault (src/EggHuntGame.sol#18) should be immutable
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#state-variables-that-could-be-declared-immutable