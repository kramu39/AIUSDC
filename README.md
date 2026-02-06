
# AIUSD – Permissionless Mint ERC-20 Token on Base

AIUSD is an experimental ERC-20 token deployed on **Base** (an Ethereum L2 by Coinbase).  

**Core feature**: Completely open minting — **anyone** can mint any amount of tokens to any address at any time, with **no cap, no roles required, and no restrictions**.

This design makes AIUSD a radical experiment in unrestricted tokenomics — more meme/art/test oriented than a traditional utility/financial token.

## Project Goals & Philosophy

- Demonstrate a maximally permissive ERC-20 implementation using OpenZeppelin standards.
- Explore what happens in a truly open-supply environment (hyper-inflation risk, spam minting, community reactions).
- Serve as a learning/reference repo for:
  - Foundry-based development workflow
  - OpenZeppelin ERC20 + extensions (Pausable, Burnable, AccessControl)
  - Deployment to Base Mainnet/Sepolia
  - Basic testing patterns
- Provide a minimal, auditable starting point that others can fork/modify.

**Not intended for**:
- Real economic value
- Stablecoin mechanics
- DeFi primitives
- Anything requiring scarcity or controlled issuance

## Token Specification

| Property              | Value                          | Notes                                                                 |
|-----------------------|--------------------------------|-----------------------------------------------------------------------|
| Network               | Base Mainnet (Chain ID 8453)   | Also deployable to Base Sepolia (84532)                               |
| Contract Address      | `0x4d1136234F488068d905ba0a4885dA1E04EaB1a3` | [Basescan](https://basescan.org/address/0x4d1136234f488068d905ba0a4885da1e04eab1a3) |
| Name                  | AIUSD                          |                                                                       |
| Symbol                | AIUSD                          |                                                                       |
| Decimals              | 18                             | Standard ERC-20                                                       |
| Initial Supply        | 0                              | No premint — supply starts empty                                      |
| Total Supply          | Dynamic (unlimited)            | Anyone can increase via `mint()`                                      |
| Minting               | Permissionless                 | `mint(address to, uint256 amount)` — public, no checks                |
| Burning               | Yes                            | Standard `burn(uint256)` & `burnFrom(address, uint256)`               |
| Pausing               | Yes                            | Only by `PAUSER_ROLE` holder (deployer initially)                     |
| Transfer Fees/Taxes   | None                           | Clean pass-through                                                    |
| Upgradability         | No                             | Immutable deployment                                                  |
| License               | MIT                            | Fully open                                                                |

## Smart Contract Architecture

- **Base**: OpenZeppelin Contracts v5.x (`^0.8.20`)
- **Inherited Contracts**:
  - `ERC20` — core token logic
  - `ERC20Burnable` — self-burn & approved burn
  - `ERC20Pausable` — emergency pause on transfers/mints/burns
  - `AccessControl` — roles for pause/unpause (no minter role!)
- **Key Functions**:
  - `mint(address to, uint256 amount)` — public → anyone calls
  - `pause()` / `unpause()` — restricted to `PAUSER_ROLE`
  - Standard: `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`, etc.
- **Overrides**: `_update()` hooks pausable logic (required in OZ v5)

Source: [`src/AIUSD.sol`](./src/AIUSD.sol)

## Security & Risk Considerations

**Critical risks** (intentional design):

- **Unlimited inflation** — supply can reach astronomical numbers in minutes via spam minting.
- **Value dilution** — any perceived value evaporates quickly.
- **No recovery** — paused transfers still allow minting unless fully paused (but pause is admin-only).

**Mitigations** (limited):

- Deployer retains `PAUSER_ROLE` & `DEFAULT_ADMIN_ROLE` → can pause in emergency.
- Anyone (including deployer) can renounce roles later via `renounceRole(...)`.
- No hidden admin functions, no owner mint, no blacklist.

**Recommendation**: Treat this token as a **social experiment / art piece / test artifact** — **never** send meaningful ETH or assets to associated addresses/pools.

No formal audit — use at your own extreme risk.

## Getting Started (Development)

### Prerequisites

- [Foundry](https://getfoundry.sh/) (`forge`, `cast`, `anvil`)
- Git
- Base RPC endpoints & Basescan API key

### Setup

```bash
git clone https://github.com/kramu39/AIUSDC.git
cd AIUSDC
forge install
cp .env.example .env     # fill in PRIVATE_KEY, RPCs, BASESCAN_API_KEY
```

### Useful Commands

| Action                        | Command                                                                 |
|-------------------------------|-------------------------------------------------------------------------|
| Compile                       | `forge build`                                                           |
| Run tests                     | `forge test -vvv`                                                       |
| Deploy to Base Sepolia        | `forge script script/DeployAIUSD.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $BASESCAN_API_KEY --chain-id 84532` |
| Deploy to Base Mainnet        | Same as above, but `--rpc-url $BASE_MAINNET_RPC_URL --chain-id 8453`   |
| Mint tokens (via cast)        | `cast send 0x4d11... "mint(address,uint256)" 0xYourAddress 1ether --rpc-url ... --private-key ...` |
| Pause contract                | `cast send 0x4d11... "pause()" --rpc-url ... --private-key ...`        |

## Testing

See [`test/AIUSD.t.sol`](./test/AIUSD.t.sol) — covers:

- Permissionless minting (fuzzed & unit)
- Pausing / unpausing behavior
- Burning (self & approved)
- Role checks
- Standard ERC-20 transfers / approvals

Run with gas report: `forge test --gas-report`

## Deployment History

- **Base Mainnet**  
  Address: `0x4d1136234F488068d905ba0a4885dA1E04EaB1a3`  
  Deployer: `0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38` (also initial admin/pauser)  
  Tx: (link from Basescan once confirmed)  
  Initial supply: 0

- **Base Sepolia**  
  (Deploy if needed for testing — update here with address)

## Interacting with AIUSD

1. Add token to wallet: Use contract address + 18 decimals
2. Mint: Call `mint` directly via wallet (e.g. MetaMask → Write Contract) or cast
3. Pause: Only deployer (or role holder) can call `pause()`
4. Verify on Basescan: Source is already verified

## Future Ideas / Extensions

- Add mint logging events or funny on-chain messages
- Implement a humorous "anti-spam" delay (e.g. cooldown per address)
- Deploy a companion NFT collection that "reacts" to mints
- Build a simple frontend dApp (React + wagmi/viem) for one-click minting
- Experiment with self-destruct or burn-all mechanics
- Fork versions: capped supply, role-based mint, permit support, etc.

## Contributing

This is an open experiment — feel free to fork, PR improvements, or create variants.

Issues/PRs welcome for:
- Better tests / invariants
- Gas optimizations
- Documentation enhancements
- Safety features (without removing core permissionlessness)

## License

MIT License — do whatever you want.

Built by **Ramu** in Nairobi, February 2026.  
Deployed on Base. Experiment responsibly .

