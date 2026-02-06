
# AIUSD – Open Mint ERC20 Token on Base

**AIUSD** is a simple, fully permissionless ERC20 token deployed on **Base Mainnet** (and optionally Base Sepolia testnet).

**Key characteristic**: **Anyone can mint unlimited tokens at any time** — there is no supply cap, no minter role, and no restrictions.

→ This makes it extremely experimental / meme / test-oriented.  
→ **Not suitable** for serious value storage, stablecoin use, or any financial purpose — supply can (and likely will) inflate to infinity very quickly.

## 🚨 Important Warnings

- **Unlimited minting**: Any address can call `mint(address to, uint256 amount)` without permission.
- **No supply cap** — total supply starts at whatever you premint (default: 0) and can grow forever.
- **Pausable** — Deployer (admin) can pause transfers/minting/burning in emergencies.
- **Burnable** — Holders can burn their own tokens.
- **Use at your own risk** — This token has **no economic guarantees** and can become worthless instantly.
- **Audit status**: None — deployed as-is for learning/experimentation.

## Token Info (Mainnet)

- **Network**: Base Mainnet (Chain ID: 8453)
- **Contract Address**: `0x4d1136234F488068d905ba0a4885dA1E04EaB1a3`
- **Explorer**: [https://basescan.org/address/0x4d1136234f488068d905ba0a4885da1e04eab1a3](https://basescan.org/address/0x4d1136234f488068d905ba0a4885da1e04eab1a3)
- **Token Name / Symbol**: AIUSD / AIUSD
- **Decimals**: 18
- **Initial Supply**: 0 (no premint)
- **Deployer / Admin / Pauser**: `0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38`
- **Verification**: Source code verified on Basescan
- **Features**: Open minting, pausable, burnable, role-based admin (only for pause/unpause)

## Features

Built with **OpenZeppelin v5**:

- `ERC20` – standard token
- `ERC20Burnable` – anyone can burn their tokens
- `ERC20Pausable` – admin can pause all token operations
- `AccessControl` – deployer has `DEFAULT_ADMIN_ROLE` & `PAUSER_ROLE`
- `mint(address to, uint256 amount)` – **public, unrestricted**
- No mint cap, no blacklist, no taxes, no fees

Solidity version: `^0.8.20`

## Project Structure

```
AIUSD/
├── src/
│   └── AIUSD.sol               # The contract
├── script/
│   └── DeployAIUSD.s.sol       # Foundry deployment script
├── test/                       # (add your tests here if you want)
├── foundry.toml
├── .env.example
└── README.md
```

## Prerequisites

- [Foundry](https://getfoundry.sh/) installed
- Base RPC endpoints (Mainnet & Sepolia)
- Basescan API key (for verification)
- Wallet private key with ETH on Base

## Environment Variables (.env)

Create `.env` from `.env.example`:

```bash
PRIVATE_KEY=0xYourPrivateKeyHere
BASE_MAINNET_RPC_URL=https://mainnet.base.org
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=YourBaseScanApiKeyHere
# Optional:
# INITIAL_SUPPLY=1000000000000000000000000   # e.g. 1_000_000 tokens
```

## Deployment

### 1. Base Mainnet (already deployed)

```bash
source .env

forge script script/DeployAIUSD.s.sol:DeployAIUSD \
  --rpc-url $BASE_MAINNET_RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY \
  --chain-id 8453 \
  -vvvv
```

Deployed address: **`0x4d1136234F488068d905ba0a4885dA1E04EaB1a3`**

### 2. Base Sepolia (Testnet)

```bash
forge script script/DeployAIUSD.s.sol:DeployAIUSD \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY \
  --chain-id 84532 \
  -vvvv
```

(Get testnet ETH from faucets like https://www.base.org/faucets)

### 3. Deploy with premint (example: 1,000 tokens)

```bash
export INITIAL_SUPPLY=1000000000000000000000

forge script ...   # rest of command
```

## Interacting with the Contract

After deployment:

- Mint tokens (anyone): `mint(address to, uint256 amount)`
- Pause (admin only): `pause()`
- Unpause (admin only): `unpause()`
- Burn your tokens: `burn(uint256 amount)` or `burnFrom(address, uint256)`

Use:
- Basescan "Write Contract" tab
- Cast (Foundry): `cast send 0x4d11... --rpc-url ... "mint(address,uint256)" 0xYourAddress 1000000000000000000`
- Wallet (MetaMask + custom token)

## Security & Recommendations

- **Do NOT** send real value to this token without understanding the risks.
- Anyone can mint → expect spam minting → token dilution.
- If spam becomes problematic → call `pause()` from deployer account.
- Consider renouncing admin role later (if desired): `renounceRole(DEFAULT_ADMIN_ROLE, msg.sender)`
- For production tokens → add caps, roles, audits, etc.
- Never reuse this exact setup for anything valuable.

## Next Steps / Ideas

- Add unit tests (`forge test`)
- Deploy frontend / dApp to interact (mint button, pause toggle)
- Create liquidity pool on Uniswap/Base DEX (if you want any trading)
- Experiment with burning mechanisms or funny mint restrictions
- Fork & modify (e.g. add max supply, only-self-mint, permit, etc.)

## License

MIT – feel free to copy, modify, destroy, meme, whatever.

Made with Foundry + OpenZeppelin on Base.  


Good luck and stay experimental!

