pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract YourContract {

  event TokenSent(address token, address receiver, uint bal);

  // record of split per address
  mapping(address => uint) public splits; // basis points

  mapping(address => uint) public ethClaimed;
  uint public totalEthClaimed = 0;

  mapping(address => mapping(address => uint)) public tokenClaimed; // erc20 -> address -> claimed amount
  mapping(address => uint) public totalTokenClaimed;

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
    return address(this).balance + totalEthClaimed;
  }

  function totalTokenReceived(address token) public view returns (uint) {
    return IERC20(token).balanceOf(address(this)) + totalTokenClaimed[token];
  }

  function ethToClaim(address receiver) external view returns (uint) {
    uint claim = totalEthReceived() * splits[receiver] / totalBasis;

    uint toSend = claim - ethClaimed[receiver];
    return toSend;
  }

  function tokenToClaim(address token, address receiver) external view returns (uint) {
    uint claim = totalTokenReceived(token) * splits[receiver] / totalBasis;

    uint toSend = claim - tokenClaimed[token][receiver];
    return toSend;
  }

  function redeemETH(address receiver) external {
    uint claim = totalEthReceived() * splits[receiver] / totalBasis;

    uint toSend = claim - ethClaimed[receiver];
    totalEthClaimed += toSend;
    ethClaimed[receiver] = claim;

    require(toSend > 0, "claimed");
    emit TokenSent(address(0), receiver, toSend);

    (bool success, ) = payable(receiver).call{value: toSend}("");
    require(success, "eth not sent");
  }

  function redeemToken(address token, address receiver) external {
    uint claim = totalTokenReceived(token) * splits[receiver] / totalBasis;

    uint toSend = claim - tokenClaimed[token][receiver];
    totalTokenClaimed[token] += toSend;
    tokenClaimed[token][receiver] = claim;

    require(toSend > 0, "claimed");
    emit TokenSent(token, receiver, toSend);

    // Interaction
    IERC20(token).transfer(receiver, toSend);
  }

  receive() external payable {}
}