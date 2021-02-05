// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import './SharedWalletAbstract.sol';

contract SharedWallet is SharedWalletAbstract {
    receive() external payable {
        allowances[msg.sender] += msg.value;
        owners[msg.sender] = true;

        emit ContractReceivedEther(msg.sender, msg.value);
    }
    
    function withdraw(
        uint _amount
    )   external 
        availableAmount(_amount) 
    {
        emit EtherWithdraw(msg.sender, _amount);
        
        allowances[msg.sender] -= _amount; 
        
        payable(msg.sender).transfer(_amount);
    }
    
    function addAllowance(
        address _to, 
        uint _amount
    )   external returns (bool){
        _addAllowance(_to, _amount);
   
        return true;
    }
    
    function reduceAllowance(
        address _from, 
        uint _amount
    )   public returns (bool) {
        _reduceAllowance(_from, _amount);
        
        return true;
    }
    
    function _addAllowance(
        address _to, 
        uint _amount
    )   internal 
        onlyOwner() 
        addressZero(_to) 
        availableAmount(_amount) 
    {
        emit AllowanceChanged(
            msg.sender, 
            _to, 
            allowances[_to], 
            allowances[_to] + _amount
        );
        
        allowances[msg.sender] -= _amount;
        allowances[_to] += _amount;
    }
    
    function _reduceAllowance(
        address _from, 
        uint _amount
    )   internal 
        onlyOwner() 
    {
        emit AllowanceChanged(
            msg.sender,
            _from,
            allowances[_from],
            allowances[_from] - _amount
        );
        
        if (_amount >= allowances[_from]) {
            allowances[msg.sender] += _amount;
            allowances[_from] = 0;
            
            return;
        }
    
        allowances[msg.sender] += _amount;
        allowances[_from] -= _amount;
    }
    
    function walletBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isOwner() public view returns (bool) {
        return (owners[msg.sender]);
    }
}