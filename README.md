# Zyra AA Wallet - Smart Contracts

A full-featured Account Abstraction (AA) wallet project built with Foundry, following the EIP-4337 standard. This project is a modern, modular, and upgradeable smart contract system inspired by the Clave architecture, now rebranded as Zyra.

## 🏗️ Project Structure

```
Zyra-AA-Wallet/
└── smart-contracts/
    ├── src/                  # Solidity source code
    │   ├── auth/            # Authentication modules
    │   ├── interfaces/      # Contract interfaces
    │   ├── libraries/       # Utility libraries
    │   ├── managers/        # Management contracts
    │   ├── modules/         # Pluggable modules
    │   └── validators/      # Signature and logic validators
    ├── test/                # Unit tests
    ├── script/              # Deployment scripts
    ├── foundry.toml         # Foundry configuration
    ├── env.example          # Environment variable example
    └── README.md            # Project documentation
```

## 🚀 Features

- **EIP-4337 Compliant**: Full Account Abstraction support
- **Modular Architecture**: Pluggable modules, validators, and hooks
- **Gas Efficient**: Uses ERC-1167 minimal proxy pattern
- **Upgradeable**: Diamond storage pattern for safe upgrades
- **Session Keys**: Temporary authorization keys
- **Recovery Mechanisms**: Social and cloud-based recovery
- **Multi-chain Support**: Deployable on Ethereum, Avalanche, and more

## 🛠️ Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) (latest version)
- Node.js 16+ (for auxiliary tooling)

### Installation

1. Go to the smart contracts directory:

```bash
cd smart-contracts
```

2. Install Foundry dependencies:

```bash
forge install
```

3. Copy the environment file:

```bash
cp env.example .env
```

4. Edit `.env` with your own keys and RPC URLs.

## 🧪 Testing

```bash
# Run all tests
forge test

# Run a specific test
forge test --match-test testInitialization

# Gas report
forge test --gas-report
```

## 🚀 Deployment

```bash
# Deploy to Sepolia
forge script script/DeploySepolia.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# Deploy to Avalanche Fuji
forge script script/DeployFuji.s.sol --rpc-url $AVALANCHE_FUJI_RPC_URL --broadcast --verify
```

## 📋 Key Contracts

### ZyraImplementation

Main wallet implementation contract. Handles:

- Transaction execution
- EIP-4337 user operation validation
- ERC-1271 signature validation
- Hook execution
- Module management

### AccountFactory

Factory contract for creating new wallet instances using the ERC-1167 minimal proxy pattern for gas efficiency.

### ZyraRegistry

Registry contract for managing:

- Wallet deployments
- Implementation upgrades
- Account tracking

### EOAValidator

ECDSA signature validator for standard wallet signatures.

## 🔒 Security Features

- **Access Control**: Owner-based permissions
- **Session Keys**: Temporary authorization
- **Recovery Mechanisms**: Social and cloud recovery
- **Upgrade Safety**: Diamond storage pattern
- **Signature Validation**: Multiple validator types

## 📊 Gas Optimization

- **ERC-1167 Proxies**: Minimal proxy pattern for deployment
- **Diamond Storage**: Efficient storage layout
- **Batch Operations**: Gas-efficient batch transactions
- **Custom Errors**: Gas-efficient error handling

## 📞 Support

For questions and support:

- Open an issue on GitHub
- Check the documentation
- Review the test files for usage examples
