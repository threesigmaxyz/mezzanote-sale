-include .env

all: clean remove install update build

# Clean the repo
clean :;
	@forge clean

# Remove modules
remove :;
	rm -rf .gitmodules && \
	rm -rf .git/modules/* && \
	rm -rf lib && touch .gitmodules 

# Install dependencies
install :;
	@forge install foundry-rs/forge-std@master --no-commit && \
	forge install openzeppelin/openzeppelin-contracts@master --no-commit 

# Update dependencies
update :;
	@forge update

# Build the project
build :;
	@forge build

# Format code
format:
	@forge fmt

# Lint code
lint:
	@forge fmt --check

# Run tests
tests :;
	@forge test -vvv --ffi

# Run tests with coverage
coverage :;
	@forge coverage --ffi

# Run tests with coverage and generate lcov.info
coverage-report :;
	@forge coverage --report lcov --ffi

# Run slither static analysis
slither :;
	@slither ./src

documentation :;
	@forge doc --build

# Deploy a local blockchain
anvil :;
	@anvil -m 'test test test test test test test test test test test junk'

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :;
	@forge script script/DeploymentScript.s.sol:DeploymentScript --ffi --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Deploy the contract to remote network and verify the code
deploy-network :;
	@export FOUNDRY_PROFILE=deploy && \
	forge script script/DeploymentScript.s.sol:DeploymentScript -f ${network} --broadcast --verify --delay 20 --retries 10 -vvvv && \
	export FOUNDRY_PROFILE=default

run-script :;
	@export FOUNDRY_PROFILE=deploy && \
	./utils/run_script.sh && \
	export FOUNDRY_PROFILE=default

run-script-local :;
	@./utils/run_script_local.sh

get-merkle-root :;
	@forge test --mt test_getMerkleRoot -vv --ffi