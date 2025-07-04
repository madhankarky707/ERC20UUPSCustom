//SPDX-License-Identifier:MIT

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC1822.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./ReentrancyGuardUpgradeable.sol";
import "./StorageSlot.sol";
import "./OwnableUpgradeable.sol";
import "./PausableUpgradeable.sol";
import "./ERC20Upgradeable.sol";

pragma solidity 0.8.28;

contract MyToken is 
    ERC20Upgradeable,
    PausableUpgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable, 
    UUPSUpgradeable 
{
    using StorageSlot for bytes32;

    bytes32 internal constant _FEE_RECIPIENT = keccak256("mytoken.v1.fee.recipient");
    bytes32 internal constant _FEE_STATUS_SLOT = keccak256("mytoken.v1.fee.enabled");
    bytes32 internal constant _FEE_VALUE = keccak256("mytoken.v1.fee.value");

    uint256 constant DIVISOR = 100;

    event FeeRecipientChanged(address indexed newRecipient);
    event FeeValueChanged(uint256 newFee);

    modifier onlyWithFeeEnabled() {
        _FEE_STATUS_SLOT.getBooleanSlot().value = true;
        _;
        _FEE_STATUS_SLOT.getBooleanSlot().value = false;
    }

    function initialize(string memory name_, string memory symbol_, address owner_, address feeRecipient_, uint256 feeValue_) public initializer {
        require(feeRecipient_ != address(0), "MyToken: zero address");
        require(feeValue_ < DIVISOR, "MyToken: fee exceed");

        __Ownable_init(owner_);
        __Pausable_init();
        __ERC20_init(name_, symbol_);

        _FEE_RECIPIENT.getAddressSlot().value = feeRecipient_;
        _FEE_VALUE.getUint256Slot().value = feeValue_;
        _FEE_STATUS_SLOT.getBooleanSlot().value = false;

        _mint(_msgSender(), 10_000_000 * 10 ** decimals());
    }

    function changeRecipient(address recipient) public onlyOwner {
        require(recipient != address(0), "MyToken: zero address");
        require(recipient != address(this), "MyToken: invalid recipient");
        _FEE_RECIPIENT.getAddressSlot().value = recipient;
        emit FeeRecipientChanged(recipient);
    }

    function changeFeeValue(uint256 feeValue_) public onlyOwner {
        require(feeValue_ < DIVISOR, "MyToken: fee exceed");
        _FEE_VALUE.getUint256Slot().value = feeValue_;
        emit FeeValueChanged(feeValue_);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);
        StorageSlot.AddressMapUint256Slot storage storedBalance = _balance.getAddressMapUint256Slot();
        uint256 fromBalance = storedBalance.value[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (_FEE_STATUS_SLOT.getBooleanSlot().value == false && from != owner() && getFeeValue() != 0) {
            amount = _processFees(from, amount);
        }

        unchecked {
            storedBalance.value[from] = fromBalance - amount;
        }
        storedBalance.value[to] += (amount);
        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _processFees(address from, uint256 amount) private onlyWithFeeEnabled nonReentrant returns (uint256) {
        uint256 fee = amount * getFeeValue() / DIVISOR;
        _transfer(
            from,
            getFeeRecipient(),
            fee
        );
        return amount - fee;
    }

    function getFeeRecipient() public view returns (address feeRecipient) {
        return _FEE_RECIPIENT.getAddressSlot().value;
    }

    function getFeeValue() public view returns (uint256 feeValue) {
        return _FEE_VALUE.getUint256Slot().value;
    }
}