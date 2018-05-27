pragma solidity ^0.4.24;

import "zos-lib/contracts/migrations/Migratable.sol";
import "openzeppelin-zos/contracts/token/ERC721/MintableERC721Token.sol";
import "openzeppelin-zos/contracts/ownership/Ownable.sol";
import "openzeppelin-zos/contracts/math/SafeMath.sol";
import "./Match.sol";

contract Numbers is Migratable, Ownable {
  using SafeMath for uint256;

  MintableERC721Token public token;
  uint256 public numEmittedTokens;
  uint256 public numberPrice; //Numbers price in wei
  Match public numbersMatch;

  event MatchStarted(Match numbersMatch);
  event MatchEnded(Match numbersMatch, address winner);

  function initialize(address owner) isInitializer("Numbers", "0") public {
  	Ownable.initialize(owner);
  	numberPrice = 1000000000000000;
  }

  function setToken(MintableERC721Token _token) external onlyOwner {
    require(_token != address(0));
    require(token == address(0));
    token = _token;
  }

  //Token administration

  function buyNumber(uint256 number) public payable {
  	require(numbersMatch.ended() || !numbersMatch.started()); //No buying during matches
  	require(msg.value >= numberPrice);
  	require(!token.exists(number));

  	emitToken(tx.origin, number);

  	//Emit buying event
  }

  function emitToken(address _tokenOwner, uint256 number) internal {
  	uint256 tokenId = number;

    token.mint(_tokenOwner, tokenId);
    numEmittedTokens = numEmittedTokens.add(1);

    //Set token uri
    //string numberUri = "https://en.wikipedia.org/wiki/%E2%88%921";
  }

  //Match lifecycle

	function setMatch(Match _match) external onlyOwner {
    require(_match != address(0));
    numbersMatch = _match;
  }

  function startMatch() public onlyOwner {
  	require(!numbersMatch.started());
  	require(!numbersMatch.ended());

  	numbersMatch.startMatch();

  	emit MatchStarted(numbersMatch);
  }

  function endMatch() public onlyOwner {
  	require(numbersMatch.started());
  	require(!numbersMatch.ended());

  	numbersMatch.endMatch();

  	address winner = numbersMatch.currentWinner();
  	uint256 prize = numbersMatch.prize();

  	if(winner != address(0) && prize > 0) {
  		winner.transfer(prize);
  	}

  	emit MatchEnded(numbersMatch, winner);
  }

  function play(uint256[] numbers, uint256[] operations) public payable {
  	require(numbersMatch.started() && !numbersMatch.ended());
  	require(msg.value >= numbersMatch.entryPrice()); //Must pay the entry price

  	address player = msg.sender;
  	uint256 balance = token.balanceOf(player);
  	uint256 numberOfNumbers = numbers.length;
  	uint256 numberOfOperations = operations.length;

  	require(balance > 0); //Must own at least one number
  	require(numberOfNumbers == balance); //Must use all their numbers
		require(numberOfNumbers == numberOfOperations.add(1)); //Must provide exactly (numbers - 1) operations
  	
  	for (uint i = 0; i < numberOfNumbers; ++i) {
      require(token.ownerOf(numbers[i]) == player); //Must own the numbers
    }

    numbersMatch.newSubmission(player, numbers, operations);
	}

}