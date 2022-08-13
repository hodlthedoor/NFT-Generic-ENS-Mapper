// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "ens-contracts/registry/ENS.sol";
import "./mocks/Mock721.sol";
import "src/GenericEnsMapper.sol";
import "forge-std/Test.sol";


contract GenericEnsMapperTests is Test {

    GenericEnsMapper private mapper;

    function setUp() public {

        mapper = new GenericEnsMapper();
    }

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainFalse_pass() public {
     
        uint256 ensId;
        bool numericOnly = false;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        mapper.addEnsContractMapping(ensId, nftArray, numericOnly, overwriteUnusedSubdomains);

    }

    function testConfigureEnsForSingleNftNumericOnlyTrueOverwriteSubdomainFalse_pass() public {
        uint256 ensId;
        bool numericOnly = true;
        bool overwriteUnusedSubdomains = false;
        IERC721 nft = new Mock721();

        IERC721[] memory nftArray = new IERC721[](1);
        nftArray[0] = nft;

        mapper.addEnsContractMapping(ensId, nftArray, numericOnly, overwriteUnusedSubdomains);

    }

    function testConfigureEnsForSingleNftNumericOnlyFalseOverwriteSubdomainTrue_pass() public {
        
    }

    function testConfigureEnsForThreeNftNumericOnlyFalseOverwriteSubdomainFalse_pass() public {
        
    }

    function testConfigureEnsForSingleNftEnsIdDoesNotExist_fail() public {
        
    }

   function testConfigureEnsForSingleNftEnsControllerNotSetToContract_fail() public {
        
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

    //end of subdomain tests
}
