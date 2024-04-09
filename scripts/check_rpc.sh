#bin

echo "Checking RPC connection to anvil :8545..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' http://localhost:8545

echo ""
echo ""
echo "Checking RPC connection to anvil :9545..."
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' http://localhost:9545