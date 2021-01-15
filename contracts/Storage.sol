// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

abstract contract Storage {
    mapping(address => uint) public allowances;
    mapping(address => bool) internal owners;
}
