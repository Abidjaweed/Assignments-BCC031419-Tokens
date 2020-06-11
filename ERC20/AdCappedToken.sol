pragma solidity ^0.6.0;

/**
* Ropsten Token Deployed at: https://ropsten.etherscan.io/token/0x661befdd9e281d5cfb2c5169ff29fa8f9f764cb4
* Token Contract Address: 0x661befdd9e281d5cfb2c5169ff29fa8f9f764cb4
*/

import "./IERC20.sol";
import "./SafeMath.sol";
// SafeMath library will allow to use arthemtic operation on uint256

contract AdCappedToken is IERC20 {
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
    
    //value of capped tokens
    uint256 private _cap;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    
    //events
    event TokensMinted(
        bool success,
        uint256 amount
    );
    
    event capSet(
        bool success,
        uint256 amount
    );
    
    
    constructor() public {
        name = "Abid Capped Practice Token 1";
        symbol = "AdcT1";
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
     * Function modifier to restrict Owner's transactions.
     */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "AdcT1: Only contract owner allowed");
        _;
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
    function transfer(address recipient, uint256 amount) external override returns(bool) {
        address sender = msg.sender;
        
        require(sender != address(0), "AdcT1: transfer from the zero address");
        require(recipient != address(0), "AdcT1: transfer to the zero address");
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
        
        require(tokenOwner != address(0), "AdcT1: approve from the zero address");
        require(spender != address(0), "AdcT1: approve to the zero address");
        
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
    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[sender][spender];
        
        require(sender != address(0), "AdcT1: transfer from the zero address");
        require(recipient != address(0), "AdcT1: transfer to the zero address");
        require(_balances[sender] > amount, "AdcT1: transfer amount exceeds balance");
        require(_allowance > amount, "AdcT1: transfer amount exceeds allowance");
        
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
     * This function will allow owner to Mint more tokens and check that total supply doesnot exceeds the capped limit
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - amount should be valid incremental value.
     */
    function Mint(uint256 amount) public onlyOwner() returns(bool) {
        require(amount > 0, "AdcT1: Amount should be valid");
        require((_totalSupply.add(amount) <= _cap), "AdcT1: Total Supply has exceeded the capped limit");
        
        _balances[contractOwner] = _balances[contractOwner].add(amount);
        _totalSupply = _totalSupply.add(amount);
        
        //events fired
        emit TokensMinted(true, amount);
        emit Transfer(address(this), contractOwner, amount);
        
        return true;
    } 
    
    /**
     * Sets the cap on the token's total supply.
     * 
     * Requirements:
     * 
     * -`capValue` must be valid and in mili AdcT1 value
     */
    function setCap(uint256 _capValue) public onlyOwner() returns (bool) {
        require(_capValue > 0, "AdcT1: Amount should be valid");
        
        _cap = _capValue;
        
        emit capSet(true, _capValue);
        return true;
    }
    
    /**
     * Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }
}