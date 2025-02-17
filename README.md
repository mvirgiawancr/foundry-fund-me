# Foundry Fund Me

This is the Foundry Fund Me project based on the Cyfrin Solidity Course, but modified and uploaded to my own repository.

## 📌 Features

- Deploy smart contracts using Foundry
- Test contracts with various levels (Unit, Forked, etc.)
- Estimate gas usage and verify contracts on Etherscan

## 🚀 Getting Started

### 1. Install Requirements

Make sure you have installed:

- [Git](https://git-scm.com/)
- [Foundry](https://getfoundry.sh/)

### 2. Clone the Repository

```sh
git clone https://github.com/mvirgiawancr/fund-meg.git
cd repo-name
make
```

### 3. Configure Environment Variables

Create a `.env` file based on `.env.example`, then add:

```sh
SEPOLIA_RPC_URL=<your_rpc_url>
PRIVATE_KEY=<your_private_key>
ETHERSCAN_API_KEY=<your_etherscan_api_key>
```

## 🔧 Usage

### 1. Deploy Smart Contract

```sh
forge script script/DeployFundMe.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### 2. Test Contracts

```sh
forge test
```

Or for forked testing:

```sh
forge test --fork-url $SEPOLIA_RPC_URL
```

### 3. Estimate Gas Usage

```sh
forge snapshot
```

## 📜 License

This project is created for learning purposes and is free to use for further development.

## 💙 Thank You!

If you like this project, don't forget to ⭐ the repository on GitHub!

---

**Made with 💖 by Virgi**
