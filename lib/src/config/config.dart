class AppConfig {
  // Ethereum configuration
  static const String infuraUrl = 'https://mainnet.infura.io/v3/63e5a7b11d7d456bb061f1135b7ddc88';

  // Price API
  static const String coingeckoApi = 'https://api.coingecko.com/api/v3/simple/price';

  // Bitcoin configuration
  static const String blockcypherApi = 'https://api.blockcypher.com/v1/btc/main';

  // Solana configuration
  static const String solanaRpcUrl = 'https://api.mainnet-beta.solana.com';

  // BNB Chain configuration
  static const String bnbChainRpcUrl = 'https://bsc-dataseed.binance.org';

  // Polygon configuration
  static const String polygonRpcUrl = 'https://polygon-rpc.com';
  // Add WebSocket URLs
  static const String solanaWsUrl = 'wss://api.mainnet-beta.solana.com/';

  // Tron configuration
  static const String tronGridApi = 'https://api.trongrid.io/v1';
  static const String usdtTronContractAddress = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';

  // Cardano configuration
  static const String blockfrostApi = 'https://cardano-mainnet.blockfrost.io/api/v0';
  // Note: Replace with environment variable or secure storage in production
  static const String blockfrostApiKey = 'YOUR_BLOCKFROST_API_KEY';

  // Ripple configuration
  // Using public Ripple node instead of third-party xrpscan for reliability
  static const String rippleApi = 'https://s1.ripple.com:51234';

  // Polkadot configuration
  static const String polkadotRpcUrl = 'https://rpc.polkadot.io';

  // USDT (ERC-20) configuration
  static const String usdtContractAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
  static const String usdtAbi = '''
    [
      {
        "constant": true,
        "inputs": [{"name": "_owner", "type": "address"}],
        "name": "balanceOf",
        "outputs": [{"name": "balance", "type": "uint256"}],
        "type": "function"
      },
      {
        "constant": false,
        "inputs": [
          {"name": "_to", "type": "address"},
          {"name": "_value", "type": "uint256"}
        ],
        "name": "transfer",
        "outputs": [{"name": "success", "type": "bool"}],
        "type": "function"
      }
    ]
    ''';
  
}