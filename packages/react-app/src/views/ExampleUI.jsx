import { Button, Card, DatePicker, Divider, Input, Progress, Slider, Spin, Switch } from "antd";
import React, { useState } from "react";
import { utils } from "ethers";
import { SyncOutlined } from "@ant-design/icons";
import { useBalance } from "eth-hooks";

import { Address, Balance, Events } from "../components";

export default function ExampleUI({
  purpose,
  address,
  mainnetProvider,
  localProvider,
  yourLocalBalance,
  price,
  tx,
  readContracts,
  writeContracts,
}) {
  const [ethToClaim, setEthToClaim] = useState();
  const [ethClaimed, setEthClaimed] = useState();
  const [ratio, setRatio] = useState();
  const [ethReceived, setEthReceived] = useState();

  let splitAddress = readContracts && readContracts.YourContract ? readContracts.YourContract.address : "...";

  return (
    <div>
      {/*
        ⚙️ Here is an example UI that displays and sets the purpose in your smart contract:
      */}
      <div style={{ border: "1px solid #cccccc", padding: 16, width: 400, margin: "auto", marginTop: 64 }}>
        <h2>Individual info:</h2>
        <Button onClick={async () => setRatio(await readContracts.YourContract.splits(address))}>Split ratio:</Button>
        {parseInt(ratio) / 10_000}
        <br />
        <Button
          onClick={async () => setEthClaimed(utils.formatEther(await readContracts.YourContract.ethClaimed(address)))}
        >
          ETH claimed:
        </Button>
        {ethClaimed}
        <br />
        <Button
          onClick={async () => setEthToClaim(utils.formatEther(await readContracts.YourContract.ethToClaim(address)))}
        >
          ETH to claim:
        </Button>
        {ethToClaim}
        <Divider />
        <Button
          onClick={() => {
            tx(writeContracts.YourContract.redeemETH(address));
          }}
        >
          Claim ETH
        </Button>
        <Divider />
        <h2>Split info:</h2>
        Split Address:
        <Address
          address={readContracts && readContracts.YourContract ? readContracts.YourContract.address : null}
          ensProvider={mainnetProvider}
          fontSize={16}
        />
        <Button
          onClick={async () => setEthReceived(utils.formatEther(await readContracts.YourContract.totalEthReceived()))}
        >
          Total ETH ever received:
        </Button>
        {ethReceived}
        <br />
        <h2>Split Bal: {utils.formatEther(useBalance(localProvider, splitAddress))}</h2>
      </div>

      {/*
        📑 Maybe display a list of events?
          (uncomment the event and emit line in YourContract.sol! )
      */}
      <Events
        contracts={readContracts}
        contractName="YourContract"
        eventName="ETHSent"
        localProvider={localProvider}
        mainnetProvider={mainnetProvider}
        startBlock={1}
      />
    </div>
  );
}
