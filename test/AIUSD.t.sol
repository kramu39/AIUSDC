// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {AIUSD} from "../src/AIUSD.sol";

contract AIUSDTest is Test {
    AIUSD public token;

    address public deployer = makeAddr("deployer");
    address public alice   = makeAddr("alice");
    address public bob     = makeAddr("bob");
    address public attacker = makeAddr("attacker");

    uint256 constant INITIAL_SUPPLY = 0; // as in your deployment

    function setUp() public {
        // Deploy as deployer
        vm.prank(deployer);
        token = new AIUSD(INITIAL_SUPPLY);

        // Give some tokens to alice for testing transfers/burns
        vm.prank(deployer);
        token.mint(alice, 10_000 ether); // using ether multiplier for readability (18 decimals)
    }

    // ────────────────────────────────────────────────────────────────
    // Basic ERC20 invariants
    // ────────────────────────────────────────────────────────────────

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "AIUSD");
        assertEq(token.symbol(), "AIUSD");
        assertEq(token.decimals(), 18);
    }

    function test_InitialState() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
        assertEq(token.balanceOf(alice), 10_000 ether);
    }

    // ────────────────────────────────────────────────────────────────
    // Open Minting – anyone can mint any amount
    // ────────────────────────────────────────────────────────────────

    function test_AnyoneCanMint() public {
        uint256 amount = 1_000_000 ether;

        vm.prank(attacker);
        token.mint(bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + 10_000 ether + amount);
    }

    function testFuzz_AnyoneCanMintFuzz(uint256 amount) public {
        vm.assume(amount > 0 && amount < type(uint128).max); // avoid overflow in fuzz

        vm.prank(attacker);
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), 10_000 ether + amount);
    }

    // ────────────────────────────────────────────────────────────────
    // Pausing functionality
    // ────────────────────────────────────────────────────────────────

    function test_PauseByAdmin() public {
        vm.prank(deployer);
        token.pause();

        assertTrue(token.paused());
    }

    function test_Pause_RevertIfNotPauser() public {
        vm.expectRevert(); // AccessControl error
        vm.prank(alice);
        token.pause();
    }

    function test_TransferRevertsWhenPaused() public {
        vm.prank(deployer);
        token.pause();

        vm.expectRevert("Pausable: paused");
        vm.prank(alice);
        token.transfer(bob, 100 ether);
    }

    function test_MintRevertsWhenPaused() public {
        vm.prank(deployer);
        token.pause();

        vm.expectRevert("Pausable: paused");
        vm.prank(attacker);
        token.mint(bob, 500 ether);
    }

    function test_BurnRevertsWhenPaused() public {
        vm.prank(deployer);
        token.pause();

        vm.expectRevert("Pausable: paused");
        vm.prank(alice);
        token.burn(100 ether);
    }

    function test_UnpauseByAdmin() public {
        vm.startPrank(deployer);
        token.pause();
        assertTrue(token.paused());

        token.unpause();
        assertFalse(token.paused());
        vm.stopPrank();

        // Now transfer should work
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    // ────────────────────────────────────────────────────────────────
    // Burning
    // ────────────────────────────────────────────────────────────────

    function test_Burn() public {
        uint256 burnAmount = 500 ether;

        uint256 before = token.balanceOf(alice);

        vm.prank(alice);
        token.burn(burnAmount);

        assertEq(token.balanceOf(alice), before - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + 10_000 ether - burnAmount);
    }

    function test_BurnFromWithApproval() public {
        vm.prank(alice);
        token.approve(bob, 300 ether);

        vm.prank(bob);
        token.burnFrom(alice, 300 ether);

        assertEq(token.balanceOf(alice), 10_000 ether - 300 ether);
    }

    // ────────────────────────────────────────────────────────────────
    // Role checks
    // ────────────────────────────────────────────────────────────────

    function test_DeployerHasRoles() public view {
        bytes32 PAUSER_ROLE = keccak256("PAUSER_ROLE");
        bytes32 ADMIN_ROLE  = 0x0000000000000000000000000000000000000000000000000000000000000000; // DEFAULT_ADMIN_ROLE

        assertTrue(token.hasRole(ADMIN_ROLE, deployer));
        assertTrue(token.hasRole(PAUSER_ROLE, deployer));
    }

    function test_AttackerHasNoRoles() public view {
        bytes32 PAUSER_ROLE = keccak256("PAUSER_ROLE");

        assertFalse(token.hasRole(PAUSER_ROLE, attacker));
    }

    // ────────────────────────────────────────────────────────────────
    // Standard ERC20 transfer / approve
    // ────────────────────────────────────────────────────────────────

    function test_Transfer() public {
        vm.prank(alice);
        token.transfer(bob, 200 ether);

        assertEq(token.balanceOf(alice), 10_000 ether - 200 ether);
        assertEq(token.balanceOf(bob), 200 ether);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 400 ether);

        vm.prank(bob);
        token.transferFrom(alice, attacker, 400 ether);

        assertEq(token.balanceOf(alice), 10_000 ether - 400 ether);
        assertEq(token.balanceOf(attacker), 400 ether);
        assertEq(token.allowance(alice, bob), 0);
    }
}