const { expect } = require("chai");
const Web3 = require("web3");
const web3 = new Web3();

const MyTokenArtifact = artifacts.require("MyToken");
const ProxyERC1967 = artifacts.require("ProxyERC1967");

contract("MyToken via ProxyERC1967", accounts => {
  const [deployer, user1, feeRecipient, newRecipient] = accounts;

  const NAME = "My Token";
  const SYMBOL = "MTK";
  const FEE = 5; // 5%

  let tokenImpl, proxy, token;

  beforeEach(async () => {
    tokenImpl = await MyTokenArtifact.new();

    // Encode the initialize call
    const initData = web3.eth.abi.encodeFunctionCall({
      name: "initialize",
      type: "function",
      inputs: [
        { type: "string", name: "name_" },
        { type: "string", name: "symbol_" },
        { type: "address", name: "owner_" },
        { type: "address", name: "feeRecipient_" },
        { type: "uint256", name: "feeValue_" }
      ]
    }, [NAME, SYMBOL, deployer, feeRecipient, FEE]);

    proxy = await ProxyERC1967.new(tokenImpl.address, initData);

    // Interact with proxy as if it's MyToken
    token = await MyTokenArtifact.at(proxy.address);
  });

  it("should initialize correctly", async () => {
    expect(await token.name()).to.equal(NAME);
    expect(await token.symbol()).to.equal(SYMBOL);
    expect(await token.getFeeRecipient()).to.equal(feeRecipient);
    expect((await token.getFeeValue()).toString()).to.equal(FEE.toString());
  });

  it("should transfer with fee correctly", async () => {
    const amount = web3.utils.toWei("1000");

    // Send some tokens to user1
    await token.transfer(user1, amount, { from: deployer });

    const feeBefore = await token.balanceOf(feeRecipient);
    const user1Before = await token.balanceOf(user1);

    const sendAmount = web3.utils.toWei("100");
    await token.transfer(deployer, sendAmount, { from: user1 });

    const feeAfter = await token.balanceOf(feeRecipient);
    const user1After = await token.balanceOf(user1);
    const feeExpected = (sendAmount * FEE / 100).toString();

    expect((feeAfter - feeBefore).toString()).to.equal(feeExpected);
    expect((user1Before - user1After).toString()).to.equal((sendAmount - feeExpected).toString());
  });

  it("should allow owner to change fee recipient", async () => {
    await token.changeRecipient(newRecipient, { from: deployer });
    expect(await token.getFeeRecipient()).to.equal(newRecipient);
  });

  it("should allow owner to change fee value", async () => {
    await token.changeFeeValue(2, { from: deployer });
    expect((await token.getFeeValue()).toString()).to.equal("2");
  });

  it("should pause transfers when paused", async () => {
    await token.pause({ from: deployer });
    try {
      await token.transfer(user1, 100, { from: deployer });
      assert.fail("Expected transfer to fail when paused");
    } catch (error) {
      assert(error.message.includes("Pausable: paused"), "Expected revert with 'Pausable: paused'");
    }
  });
});
