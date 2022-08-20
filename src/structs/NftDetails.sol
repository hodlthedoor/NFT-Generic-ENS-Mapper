// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct NftDetails {
    bytes32 ParentNamehash;
    string Label;
    IERC721 NftAddress;
    uint96 NftId; //doing this for memory space.. unlikely we get id more than this.
}
