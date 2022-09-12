// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "src/structs/Config.sol";
import "ens-contracts/registry/ENS.sol";
import "./mocks/Mock721.sol";
import "./mocks/MockEns.sol";
import "./mocks/MockNameWrapper.sol";
import "src/GenericEnsMapper.sol";
import "forge-std/Test.sol";

contract GenericEnsMapperWithNameWrapperTests is Test {
    using stdStorage for StdStorage;

    GenericEnsMapper mapper;
    MockNameWrapper wrapper;
    uint256 private EnsTokenId;
    bytes32 private EnsTokenHash;
    uint256 private EnsTokenId2;
    bytes32 private EnsTokenHash2;
    string[] private DomainArray;
    string[] private DomainArray2;

    function setUp() public {
        mapper = new GenericEnsMapper();

        DomainArray = new string[](2);
        DomainArray[0] = "test";
        DomainArray[1] = "eth";

        DomainArray2 = new string[](2);
        DomainArray2[0] = "test2";
        DomainArray2[1] = "eth";
        EnsTokenHash = mapper.getDomainHash(DomainArray);
        EnsTokenHash2 = mapper.getDomainHash(DomainArray2);
        EnsTokenId = uint256(EnsTokenHash);
        EnsTokenId2 = uint256(EnsTokenHash2);
    }

    function setupMockNameWrapper(address _owner) private {
        wrapper = new MockNameWrapper();
        stdstore
            .target(_owner)
            .sig(mapper.EnsNameWrapper.selector)
            .checked_write(address(wrapper));
    }

    function setupMockEnsToken(uint256 _id) private {
        Mock721 ens = new Mock721();

        ens.mintTokenById(address(mapper.EnsNameWrapper()), _id);

        stdstore
            .target(address(mapper))
            .sig(mapper.EnsToken.selector)
            .checked_write(address(ens));
    }

    function setupMockEns(address _owner) private {
        MockEns ens = new MockEns(_owner);
        stdstore
            .target(address(mapper))
            .sig(mapper.EnsContract.selector)
            .checked_write(address(ens));
    }

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainFalse_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        address tokenOwner = address(0x999999);
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockNameWrapper(address(mapper));
        setupMockEnsToken(ensId);
        setupMockEns(address(mapper.EnsNameWrapper()));
        wrapper.updateApprovedAddress(ensId, tokenOwner, true);

        vm.startPrank(tokenOwner);

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        (, bool numericOnlyValue, bool overwriteUnusedSubdomainsValue) = mapper
            .ParentNodeToConfig(ensHash);
        IERC721 nftValue = mapper.ParentNodeToNftContracts(ensHash, 0);

        //assert
        assertEq(
            overwriteUnusedSubdomainsValue,
            overwriteUnusedSubdomains,
            "overwrite subdomains incorrect"
        );
        assertEq(numericOnlyValue, numericOnly, "numericOnly incorrect");
        assertEq(address(nftValue), address(nft), "nft object incorrect");
    }

    function testConfigureEnsAlreadyConfiguredEnsChangeNumericOnly_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        address tokenOwner = address(0x1234);

        //set up mock ens with the mapper contract as controller
        setupMockNameWrapper(address(mapper));
        setupMockEnsToken(ensId);
        setupMockEns(address(mapper.EnsNameWrapper()));
        wrapper.updateApprovedAddress(ensId, tokenOwner, true);

        vm.startPrank(tokenOwner);

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        mapper.updateSettingsToExistingEns(
            ensHash,
            !numericOnly,
            overwriteUnusedSubdomains
        );

        (bool initialisedValue, bool numericOnlyValue, ) = mapper
            .ParentNodeToConfig(ensHash);

        assertTrue(initialisedValue);

        //assert
        assertTrue(numericOnlyValue, "numericOnly should be true");
    }

    function testClaimSubdomainWithEligibleNft_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        address nftOwner = address(0xbada55);
        uint96 tokenId = 420;

        nft.mintTokenById(nftOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockNameWrapper(address(mapper));
        setupMockEnsToken(ensId);
        setupMockEns(address(mapper.EnsNameWrapper()));
        wrapper.updateApprovedAddress(ensId, tokenOwner, true);

        vm.prank(tokenOwner);
        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        changePrank(nftOwner);

        vm.expectCall(
            address(wrapper),
            abi.encodeCall(
                wrapper.setSubnodeRecord,
                (
                    ensHash,
                    label,
                    address(mapper),
                    address(mapper),
                    0,
                    0,
                    type(uint64).max
                )
            )
        );
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        (, , IERC721 nftValue, uint256 idValue) = mapper.SubnodeToNftDetails(
            subnodeHash
        );

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, tokenId, "NFT token id incorrect");
    }

    function testRemoveSubdomainApplySameSubdomainWhenAllowed_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = true;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);
        address ensOwner = address(0x111111);

        nft.mintTokenById(tokenOwner, 1);
        nft.mintTokenById(tokenOwner, 2);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        string memory label1 = "label1";

        string[] memory labelArray = new string[](3);
        labelArray[0] = label1;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subdomainHash = mapper.getDomainHash(labelArray);

        //set up mock ens with the mapper contract as controller
        setupMockNameWrapper(address(mapper));
        setupMockEnsToken(ensId);
        setupMockEns(address(mapper.EnsNameWrapper()));
        wrapper.updateApprovedAddress(ensId, ensOwner, true);

        vm.startPrank(ensOwner);
        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        changePrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 1, nft, label1);

        (, string memory Label, IERC721 nftValue, uint256 idValue) = mapper
            .SubnodeToNftDetails(subdomainHash);

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, 1, "NFT token id incorrect");
        assertEq(nftValue.ownerOf(1), tokenOwner, "NFT ownerOf incorrect");
        assertEq(Label, label1, "NFT label incorrect");

        mapper.removeSubdomain(subdomainHash);

        (, , nftValue, idValue) = mapper.SubnodeToNftDetails(subdomainHash);

        assertEq(address(nftValue), address(0), "NFT address incorrect");
        assertEq(idValue, 0, "NFT token id incorrect");

        mapper.claimSubdomain(ensHash, 2, nft, label1);

        (, , nftValue, idValue) = mapper.SubnodeToNftDetails(subdomainHash);
        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, 2, "NFT token id incorrect");

        vm.stopPrank();
    }

    function testConfigureEnsAlreadyConfiguredAddNftContract_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        IERC721 newNft = new Mock721();

        //set up mock ens with the mapper contract as controller
        setupMockNameWrapper(address(mapper));
        setupMockEnsToken(ensId);
        setupMockEns(address(mapper.EnsNameWrapper()));
        wrapper.updateApprovedAddress(ensId, address(this), true);

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
        mapper.addContractToExistingEns(ensHash, newNft);

        (, bool numericOnlyValue, bool overwriteUnusedSubdomainsValue) = mapper
            .ParentNodeToConfig(ensHash);
        IERC721 nft1Value = mapper.ParentNodeToNftContracts(ensHash, 0);
        IERC721 nft2Value = mapper.ParentNodeToNftContracts(ensHash, 1);

        //assert
        assertEq(
            overwriteUnusedSubdomainsValue,
            overwriteUnusedSubdomains,
            "overwrite subdomains incorrect"
        );
        assertEq(numericOnlyValue, numericOnly, "numericOnly incorrect");
        assertEq(address(nft1Value), address(nft), "nft 1 object incorrect");
        assertEq(address(nft2Value), address(newNft), "nft 2 object incorrect");
    }
}
