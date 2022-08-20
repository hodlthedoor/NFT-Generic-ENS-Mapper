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
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external {}

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external {
        bytes32 namehash = keccak256(abi.encodePacked(node, label));
        nodeExists[namehash] = true;
    }

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32) {}

    function setResolver(bytes32 node, address resolver) external {}

    function setOwner(bytes32 node, address owner) external {}

    function setTTL(bytes32 node, uint64 ttl) external {}

    function setApprovalForAll(address operator, bool approved) external {}

    function owner(bytes32 node) external view returns (address) {
        return ownerAddress;
    }

    function resolver(bytes32 node) external view returns (address) {}

    function ttl(bytes32 node) external view returns (uint64) {}

    function recordExists(bytes32 node) external view returns (bool) {
        return nodeExists[node];
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool)
    {}
}
