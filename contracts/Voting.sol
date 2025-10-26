// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract VoteICC {

  struct Candidate {
    uint candid;
    uint votes;
  }

  Candidate[] internal total_Candidates;
  mapping(address => bool) public hasVoted;
  bool public election_state_open = true;
  address public owner;
  uint public endTime;

  event Voted(address indexed voter, uint indexed candid);
  event ElectionClosed();

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this");
    _;
  }

  modifier electionOpen() {
    require(election_state_open, "Voting is closed");
    require(block.timestamp < endTime, "Election time ended");
    _;
  }

  constructor(uint[] memory ids, uint durationSeconds) {
    owner = msg.sender;
    endTime = block.timestamp + durationSeconds;
    for (uint i = 0; i < ids.length; i++) {
      total_Candidates.push(Candidate(ids[i], 0));
    }
  }

  function vote(uint id) public electionOpen {
    require(!hasVoted[msg.sender], "Already voted");
    bool found = false;
    for (uint i = 0; i < total_Candidates.length; i++) {
      if (total_Candidates[i].candid == id) {
        total_Candidates[i].votes++;
        found = true;
        emit Voted(msg.sender, id);
        break;
      }
    }
    require(found, "Candidate does not exist");
    hasVoted[msg.sender] = true;
  }

  function closeElection() public onlyOwner {
    election_state_open = false;
    emit ElectionClosed();
  }

  function get_State() public view returns (uint[] memory votes, uint[] memory candids) {
    uint len = total_Candidates.length;
    votes = new uint[](len);
    candids = new uint[](len);

    for (uint x = 0; x < len; x++) {
      votes[x] = total_Candidates[x].votes;
      candids[x] = total_Candidates[x].candid;
    }

    return (votes, candids);
  }

  function getWinner() public view returns (uint winnerId, uint winnerVotes) {
    require(!election_state_open || block.timestamp >= endTime, "Election not finished");
    uint maxVotes = 0;
    uint winner = 0;
    for (uint i = 0; i < total_Candidates.length; i++) {
      if (total_Candidates[i].votes > maxVotes) {
        maxVotes = total_Candidates[i].votes;
        winner = total_Candidates[i].candid;
      }
    }
    return (winner, maxVotes);
  }
}
