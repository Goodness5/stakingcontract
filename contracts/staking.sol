// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//users stake usdt
//user get 20% APY CVIII as reward;
// tken ratio 1: 1

contract StakERC20 is Ownable {
    IERC20 public rewardToken;
    IERC20 public stakeToken;

    uint256 constant SECONDS_PER_YEAR = 31536000;

    struct User {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 rewardAccrued;
    }

    mapping(address => User) user;
    error tryAgain();

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    function setStakeToken(address _token)
        external
        onlyOwner
        returns (address _newToken)
    {
        require(IERC20(_token) != stakeToken, "Token already set");
        require(IERC20(_token) != rewardToken, "canot stake reward");

        require(_token != address(0), "cannot set address zero");

        stakeToken = IERC20(_token);
        _newToken = address(stakeToken);
    }

    function stake(uint256 amount) external {
        User storage _user = user[msg.sender];
        uint256 _amount = _user.stakedAmount;

        stakeToken.transferFrom(msg.sender, address(this), amount);

        if (_amount == 0) {
            _user.stakedAmount = amount;
            _user.startTime = block.timestamp;
        } else {
            updateReward();
            _user.stakedAmount += amount;
        }
    }

    function calcReward() public view returns (uint256 _reward) {
        User storage _user = user[msg.sender];

        uint256 _amount = _user.stakedAmount;
        uint256 _startTime = _user.startTime;
        uint256 duration = block.timestamp - _startTime;

        _reward = (duration * 20 * _amount) / (SECONDS_PER_YEAR * 100);
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
        stakeToken.transfer(msg.sender, amount);
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