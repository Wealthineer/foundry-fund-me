// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//1. Deploy mocks when we are on a local anvil chain
//2. Keep track of contract addresses accross different networks
//Sepolia ETH/USD
//main net ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

uint8 constant ETH_USD_DECIMALS = 8;
int256 constant ETH_USD_INITIAL_PRICE = 1600e8;
uint256 constant SEPOLIA_CHAIN_ID = 11155111;
uint256 constant MAINNET_CHAIN_ID = 1;

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            ETH_USD_DECIMALS,
            ETH_USD_INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });

        return anvilConfig;
    }
}
