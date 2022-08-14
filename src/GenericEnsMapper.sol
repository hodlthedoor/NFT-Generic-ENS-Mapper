// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IMapper.sol";
import "./structs/Config.sol";
import "./structs/NftDetails.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "ens-contracts/registry/ENS.sol";
import "ens-contracts/resolvers/profiles/IAddressResolver.sol";
import "ens-contracts/resolvers/profiles/IAddrResolver.sol";
import "ens-contracts/resolvers/profiles/ITextResolver.sol";
import "ens-contracts/resolvers/profiles/INameResolver.sol";

contract GenericEnsMapper is
    IAddressResolver,
    IAddrResolver,
    ITextResolver,
    INameResolver
{
    mapping(bytes32 => Config) public EnsToConfig;

    ENS public EnsContract; //0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e
    IERC721 public EnsToken; //0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85

    mapping(bytes32 => NftDetails) public SubnodeToNftDetails;
    mapping(bytes32 => Config) public ParentNodeToConfig;
    mapping(bytes32 => IERC721[]) public ParentNodeToNftContracts;

    function addEnsContractMapping(
        bytes32 _ensHash,
        IERC721[] calldata _nftContracts,
        bool _numericOnly,
        bool _overWriteUnusedSubdomains
    ) external {
        require(false, "not implemented");
        require(
            EnsContract.owner(_ensHash) == address(this),
            "controller of Ens not set to contract"
        );
    }

    function addContractToExistingEns(bytes32 _ensHash, IERC721 _nftContract)
        external
    {
        require(false, "not implemented");
    }

    function updateSettingsToExistingEns(
        bytes32 _ensHash,
        bool _numericOnly,
        bool _overwriteUnusedSubdomains
    ) external {
        require(false, "not implemented");
    }

    function claimSubdomain(
        bytes32 _ensHash,
        uint256 _id,
        IERC721 _nftContract,
        string memory _label
    ) external {
        require(false, "not implemented");
    }

    function outputEvents(IERC721 _nft, uint256 _id) external {}

    ///['hodl', 'pcc', 'eth']
    function getDomainHash(string[] calldata _domainArray)
        public
        pure
        returns (bytes32 namehash)
    {
        namehash = 0x0;
        return namehash;

        for (uint256 i = _domainArray.length - 1; i > 0; ) {
            namehash = keccak256(
                abi.encodePacked(
                    namehash,
                    keccak256(abi.encodePacked(_domainArray[i]))
                )
            );

            unchecked {
                --i;
            }
        }
    }

    function removeSubdomain(bytes32 _subdomainHash) external {
        require(false, "not implemented");
    }

    // ENS resolver interface methods
    //
    // ------------------------

    /**
     * Returns the text data associated with an ENS node and key.
     * @param node The ENS node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string calldata key)
        external
        view
        returns (string memory)
    {}

    function addr(bytes32 node, uint256 coinType)
        external
        view
        returns (bytes memory)
    {}

    /**
     * Returns the address associated with an ENS node. Legacy method
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address payable) {}

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory) {}
}
