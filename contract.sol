// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ResearchRewards {

    // ERC20 token interface to interact with the reward token (e.g., DAI, USDT, or custom ERC20)
    IERC20 public rewardToken;

    // Struct to hold information about each research paper submission
    struct ResearchPaper {
        address author;
        string paperTitle;
        uint256 rewardAmount;
        bool isReviewed;
        bool isApproved;
    }

    // Mapping of research papers by ID
    mapping(uint256 => ResearchPaper) public researchPapers;
    uint256 public paperCount = 0; // Counter for the research papers

    // Event to notify when a paper is submitted
    event ResearchPaperSubmitted(uint256 paperId, address author, string paperTitle);
    // Event to notify when a paper is reviewed and approved
    event ResearchPaperReviewed(uint256 paperId, bool isApproved, uint256 rewardAmount);
    // Event to notify when a reward is issued
    event RewardIssued(uint256 paperId, address author, uint256 rewardAmount);

    // Constructor to set the reward token (could be USDT, DAI, or custom token)
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to submit a new research paper
    function submitResearchPaper(string memory _paperTitle) public {
        paperCount++;
        researchPapers[paperCount] = ResearchPaper({
            author: msg.sender,
            paperTitle: _paperTitle,
            rewardAmount: 0,
            isReviewed: false,
            isApproved: false
        });
        emit ResearchPaperSubmitted(paperCount, msg.sender, _paperTitle);
    }

    // Function for reviewers to review and approve/reject a paper
    function reviewResearchPaper(uint256 _paperId, bool _isApproved, uint256 _rewardAmount) public {
        require(_paperId > 0 && _paperId <= paperCount, "Invalid paper ID");
        ResearchPaper storage paper = researchPapers[_paperId];
        require(!paper.isReviewed, "Paper already reviewed");

        // Mark the paper as reviewed
        paper.isReviewed = true;
        paper.isApproved = _isApproved;
        paper.rewardAmount = _rewardAmount;

        // Emit the event to notify that the paper has been reviewed
        emit ResearchPaperReviewed(_paperId, _isApproved, _rewardAmount);

        // If the paper is approved, issue the reward
        if (_isApproved) {
            require(rewardToken.balanceOf(address(this)) >= _rewardAmount, "Insufficient reward tokens in contract");
            rewardToken.transfer(paper.author, _rewardAmount); // Transfer the reward tokens to the author
            emit RewardIssued(_paperId, paper.author, _rewardAmount);
        }
    }

    // Function to allow contract owner to deposit reward tokens into the contract
    function depositRewardTokens(uint256 _amount) public {
        rewardToken.transferFrom(msg.sender, address(this), _amount);
    }

    // Function to check the remaining balance of the reward tokens in the contract
    function remainingRewardTokens() public view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }
}
 