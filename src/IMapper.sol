// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface IMapper {

    //add new ENS => NFT contract settings
    function addEnsContractMapping(uint256 _ensId, address[] calldata _address, bool _numericOnly, bool _overWriteUnusedSubdomains) external;   

    //claim a subdomain from a valid ENS domain using a valid address / id
    function claimSubdomain(uint256 _ensId, uint256 _tokenId, IERC721 _nftContractAddress, string calldata _label) external;
    
    //remove a subdomain that is bound to a current NFT
    function removeSubdomain(uint256 _ensId, uint256 _tokenId, address _nftContractAddress) external;

    //output an addrChanged event for all subdomains linked to the NFT (this is for DAPP support, as some use graph events)
    function outputAddrChangedEvent(uint256 _tokenId, address _nftContractAddress) external;

    
}