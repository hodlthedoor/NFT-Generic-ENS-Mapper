// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import "forge-std/Test.sol";
import "ens-contracts/registry/ENS.sol";

contract MockEns is ENS, Test {
    address private ownerAddress;

    mapping(bytes32 => bool) private nodeExists;

    constructor(address _owner) {
        ownerAddress = _owner;
    }

    function setRecord(
        bytes32,
        address,
        address,
        uint64
    ) external {}

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address,
        address,
        uint64
    ) external {
        bytes32 namehash = keccak256(abi.encodePacked(node, label));
        nodeExists[namehash] = true;
    }

    function setSubnodeOwner(
        bytes32,
        bytes32,
        address
    ) external returns (bytes32) {}

    function setResolver(bytes32, address) external {}

    function setOwner(bytes32, address) external {}

    function setTTL(bytes32, uint64) external {}

    function setApprovalForAll(address, bool) external {}

    function owner(bytes32) external view returns (address) {
        return ownerAddress;
    }

    function resolver(bytes32) external view returns (address) {}

    function ttl(bytes32) external view returns (uint64) {}

    function recordExists(bytes32 node) external view returns (bool) {
        return nodeExists[node];
    }

    function isApprovedForAll(address, address) external view returns (bool) {}
}
