pragma solidity ^0.4.24;

import "openzeppelin-zos/contracts/ownership/Ownable.sol";
import "openzeppelin-zos/contracts/math/SafeMath.sol";

contract Match is Ownable {
	using SafeMath for uint256;

	bool public ended;
	bool public started;
	uint256 public target; //Target number. Closest wins
	uint256 public entryPrice; //Price to play in wei
	uint256 public prize;
	address public currentWinner;
	uint256 public currentBestDistance;
	uint256 public numberOfSubmissions;

	function initialize(address game, uint256 _target, uint256 _entryPrice) isInitializer("Match", "0") public {
		Ownable.initialize(game);
		ended = false;
		started = false;
		target = _target;
		entryPrice = _entryPrice;
	}

	function startMatch() public onlyOwner {
		started = true;
	}

	function endMatch() public onlyOwner {
		ended = true;
	}

	function newSubmission(address player, uint256[] numbers, uint256[] operations) public onlyOwner {
		uint256 submittedSolution = numbers[0];

		uint256 numberOfOperations = operations.length;
  	for (uint i = 0; i < numberOfOperations; ++i) {
  		require(operations[i] < 2); //Operations must be 0: Add, 1: Sub

      if(operations[i] == 0) { //Add
      	submittedSolution = submittedSolution.add(numbers[i+1]);
      } else { //Sub
      	submittedSolution = submittedSolution.sub(numbers[i+1]);
      }
    }

    prize = prize.add(entryPrice);
    numberOfSubmissions = numberOfSubmissions.add(1);

    //Check if submission is closer than current best solution
    uint256 distance;

    if(submittedSolution >= target) {
    	distance = submittedSolution.sub(target);
    } else {
    	distance = target.sub(submittedSolution);
    }
    
    if(numberOfSubmissions == 1 || distance < currentBestDistance) {
    	currentBestDistance = distance;
    	currentWinner = player;
    }
	}

}