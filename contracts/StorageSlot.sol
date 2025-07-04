pragma solidity 0.8.28;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct StringSlot {
        string value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    struct AddressMapUint256Slot {
        mapping(address => uint256) value;
    }

    struct AddressDoubleMapUint256Slot {
        mapping(address => mapping(address => uint256)) value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `StringSlot` with member `value` located at `slot`.
     */
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `AddressMapUint256Slot` with member `value` located at `slot`.
     */
    function getAddressMapUint256Slot(bytes32 slot) internal pure returns (AddressMapUint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `AddressDoubleMapUint256Slot` with member `value` located at `slot`.
     */
    function getAddressDoubleMapUint256Slot(bytes32 slot) internal pure returns (AddressDoubleMapUint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}