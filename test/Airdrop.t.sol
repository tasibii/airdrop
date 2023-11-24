// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.22;

import { console2, Test } from "forge-std/Test.sol";
import { IAirdrop, Airdrop } from "src/Airdrop.sol";
import { MockERC20 } from "test/utils/MockERC20.sol";

contract AirdropTest is Test {
    Airdrop airdrop;
    MockERC20 token;
    MockERC20 token2;
    address bob;
    address alice;
    address owner;

    uint256 campaignId;

    modifier prank(address pranker) {
        vm.startPrank(pranker);
        _;
        vm.stopPrank();
    }

    // Merkle Root:
    // 0xe03ffe2d54e70ff746742b7392a295e1705c88a5042e62a2661af9f7fc4334f3
    // Proof 1:
    // 0x2f5e39dc76777ab50eef56231f95f8c639bfda592c3e1ce2fbb46079923a1db4
    // Proof 2:
    // 0xaf2d2df733dc3bca507d18548dd31a088f02d4bd4bc61fda45fa5dbdd625413c

    function setUp() public {
        bob = vm.addr(1);
        alice = vm.addr(2);
        owner = vm.addr(3);
        airdrop = new Airdrop(owner);
        token = new MockERC20("Test", "TST");
        token.mint(address(airdrop), 1.5 ether);
    }

    function test_setCampaignSuccess() public prank(owner) {
        campaignId = block.timestamp;
        vm.expectEmit(address(airdrop));
        emit IAirdrop.CampaignStarted(block.timestamp);
        airdrop.startCampaign(0xe03ffe2d54e70ff746742b7392a295e1705c88a5042e62a2661af9f7fc4334f3, address(token), 300);
    }

    function test_setCampaignNotOwnerFailed() public prank(bob) {
        campaignId = block.timestamp;
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", bob));
        airdrop.startCampaign(0xe03ffe2d54e70ff746742b7392a295e1705c88a5042e62a2661af9f7fc4334f3, address(token), 300);
    }

    function test_withdrawSuccess() public prank(owner) {
        vm.expectEmit(address(airdrop));
        emit IAirdrop.Withdrawal(owner, address(token), 1.5 ether);
        airdrop.withdraw(owner, address(token), 1.5 ether);
    }

    function test_withdrawNotOwnerFailed() public prank(bob) {
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", bob));
        airdrop.withdraw(bob, address(token), 1.5 ether);
    }

    function test_RedeemSuccess() public {
        test_setCampaignSuccess();
        _bobRedeem();
        _aliceRedeem();
    }

    function test_RedeemExpiredFailed() public {
        test_setCampaignSuccess();
        vm.warp(block.timestamp + 301);
        _expiredRedeem();
    }

    function test_RedeemInvalidProofFailed() public {
        test_setCampaignSuccess();
        _invalidProofRedeem();
    }

    function test_RedeemAlreadyRedeemFailed() public {
        test_setCampaignSuccess();
        _aliceRedeem();
        _alreadyRedeem();
    }

    function _bobRedeem() internal prank(bob) {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = 0x2f5e39dc76777ab50eef56231f95f8c639bfda592c3e1ce2fbb46079923a1db4;
        vm.expectEmit(address(airdrop));
        emit IAirdrop.Redeemed(bob, address(token), 1 ether);
        airdrop.redeem(bob, 1 ether, campaignId, proof);
    }

    function _aliceRedeem() internal prank(alice) {
        bytes32[] memory proof = new bytes32[](1);
        // forgefmt: disable-next-line
        proof[0] = 0xaf2d2df733dc3bca507d18548dd31a088f02d4bd4bc61fda45fa5dbdd625413c;
        vm.expectEmit(address(airdrop));
        emit IAirdrop.Redeemed(alice, address(token), 0.5 ether);
        airdrop.redeem(alice, 0.5 ether, campaignId, proof);
    }

    function _expiredRedeem() internal prank(alice) {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = 0xaf2d2df733dc3bca507d18548dd31a088f02d4bd4bc61fda45fa5dbdd625413c;
        vm.expectRevert(abi.encodeWithSelector(IAirdrop.CampaignExpired.selector, 1_680_221_100));
        airdrop.redeem(alice, 0.5 ether, campaignId, proof);
    }

    function _invalidProofRedeem() internal prank(alice) {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = 0xaf2d2df733dc3bca507d18548dd31a088f02d4bd4bc61fda45fa5dbdd625413d;
        vm.expectRevert(abi.encodeWithSelector(IAirdrop.InvalidProofs.selector, proof));
        airdrop.redeem(alice, 0.5 ether, campaignId, proof);
    }

    function _alreadyRedeem() internal prank(alice) {
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = 0xaf2d2df733dc3bca507d18548dd31a088f02d4bd4bc61fda45fa5dbdd625413c;
        vm.expectRevert(abi.encodeWithSelector(IAirdrop.AlreadyClaimed.selector));
        airdrop.redeem(alice, 0.5 ether, campaignId, proof);
    }
}
