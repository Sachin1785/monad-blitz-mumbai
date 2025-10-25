// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenEscrow {
    address public owner;

    // user => token => locked amount
    mapping(address => mapping(address => uint256)) public locked;

    event TokensLocked(address indexed user, address indexed token, uint256 amount);
    event TokensReleased(address indexed user, address indexed token, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // User must approve this contract to spend their tokens before calling this
    function lockTokens(address token, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        locked[msg.sender][token] += amount;
        emit TokensLocked(msg.sender, token, amount);
    }

    // Only owner (platform) can release tokens to a user (e.g., after trade completion or cancellation)
    function releaseTokens(address user, address token, uint256 amount) external {
        require(msg.sender == owner, "Only owner can release");
        require(locked[user][token] >= amount, "Insufficient locked");
        locked[user][token] -= amount;
        require(IERC20(token).transfer(user, amount), "Release failed");
        emit TokensReleased(user, token, amount);
    }
}
