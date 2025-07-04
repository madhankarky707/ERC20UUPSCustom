# MyToken (UUPS Upgradeable ERC20 with Custom Storage Slots)

This project implements an upgradeable ERC20 token using a UUPS pattern, deployed via an `ERC1967Proxy`. It uses custom storage slots (based on `StorageSlot` library) for storing fee configuration data and supports pausable and upgradeable behavior.

---

## 🧱 Features

- ✅ ERC20-compliant token
- ✅ UUPS (Universal Upgradeable Proxy Standard)
- ✅ `ERC1967Proxy` for upgradeable deployment
- ✅ Custom storage layout via `StorageSlot`
- ✅ Fee deduction on transfers
- ✅ Owner-controlled fee recipient and value
- ✅ Pausable/unpausable transfers
- ✅ Upgradable via `_authorizeUpgrade`

---

## 🗃️ Contract Structure

### 📄 `MyToken.sol`
Located in `contracts/`, this contract:
- Extends `ERC20Upgradeable`, `OwnableUpgradeable`, `PausableUpgradeable`, `UUPSUpgradeable`
- Uses `StorageSlot` to store:
  - `_FEE_RECIPIENT`: Address receiving transfer fees
  - `_FEE_VALUE`: Fee percentage
  - `_FEE_STATUS_SLOT`: Tracks when fee is being processed to prevent recursion

### 📄 `ProxyERC1967.sol`
A minimal constructor-based proxy that follows the [EIP-1967](https://eips.ethereum.org/EIPS/eip-1967) standard.

```solidity
contract ProxyERC1967 is ERC1967Proxy {
    constructor(address implementation, bytes memory _data) 
        ERC1967Proxy(implementation, _data) {}
}
```

---

## 🚀 Deployment (via Hardhat Ignition)

### Prerequisites
```bash
npm install
```

### Deploy with Ignition

Make sure you're using Hardhat with `@nomicfoundation/hardhat-ignition`.

```bash
npx hardhat ignition deploy ignition/modules/MyTokenModule.js
```

You can configure the module at `ignition/modules/MyTokenModule.js`:

```js
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const Web3 = require("web3");

const web3 = new Web3();

module.exports = buildModule("MyTokenModule", (m) => {
  const owner =  web3.eth.accounts.create();
  const feeRecipient =  web3.eth.accounts.create();
  const name = "MyToken";
  const symbol = "MTK";
  const feeValue = 5; // 5%

  // Deploy logic/implementation contract
  const tokenImpl = m.contract("MyToken");

  // Prepare initializer data for proxy
  const initData = web3.eth.abi.encodeFunctionCall(
    {
      name: "initialize",
      type: "function",
      inputs: [
        { type: "string", name: "name_" },
        { type: "string", name: "symbol_" },
        { type: "address", name: "owner_" },
        { type: "address", name: "feeRecipient_" },
        { type: "uint256", name: "feeValue_" },
      ],
    },
    [name, symbol, owner.address, feeRecipient.address, feeValue]
  );

  // Deploy ProxyERC1967 with implementation address and initializer calldata
  const proxy = m.contract("ProxyERC1967", [tokenImpl, initData]);

  return { tokenImpl, proxy };
});
```

---

## 🧪 Testing

Tests are written in Hardhat. Run tests via:

```bash
npx hardhat test
```

### Includes tests for:
- Initialization via proxy
- Fee deduction logic
- Pause and unpause behavior
- Transfer failure when paused
- Upgradeability (via `_authorizeUpgrade`)

---

## 🛠️ Usage

### Transfer with Fee (5% by default)
```solidity
token.transfer(recipient, 1000); // 5% fee deducted, 950 received
```

### Pause / Unpause
```solidity
await token.pause({ from: owner });
await token.unpause({ from: owner });
```

### Change Fee
```solidity
await token.changeFeeValue(10, { from: owner }); // Sets fee to 10%
```

---

## 📦 Custom Storage

Instead of using regular Solidity state variables, storage is accessed via hashed `bytes32` keys:

```solidity
_FEE_RECIPIENT.getAddressSlot().value
_FEE_VALUE.getUint256Slot().value
```

This design is upgrade-safe and avoids storage layout collisions.

---

## 🔐 Upgradeability

Upgrades are authorized by the contract owner. Use `upgradeTo()` from the proxy address:

```solidity
proxy.upgradeTo(newImplementation);
```

The `MyToken` contract enforces this with:

```solidity
function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
```

---

## 📄 License

MIT