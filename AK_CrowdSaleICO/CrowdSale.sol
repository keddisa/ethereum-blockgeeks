pragma solidity ^0.4.24;

import "./IERC20.sol";
import "./SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;

    uint256 private cap; // maximum amount of ether to be raised
    uint256 private weiRaised; // current amount of wei raised

    uint256 private rate; // price in wei per smallest unit of token (e.g. 1 wei = 10 smallet unit of a token)
    address private wallet; // wallet to hold the ethers
    IERC20 private token; // address of erc20 tokens

    event TransferFinished (address wallet, uint256 tokens);
   /**
    * Event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    // -----------------------------------------
    // Public functions (DO NOT change the interface!)
    // -----------------------------------------
   /**
    * @param _rate Number of token units a buyer gets per wei
    * @dev The rate is the conversion between wei and the smallest and indivisible token unit.
    * @param _wallet Address where collected funds will be forwarded to
    * @param _token Address of the token being sold
    */
    constructor(uint256 _rate, address _wallet, IERC20 _token) public {
        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    /**
    * @dev Fallback function for users to send ether directly to contract address
    */
    function() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable {
        // Below are some general steps that should be done.
        // You need to decide the right order to do them in.
        //  - Validate any conditions
        //  - Calculate number of tokens
        //  - Update any states
        //  - Transfer tokens and emit event
        //  - Forward funds to wallet

        uint256 numberOfTokens = msg.value.div(rate);
        // Check if buying these tokens would cause totalSupply to surpass cap
        require (token.totalSupply().add(numberOfTokens) < cap);
        require (wallet != address(0));
        require (beneficiary != address(0));
        require (msg.value > 0);
        weiRaised = weiRaised.add(numberOfTokens);
        token.transfer(beneficiary, numberOfTokens);
        emit TokensPurchased(msg.sender, beneficiary, msg.value, numberOfTokens);
        wallet.transfer(msg.value);
        emit TransferFinished (wallet, msg.value);
    }

    /**
    * @dev Checks whether the cap has been reached.
    * @return Whether the cap was reached
    */
    function capReached() public view returns (bool) {
        require(token.totalSupply() >= cap);
        return true;
    }


}
