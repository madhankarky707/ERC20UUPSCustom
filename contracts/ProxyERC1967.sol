//SPDX-License-Identifier:UNLICENSED

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

pragma solidity 0.8.28;

contract ProxyERC1967 is ERC1967Proxy {
    constructor(address implementation, bytes memory _data) ERC1967Proxy(implementation, _data) {}
}