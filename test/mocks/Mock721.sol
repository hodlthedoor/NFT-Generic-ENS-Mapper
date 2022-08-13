// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;


import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";


contract Mock721 is ERC721 {

    constructor()ERC721("TEST", "TEST"){

    }

    function mintTokenById(address _addr, uint256 _id) public {
        _mint(_addr, _id);
    }
}