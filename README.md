# NFT-Generic-ENS-Mapper

A custom controller and resolver that can be used to extend ERC-721 collections to bind ENS subdomains.

This custom controller contract is compatible with both ENS native token and the official ENS NameWrapper.


## How to set up

 1. Set Generic ENS Mapper contract as controller for a standard ENS token or add to approval addresses if you're using a wrapped ENS
 2. Run the `addEnsContractMapping` function with settings (see below)
 3. Eligible holders can run the `claimSubdomain` function and claim a subdomain that will dynamically link to an NFT


### Details

The `addEnsContractMapping` function is used to set up an ENS subdomain claim. It has 5 inputs:

**_domainArray**
		
		This is a string representation of the domain `bayc.eth` would be `['bayc', 'eth']`
		
**_ensHash**
		
		This is the bytes32 namehash of the ENS domain
		
**_nftContracts**
		
		This is an array of addresses of the contracts that can claim a subdomain. Each address should implement the IERC721 interface. There is a maximum of 5 addresses can be set up per ENS domain, this is to allow sub-collections to claim if wanted.
		
**_numericOnly**
		
		This will only allocate the numeric ID value to the subdomain and will not allow free text labels. If I have BAYC ID 4466 then my subdomain will be `4466.bayc.eth`. This can only be used if there is a single collection (see _nftContracts)
		
**_overWriteUnusedSubdomains**
		
		This will allow discarded subdomains to be reclaimed. If it is set to `false` then if a name is "burned" it cannot be reclaimed by this contract again
____
The `claimSubdomain` function is used by an eligible NFT holder to claim a subdomain. It has 4 inputs:


**_ensHash**
		
		This is the bytes32 namehash of the parent ENS domain
		
**_id**
		
		This is the ID of the NFT that is claiming the subdomain
		
**_nftContract**
		
		This is the address of the NFT that is claiming the subdomain
		
**_label**
		
		Select the label you want for your subdomain. Anything alpha-numeric (lower-case), there is no minimum character limit on subdomains so single characters are accepted. Advanced users can select other uni-code characters including emojis through the contract (at your own risk)





