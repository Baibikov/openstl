// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ERC8551 {

    // allowances allow of user check is send address
    mapping (address => mapping (address => uint256)) private _allowances;

    // balance of the users
    mapping (address => uint256) private _balances;

    string private _name;

    string private _symbol;

    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_) {
        // check the required parameters of the token meta information
        require(bytes(name_).length > 0, "ERC8551: token name is required");
        require(bytes(symbol_).length > 0, "ERC8551: token symbol is required");
        
        _name = name_;
        _symbol = symbol_;

        // base tockens for owner
        _mint(msg.sender, 100 * 10**uint(decimals()));
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /*
        ERC20 implemented methdos
    */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns(uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // allowed withdrawal amount
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC8551: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC8551: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    /*
        private implementation methods
    */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        _validateSenderRecipient(sender, recipient);

        uint256 senderBalance = _balances[sender];

        // if sender balance < amount 
        // get ERC8551 error.
        require(senderBalance >= amount, "ERC8551: transfer amount exceeds balance");

        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != _zeroAccount(), "ERC8551: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
    }

    function _validateSenderRecipient(address sender, address recipient) private pure {
        require(sender != _zeroAccount(), "ERC8551: transfer from the zero address");
        require(recipient != _zeroAccount(), "ERC8551: transfer to the zero address");
    }

    function _zeroAccount() private pure returns(address) {
        return address(0);
    }   

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _validateSenderRecipient(owner, spender);
        _allowances[owner][spender] = amount;
    }
}