// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.8.0;

import './SafeMath.sol';
import './SharedWalletAbstract.sol';

contract SharedWallet is SharedWalletAbstract {
    using SafeMath for uint;
 
    receive() external payable {
        emit ContractReceivedEther(msg.sender, msg.value);
        allowances[msg.sender] = allowances[msg.sender].add(msg.value);
        owners[msg.sender] = true;
    }
    
    function withdraw(
        uint _amount
    ) external availableAmount(_amount) {
        emit EtherWithdraw(msg.sender, _amount);
        
        allowances[msg.sender] = allowances[msg.sender].sub(_amount); 
        
        msg.sender.transfer(_amount);
    }
    
    function addAllowance(
        address _to, 
        uint _amount
    ) external returns (bool){
        _addAllowance(_to, _amount);
   
        return true;
    }
    
    function reduceAllowance(address _from, uint _amount) public returns (bool) {
        _reduceAllowance(_from, _amount);
        
        return true;
    }
    
    function _addAllowance(
        address _to, 
        uint _amount
    ) internal onlyOwner() addressZero(_to) availableAmount(_amount) {
        emit AllowanceChanged(
            msg.sender, 
            _to, 
            allowances[_to], 
            allowances[_to].add(_amount)
        );
        
        allowances[msg.sender] = allowances[msg.sender].sub(_amount);
        allowances[_to] = allowances[_to].add(_amount);
    }
    
    function _reduceAllowance(address _from, uint _amount) internal onlyOwner() {
        emit AllowanceChanged(
            msg.sender,
            _from,
            allowances[_from],
            allowances[_from].sub(_amount)
        );
        
        if (_amount >= allowances[_from]) {
            allowances[msg.sender] =  allowances[msg.sender].add(_amount);
            allowances[_from] = 0;
            
            return;
        }
    
        allowances[msg.sender] =  allowances[msg.sender].add(_amount);
        allowances[_from] = allowances[_from].sub(_amount);
    }
    
    function walletBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isOwner() public view returns (bool) {
        return (owners[msg.sender]);
    }
}