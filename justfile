set dotenv-load

report:
  sh -c 'forge clean && FOUNDRY_PROFILE=ci forge test --gas-report --fuzz-seed 1 | sed -e/\|/\{ -e:1 -en\;b1 -e\} -ed' >> logs.log 2>&1
  cat .gas-report >> logs.log 2>&1

yul contractName:
  sh -c 'forge inspect {{contractName}} ir-optimized > yul.sol' >> logs.log 2>&1

run-script script_name flags='' sig='' args='':
  sh -c 'FOUNDRY_PROFILE=ci forge script script/{{script_name}}.s.sol {{sig}} {{args}} \
    --rpc-url "https://rpc.dev.buildbear.io/arjun" \
    --private-key "5f61ba1a9c46f64c7040211cb8ddf50d64fe8b91f3e8a5e45a5bfb627f22f48d" \
    --etherscan-api-key "verifyContract" \
    --verifier-url "https://rpc.dev.buildbear.io/verify/etherscan/arjun" \
    -vvvv {{flags}}' >> logs.log 2>&1

run-create-action-script flags:
  sh -c 'just run-script "CreateAction" {{flags}} "--sig \"run(address)\"" "0xA8dA1B4Bd5d18C2B5f1F926F6caB531de5CaCfb5"' >> logs.log 2>&1

dry-run-deploy:
  sh -c 'just run-script "Deploy"' >> logs.log 2>&1

deploy:
  sh -c 'just run-script "Deploy" "--broadcast --verify --slow"' >> logs.log 2>&1

verify:
  sh -c 'just run-script "Deploy" "--verify"' >> logs.log 2>&1

dry-run-create-new-llama:
  sh -c 'just run-create-action-script ""' >> logs.log 2>&1

# Verification is unnecessary for this script because it does not create any contracts.
create-new-llama:
  sh -c 'just run-create-action-script "--broadcast"' >> logs.log 2>&1