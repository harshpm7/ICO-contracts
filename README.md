# ICO-contracts


There are several contracts those are included for a proper functioning of the ICO process. I have majorly used the open-zeppelin library and the contracts provided by them like safemath, pausable, ERC20, IERC20 etc. The constrains and functionalities mentioned in the use case are better described in ICO.sol and Token.sol .
The Token.sol will be deployed and generate a token of the specified value and a particular name and symbol and will distribute the tokens to different wallets in different proportion as mentioned in the problem statement.
The ICO.sol will be deployed so that it can distribute the Initial Coin Offerings in different proportions and phases in different sales as mentioned in the tokenomics part of the problem statement. The various conditions if the pre sale, private sale or the crowd sale is on will be checked simultaneously during the function call. Also the pausable.sol contract is imported or inherited so it will make the modifiers available for our function namely 'whenNotPaused' and 'whenPaused' , which can be applied to the functions of your contract.
