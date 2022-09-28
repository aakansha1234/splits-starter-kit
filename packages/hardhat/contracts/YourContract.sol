pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract YourContract {

  event TokenSent(address token, address receiver, uint bal);

  // record of split per address
  mapping(address => uint) public splits; // basis points

  mapping(address => uint) public ethClaimed;
  uint public totalEthReceivedTillLastClaim = 0;
  uint public ethBalanceAfterLastClaim = 0;

  mapping(address => mapping(address => uint)) public tokenClaimed; // erc20 -> address -> claimed amount
  mapping(address => uint) public totalTokenReceivedTillLastClaim;
  mapping(address => uint) public tokenBalanceAfterLastClaim;

  uint constant totalBasis = 10_000;

  constructor(address[] memory _addr, uint[] memory _split) {
    require(_addr.length == _split.length, "!equal");
    uint total = 0;
    for (uint i=0; i < _addr.length; ++i) {
      total += _split[i];
      splits[_addr[i]] = _split[i];
    }
    require(total == totalBasis, "total!=10K");
  }

  function totalEthReceived() public view returns (uint) {
    return totalEthReceivedTillLastClaim + address(this).balance - ethBalanceAfterLastClaim;
  }

  function totalTokenReceived(address token) public view returns (uint) {
    return totalTokenReceivedTillLastClaim[token] + IERC20(token).balanceOf(address(this)) - tokenBalanceAfterLastClaim[token];
  }

  function ethToClaim(address receiver) external view returns (uint) {
    uint redeemed = ethClaimed[receiver];
    uint claim = totalEthReceived() * splits[receiver] / totalBasis;

    uint toSend = claim - redeemed;
    return toSend;
  }

  function tokenToClaim(address token, address receiver) external view returns (uint) {
    uint claimed = tokenClaimed[token][receiver];
    uint claim = totalTokenReceived(token) * splits[receiver] / totalBasis;

    uint toSend = claim - claimed;
    return toSend;
  }

  function redeemETH(address receiver) external {
    if (address(this).balance > ethBalanceAfterLastClaim) {
      totalEthReceivedTillLastClaim = totalEthReceived();
    }

    uint claimed = ethClaimed[receiver];
    uint claim = totalEthReceivedTillLastClaim * splits[receiver] / totalBasis;
    ethClaimed[receiver] = claim;

    uint toSend = claim - claimed;

    require(toSend > 0, "claimed");
    emit TokenSent(address(0), receiver, toSend);

    ethBalanceAfterLastClaim = address(this).balance - toSend;
    (bool success, ) = payable(receiver).call{value: toSend}("");
    require(success, "eth not sent");
  }

  function redeemToken(address token, address receiver) external {
    if (IERC20(token).balanceOf(address(this)) > tokenBalanceAfterLastClaim[token]) {
      totalTokenReceivedTillLastClaim[token] = totalTokenReceived(token);
    }

    uint claimed = tokenClaimed[token][receiver];
    uint claim = totalTokenReceivedTillLastClaim[token] * splits[receiver] / totalBasis;
    tokenClaimed[token][receiver] = claim;

    uint toSend = claim - claimed;

    require(toSend > 0, "claimed");
    emit TokenSent(token, receiver, toSend);

    tokenBalanceAfterLastClaim[token] = IERC20(token).balanceOf(address(this)) - toSend;

    IERC20(token).transfer(receiver, toSend);
  }

  receive() external payable {}
}
