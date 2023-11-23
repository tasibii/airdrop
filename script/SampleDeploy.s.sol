// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "boundry-deployment-kit/BaseDeploy.s.sol";
import {Sample, SampleUUPS, SampleTransparent} from "src/Sample.sol";

contract SampleDeploy is BaseDeploy {
    function _defaultAdmin() internal pure override returns (address _admin) {
        _admin = 0x58f5663cCb305366F584b5f4dF523728D5479396;
    }

    function deploySample()
        external
        broadcast
        returns (address payable deployed)
    {
        deployed = deployRaw("Sample.sol:Sample", abi.encode());
    }

    function deploySampleUUPS()
        external
        broadcast
        returns (address payable proxy)
    {
        switchKind(Kind.Uups);
        proxy = deployProxyRaw(
            "Sample.sol:SampleUUPS",
            abi.encodeCall(SampleUUPS.initialize, ())
        );
    }

    function deploySampleTransparent()
        external
        broadcast
        returns (address payable proxy)
    {
        switchKind(Kind.Transparent);
        proxy = deployProxyRaw(
            "Sample.sol:SampleTransparent",
            abi.encodeCall(SampleTransparent.initialize, ())
        );
    }

    function upgradeContract(address payable proxy) external broadcast {
        address logic = deployLogic("Sample.sol:SampleUUPS");
        switchKind(Kind.Uups);
        upgradeTo(proxy, logic);
    }
}
