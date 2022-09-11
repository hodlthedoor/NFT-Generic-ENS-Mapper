// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "ens-contracts/registry/ENS.sol";
import "ens-contracts/ethregistrar/IBaseRegistrar.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import "ens-contracts/wrapper/IMetadataService.sol";
import "ens-contracts/wrapper/INameWrapper.sol";

contract MockNameWrapper {
    mapping(uint256 => mapping(address => bool)) public IdToApprovedAddressMap;

    function updateApprovedAddress(
        uint256 _id,
        address _addr,
        bool _approved
    ) public {
        IdToApprovedAddressMap[_id][_addr] = _approved;
    }

    function ens() external view returns (ENS) {}

    function registrar() external view returns (IBaseRegistrar) {}

    function metadataService() external view returns (IMetadataService) {}

    function names(bytes32) external view returns (bytes memory) {}

    function wrap(
        bytes calldata name,
        address wrappedOwner,
        address resolver
    ) external {}

    function wrapETH2LD(
        string calldata label,
        address wrappedOwner,
        uint32 fuses,
        uint64 _expiry,
        address resolver
    ) external returns (uint64 expiry) {}

    function registerAndWrapETH2LD(
        string calldata label,
        address wrappedOwner,
        uint256 duration,
        address resolver,
        uint32 fuses,
        uint64 expiry
    ) external returns (uint256 registrarExpiry) {}

    function renew(
        uint256 labelHash,
        uint256 duration,
        uint64 expiry
    ) external returns (uint256 expires) {}

    function unwrap(
        bytes32 node,
        bytes32 label,
        address owner
    ) external {}

    function unwrapETH2LD(
        bytes32 label,
        address newRegistrant,
        address newController
    ) external {}

    function setFuses(bytes32 node, uint32 fuses)
        external
        returns (uint32 newFuses)
    {}

    function setChildFuses(
        bytes32 parentNode,
        bytes32 labelhash,
        uint32 fuses,
        uint64 expiry
    ) external {}

    function setSubnodeRecord(
        bytes32 node,
        string calldata label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    ) external {}

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external {}

    function setSubnodeOwner(
        bytes32 node,
        string calldata label,
        address newOwner,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32) {}

    function isTokenOwnerOrApproved(bytes32 node, address addr)
        external
        returns (bool)
    {
        return IdToApprovedAddressMap[uint256(node)][addr];
    }

    function setResolver(bytes32 node, address resolver) external {}

    function setTTL(bytes32 node, uint64 ttl) external {}

    function ownerOf(uint256 id) external returns (address owner) {}

    function allFusesBurned(bytes32 node, uint32 fuseMask)
        external
        view
        returns (bool)
    {}
}
