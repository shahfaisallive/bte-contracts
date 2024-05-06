// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BloggerBTERewards is ReentrancyGuard, Ownable {
    IERC20 public bteToken;
    address private signerAddress;  // Address of the authorized signer

    constructor(address _bteTokenAddress, address _signerAddress) {
        bteToken = IERC20(_bteTokenAddress);
        signerAddress = _signerAddress;
    }

    function claimTokens(address blogger, uint256 amount, bytes memory signature) external nonReentrant {
        require(_verify(blogger, amount, signature), "Invalid signature");
        require(bteToken.transfer(blogger, amount), "Token transfer failed");
    }

    function _verify(address blogger, uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(blogger, amount)));
        return recoverSigner(message, signature) == signerAddress;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65, "Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}
