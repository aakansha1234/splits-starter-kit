# 🏗 Splits prototype

Deploy a contract with pre-determind split among a group of addresses. Any ETH or ERC20 token sent to the contract will now be available for the recipient addresses to claim in the correct ratio according to the split.

Due to the complexity that a erc20 token receiver doesn't know when it receives tokens, this is a little more challenging than you might think!

# 🏄‍♂️ Quick Start

Prerequisites: [Node (v16 LTS)](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> clone/fork 🏗 scaffold-eth:

```bash
git clone https://github.com/aakansha1234/splits-starter-kit.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd splits-starter-kit
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd splits-starter-kit
yarn start
```

> open 3 separate windows with different wallet addresses (use incognito and different browsers to get different addresses).

> Go to `00_deploy_your_contract.js` and use those 3 addresses to replace in `YourContract` args.

> in a third terminal window, 🛰 deploy your contract:

```bash
cd splits-starter-kit
yarn deploy
```

🔏 Edit your smart contract `YourContract.sol` in `packages/hardhat/contracts`

📝 Edit your frontend `App.jsx` in `packages/react-app/src`

💼 Edit your deployment scripts in `packages/hardhat/deploy`

📱 Open http://localhost:3000 to see the app

# 🚶‍♂️ Demo walkthrough

- Send `YourContract` a balance of 1 ether from local faucet.
- Also send ether from faucet to the address in each window.
- Play with SplitsUI, and interchange between sending ether to `YourContract` and claiming ETH.
- Notice how the correct claim amount is calculated.