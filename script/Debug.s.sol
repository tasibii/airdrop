// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {BaseScript, ErrorHandler} from "boundry-deployment-kit/Base.s.sol";

contract Debug is BaseScript {
    using ErrorHandler for *;

    function debug(
        uint256 forkBlock,
        address from,
        address to,
        uint256 value,
        bytes memory callData
    ) external {
        if (forkBlock != 0) {
            vm.rollFork(forkBlock);
        }
        vm.prank(from);
        (bool success, bytes memory returnOrRevertData) = to.call{value: value}(
            callData
        );
        success.handleRevert(returnOrRevertData);
    }
}
