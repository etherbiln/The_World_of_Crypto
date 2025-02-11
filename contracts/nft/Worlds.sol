// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Worlds is ERC1155, Ownable {
    uint256 public constant ENTRY_PASS = 1;
    uint256 public constant BONUS_REWARD = 2;

    mapping(address => bool) public hasEntryPass;

    event EntryPassMinted(address indexed account);
    event BonusRewardMinted(address indexed account, uint256 amount);

    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender) {}

    function mintEntryPass(address account) external onlyOwner {
        require(!hasEntryPass[account], "Worlds: Entry pass already minted");
        hasEntryPass[account] = true;
        _mint(account, ENTRY_PASS, 1, "");
        emit EntryPassMinted(account);
    }

    function mintBonusReward(address account, uint256 amount) external onlyOwner {
        require(amount > 0, "Worlds: Invalid amount");
        _mint(account, BONUS_REWARD, amount, "");
        emit BonusRewardMinted(account, amount);
    }

    function setURI(string memory newuri) external onlyOwner {
        _setURI(newuri);
    }

    // Override _update to enforce ENTRY_PASS constraints
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 value = values[i];

            if (id == ENTRY_PASS) {
                if (to != address(0)) { // Skip burn address check
                    uint256 currentBalance = balanceOf(to, ENTRY_PASS);
                    require(
                        currentBalance + value <= 1,
                        "Worlds: Max 1 ENTRY_PASS per address"
                    );
                }
            }
        }
        super._update(from, to, ids, values);
    }
}