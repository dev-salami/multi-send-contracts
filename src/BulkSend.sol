// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title BulkSend Contract
 * @author Salami Khalil
 * @dev Contract for sending bulk tokens or Ether
 * @notice This contract allows the user to send bulk tokens or Ether to an array of addresses.
 */
contract BulkSend {
    address private immutable i_owner;
    uint256 private s_eth_send_fee; // in wei
    uint256 private s_token_send_fee; // in wei

    event Sent_Bulk_Token(address indexed from, address[] to, uint256[] amount);
    event Sent_Bulk_ETH(address indexed from, address[] to, uint256[] amount);

    constructor() {
        i_owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        _;
    }

    /**
     * @dev Sends bulk tokens to an array of addresses.
     * @param token_addr Contract address for the token.
     * @param _addresses Array of addresses to send tokens to.
     * @param _amounts Array of token amounts corresponding to each address.
     * @return success Boolean indicating a successful transaction.
     */
    function bulkSendToken(
        address token_addr,
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external payable returns (bool success) {
        require(
            _addresses.length == _amounts.length,
            "Number of addresses do not match amounts"
        );
        IERC20 token = IERC20(token_addr);
        uint256 no_of_address = _addresses.length;
        uint256 total_amount;
        uint256 SEND_FEE = s_token_send_fee * no_of_address * 1 wei;

        for (uint8 i = 0; i < no_of_address; i++) {
            total_amount += _amounts[i];
        }

        require(msg.value >= SEND_FEE, "Not enough ETH");

        require(
            total_amount <= token.allowance(msg.sender, address(this)),
            "Not enough token allowance"
        );

        // transfer token to _addresses
        for (uint8 j = 0; j < no_of_address; j++) {
            token.transferFrom(msg.sender, _addresses[j], _amounts[j]);
        }
        // transfer change back to the sender
        if (msg.value > SEND_FEE) {
            uint256 change = msg.value - SEND_FEE;
            (bool sent, ) = payable(msg.sender).call{value: change}("");
            require(sent, "Balance not sent");
        }

        emit Sent_Bulk_Token(msg.sender, _addresses, _amounts);
        return true;
    }

    /**
     * @dev Sends bulk Ether to an array of addresses.
     * @param _addresses Array of addresses to send Ether to.
     * @param _amounts Array of Ether amounts corresponding to each address.
     * @return success Boolean indicating a successful transaction.
     */
    function bulkSendEth(
        address[] memory _addresses,
        uint256[] memory _amounts
    ) external payable returns (bool success) {
        require(
            _addresses.length == _amounts.length,
            "Number of addresses do not match amounts"
        );
        uint256 no_of_address = _addresses.length;

        uint256 total_amount;
        uint256 SEND_FEE = (s_eth_send_fee * no_of_address);

        for (uint8 i = 0; i < _amounts.length; i++) {
            total_amount += _amounts[i];
        }
        uint256 requiredAmount = SEND_FEE + total_amount;

        // Ensure that the ethereum sent is enough to complete the transaction
        // uint256 requiredAmount = (total_amount * 1 wei) + s_eth_send_fee;
        require(msg.value >= requiredAmount, "Not enough eth sent");

        // Transfer to each address
        for (uint8 j = 0; j < _addresses.length; j++) {
            (bool sent, ) = payable(_addresses[j]).call{value: (_amounts[j])}(
                ""
            );
            require(sent, "ETH NOT SENT");
        }

        // Return change to the sender
        if (msg.value > requiredAmount) {
            uint256 change = msg.value - requiredAmount;
            (bool sent, ) = payable(msg.sender).call{value: change}("");
            require(sent, "CHANGE NOT SENT");
        }
        emit Sent_Bulk_ETH(msg.sender, _addresses, _amounts);

        return true;
    }

    /**
     * @dev Withdraws Ether from the contract. Only callable by the owner.
     */
    function withdrawEther() external onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(sent, " Withdraw unsuccesful");
    }

    /**
     * @dev Sets the fee for sending Ether.
     * @param amount New fee amount in Wei.
     */
    function setETH_Send_Fee(uint256 amount) external onlyOwner {
        s_eth_send_fee = amount;
    }

    /**
     * @dev Sets the fee for sending tokens.
     * @param amount New fee amount in Wei.
     */
    function setToken_Send_Fee(uint256 amount) external onlyOwner {
        s_token_send_fee = amount;
    }

    // GETTER FUNCTIONS

    function ethSendFee() external view returns (uint256) {
        return s_eth_send_fee;
    }

    function tokenSendFee() external view returns (uint256) {
        return s_token_send_fee;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
