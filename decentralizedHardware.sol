pragma solidity ^0.4.0;
contract decentralizedMining{
	struct miner {
		uint deadline;
		uint highestPrice;
		address highestMiner;
		uint priceHash;
		address recipient;
		address thirdParty;
		uint thirdPartyFee;
		uint deliveryDeadline;
	}
	mapping(uint => miner) miners;
	uint numMiners;

	function startPurchase(uint timeLimit, address thirdParty, uint thirdPartyFee, uint deliveryDeadline) returns (uint minerID){
		uint ID = numMiners++;
		miner a = miners[ID];
		a.deadline = block.number + timeLimit;
		a.recipient = msg.sender;
		a.thirdParty = thirdParty;
		a.thirdPartyFee = thirdPartyFee;
		a.deliveryDeadline = block.number + timeLimit + deliveryDeadline;
	}
	function Price(uint id, uint minersHash) returns (address highestMiner){
		miner a = miners[id];
		if (a.highestMiner + 1*10^18 > msg.value || a.deadline > block.number) {
			msg.sender.send(msg.value);
			return a.highestMiner;
		}
		a.highestMiner.send(a.highestPrice);
		a.highestMiner = msg.sender;
		a.highestPrice = msg.value;
		a.priceHash  = minersHash;
		return msg.sender;
	}
	function endPurchase(uint id, uint key) returns (address highestMiner){
		miner a = miners[id];
		if (block.number >= a.deadline && sha3(key) == a.priceHash) {
			a.recipient.send(a.highestPrice-a.thirdPartyFee);
			a.thirdParty.send(a.thirdPartyFee);
			clean(id);
		}
	}
	function notDelivered(uint id) {
		miner a = miners[id];
		if (block.number >= a.deliveryDeadline && msg.sender == a.highestMiner){
			a.highestMiner.send(a.highestPrice);
			clean(id);
		}
	}
	function clean(uint id) private{
		miner a = miners[id];
		a.highestPrice = 0;
		a.highestMiner =0;
		a.deadline = 0;
		a.deliveryDeadline = 0;
		a.recipient = 0;
		a.priceHash = 0;
		a.thirdPartyFee = 0;
		a.thirdParty = 0;
	}
}