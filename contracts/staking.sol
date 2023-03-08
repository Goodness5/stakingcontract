// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//users stake stakableTokens
//user get 20% APY CVIII as reward;
// token ratio 1: 1

contract StakERC20 is Ownable {
    IERC20 public rewardToken;
    IERC20[] public stakableTokens;
    IERC20 public SpecialToken;

    uint256 constant SECONDS_PER_YEAR = 31536000;

    struct User {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 rewardAccrued;
        IERC20 stakeToken;
    }

    mapping(address => User) user;
    error tryAgain();

    constructor(address _rewardToken, address _undead) {
        rewardToken = IERC20(_rewardToken);
        SpecialToken = IERC20(_undead);
    }

// function setStakeToken(address _token)
//     external
//     returns (address _newToken)
// {
//     require(isStakable(_token) == false, "token already stakable");
//     require(IERC20(_token) != rewardToken, "cannot stake reward");
//     require(_token != address(0), "cannot set address zero");

//     _newToken = address(IERC20(_token));
//     stakableTokens.push(IERC20(_token));

//     // Update the stakeToken for each user who has staked the token
//     for (uint256 i = 0; i < stakableTokens.length; i++) {
//         if (address(stakableTokens[i]) == _token) {
//             User storage _user = user[msg.sender];
//             _user.stakeToken = IERC20(_token);
//         }
//     }
// }



    function stake(address token, uint256 amount) external {
        User storage _user = user[msg.sender];
        require(token != address(0), "address zero unstakabble");
        require(token != address(rewardToken), "cannot stake reward");
        require(isStakable(token), "token not stakable");

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (_user.stakedAmount == 0) {
            _user.stakeToken = IERC20(token);
            _user.stakedAmount = amount;
            _user.startTime = block.timestamp;
        } else {
            require(token == address(_user.stakeToken), "user already staked a different token");
            updateReward();
            _user.stakedAmount += amount;
        }
    }

    function isStakable(address token) internal view returns (bool) {
        for (uint256 i = 0; i < stakableTokens.length; i++) {
            if (address(stakableTokens[i]) == token) {
                return true;
            }
        }
        return false;
    }

    function addStakableToken(address token) external onlyOwner {
        require(!isStakable(token), "Token already stakable");
        require(token != address(0), "cannot add address zero");
        require(token != address(rewardToken), "cannot stake reward");

        stakableTokens.push(IERC20(token));
    }

 function removeStakableToken(address token) external onlyOwner {
    require(isStakable(token), "Token not stakable");
    for (uint256 i = 0; i < stakableTokens.length; i++) {
        if (address(stakableTokens[i]) == token) {
            if (i != stakableTokens.length - 1) {
                stakableTokens[i] = stakableTokens[stakableTokens.length - 1];
            }
            stakableTokens.pop();
            return;
        }
    }
}



    function calcReward() public view returns (uint256 _reward) {
        User storage _user = user[msg.sender];
        uint256 _amount = _user.stakedAmount;
        uint256 _startTime = _user.startTime;
        uint256 duration = block.timestamp - _startTime;

            if (_user.stakeToken == SpecialToken) {
                _reward = ((20 * _amount) / 100);
            }
            else{
                _reward = (duration * 20 * _amount) / (SECONDS_PER_YEAR * 100);
            }
    }

    function claimReward(uint256 amount) public {
        User storage _user = user[msg.sender];
        updateReward();
        uint256 _claimableReward = _user.rewardAccrued;
        require(_claimableReward >= amount, "insufficient funds");
        _user.rewardAccrued -= amount;
        if (amount > rewardToken.balanceOf(address(this))) revert tryAgain();
        rewardToken.transfer(msg.sender, amount);
    }

    function updateReward() public {
        User storage _user = user[msg.sender];
        uint256 _reward = calcReward();
        _user.rewardAccrued += _reward;
        _user.startTime = block.timestamp;
    }

function withdrawStaked(uint256 amount) public {
    User storage _user = user[msg.sender];
    uint256 staked = _user.stakedAmount;
    require(staked >= amount, "insufficient fund");
    updateReward();
    _user.stakedAmount -= amount;
    require(_user.stakeToken.transfer(msg.sender, amount), "transfer failed");
}



    function closeAccount() external {
        User storage _user = user[msg.sender];
        uint256 staked = _user.stakedAmount;
        withdrawStaked(staked);
        uint256 reward = _user.rewardAccrued;
        claimReward(reward);
    }

    function userInfo(address _user) external view returns (User memory) {
        return user[_user];
    }
}