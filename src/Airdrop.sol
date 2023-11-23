// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

interface IAirdrop {
    struct AirdropCampaign {
        bytes32 root;
        address token;
        uint96 expiredAt;
    }

    error AlreadyClaimed();
    error InvalidProofs(bytes32[] proofs);
    error CampaignExpired(uint96 expiredAt);

    event Withdrawal(
        address indexed recipient,
        address indexed token,
        uint256 amount
    );
    event Redeemed(
        address indexed account,
        address indexed token,
        uint256 amount
    );
    event CampaignStarted(uint256 campaignId);
}

contract Airdrop is IAirdrop, Ownable {
    using MerkleProof for *;
    using SafeTransferLib for *;

    mapping(uint256 => AirdropCampaign) private _airdropCampaign;
    mapping(address => mapping(uint256 => bool)) private _hasClaimed;

    receive() external payable {}

    constructor(address initOwner) Ownable(initOwner) {}

    function startCampaign(
        bytes32 merkleRoot,
        address token,
        uint96 duration
    ) external onlyOwner {
        uint96 expired;
        uint256 timestamp = block.timestamp;
        unchecked {
            expired = uint96(timestamp) + duration;
        }
        _airdropCampaign[timestamp] = AirdropCampaign(
            merkleRoot,
            token,
            expired
        );

        emit CampaignStarted(timestamp);
    }

    function redeem(
        address to,
        uint256 amount,
        uint256 campaignId,
        bytes32[] calldata proofs
    ) external payable {
        _beforeRedeem(to, amount, campaignId, proofs);
        address token = _airdropCampaign[campaignId].token;
        if (token == address(0)) {
            to.safeTransferETH(amount);
        } else {
            token.safeTransfer(to, amount);
        }

        emit Redeemed(to, token, amount);
    }

    function withdraw(
        address recipient,
        address token,
        uint256 amount
    ) external onlyOwner {
        if (token == address(0)) {
            recipient.safeTransferETH(amount);
        } else {
            token.safeTransfer(recipient, amount);
        }

        emit Withdrawal(recipient, token, amount);
    }

    function _beforeRedeem(
        address account,
        uint256 amount,
        uint256 campaignId,
        bytes32[] calldata proofs
    ) internal {
        _expiredCheck(campaignId);
        _claimedCheck(account, campaignId);
        _proofsCheck(account, amount, campaignId, proofs);
        _hasClaimed[account][campaignId] = true;
    }

    function _claimedCheck(address account, uint256 campaignId) internal view {
        if (_hasClaimed[account][campaignId]) revert AlreadyClaimed();
    }

    function _expiredCheck(uint256 campaignId) internal view {
        uint256 _cId = campaignId;
        uint96 expiredAt = _airdropCampaign[_cId].expiredAt;
        if (expiredAt < uint96(block.timestamp)) {
            revert CampaignExpired(expiredAt);
        }
    }

    function _proofsCheck(
        address account,
        uint256 amount,
        uint256 campaignId,
        bytes32[] calldata proofs
    ) internal view {
        bytes32 root = _airdropCampaign[campaignId].root;
        bool valid = proofs.verify(
            root,
            keccak256(abi.encodePacked(account, amount))
        );
        if (!valid) revert InvalidProofs(proofs);
    }
}
