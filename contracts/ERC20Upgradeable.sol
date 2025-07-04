pragma solidity 0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./StorageSlot.sol";

contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20, IERC20Metadata {
    using StorageSlot for bytes32;

    bytes32 internal constant _name = keccak256("mytoken.v1.erc20.name");
    bytes32 internal constant _symbol = keccak256("mytoken.v1.erc20.symbol");
    bytes32 internal constant _balance = keccak256("mytoken.v1.erc20.balance");
    bytes32 internal constant _totalSupply = keccak256("mytoken.v1.erc20.totalSupply");
    bytes32 internal constant _allowance = keccak256("mytoken.v1.erc20.allowance");

     /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * Both values are immutable: they can only be set once during construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name.getStringSlot().value = name_;
        _symbol.getStringSlot().value = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name.getStringSlot().value;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol.getStringSlot().value;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply.getUint256Slot().value;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balance.getAddressMapUint256Slot().value[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowance.getAddressDoubleMapUint256Slot().value[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowance.getAddressDoubleMapUint256Slot().value[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowance.getAddressDoubleMapUint256Slot().value[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        StorageSlot.AddressMapUint256Slot storage storedBalance = _balance.getAddressMapUint256Slot();
        uint256 fromBalance = storedBalance.value[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            storedBalance.value[from] = fromBalance - amount;
        }
        storedBalance.value[to] += amount;
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply.getUint256Slot().value += amount;
        _balance.getAddressMapUint256Slot().value[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        StorageSlot.AddressMapUint256Slot storage storedBalance = _balance.getAddressMapUint256Slot();
        uint256 accountBalance = storedBalance.value[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            storedBalance.value[account] = accountBalance - amount;
        }
        _totalSupply.getUint256Slot().value -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowance.getAddressDoubleMapUint256Slot().value[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
