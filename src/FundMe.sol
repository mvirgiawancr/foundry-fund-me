// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant minimumUSD = 5e18;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToFunded;
    address private immutable owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUSD,
            "Didn't send enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToFunded[msg.sender] =
            s_addressToFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        return priceFeed.version();
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 fundersIndex = 0;
            fundersIndex < fundersLength;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_addressToFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /*
   view and pure functions
   */

    function getAddressToFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
