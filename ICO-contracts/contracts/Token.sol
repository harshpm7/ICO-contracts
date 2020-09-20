pragma solidity ^0.5.0;

import './ERC20.sol';
import './SafeMath.sol';

contract Token is ERC20 {
    using SafeMath for uint;
    address public admin;

    address payable reserveWallet = 0xE33f4C2306eFE9BF66a64A3c42408d2Fe1Cb890f;
    address public interestPayoutWallet = 0xE33f4C2306eFE9BF66a64A3c42408d2Fe1Cb890f;
    address public teamMemberHRWallet = 0xE33f4C2306eFE9BF66a64A3c42408d2Fe1Cb890f;
    address public companyGeneratFundWallet = 0xE33f4C2306eFE9BF66a64A3c42408d2Fe1Cb890f;
    address public bountiesAndAirdropWallet = 0xE33f4C2306eFE9BF66a64A3c42408d2Fe1Cb890f;

    constructor(
        string memory name, 
        string memory symbol,
        uint _totalSupply
    ) ERC20(name, symbol) public {
        admin = msg.sender;
        _totalSupply = _totalSupply * 1e18;
        _mint(reserveWallet, _totalSupply.mul(30).div(100));
        _mint(interestPayoutWallet, _totalSupply.mul(20).div(100));
        _mint(teamMemberHRWallet, _totalSupply.mul(10).div(100));
        _mint(companyGeneratFundWallet, _totalSupply.mul(13).div(100));
        _mint(bountiesAndAirdropWallet, _totalSupply.mul(2).div(100));
        _mint(admin, _totalSupply.mul(25).div(100));
    }
    
    function transferAdmin(address newAdmin) external {
        require(msg.sender == admin);
        admin = newAdmin;
    }
}