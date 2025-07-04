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
