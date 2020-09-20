pragma solidity ^0.5.0;

import './IERC20.sol';
import './SafeMath.sol';
import './token.sol';
import './Pausable.sol';

contract ICO is Pausable{
    using SafeMath for uint;
    IERC20 erctoken;
    
    address payable public admin;
    uint public privateSaleDuration;
    uint public preSaleDuration = 30 days; // 15 days will be skip for private sale
    uint public crowdSaleDuration = 60 days; // 15 + 15 = 30 days will be skip for private and pre sale
    uint public crowdSalePhasesTime;
    uint public tokenPrice; // 1000000000000000 // 0.001
    uint public ethPrice;
    uint256 tokenSaleAmount = 12000000000; // 12.5 billion token for private sale, pre sale and crowd sale
    
    uint public availableTokensForPrivateSale;
    uint public availableTokensForPreSale;
    uint public availableTokensForCrowdSale;
    uint public availableTokensForCrowdSaleFirstWeek;
    uint public availableTokensForCrowdSaleSecondWeek;
    uint public availableTokensForCrowdSaleThreeWeek;
    uint public availableTokensForCrowdSaleFourWeek;
    
    uint public minPurchase;

    constructor(
        uint _tokenPrice
    ) 
    public {
        admin = msg.sender;
        tokenPrice = _tokenPrice;
        minPurchase = 500; // 500 $
        crowdSalePhasesTime = block.timestamp + 30 days;
        
        // Total available token for ico is 12.5 billion
        availableTokensForPrivateSale = tokenSaleAmount.mul(25).div(100);
        availableTokensForPreSale = tokenSaleAmount.mul(20).div(100);
        
        availableTokensForCrowdSale = tokenSaleAmount.mul(25).div(100); // for 4 weeks of crowdsale
        availableTokensForCrowdSaleFirstWeek = tokenSaleAmount.mul(15).div(100); // for 1st week of crowdsale 
        availableTokensForCrowdSaleFirstWeek = tokenSaleAmount.mul(10).div(100); // for 2nd week of crowdsale
        availableTokensForCrowdSaleFirstWeek = tokenSaleAmount.mul(5).div(100); // for 3rd week of crowdsale
        availableTokensForCrowdSaleFirstWeek = tokenSaleAmount.mul(25).div(100); // for 4th week of crowdsale
    }
    
    function setTokenAddressandSendTokenAmount(address tokenAddress) public onlyAdmin{
        erctoken = IERC20(tokenAddress);
        // erctoken.transferFrom(msg.sender, address(this), bal);
        erctoken.transferFrom(msg.sender, address(this), erctoken.balanceOf(msg.sender));
    }
    
    function start()
        external
        onlyAdmin()
        whenNotPaused
        icoNotActive() {
        privateSaleDuration = block.timestamp + 15 days;
    }
    
    function buyPrivateSale()
        external 
        payable
        whenNotPaused
        privateSaleActive() 
    {
        uint256 totalPrice = (msg.value/1e18) * ethPrice;
        
        require(
          totalPrice >= minPurchase, 
          'have to buy between minPurchase and maxPurchase'
        );
        uint tokenAmount = totalPrice.div(tokenPrice);
        require(
          tokenAmount <= availableTokensForPrivateSale, 
          'Not enough tokens left for sale'
        );
        availableTokensForPrivateSale.sub(tokenAmount);
        erctoken.transfer(msg.sender, tokenAmount);
        admin.transfer(msg.value);
    }
    
    function buyPreSale()
        external
        payable
        whenNotPaused
        privateSaleEnded()
        preSaleActive() {
        uint256 totalPrice = (msg.value/1e18) * ethPrice;
            
        require(
          totalPrice >= minPurchase, 
          'have to buy between minPurchase and maxPurchase'
        );
        uint tokenAmount = totalPrice.div(tokenPrice);
        require(
          tokenAmount <= availableTokensForPreSale, 
          'Not enough tokens left for sale'
        );
        availableTokensForPreSale.sub(tokenAmount);
        erctoken.transfer(msg.sender, tokenAmount);
        admin.transfer(msg.value);
    }
    
    function buyCrowdSale()
        external
        payable
        preSaleEnded()
        whenNotPaused
        crowdSaleActive() {
        uint256 totalPrice = (msg.value/1e18) * ethPrice;
        require(
          totalPrice >= minPurchase, 
          'have to buy between minPurchase and maxPurchase'
        );
        uint tokenAmount = totalPrice.div(tokenPrice);
        if (crowdSalePhasesTime <= block.timestamp + 7 days) {
            require(
              tokenAmount <= availableTokensForCrowdSaleFirstWeek, 
              'Not enough tokens left for sale'
            );
            availableTokensForCrowdSaleFirstWeek.sub(tokenAmount);
        } else if (crowdSalePhasesTime <= block.timestamp + 14 days) {
            require(
              tokenAmount <= availableTokensForCrowdSaleSecondWeek, 
              'Not enough tokens left for sale'
            );
            availableTokensForCrowdSaleSecondWeek.sub(tokenAmount);
        } else if (crowdSalePhasesTime <= block.timestamp + 21 days) {
            require(
              tokenAmount <= availableTokensForCrowdSaleThreeWeek, 
              'Not enough tokens left for sale'
            );
            availableTokensForCrowdSaleThreeWeek.sub(tokenAmount);
        } else if (crowdSalePhasesTime <= block.timestamp + 28 days) {
            require(
              tokenAmount <= availableTokensForCrowdSaleFourWeek, 
              'Not enough tokens left for sale'
            );
            availableTokensForCrowdSaleFourWeek.sub(tokenAmount);
        } else {
            return;
        }
        availableTokensForCrowdSale.sub(tokenAmount);
        erctoken.transfer(msg.sender, tokenAmount);
        admin.transfer(msg.value);
    }
    
    function setETHPrice(uint256 price) external onlyAdmin {
        require(price > 0, "Invalid Price");
        ethPrice = price;
    }
    
    modifier privateSaleActive() {
        require(
          privateSaleDuration > 0 && block.timestamp < privateSaleDuration && availableTokensForPrivateSale > 0, 
          'ICO must be active'
        );
        _;
    }
    
    modifier privateSaleEnded() {
        require(
          privateSaleDuration > 0 && (block.timestamp >= privateSaleDuration || availableTokensForPrivateSale == 0), 
          'ICO must have ended'
        );
        _;
    }
    
    modifier preSaleActive() {
        require(
          preSaleDuration > 0 && block.timestamp < preSaleDuration && availableTokensForPreSale > 0, 
          'ICO must be active'
        );
        _;
    }
    
    modifier preSaleEnded() {
        require(
          preSaleDuration > 0 && (block.timestamp >= preSaleDuration || availableTokensForPreSale == 0), 
          'ICO must have ended'
        );
        _;
    }
    
    modifier crowdSaleActive() {
        require(
          crowdSaleDuration > 0 && block.timestamp < crowdSaleDuration && availableTokensForCrowdSale > 0, 
          'ICO must be active'
        );
        _;
    }
    
    modifier crowdSaleEnded() {
        require(
          crowdSaleDuration > 0 && (block.timestamp >= crowdSaleDuration || availableTokensForCrowdSale == 0), 
          'ICO must have ended'
        );
        _;
    }
    
    modifier icoNotActive() {
        require(privateSaleDuration == 0, 'ICO should not be active');
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }
    
    function pauseIco() public onlyAdmin {
        _pause();
    }
    
    
    function unpauseIco() public onlyAdmin {
        _unpause();
    }
}