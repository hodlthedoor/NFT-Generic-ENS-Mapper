// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./structs/Config.sol";
import "./structs/NftDetails.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
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

    ENS public EnsContract = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    IERC721 public EnsToken =
        IERC721(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);

    mapping(bytes32 => NftDetails) public SubnodeToNftDetails;
    mapping(bytes32 => Config) public ParentNodeToConfig;
    mapping(bytes32 => IERC721[]) public ParentNodeToNftContracts;

    event SubdomainClaimed(
        IERC721 indexed _nftContract,
        uint96 indexed _tokenId,
        bytes32 _ensHash,
        string _label
    );

    function checkNftContracts(IERC721[] calldata _nftContracts) private {
        for (uint256 i; i < _nftContracts.length; ) {
            require(
                ERC165Checker.supportsInterface(
                    address(_nftContracts[i]),
                    type(IERC721).interfaceId
                ),
                "need to be IERC721 contracts"
            );

            unchecked {
                ++i;
            }
        }
    }

    function addEnsContractMapping(
        string[] calldata _domainArray,
        bytes32 _ensHash,
        IERC721[] calldata _nftContracts,
        bool _numericOnly,
        bool _overWriteUnusedSubdomains
    ) external isEnsApprovedOrOwner(_ensHash) {
        require(
            EnsContract.owner(_ensHash) == address(this),
            "controller of Ens not set to contract"
        );
        require(getDomainHash(_domainArray) == _ensHash, "incorrect namehash");
        require(_nftContracts.length < 6, "maximum 5 contracts per ENS");
        require(_nftContracts.length > 0, "need at least 1 NFT contract");
        require(
            !(_nftContracts.length > 1 && _numericOnly),
            "Numeric only not compatible with multiple contracts"
        );
        checkNftContracts(_nftContracts);
        ParentNodeToConfig[_ensHash] = Config(
            true,
            _numericOnly,
            _overWriteUnusedSubdomains,
            _domainArray
        );
        ParentNodeToNftContracts[_ensHash] = _nftContracts;
    }

    function addContractToExistingEns(bytes32 _ensHash, IERC721 _nftContract)
        external
        isEnsApprovedOrOwner(_ensHash)
    {
        uint256 numberOfContracts = ParentNodeToNftContracts[_ensHash].length;
        require(numberOfContracts < 5, "maximum 5 contracts per ENS");
        require(
            !isValidNftContract(_ensHash, _nftContract),
            "duplicate NFT contract"
        );
        require(
            !ParentNodeToConfig[_ensHash].NumericOnly,
            "Numeric only not compatible with multiple contracts"
        );

        ParentNodeToNftContracts[_ensHash].push(_nftContract);
    }

    function updateSettingsToExistingEns(
        bytes32 _ensHash,
        bool _numericOnly,
        bool _overwriteUnusedSubdomains
    ) external {
        require(
            !(ParentNodeToNftContracts[_ensHash].length > 1 && _numericOnly),
            "Numeric only not compatible with multiple contracts"
        );
        Config memory config = ParentNodeToConfig[_ensHash];
        require(config.Initialised, "ENS not configured");

        config.NumericOnly = _numericOnly;
        config.CanOverwriteSubdomains = _overwriteUnusedSubdomains;

        ParentNodeToConfig[_ensHash] = config;
    }

    function claimSubdomain(
        bytes32 _ensHash,
        uint96 _id,
        IERC721 _nftContract,
        string memory _label
    ) external isNftOwner(_nftContract, _id) {
        require(
            isValidNftContract(_ensHash, _nftContract),
            "Not valid contract"
        );
        Config memory config = ParentNodeToConfig[_ensHash];
        string memory label = config.NumericOnly ? uint2str(_id) : _label;
        bytes32 subnodeHash = keccak256(
            abi.encodePacked(_ensHash, keccak256(abi.encodePacked(label)))
        );
        require(
            SubnodeToNftDetails[subnodeHash].NftAddress == IERC721(address(0)),
            "Subdomain has already been claimed"
        );
        require(
            !EnsContract.recordExists(subnodeHash) ||
                config.CanOverwriteSubdomains,
            "not allowed previously used subdomain"
        );

        NftDetails memory details = NftDetails(
            _ensHash,
            label,
            _nftContract,
            _id
        );

        SubnodeToNftDetails[subnodeHash] = details;

        EnsContract.setSubnodeRecord(
            _ensHash,
            keccak256(abi.encodePacked(label)),
            address(this),
            address(this),
            0
        );

        emit AddrChanged(subnodeHash, _nftContract.ownerOf(_id));
        emit AddressChanged(
            subnodeHash,
            60,
            abi.encodePacked(_nftContract.ownerOf(_id))
        );
        emit SubdomainClaimed(_nftContract, _id, _ensHash, label);
    }

    function isValidNftContract(bytes32 _ensHash, IERC721 _nftContract)
        private
        returns (bool _isPresent)
    {
        IERC721[] memory contracts = ParentNodeToNftContracts[_ensHash];
        uint256 total = contracts.length;
        for (uint256 i; i < total; ) {
            if (contracts[i] == _nftContract) {
                _isPresent = true;
            }

            unchecked {
                ++i;
            }
        }
    }

    function outputEvents(bytes32 _subnodeHash) external {
        NftDetails memory details = SubnodeToNftDetails[_subnodeHash];
        address owner = details.NftAddress.ownerOf(details.NftId);

        emit AddrChanged(_subnodeHash, owner);
        emit AddressChanged(_subnodeHash, 60, abi.encodePacked(owner));
    }

    ///['hodl', 'pcc', 'eth']
    function getDomainHash(string[] calldata _domainArray)
        public
        pure
        returns (bytes32 namehash)
    {
        namehash = 0x0;

        for (uint256 i = _domainArray.length; i > 0; ) {
            unchecked {
                --i;
            }
            namehash = keccak256(
                abi.encodePacked(
                    namehash,
                    keccak256(abi.encodePacked(_domainArray[i]))
                )
            );
        }
    }

    function removeSubdomain(bytes32 _subdomainHash) external {
        NftDetails memory details = SubnodeToNftDetails[_subdomainHash];
        require(
            address(details.NftAddress) != address(0),
            "subdomain not configured"
        );

        delete SubnodeToNftDetails[_subdomainHash];

        emit AddrChanged(_subdomainHash, address(0));
        emit AddressChanged(_subdomainHash, 60, abi.encodePacked(address(0)));
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
    function name(bytes32 node) external view returns (string memory) {
        NftDetails memory details = SubnodeToNftDetails[node];
        string memory label = details.Label;
        string[] memory domainArray = ParentNodeToConfig[details.ParentNamehash]
            .DomainArray;
        for (uint256 i; i < domainArray.length; ) {
            label = string(abi.encodePacked(label, ".", domainArray[i]));

            unchecked {
                ++i;
            }
        }

        return label;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    modifier isNftOwner(IERC721 _nftContract, uint96 _id) {
        require(_nftContract.ownerOf(_id) == msg.sender, "not owner of NFT");
        _;
    }

    modifier isEnsApprovedOrOwner(bytes32 _ensHash) {
        address owner = EnsToken.ownerOf(uint256(_ensHash));
        require(
            owner == msg.sender || EnsToken.isApprovedForAll(owner, msg.sender),
            "not approved or owner"
        );
        _;
    }
}
