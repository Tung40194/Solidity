/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
contract Voting {
    // candidate struct
     struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    mapping(address => bool) public voters;
    mapping(uint256 => Candidate) public candidates;
    uint256 public candidatesCount = 0;
    
    // voted event
    event votedEvent(uint256 indexed _candidateId);
    
    constructor() public {
        // hard code candidate list when deploy contract
        addCandidate("Hillary"); // ID 1
        addCandidate("Biden"); // ID 2
        addCandidate("Trump"); // ID 3
    }
    function didIVote() public view returns (bool){
        return voters[msg.sender];
    }
    
    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }
    
    function vote(uint256 _candidateId) public {
        // require that they haven't voted before
        require(!voters[msg.sender]);
        // require a valid candidate ID
        require(_candidateId > 0 && _candidateId <= candidatesCount);
        // mark that voter has voted
        voters[msg.sender] = true;
        // update candidate vote count
        candidates[_candidateId].voteCount++;
        // trigger vote event
        emit votedEvent(_candidateId);
    }
    
    function getCandidateName(uint8 _id) view  public returns( string memory ){
        return candidates[_id].name;
}}