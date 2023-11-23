// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.22;

import {Sample} from "src/Sample.sol";
import {Test} from "forge-std/Test.sol";

contract SampleTest is Test {
    Sample public sample;

    function setUp() public {
        sample = new Sample();
    }

    function testGreeting() public {
        assertEq("Hello world!", sample.greeting());
    }
}
