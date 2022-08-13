// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IMapper.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract GenericEnsMapper {


    function addEnsContractMapping(uint256 _ensId, IERC721[] calldata _address, bool _numericOnly, bool _overWriteUnusedSubdomains) external{
        require(false, "not implemented");
    }  


}
