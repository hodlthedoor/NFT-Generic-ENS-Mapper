// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "src/structs/Config.sol";
import "ens-contracts/registry/ENS.sol";
import "./mocks/Mock721.sol";
import "./mocks/MockEns.sol";
import "src/GenericEnsMapper.sol";
import "forge-std/Test.sol";

contract GenericEnsMapperTests is Test {
    using stdStorage for StdStorage;

    event AddressChanged(
        bytes32 indexed node,
        uint256 coinType,
        bytes newAddress
    );
    event AddrChanged(bytes32 indexed node, address a);
    event SubdomainClaimed(
        bytes32 indexed _nodeHash,
        IERC721 indexed _nftContract,
        uint96 indexed _tokenId,
        string _name
    );

    GenericEnsMapper private mapper;
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

    function setupMockEns(address _owner) private {
        MockEns ens = new MockEns(_owner);
        stdstore
            .target(address(mapper))
            .sig(mapper.EnsContract.selector)
            .checked_write(address(ens));
    }

    function setupMockEnsTokens(uint256[] memory _id, address[] memory _owner)
        private
    {
        require(_id.length == _owner.length, "array lengths different");
        Mock721 ens = new Mock721();

        for (uint256 i; i < _id.length; i++) {
            ens.mintTokenById(_owner[i], _id[i]);
        }

        stdstore
            .target(address(mapper))
            .sig(mapper.EnsToken.selector)
            .checked_write(address(ens));
    }

    function setupMockEnsToken(uint256 _id, address _owner) private {
        Mock721 ens = new Mock721();

        ens.mintTokenById(_owner, _id);

        stdstore
            .target(address(mapper))
            .sig(mapper.EnsToken.selector)
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
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
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

    function testConfigureEnsForSingleNftNumericOnlyTrueOverwriteSubdomainFalse_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
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

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainTrue_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = true;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
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

    function testConfigureEnsForThreeNftNumericOnlyFalseOverwriteSubdomainFalse_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft1 = new Mock721();
        IERC721 nft2 = new Mock721();
        IERC721 nft3 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](3);
        nftArray[0] = nft1;
        nftArray[1] = nft2;
        nftArray[2] = nft3;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
        IERC721 nft1Value = mapper.ParentNodeToNftContracts(ensHash, 0);
        IERC721 nft2Value = mapper.ParentNodeToNftContracts(ensHash, 1);
        IERC721 nft3Value = mapper.ParentNodeToNftContracts(ensHash, 2);

        //assert
        assertEq(
            overwriteUnusedSubdomainsValue,
            overwriteUnusedSubdomains,
            "overwrite subdomains incorrect"
        );
        assertEq(numericOnlyValue, numericOnly, "numericOnly incorrect");
        assertEq(address(nft1Value), address(nft1), "nft 1 object incorrect");
        assertEq(address(nft2Value), address(nft2), "nft 2 object incorrect");
        assertEq(address(nft3Value), address(nft3), "nft 3 object incorrect");
    }

    function testConfigureEnsForSingleNftEnsIdDoesNotExist_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId + 666, address(this));

        //act
        vm.expectRevert("ERC721: invalid token ID");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
    }

    function testConfigureEnsNotOwnerOrApproved_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        address notOwner = address(0xfefe);
        vm.prank(notOwner);
        vm.expectRevert("not approved or owner");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
    }

    function testConfigureEnsForSingleNftEnsControllerNotSetToContract_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with random address as controller
        setupMockEns(address(0x1337));
        setupMockEnsToken(ensId, address(this));

        //act
        vm.expectRevert("controller of Ens not set to contract");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
    }

    function testConfigureEnsForSingleNftContractNotIERC721_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        MockNot721 nft1 = new MockNot721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = IERC721(address(nft1));

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        vm.expectRevert("need to be IERC721 contracts");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
    }
  function testConfigureEnsTwice_fail()
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

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.expectRevert("already been configured");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            !numericOnly,
            !overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
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
    function testConfigureEnsForThreeNftContractOneNotIERC721_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft1 = new Mock721();
        IERC721 nft2 = IERC721(address(new MockNot721()));
        IERC721 nft3 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](3);
        nftArray[0] = nft1;
        nftArray[1] = nft2;
        nftArray[2] = nft3;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        vm.expectRevert("need to be IERC721 contracts");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
        mapper.addContractToExistingEns(ensHash, newNft);

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
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

    function testConfigureEnsAlreadyConfiguredAddNftContractNotApprovedEnsOwner_fail()
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

        IERC721 newNft = new Mock721();

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        address notOwner = address(0xbbbb);
        vm.prank(notOwner);
        vm.expectRevert("not approved or owner");
        mapper.addContractToExistingEns(ensHash, newNft);
    }

    function testConfigureEnsAlreadyConfiguredAddDuplicateNftContract_fail()
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

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.expectRevert("duplicate NFT contract");
        mapper.addContractToExistingEns(ensHash, nft);
    }

    function testConfigureEnsForSingleNftChangeNumericOnlyTrueMultipleNftContracts_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();
        IERC721 nft2 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](2);
        nftArray[0] = nft;
        nftArray[1] = nft2;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.expectRevert("Numeric only not compatible with multiple contracts");
        mapper.updateSettingsToExistingEns(
            ensHash,
            !numericOnly,
            overwriteUnusedSubdomains
        );
    }

    function testConfigureEnsForSingleNftNumericOnlyTrueAddNewContract_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();
        IERC721 nft2 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.expectRevert("Numeric only not compatible with multiple contracts");
        mapper.addContractToExistingEns(ensHash, nft2);
    }

    //limit of 5 NFT contracts per subdomain
    function testConfigureEnsAlreadyConfiguredAddNftContractsTryAdd6_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft1 = new Mock721();
        IERC721 nft2 = new Mock721();
        IERC721 nft3 = new Mock721();
        IERC721 nft4 = new Mock721();
        IERC721 nft5 = new Mock721();
        IERC721 nft6 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](5);
        nftArray[0] = nft1;
        nftArray[1] = nft2;
        nftArray[2] = nft3;
        nftArray[3] = nft4;
        nftArray[4] = nft5;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.expectRevert("maximum 5 contracts per ENS");
        mapper.addContractToExistingEns(ensHash, nft6);
    }

    function testSetupEnsWithEmptyNftArray_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;

        IERC721[] memory nftArray;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        vm.expectRevert("need at least 1 NFT contract");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
    }

    function testConfigureEnsWith6NftContracts_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft1 = new Mock721();
        IERC721 nft2 = new Mock721();
        IERC721 nft3 = new Mock721();
        IERC721 nft4 = new Mock721();
        IERC721 nft5 = new Mock721();
        IERC721 nft6 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](6);
        nftArray[0] = nft1;
        nftArray[1] = nft2;
        nftArray[2] = nft3;
        nftArray[3] = nft4;
        nftArray[4] = nft5;
        nftArray[5] = nft6;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        vm.expectRevert("maximum 5 contracts per ENS");
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
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
        IERC721 nft2 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

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

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);

        assertTrue(initialisedValue);

        //assert
        assertTrue(numericOnlyValue, "numericOnly should be true");
    }

    function testConfigureEnsAlreadyConfiguredEnsChangeOverwriteSubdomains_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();
        IERC721 nft2 = new Mock721();

        IERC721[] memory nftArray = new IERC721[](2);
        nftArray[0] = nft;
        nftArray[1] = nft2;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

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
            numericOnly,
            !overwriteUnusedSubdomains
        );

        (
            bool initialisedValue,
            bool numericOnlyValue,
            bool overwriteUnusedSubdomainsValue
        ) = mapper.ParentNodeToConfig(ensHash);
        IERC721 nft1Value = mapper.ParentNodeToNftContracts(ensHash, 0);
        IERC721 nft2Value = mapper.ParentNodeToNftContracts(ensHash, 1);

        //assert
        assertFalse(numericOnlyValue, "numericOnly should be true");
        assertTrue(
            overwriteUnusedSubdomainsValue,
            "overwriteUnusedSubdomainsValue should be false"
        );
        assertEq(address(nft1Value), address(nft), "NFT 1 address incorrect");
        assertEq(address(nft2Value), address(nft2), "NFT 2 address incorrect");
    }

    // End admin functions
    //
    //--------------------------------------------

    //subdomain tests

    function testClaimSubdomainWithEligibleNft_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
        vm.prank(tokenOwner);
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

    function testClaimSubdomainWithTwoEligibleNft_pass() public {
        //assign

        bytes32 ensHash = bytes32(EnsTokenId);
        Mock721 nft = new Mock721();

        uint96 tokenId = 420;
        uint96 tokenId2 = 666;

        //address tokenOwner = address(0xfafbfc);

        nft.mintTokenById(address(0xfafbfc), tokenId);
        nft.mintTokenById(address(0xfafbfc), tokenId2);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(EnsTokenId, address(this));

        string memory label = "testlabel1";
        string memory label2 = "testlabel2";
        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            false,
            false
        );

        vm.startPrank(address(0xfafbfc));
        mapper.claimSubdomain(ensHash, tokenId, nft, label);
        mapper.claimSubdomain(ensHash, tokenId2, nft, label2);

        bytes32 subnodeHash = keccak256(
            abi.encodePacked(ensHash, keccak256(abi.encodePacked(label)))
        );

        string[] memory labelArray2 = new string[](3);
        labelArray[0] = label2;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash2 = keccak256(
            abi.encodePacked(ensHash, keccak256(abi.encodePacked(label2)))
        ); //mapper.getDomainHash(labelArray2);

        emit log_named_bytes32("subnodehash1", subnodeHash);
        emit log_named_bytes32("subnodehash2", subnodeHash2);

        (, , IERC721 nftValue, uint256 idValue) = mapper.SubnodeToNftDetails(
            subnodeHash
        );

        (, , IERC721 nftValue2, uint256 idValue2) = mapper.SubnodeToNftDetails(
            subnodeHash2
        );

        emit log_named_address("nft address 1", address(nftValue));
        emit log_named_address("nft address 2", address(nftValue2));

        vm.stopPrank();
        assertEq(address(nftValue), address(nft), "NFT 1 address incorrect");
        assertEq(idValue, tokenId, "NFT 1 token id incorrect");

        assertEq(address(nftValue2), address(nft), "NFT 2 address incorrect");
        assertEq(idValue2, tokenId2, "NFT 2 token id incorrect");
    }

    function testClaimSubdomainWithNftThatAlreadyHasSubdomain_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);
        vm.expectRevert("Subdomain has already been claimed");
        mapper.claimSubdomain(ensHash, tokenId, nft, label);
        vm.stopPrank();

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

    function testClaimSubdomainThatHasAlreadyBeenClaimed_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        address otherTokenOwner = address(0xccbbaa);
        uint96 tokenId = 420;
        uint96 otherTokenId = 777;

        nft.mintTokenById(tokenOwner, tokenId);
        nft.mintTokenById(otherTokenOwner, otherTokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.prank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        vm.prank(otherTokenOwner);
        vm.expectRevert("Subdomain has already been claimed");
        mapper.claimSubdomain(ensHash, otherTokenId, nft, label);
    }

    function testRemoveSubdomainFromNotApprovedAddress_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        (, , IERC721 nftValue, uint256 idValue) = mapper.SubnodeToNftDetails(
            subnodeHash
        );
        vm.stopPrank();
        vm.expectRevert("not owner of token");
        vm.prank(address(0x334343));
        mapper.removeSubdomain(subnodeHash);

        (, , IERC721 nftValue2, uint256 idValue2) = mapper.SubnodeToNftDetails(
            subnodeHash
        );

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, tokenId, "NFT token id incorrect");

        //these addresses shouldn't reset as a none owner tried to reset the domain
        assertEq(address(nftValue2), address(nft), "Reset NFT address incorrect");
        assertEq(idValue2, tokenId, "Reset NFT token id incorrect");
    }

    function testClaimAndRemoveSubdomainThenApplyNewSubdomain_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";
        string memory label2 = "222test222";

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        labelArray[0] = label2;

        bytes32 subnodeHash2 = mapper.getDomainHash(labelArray);

        (, , IERC721 nftValue, uint256 idValue) = mapper.SubnodeToNftDetails(
            subnodeHash
        );

        emit log_named_address("nft address", address(nftValue));

        mapper.removeSubdomain(subnodeHash);
        mapper.claimSubdomain(ensHash, tokenId, nft, label2);

        (, , IERC721 nftValue2, uint256 idValue2) = mapper.SubnodeToNftDetails(
            subnodeHash2
        );

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, tokenId, "NFT token id incorrect");

        assertEq(address(nftValue2), address(nft), "NFT address incorrect");
        assertEq(idValue2, tokenId, "NFT token id incorrect");
    }

    function testClaimSubdomainFromMultipleNftEnsContract_pass() public {
        //assign

        bytes32 ensHash = EnsTokenHash;

        string memory label1 = "label1";
        string memory label2 = "label2";
        string memory label3 = "label3";

        //address tokenOwner = address(0xaa998877);

        IERC721[] memory nftArray = new IERC721[](3);
        nftArray[0] = new Mock721();
        nftArray[1] = new Mock721();
        nftArray[2] = new Mock721();

        Mock721(address(nftArray[0])).mintTokenById(address(0xaa998877), 1);
        Mock721(address(nftArray[1])).mintTokenById(address(0xaa998877), 2);
        Mock721(address(nftArray[2])).mintTokenById(address(0xaa998877), 3);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label1;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(uint256(ensHash), address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            false,
            false
        );

        vm.startPrank(address(0xaa998877));
        mapper.claimSubdomain(ensHash, 1, nftArray[0], label1);
        mapper.claimSubdomain(ensHash, 2, nftArray[1], label2);
        mapper.claimSubdomain(ensHash, 3, nftArray[2], label3);
        vm.stopPrank();

        bytes32 subnodeHash1 = mapper.getDomainHash(labelArray);

        labelArray[0] = label2;
        bytes32 subnodeHash2 = mapper.getDomainHash(labelArray);

        labelArray[0] = label3;
        bytes32 subnodeHash3 = mapper.getDomainHash(labelArray);

        (, , IERC721 nftValue1, uint256 idValue1) = mapper.SubnodeToNftDetails(
            subnodeHash1
        );
        (, , IERC721 nftValue2, uint256 idValue2) = mapper.SubnodeToNftDetails(
            subnodeHash2
        );
        (, , IERC721 nftValue3, uint256 idValue3) = mapper.SubnodeToNftDetails(
            subnodeHash3
        );

        emit log_named_address("nft address 1", address(nftValue1));
        emit log_named_address("nft address 2", address(nftValue2));
        emit log_named_address("nft address 3", address(nftValue3));

        assertEq(
            address(nftValue1),
            address(nftArray[0]),
            "NFT address incorrect"
        );
        assertEq(idValue1, 1, "NFT token id incorrect");
        assertEq(
            nftValue1.ownerOf(1),
            address(0xaa998877),
            "NFT ownerOf incorrect"
        );

        assertEq(
            address(nftValue2),
            address(nftArray[1]),
            "NFT address incorrect"
        );
        assertEq(idValue2, 2, "NFT token id incorrect");
        assertEq(
            nftValue2.ownerOf(2),
            address(0xaa998877),
            "NFT ownerOf incorrect"
        );

        assertEq(
            address(nftValue3),
            address(nftArray[2]),
            "NFT address incorrect"
        );
        assertEq(idValue3, 3, "NFT token id incorrect");
        assertEq(
            nftValue3.ownerOf(3),
            address(0xaa998877),
            "NFT ownerOf incorrect"
        );
    }

    function testClaimSubdomainFromIncorrectButExistingNft_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        uint256 ensId2 = EnsTokenId2;
        bytes32 ensHash = bytes32(ensId);
        bytes32 ensHash2 = bytes32(ensId2);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        uint256[] memory arr = new uint256[](2);
        arr[0] = ensId;
        arr[1] = ensId2;

        address[] memory arr2 = new address[](2);
        arr2[0] = address(this);
        arr2[1] = address(this);
        setupMockEnsTokens(arr, arr2);

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
        nftArray[0] = new Mock721();
        mapper.addEnsContractMapping(
            DomainArray2,
            ensHash2,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.prank(tokenOwner);
        vm.expectRevert("Not valid contract");
        mapper.claimSubdomain(ensHash2, tokenId, nft, label);
    }

    function testClaimSubdomainFromIncorrectButExistingEnsContract_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        uint256 ensId2 = 689;
        bytes32 ensHash = bytes32(ensId);
        bytes32 ensHash2 = bytes32(ensId2);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        uint256[] memory arr = new uint256[](2);
        arr[0] = ensId;
        arr[1] = ensId2;

        address[] memory arr2 = new address[](2);
        arr2[0] = address(this);
        arr2[1] = address(this);
        setupMockEnsTokens(arr, arr2);

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );
        nftArray[0] = new Mock721();
        // mapper.addEnsContractMapping(
        //     ensHash2,
        //     nftArray,
        //     numericOnly,
        //     overwriteUnusedSubdomains
        // );

        vm.prank(tokenOwner);
        vm.expectRevert("ERC721: invalid token ID");
        mapper.claimSubdomain(ensHash, tokenId, nftArray[0], label);
    }

    function testRemoveSubdomainApplySameSubdomainWhenAllowed_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = true;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 1, nft, label1);

        (
            bytes32 ParentNamehash,
            string memory Label,
            IERC721 nftValue,
            uint256 idValue
        ) = mapper.SubnodeToNftDetails(subdomainHash);

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, 1, "NFT token id incorrect");
        assertEq(nftValue.ownerOf(1), tokenOwner, "NFT ownerOf incorrect");

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

    function testRemoveSubdomainApplySameSubdomainWhenNotAllowed_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 1, nft, label1);

        (, , IERC721 nftValue, uint256 idValue) = mapper.SubnodeToNftDetails(
            subdomainHash
        );

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, 1, "NFT token id incorrect");
        assertEq(nftValue.ownerOf(1), tokenOwner, "NFT ownerOf incorrect");

        mapper.removeSubdomain(subdomainHash);

        (, , nftValue, idValue) = mapper.SubnodeToNftDetails(subdomainHash);

        assertEq(address(nftValue), address(0), "NFT address incorrect");
        assertEq(idValue, 0, "NFT token id incorrect");

        vm.expectRevert("not allowed previously used subdomain");
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        vm.stopPrank();
    }

    function testClaimSubdomainWithNumericOnly_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

        nft.mintTokenById(tokenOwner, 1);
        nft.mintTokenById(tokenOwner, 2);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        string memory label1 = "label1";

        string[] memory labelArray = new string[](3);
        labelArray[0] = label1;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        //doesn't matter what label is passed in if numericOnly is on
        labelArray[0] = "2";
        bytes32 subdomainHash = mapper.getDomainHash(labelArray);

        (
            bytes32 ParentNamehash,
            string memory Label,
            IERC721 nftValue,
            uint256 idValue
        ) = mapper.SubnodeToNftDetails(subdomainHash);

        assertEq(address(nftValue), address(nft), "NFT address incorrect");
        assertEq(idValue, 2, "NFT token id incorrect");
        assertEq(nftValue.ownerOf(2), tokenOwner, "NFT ownerOf incorrect");
    }

    function testEmitAddrChangedOnRegistration_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);

        vm.expectEmit(true, false, false, false);
        emit AddrChanged(subdomainHash, tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);
    }

    function testEmitSubdomainClaimedOnRegistration_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);

        vm.expectEmit(true, true, true, false, address(mapper));
        emit SubdomainClaimed(subdomainHash,nft, 2, "label1.test.eth");
        mapper.claimSubdomain(ensHash, 2, nft, label1);
    }

    function testEmitAddressChangedOnRegistration_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);

        vm.expectEmit(true, true, false, false);
        emit AddressChanged(subdomainHash, 60, abi.encodePacked(tokenOwner));
        mapper.claimSubdomain(ensHash, 2, nft, label1);
    }

    function testEmitAddrChangedOnRemoval_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        vm.expectEmit(true, false, false, false);
        emit AddrChanged(subdomainHash, address(0));
        mapper.removeSubdomain(subdomainHash);
    }

    function testEmitAddressChangedOnRemoval_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        vm.expectEmit(true, false, false, false, address(mapper));
        emit AddressChanged(subdomainHash, 60, abi.encode(address(0)));
        mapper.removeSubdomain(subdomainHash);
    }

    function testEmitAddressChangedOnFunctionCallSingleNft_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        address newTokenOwner = address(0x121212);
        nft.safeTransferFrom(tokenOwner, newTokenOwner, 2, "");

        vm.expectEmit(true, false, true, true, address(mapper));
        emit AddressChanged(subdomainHash, 60, abi.encodePacked(newTokenOwner));
        mapper.outputEvents(subdomainHash);
    }

    function testEmitAddrChangedOnFunctionCallSingleNft_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0x123456);

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
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, 2, nft, label1);

        address newTokenOwner = address(0x121212);
        nft.safeTransferFrom(tokenOwner, newTokenOwner, 2, "");

        vm.expectEmit(true, false, false, false, address(mapper));
        emit AddrChanged(subdomainHash, newTokenOwner);
        mapper.outputEvents(subdomainHash);
    }

    //end of subdomain tests

    //resolver tests
    function testGetCorrectNameFromResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        string memory name = mapper.name(subnodeHash);

        assertEq(
            name,
            "testlabel.test.eth",
            "Name is incorrect from name resolver"
        );
    }

    function testGetAndSetCorrectTextFromResolverFromNotSubdomainHolder_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        string memory key = "test";
        string memory value = "value";

        vm.stopPrank();
        vm.prank(address(0x55555));
        vm.expectRevert("not owner of subdomain");
        mapper.setText(subnodeHash, key, value);
    }

    function testGetAndSetCorrectTextFromResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        string memory key = "test";
        string memory value = "value";
        mapper.setText(subnodeHash, key, value);
        string memory returnValue = mapper.text(subnodeHash, key);

        emit log_named_string("text value", returnValue);
        assertEq(
            address(nft),
            0x185a4dc360CE69bDCceE33b3784B0282f7961aea,
            "nft address incorrect, test will fail"
        );
        assertEq(
            returnValue,
            value,
            "Text value is incorrect from text resolver"
        );
    }

    function testGetCorrectAvatarFromResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        string memory avatar = mapper.text(subnodeHash, "avatar");

        emit log_named_string("avatar text", avatar);
        assertEq(
            address(nft),
            0x185a4dc360CE69bDCceE33b3784B0282f7961aea,
            "nft address incorrect, test will fail"
        );
        assertEq(
            avatar,
            "eip155:erc721:0x185a4dc360ce69bdccee33b3784b0282f7961aea/420",
            "Avatar is incorrect from text resolver"
        );
    }

   function testGetNoAddrFromAddrResolverAfterSubdomainRemoved_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        mapper.removeSubdomain(subnodeHash);
        
        vm.expectRevert("subdomain not configured");
        address addr =    mapper.addr(subnodeHash);

    }

    function testGetCorrectAddrFromAddrResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);

        assertEq(
            mapper.addr(subnodeHash),
            tokenOwner,
            "Address is incorrect from address resolver"
        );
    }

    function testGetCorrectAddressFromAddressResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        bytes memory addressBytes = mapper.addr(subnodeHash, 60);
        address addr;
        assembly {
            addr := mload(add(addressBytes, 20))
        }

        assertEq(
            addr,
            tokenOwner,
            "Address is incorrect from address resolver"
        );
    }

    function testGetCorrectAddressAfterNftTransferFromAddressResolver_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        bytes memory addressBytes = mapper.addr(subnodeHash, 60);
        address addr;
        assembly {
            addr := mload(add(addressBytes, 20))
        }

        assertEq(
            addr,
            tokenOwner,
            "Address is incorrect from address resolver"
        );

        address newTokenOwner = address(0x121212);
        nft.safeTransferFrom(tokenOwner, newTokenOwner, tokenId, "");

        addressBytes = mapper.addr(subnodeHash, 60);

        assembly {
            addr := mload(add(addressBytes, 20))
        }

        assertEq(
            addr,
            newTokenOwner,
            "Address is incorrect from address resolver"
        );
    }

    function testGetEmptyOtherAddressFromAddressResolverAfterTransfer_pass()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        address otherAddress = address(0x122244);
        uint256 coinType = 22;
        mapper.setAddr(subnodeHash, coinType, abi.encodePacked(otherAddress));
        bytes memory addressBytes = mapper.addr(subnodeHash, coinType);
        address addr;
        assembly {
            addr := mload(add(addressBytes, 20))
        }

        assertEq(
            addr,
            otherAddress,
            "Address is incorrect from address resolver"
        );

        address newTokenOwner = address(0x121212);
        nft.safeTransferFrom(tokenOwner, newTokenOwner, tokenId, "");

        addressBytes = mapper.addr(subnodeHash, coinType);

        assertEq(addressBytes.length, 0, "address should be empty");
    }

    function testGetCorrectOtherAddressFromAddressResolver_pass() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        address otherAddress = address(0x122244);
        uint256 coinType = 22;
        mapper.setAddr(subnodeHash, coinType, abi.encodePacked(otherAddress));
        bytes memory addressBytes = mapper.addr(subnodeHash, coinType);
        address addr;
        assembly {
            addr := mload(add(addressBytes, 20))
        }

        assertEq(
            addr,
            otherAddress,
            "Address is incorrect from address resolver"
        );
    }

    function testSetEthOtherAddressFromAddressResolver_fail() public {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        address otherAddress = address(0x122244);
        uint256 coinType = 60;
        vm.expectRevert("cannot set eth address");
        mapper.setAddr(subnodeHash, coinType, abi.encodePacked(otherAddress));
    }

    function testGetCorrectOtherAddressFromAddressResolverFromNotOwnerOfSubdomain_fail()
        public
    {
        //assign
        uint256 ensId = EnsTokenId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        Mock721 nft = new Mock721();

        address tokenOwner = address(0xfafbfc);
        uint96 tokenId = 420;

        nft.mintTokenById(tokenOwner, tokenId);

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;
        string memory label = "testlabel";

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));
        setupMockEnsToken(ensId, address(this));

        //act
        mapper.addEnsContractMapping(
            DomainArray,
            ensHash,
            nftArray,
            numericOnly,
            overwriteUnusedSubdomains
        );

        vm.startPrank(tokenOwner);
        mapper.claimSubdomain(ensHash, tokenId, nft, label);

        string[] memory labelArray = new string[](3);
        labelArray[0] = label;
        labelArray[1] = "test";
        labelArray[2] = "eth";

        bytes32 subnodeHash = mapper.getDomainHash(labelArray);
        address otherAddress = address(0x122244);
        uint256 coinType = 22;
        vm.stopPrank();
        vm.startPrank(address(0x55222444));
        vm.expectRevert("not owner of subdomain");
        mapper.setAddr(subnodeHash, coinType, abi.encodePacked(otherAddress));
    }

    function testNamehashFunctionMainDomain() public {
        bytes32 pccEth = 0x32e8b9e368196ff01039bd331e918814dfeaf9c11fc076af54e5ea098647a280;

        string[] memory domain = new string[](2);
        domain[0] = "pcc";
        domain[1] = "eth";

        assertEq(
            mapper.getDomainHash(domain),
            pccEth,
            "domain namehash incorrect"
        );
    }

    function testNamehashFunctionSubdomain() public {
        bytes32 hodlPccEth = 0xe9ad53ae31b1c5aabef5d4a492d5a882e1c282447326886b6e332a3e7f2c6a52;
        string[] memory domainArray = new string[](3);

        domainArray[0] = "hodl";
        domainArray[1] = "pcc";
        domainArray[2] = "eth";

        assertEq(
            mapper.getDomainHash(domainArray),
            hodlPccEth,
            "subdomain namehash incorrect"
        );
    }
}
