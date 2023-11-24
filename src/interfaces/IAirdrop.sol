// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

interface IAirdrop {
    struct AirdropCampaign {
        bytes32 root;
        address token;
        uint96 expiredAt;
    }

    error AlreadyClaimed();
    error InvalidProofs(bytes32[] proofs);
    error CampaignExpired(uint96 expiredAt);

    event Withdrawal(address indexed recipient, address indexed token, uint256 amount);
    event Redeemed(address indexed account, address indexed token, uint256 amount);
    event CampaignStarted(uint256 campaignId);
}
