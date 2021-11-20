pragma solidity 0.7.0;

import "./IBank.sol";
import "./IPriceOracle.sol";

contract BlankBank is IBank {
    
    mapping(address => Account) public accountMap;
    
    constructor() {
        
    }
    
    /*
     * The purpose of this function is to allow end-users to deposit a given 
     * token amount into their bank account.
     * @param token - the address of the token to deposit. If this address is
     *                set to 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE then 
     *                the token to deposit is ETH.
     * @param amount - the amount of the given token to deposit.
     * @return - true if the deposit was successful, otherwise revert.
     */
    
    address priceAdress = 0xc3F639B8a6831ff50aD8113B438E2Ef873845552;
    
    event Received(address, uint);
    
    function deposit(address token, uint256 amount) payable external override returns (bool) {
        
        if (amount > 0) {
            
            uint256 _price;
            if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                _price = amount;
            } else {
                IPriceOracle _oracle = IPriceOracle(priceAdress);
                _price = amount * _oracle.getVirtualPrice(token);
            }
            
            emit Received(msg.sender, amount);
            accountMap[msg.sender].deposit = accountMap[msg.sender].deposit + _price;
            
            
            emit Deposit(msg.sender, token, amount);
            return true;
        } else {
            return false;
        }
        
    }
    
    /*
     * The purpose of this function is to allow end-users to withdraw a given 
     * token amount from their bank account. Upon withdrawal, the user must
     * automatically receive a 3% interest rate per 100 blocks on their deposit.
     * @param token - the address of the token to withdraw. If this address is
     *                set to 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE then 
     *                the token to withdraw is ETH.
     * @param amount - the amount of the given token to withdraw. If this param
     *                 is set to 0, then the maximum amount available in the 
     *                 caller's account should be withdrawn.
     * @return - the amount that was withdrawn plus interest upon success, 
     *           otherwise revert.
     */
    function withdraw(address token, uint256 amount) external override returns(uint256) {

        if (amount > 0) {
            uint256 _currentBlock = block.number;
            
            uint256 _blockInterval =  _currentBlock - accountMap[msg.sender].lastInterestBlock;
            accountMap[msg.sender].lastInterestBlock = _currentBlock;
            
            uint256 _interestRate = ((_blockInterval / 100) * 3) / 100;
            
            uint256 _interest = accountMap[msg.sender].deposit * _interestRate;
            accountMap[msg.sender].interest = _interest;
            
            uint256 _price = amount + _interest;
            if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                
            } else {
                IPriceOracle _oracle = IPriceOracle(priceAdress);
                _price = _price * _oracle.getVirtualPrice(token);
            }
            
            if (accountMap[msg.sender].deposit >= _price) {
                
                
                accountMap[msg.sender].deposit = accountMap[msg.sender].deposit - _price;
                msg.sender.transfer(amount);
                
                emit Withdraw(msg.sender, token, amount);
            
                return _price;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    
    /*
     * The purpose of this function is to allow users to borrow funds by using their 
     * deposited funds as collateral. The minimum ratio of deposited funds over 
     * borrowed funds must not be less than 150%.
     * @param token - the address of the token to borrow. This address must be
     *                set to 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, otherwise  
     *                the transaction must revert.
     * @param amount - the amount to borrow. If this amount is set to zero (0),
     *                 then the amount borrowed should be the maximum allowed, 
     *                 while respecting the collateral ratio of 150%.
     * @return - the current collateral ratio.
     */
    function borrow(address token, uint256 amount) external override returns (uint256) {
        
    }
     
    /*
     * The purpose of this function is to allow users to repay their loans.
     * Loans can be repaid partially or entirely. When replaying a loan, an
     * interest payment is also required. The interest on a loan is equal to
     * 5% of the amount lent per 100 blocks. If the loan is repaid earlier,
     * or later then the interest should be proportional to the number of 
     * blocks that the amount was borrowed for.
     * @param token - the address of the token to repay. If this address is
     *                set to 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE then 
     *                the token is ETH.
     * @param amount - the amount to repay including the interest.
     * @return - the amount still left to pay for this loan, excluding interest.
     */
    function repay(address token, uint256 amount) payable external override returns (uint256) {
        
    }
     
    /*
     * The purpose of this function is to allow so called keepers to collect bad
     * debt, that is in case the collateral ratio goes below 150% for any loan. 
     * @param token - the address of the token used as collateral for the loan. 
     * @param account - the account that took out the loan that is now undercollateralized.
     * @return - true if the liquidation was successful, otherwise revert.
     */
    function liquidate(address token, address account) payable external override returns (bool) {
        
    }
 
    /*
     * The purpose of this function is to return the collateral ratio for any account.
     * The collateral ratio is computed as the value deposited divided by the value
     * borrowed. However, if no value is borrowed then the function should return 
     * uint256 MAX_INT = type(uint256).max
     * @param token - the address of the deposited token used a collateral for the loan. 
     * @param account - the account that took out the loan.
     * @return - the value of the collateral ratio with 2 percentage decimals, e.g. 1% = 100.
     *           If the account has no deposits for the given token then return zero (0).
     *           If the account has deposited token, but has not borrowed anything then 
     *           return MAX_INT.
     */
    function getCollateralRatio(address token, address account) view external override returns (uint256) {
        
    }

    /*
     * The purpose of this function is to return the balance that the caller 
     * has in their own account for the given token (including interest).
     * @param token - the address of the token for which the balance is computed.
     * @return - the value of the caller's balance with interest, excluding debts.
     */
    function getBalance(address token) view external override returns (uint256) {
        
        uint256 _blockInterval = block.number - accountMap[msg.sender].lastInterestBlock;
        
        uint256 _interestRate = ((_blockInterval / 100) * 3) / 100;
        
        uint256 _interest = accountMap[msg.sender].deposit * _interestRate;
        
        uint256 _price = accountMap[msg.sender].deposit + _interest;
        
        if (token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {

        } else {
            IPriceOracle _oracle = IPriceOracle(priceAdress);
            _price = _price * _oracle.getVirtualPrice(token);
        }
        
        return _price;
    }
    
}