// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract AIUSD is ERC20, ERC20Burnable, ERC20Pausable, AccessControl {
    // Still keeping roles for pause functionality and future admin control
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /**
     * @dev Constructor:
     * - Grants admin & pauser role to deployer
     * - Mints optional initial supply to deployer
     * - Anyone can call mint() afterward — no restriction
     */
    constructor(uint256 initialSupply) ERC20("AIUSD", "AIUSD") {
        // Deployer gets admin rights and can pause if needed
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        // Optional: mint some tokens to deployer at launch
        if (initialSupply > 0) {
            _mint(msg.sender, initialSupply);
        }
    }

    /**
     * @dev ANYONE can mint any amount to any address.
     * No role check, no supply cap — completely open.
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /**
     * @dev Pauses all token transfers, minting, burning.
     * Only accounts with PAUSER_ROLE can pause (deployer by default).
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses everything.
     * Only PAUSER_ROLE.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // Required override for pausable + ERC20 v5 compatibility
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}