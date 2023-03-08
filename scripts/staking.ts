import { ethers, network } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";

async function main() {
  const [owner, holder1, holder2, holder3] = await ethers.getSigners();
  //deploy reward token
  const Token = await ethers.getContractFactory("Superman");
  const token = await Token.deploy("Superman", "SGK");
  await token.deployed();

  const tokenaddress = token.address;

  console.log(`Reward Token deployed to ${tokenaddress}`);

  ///deploy Staking contract

  const Staking = await ethers.getContractFactory("StakERC20");
  const staking = await Staking.deploy(tokenaddress);
  await staking.deployed();
  console.log(`Staking contract deployed to ${staking.address}`);

  // stakeToken

  const USDT = await ethers.getContractFactory("Undead");
  const usdt = await USDT.deploy();
  await usdt.deployed();

  const usdtAdress = usdt.address;
  console.log(`staking Token deployed to ${usdtAdress}`);

  const tokenSet = await staking.setStakeToken(usdtAdress);
  //   console.log(await tokenSet.wait());
  console.log(`staked Token  ${await staking.stakeToken()}`);

  // const staker1Minting = await usdt.connect(holder1).mint(100);
  // await usdt.connect(holder1).approve(staking.address, 100000000);

  // const staker1 = await staking.connect(holder1).stake(50000000);
  // const userInfo1 = await staking.userInfo(holder1.address);
  // console.log(`holder1 infornation ${userInfo1}`);

  await ethers.provider.send("evm_mine", [1708037999]);

  await staking.connect(holder1).updateReward();

  const userInfo = await staking.userInfo(holder1.address);
  console.log(`holder1 infornation ${userInfo}`);

  await token.transfer(staking.address, 100000000);

  await staking.connect(holder1).claimReward(10000000);

  const userInfoAfter = await staking.userInfo(holder1.address);
  console.log(`holder1 infornation ${userInfoAfter}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

//18 772 231

// 18 772 216

//  10 005 054