import { ethers, network } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import hre from "hardhat";
import { BigNumber } from "ethers";

async function main() {
  const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const DAIHolder = "0x748dE14197922c4Ae258c7939C7739f3ff1db573";
  // const [owner, holder1, holder2, holder3] = await ethers.getSigners();

  //deploy reward token
  const Token = await ethers.getContractFactory("CVIII");
  const token = await Token.deploy("web3Bridge", "VIII");
  await token.deployed();

  const tokenaddress = token.address;

  console.log(`Reward Token deployed to ${tokenaddress}`);

  ///deploy Staking contract

  const Staking = await ethers.getContractFactory("StakERC20");
  const staking = await Staking.deploy(tokenaddress);
  await staking.deployed();
  console.log(`Staking contract deployed to ${staking.address}`);

  /// connect dai
  const dai = await ethers.getContractAt("IDAI", DAI);

  const daiAdress = dai.address;
  console.log(`staking Token deployed to ${daiAdress}`);

  const balance = await dai.balanceOf(DAIHolder);
  console.log(`balnce is ${balance}`);

  const helpers = require("@nomicfoundation/hardhat-network-helpers");

  const address = DAIHolder;
  await helpers.impersonateAccount(address);
  const impersonatedSigner = await ethers.getSigner(address);

  const tokenSet = await staking.setStakeToken(daiAdress);
  //   console.log(await tokenSet.wait());
  console.log(`staked Token  ${await staking.stakeToken()}`);

  const stakeDai = await ethers.utils.parseEther("50");

  await dai.connect(impersonatedSigner).approve(staking.address, stakeDai);

  const allowance = await dai.allowance(DAIHolder, staking.address);
  // console.log(`allowance ${allowance.wait()}`);

  const staker1 = await staking.connect(impersonatedSigner).stake(stakeDai);
  const userInfo1 = await staking.userInfo(impersonatedSigner.address);
  console.log(`holder1 infornation ${userInfo1}`);

  await ethers.provider.send("evm_mine", [1708037999]);

  await staking.connect(impersonatedSigner).updateReward();

  const userInfo = await staking.userInfo(impersonatedSigner.address);
  console.log(`holder1 infornation ${userInfo}`);
  let a = BigNumber.from("10000000000000000000");
  // let b = BigNumber.from("10000000000000000000");

  await token.transfer(staking.address, a);

  await staking.connect(impersonatedSigner).claimReward(a);

  const userInfoAfter = await staking.userInfo(impersonatedSigner.address);
  console.log(`holder1 infornation ${userInfoAfter}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});