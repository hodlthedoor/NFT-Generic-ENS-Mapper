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

    GenericEnsMapper private mapper;

    function setUp() public {

        mapper = new GenericEnsMapper();
    }

    function setupMockEns(address _owner) private {
        MockEns ens = new MockEns(_owner);
        stdstore.target(address(mapper))
                .sig(mapper.EnsContract.selector)
                .checked_write(address(ens));

    }

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainFalse_pass() public {
     
        //assign
        uint256 ensId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));

        //act       
        mapper.addEnsContractMapping(ensHash, nftArray, numericOnly, overwriteUnusedSubdomains);

        (bool initialisedValue, bool numericOnlyValue, bool overwriteUnusedSubdomainsValue) = mapper.ParentNodeToConfig(ensHash);
        IERC721 nftValue = mapper.ParentNodeToNftContracts(ensHash, 0);

        //assert
        assertEq(overwriteUnusedSubdomainsValue, overwriteUnusedSubdomains, "overwrite subdomains incorrect");
        assertEq(numericOnlyValue, numericOnly, "numericOnly incorrect");
        assertEq(address(nftValue), address(nft), "nft object incorrect");

    }

    function testConfigureEnsForSingleNftNumericOnlyTrueOverwriteSubdomainFalse_pass() public {
        
        //assign
        uint256 ensId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with the mapper contract as controller
        setupMockEns(address(mapper));

        //act       
        mapper.addEnsContractMapping(ensHash, nftArray, numericOnly, overwriteUnusedSubdomains);

        (bool initialisedValue, bool numericOnlyValue, bool overwriteUnusedSubdomainsValue) = mapper.ParentNodeToConfig(ensHash);
        IERC721 nftValue = mapper.ParentNodeToNftContracts(ensHash, 0);

        //assert
        assertEq(overwriteUnusedSubdomainsValue, overwriteUnusedSubdomains, "overwrite subdomains incorrect");
        assertEq(numericOnlyValue, numericOnly, "numericOnly incorrect");
        assertEq(address(nftValue), address(nft), "nft object incorrect");

    }

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainTrue_pass() public {
        
    }

    function testConfigureEnsForThreeNftNumericOnlyFalseOverwriteSubdomainFalse_pass() public {
        
    }

    function testConfigureEnsForSingleNftEnsIdDoesNotExist_fail() public {
        
    }

    function testConfigureEnsNotOwnerOrApproved_fail() public {

    }

   function testConfigureEnsForSingleNftEnsControllerNotSetToContract_fail() public {
        //assign
        uint256 ensId;
        bytes32 ensHash = bytes32(ensId);
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        //set up mock ens with random address as controller
        setupMockEns(address(0x1337));
        
        //act       
        vm.expectRevert("controller of Ens not set to contract");
        mapper.addEnsContractMapping(ensHash, nftArray, numericOnly, overwriteUnusedSubdomains);
    }

   function testConfigureEnsForSingleNftContractNotIERC721_fail() public {
        
    }

    function testConfigureEnsForThreeNftContractOneNotIERC721_fail() public {
        
    }

    function testConfigureEnsAlreadyConfiguredAddNftContract_pass() public {
        
    }

    function testConfigureEnsForSingleNftChangeNumericOnlyTrueMultipleNftContracts_fail() public {
        
    }

    function testConfigureEnsForSingleNftNumericOnlyTrueAddNewContract_fail() public {
        
    }

    //limit of 5 NFT contracts per subdomain
    function testConfigureEnsAlreadyConfiguredAddNftContractsTryAdd6_fail() public {
        
    }

    function testConfigureEnsAlreadyConfiguredEnsChangeNumericOnly_pass() public {

    }

    function testConfigureEnsAlreadyConfiguredEnsChangeOverwriteSubdomains_pass() public {

    }

    // End admin functions
    //
    //--------------------------------------------

    //subdomain tests

    function testClaimSubdomainWithEligibleNft_pass() public {

    }

    function testClaimSubdomainWithNftIdHigherThanUint96Max_fail() public {

    }

    function testClaimSubdomainWithTwoEligibleNft_pass() public {

    }

    function testClaimSubdomainWithNftThatAlreadyHasSubdomain_fail() public {
        
    }  

    function testClaimAndRemoveSubdomainThenApplyNewSubdomain_pass() public {

    }

    function testClaimSubdomainFromMultipleNftEnsContract_pass() public {

    }

    function testClaimSubdomainFromIncorrectButExistingNft_fail() public {
        
    }

    function testClaimSubdomainFromIncorrectButExistingEnsContract_fail() public {
        
    }

    function testRemoveSubdomainApplySameSubdomainWhenAllowed_pass() public {

    }
    function testRemoveSubdomainApplySameSubdomainWhenNotAllowed_fail() public {
        
    }

    function testClaimSubdomainWithNumericOnly_pass() public {
        
    }

    function testEmitAddrChangedOnRegistration_pass() public {
        
    }

    function testEmitAddrChangedOnRemoval_pass() public {
        
    }

    function testEmitAddrChangedOnFunctionCallSingleNft_pass() public {
        
    }

    function testEmitAddrChangedOnFunctionCallMultipleNft_pass() public {
        
    }

    function testTransferNftAddressFunctionUpdates_pass() public {

    }

    //end of subdomain tests
}
