pragma solidity ^0.6.0;

/**
* Ropsten Token Deployed at: https://ropsten.etherscan.io/token/0xf28e912fa14b678c6b516f580e681e0535549d53
* Token Contract Address: 0xf28e912fa14b678c6b516f580e681e0535549d53
*/

import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on uint256

contract TimeBoundPToken is IERC20 {
    //owner, sender both are same name for tokenOwner
    
    //Extending uint256 with SafeMath Library.
    using SafeMath for uint256;
    
    address public contractOwner;
    
    //mapping to keep balances
    mapping (address => uint256) private _balances;
    
    //mapping to keep allowances
    //      tokenOwner           spender    amount
    mapping (address => mapping (address => uint256)) private _allowances;
    
    //the amount of tokens in existence
    uint256 private _totalSupply;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    
    //releaseTime must be in future and unix time format
    uint256 public releaseTime;
    
    //events
    event releaseTimeSet(
        bool success,
        uint256 time
    );
    
    
    /**
     * Function modifier to restrict Owner's transactions.
     */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "TB-P-Token: Only contract owner allowed");
        _;
    }
    
    /**
     * Function modifier to restrict Owner's transactions.
     */
    modifier TimeLock() {
        require(block.timestamp >= releaseTime, "TB-P-Token: Token is locked, wait for releaseTime");
        _;
    }
    
    
    constructor() public {
        name = "TimeBound Practice Token";
        symbol = "TB-P-Token";
        decimals = 3;
        contractOwner = msg.sender;
        
        //1 million tokens generated
        _totalSupply = 1000000 * (10 ** uint256(decimals));
        
        //transfer totalsupply to contractOwner
        _balances[contractOwner] = _totalSupply;
        
        //emit Transfer event
        emit Transfer(address(this), contractOwner, _totalSupply);
    }
    
   
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view override returns(uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns(uint256) {
        return _balances[account]; 
    }
    
    
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     * 
     * - `sender` and `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override TimeLock() returns(bool) {
        address sender = msg.sender;
        
        require(sender != address(0), "TB-P-Token: transfer from the zero address");
        require(recipient != address(0), "TB-P-Token: transfer to the zero address");
        require(_balances[sender] > amount);
        
        //decrease the balance of token sender account
        _balances[sender] = _balances[sender].sub(amount); 
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) external view override returns(uint256) {
        return _allowances[tokenOwner][spender];
    } 
    
    
    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns(bool) {
        address tokenOwner = msg.sender;
        
        require(tokenOwner != address(0), "TB-P-Token: approve from the zero address");
        require(spender != address(0), "TB-P-Token: approve to the zero address");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }
    
    
    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     * here sender is the tokenOwner
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller(spender) must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override TimeLock() returns(bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[sender][spender];
        
        require(sender != address(0), "TB-P-Token: transfer from the zero address");
        require(recipient != address(0), "TB-P-Token: transfer to the zero address");
        require(_balances[sender] > amount, "TB-P-Token: transfer amount exceeds balance");
        require(_allowance > amount, "TB-P-Token: transfer amount exceeds allowance");
        
        //deducting the allowance
        _allowance = _allowance.sub(amount);
        
        // ---Transfer execution---
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient].add(amount);
        
        //owner decrease balance
        _balances[sender] =_balances[sender].sub(amount); 
        
        emit Transfer(sender, recipient, amount);
        // ---end execution--
        
        //decrease the approval amount
        _allowances[sender][spender] = _allowance;
        
        emit Approval(sender, spender, amount);
        
        return true;
    }
    
    /**
     * Function to set the release time for transfer and transferFrom functions
     * - www.unixtimestamp.com (for converting time into unix time)
     * Requirements:
     * - releaseTime must be unix time
     * - _releaseTime must be valid and in the future
     */
    function setReleaseTime(uint _releaseTime) public onlyOwner() returns(bool) {
        require(_releaseTime > block.timestamp, "TB-P-Token: releaseTime must be valid and in the future");
        //                     ^transaction time 
        releaseTime = _releaseTime;
        
        emit releaseTimeSet(true, _releaseTime);
        
        return true;
    }
    
}