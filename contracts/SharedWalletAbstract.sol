// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import './Storage.sol';

abstract contract SharedWalletAbstract is Storage {
    event AllowanceChanged(
        address indexed _from, 
        address indexed _to, 
        uint _oldAmount,
        uint _newAmount
    );
    event EtherWithdraw(address indexed _to, uint _amount);
    event ContractReceivedEther(address indexed _addr, uint _amount);
    
    modifier availableAmount(uint _amount) {
        require(allowances[msg.sender] >= _amount, 'Not enough Ether!');
        _;
    }
    
    modifier onlyOwner() {
        require(owners[msg.sender] == true, 'Only owner!');   
        _;
    }

    modifier addressZero(address _addr) {
        require(_addr != address(0x00), 'recipient cannot be zero!');
        _;
    }   
}
