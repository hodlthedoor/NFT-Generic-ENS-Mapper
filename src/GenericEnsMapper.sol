// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/console.sol";
import "./structs/Config.sol";
import "./structs/NftDetails.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "ens-contracts/registry/ENS.sol";
import "ens-contracts/resolvers/profiles/IAddressResolver.sol";
import "ens-contracts/resolvers/profiles/IAddrResolver.sol";
import "ens-contracts/resolvers/profiles/ITextResolver.sol";
import "ens-contracts/resolvers/profiles/INameResolver.sol";
import "ens-contracts/wrapper/INameWrapper.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol";
import "EnsPrimaryContractNamer/PrimaryEns.sol";

contract GenericEnsMapper is
    IAddressResolver,
    IAddrResolver,
    ITextResolver,
    INameResolver,
    IERC1155Receiver,
    PrimaryEns
{
    using Strings for *;

    uint256 private constant COIN_TYPE_ETH = 60;

    event addNftContractToEns(
        bytes32 indexed _ensHash,
        IERC721 indexed _nftContract
    );
    event updateEnsClaimConfig(
        bytes32 indexed _ensHash,
        bool _numericOnly,
        bool _canOverwriteSubdomains
    );

    INameWrapper public EnsNameWrapper;

    ENS public EnsContract = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    IERC721 public EnsToken =
        IERC721(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);

    mapping(bytes32 => Config) public EnsToConfig;
    mapping(bytes32 => NftDetails) public SubnodeToNftDetails;
    mapping(bytes32 => Config) public ParentNodeToConfig;
    mapping(bytes32 => IERC721[]) public ParentNodeToNftContracts;

    mapping(bytes32 => mapping(address => mapping(uint256 => bytes))) OtherAddresses;
    mapping(bytes32 => mapping(bytes32 => string)) TextMappings;

    event SubdomainClaimed(
        bytes32 indexed _nodeHash,
        IERC721 indexed _nftContract,
        uint96 indexed _tokenId,
        string _name
    );

    event SubdomainRemoved(
        bytes32 indexed _nodeHash,
        IERC721 indexed _nftContract,
        uint96 indexed _tokenId,
        string _name
    );

    function checkNftContracts(IERC721[] calldata _nftContracts) private view {
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
        address owner = EnsContract.owner(_ensHash);
        require(
            owner == address(this) || owner == address(EnsNameWrapper),
            "controller of Ens not set to contract"
        );
        require(getDomainHash(_domainArray) == _ensHash, "incorrect namehash");
        require(_nftContracts.length < 6, "maximum 5 contracts per ENS");
        require(_nftContracts.length > 0, "need at least 1 NFT contract");
        require(
            !(_nftContracts.length > 1 && _numericOnly),
            "Numeric only not compatible with multiple contracts"
        );
        require(
            !ParentNodeToConfig[_ensHash].Initialised,
            "already been configured"
        );
        checkNftContracts(_nftContracts);
        ParentNodeToConfig[_ensHash] = Config(
            true,
            _numericOnly,
            _overWriteUnusedSubdomains,
            _domainArray
        );
        ParentNodeToNftContracts[_ensHash] = _nftContracts;

        //output events
        emit updateEnsClaimConfig(
            _ensHash,
            _numericOnly,
            _overWriteUnusedSubdomains
        );

        for (uint256 i; i < _nftContracts.length; ) {
            emit addNftContractToEns(_ensHash, _nftContracts[i]);

            unchecked {
                ++i;
            }
        }
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
        emit addNftContractToEns(_ensHash, _nftContract);
    }

    function updateSettingsToExistingEns(
        bytes32 _ensHash,
        bool _numericOnly,
        bool _overwriteUnusedSubdomains
    ) external isEnsApprovedOrOwner(_ensHash) {
        require(
            !(ParentNodeToNftContracts[_ensHash].length > 1 && _numericOnly),
            "Numeric only not compatible with multiple contracts"
        );
        Config memory config = ParentNodeToConfig[_ensHash];
        require(config.Initialised, "ENS not configured");

        config.NumericOnly = _numericOnly;
        config.CanOverwriteSubdomains = _overwriteUnusedSubdomains;

        ParentNodeToConfig[_ensHash] = config;

        emit updateEnsClaimConfig(
            _ensHash,
            _numericOnly,
            _overwriteUnusedSubdomains
        );
    }

    /**
     * @notice Claim subdomain
     * @param _ensHash parent namehash of the subdomain
     * @param _id ID of ERC-721 NFT
     * @param _nftContract address of the ERC-721 NFT contract
     * @param _label label for the subdomain
     */
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
        require(config.Initialised, "configuration for ENS not enabled");
        string memory label = config.NumericOnly ? _id.toString() : _label;
        bytes32 subnodeHash = keccak256(
            abi.encodePacked(_ensHash, keccak256(abi.encodePacked(label)))
        );
        require(
            SubnodeToNftDetails[subnodeHash].ParentNamehash == 0x0,
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

        if (EnsToken.ownerOf(uint256(_ensHash)) == address(EnsNameWrapper)) {
            EnsNameWrapper.setSubnodeRecord(
                _ensHash,
                label,
                address(this),
                address(this),
                0, //ttl
                0, //fuses
                type(uint64).max
            );
        } else {
            EnsContract.setSubnodeRecord(
                _ensHash,
                keccak256(abi.encodePacked(label)),
                address(this),
                address(this),
                0
            );
        }

        emit AddrChanged(subnodeHash, _nftContract.ownerOf(_id));
        emit AddressChanged(
            subnodeHash,
            60,
            abi.encodePacked(_nftContract.ownerOf(_id))
        );
        emit SubdomainClaimed(
            subnodeHash,
            _nftContract,
            _id,
            name(subnodeHash)
        );
    }

    function isValidNftContract(bytes32 _ensHash, IERC721 _nftContract)
        private
        view
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
        address owner = getOwnerFromDetails(_subnodeHash);

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

    /**
     * @notice removes the subdomain mapping from this resolver contract
     * @param _subdomainHash namehash of the subdomain
     */
    function removeSubdomain(bytes32 _subdomainHash) external {
        NftDetails memory details = SubnodeToNftDetails[_subdomainHash];
        require(details.ParentNamehash != 0x0, "subdomain not configured");
        require(
            details.NftAddress.ownerOf(details.NftId) == msg.sender,
            "not owner of token"
        );

        delete SubnodeToNftDetails[_subdomainHash];

        emit AddrChanged(_subdomainHash, address(0));
        emit AddressChanged(_subdomainHash, 60, abi.encodePacked(address(0)));
        emit SubdomainRemoved(
            _subdomainHash,
            details.NftAddress,
            details.NftId,
            name(_subdomainHash)
        );
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
    {
        NftDetails memory details = SubnodeToNftDetails[node];

        if (keccak256(abi.encodePacked(key)) == keccak256("avatar")) {
            string memory str = string(
                abi.encodePacked(
                    "eip155:erc721:",
                    address(details.NftAddress).toHexString(),
                    "/",
                    details.NftId.toString()
                )
            );
            return str;
        } else {
            return TextMappings[node][keccak256(abi.encodePacked(key))];
        }
    }

    /**
     * Sets the text data associated with an ENS node and key.
     * May only be called by the owner of the linked NFT
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external authorised(node) {
        TextMappings[node][keccak256(abi.encodePacked(key))] = value;
        emit TextChanged(node, key, value);
    }

    function addr(bytes32 node, uint256 coinType)
        external
        view
        returns (bytes memory)
    {
        address owner = getOwnerFromDetails(node);
        if (coinType == COIN_TYPE_ETH) {
            return abi.encodePacked(owner);
        } else {
            return OtherAddresses[node][owner][coinType];
        }
    }

    /**
     * Returns the address associated with an ENS node. Legacy method
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address payable) {
        return payable(getOwnerFromDetails(node));
    }

    function setAddr(
        bytes32 node,
        uint256 coinType,
        bytes memory a
    ) public authorised(node) {
        emit AddressChanged(node, coinType, a);
        require(coinType != COIN_TYPE_ETH, "cannot set eth address");
        address nftOwner = getOwnerFromDetails(node);
        OtherAddresses[node][nftOwner][coinType] = a;
    }

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) public view returns (string memory) {
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

    function getOwnerFromDetails(bytes32 _subnodeHash)
        private
        view
        returns (address)
    {
        NftDetails memory details = SubnodeToNftDetails[_subnodeHash];
        require(details.ParentNamehash != 0x0, "subdomain not configured");
        address owner = details.NftAddress.ownerOf(details.NftId);
        return owner;
    }

    //ERC1155 receiver

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        require(false, "cannot do batch transfer");
        return this.onERC1155BatchReceived.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return
            interfaceId == this.onERC1155Received.selector ||
            interfaceId == 0x3b3b57de || //addr
            interfaceId == 0x59d1d43c || //text
            interfaceId == 0x691f3431 || //name
            interfaceId == 0x01ffc9a7;
    }

    modifier isNftOwner(IERC721 _nftContract, uint96 _id) {
        require(_nftContract.ownerOf(_id) == msg.sender, "not owner of NFT");
        _;
    }

    modifier isEnsApprovedOrOwner(bytes32 _ensHash) {
        address owner = EnsToken.ownerOf(uint256(_ensHash));
        require(
            owner == msg.sender ||
                EnsToken.isApprovedForAll(owner, msg.sender) ||
                (owner == address(EnsNameWrapper) &&
                    EnsNameWrapper.isTokenOwnerOrApproved(
                        _ensHash,
                        msg.sender
                    )),
            "not approved or owner"
        );
        _;
    }

    modifier authorised(bytes32 _subnodeHash) {
        address owner = getOwnerFromDetails(_subnodeHash);
        require(owner == msg.sender, "not owner of subdomain");
        _;
    }
}
