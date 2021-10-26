pragma solidity ^0.5.12;

// TODO: import erC20? Or import special DADA modified ERC-20 possible?
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

/** 
 * Utilities library
 */
library Utilities {
	// concat two bytes objects
    function concat(bytes memory a, bytes memory b)
            internal pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }

    // convert address to bytes
    function toBytes(address x) internal pure returns (bytes memory b) { 
		b = new bytes(20); 
	
		for (uint i = 0; i < 20; i++) 
			b[i] = byte(uint8(uint(x) / (2**(8*(19 - i))))); 
	}

	// convert uint256 to bytes
	function toBytes(uint256 x) internal pure returns (bytes memory b) {
    	b = new bytes(32);
    	assembly { mstore(add(b, 32), x) }
	}
}

/*
 * @title Contract that allows an owner of a Creep to scribe a message attached to the token.
 * There's no limit on the number of messages they can scribe or the length for a single message
 * Each message is an on-chain transaction requiring gas
 * @dev Conlan Rios
 * Modified by sparrow
 */
contract Scribe {
	// A record event that emits each time an owner dictates a message
	event Record (
		// the address of who dicated this document
		address dictator,
		// The Creeps contract address
        address 0x068696a3cf3c4676b65f1c9975dd094260109d02,
        // The Creep printIndex
	uint printIndex,
        // The text of the dictation
        string text
    );

	// A recorded document which tracks the dictator, the text, and the timestamp of when it was created
	struct Document {
		// the address of who dicated this document
		address dictator;
		// the text of the dictation
		string text;
		// the block time of the dictation
		uint creationTime;
	}

	// Mapping of document keys to documents (keys are concated token address + tokenId)
	mapping (bytes => Document[]) public documents;
	
	// Mapping of document keys to the count of dictated documents
	mapping (bytes => uint) public documentsCount;

	// Function for dictating an owner message
	function dictate(uint256 printIndex, string memory _text) public {
		// check that the message sender owns the token 
		// the function in DadaCollectible.sol that returns the owner address given a unique printIndex
		// is DrawingPrintToAddress
		require(DrawingPrintToAddress(_printIndex) == msg.sender, "Sender not authorized to dictate.");
		// get the document key for this address and token id
		bytes memory documentKey = getDocumentKey(_printIndex);
		// push a new document with the dictator address, message, and timestamp
		documents[documentKey].push(Document(msg.sender, _text, block.timestamp));
		// increase the documents counter for this key
		documentsCount[documentKey]++;
		// emit an event for this newly created record
		emit Record(msg.sender, _printIndex, _text);
	}

	// Function for getting the document key for a given Creep address + drawingId + printIndex
	function getDocumentKey( _printIndex) public pure returns (bytes memory) {
	        //each modified ERC-20 token can be uniquely addressed by printIndex
		return Utilities.concat(Utilities.toBytes(_tokenAddress), Utilities.toBytes(_printIndex));
	}
}
