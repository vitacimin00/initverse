#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
WALLET_ADDRESS="0x51372558b0b9205E6c42d804311be7DaBE532885"
CPU_CORES=$(nproc)
MINING_SOFTWARE_URL="https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64"
POOL_ADDRESSES=(
    "pool-a.yatespool.com:31588"
    "pool-b.yatespool.com:32488"
)

# Generate random worker name
generate_worker_name() {
    syllables=("ka" "ri" "ta" "su" "mi" "no" "pa" "li" "jo" "mo")
    name=""
    for _ in {1..3}; do
        name+="${syllables[$RANDOM % ${#syllables[@]}]}"
    done
    name+="$((RANDOM % 100))"
    echo "$name"
}

# Setup pool mining automatically
setup_pool_mining_auto() {
    echo -e "${YELLOW}Setting up Pool Mining (Auto)...${NC}"
    
    # Use the first pool address
    POOL_ADDRESS=${POOL_ADDRESSES[0]}
    echo -e "${GREEN}Selected Pool: $POOL_ADDRESS${NC}"
    
    # Generate random worker name
    WORKER_NAME=$(generate_worker_name)
    echo -e "${GREEN}Generated Worker Name: $WORKER_NAME${NC}"
    
    # Create directory and download mining software
    mkdir -p ini-miner && cd ini-miner
    
    # Download and extract mining software
    echo -e "${YELLOW}Downloading mining software...${NC}"
    wget "$MINING_SOFTWARE_URL" -O iniminer-linux-x64
    chmod +x iniminer-linux-x64
    
    # Check if executable exists
    if [ ! -f "./iniminer-linux-x64" ]; then
        echo -e "${RED}Error: Mining software not found${NC}"
        return 1
    fi
    
    # Set up mining command
    MINING_CMD="./iniminer-linux-x64 --pool stratum+tcp://${WALLET_ADDRESS}.${WORKER_NAME}@${POOL_ADDRESS}"
    
    # Use 2 CPU cores
    for ((i=0; i<2; i++)); do
        MINING_CMD+=" --cpu-devices $i"
    done
    
    # Start mining
    echo -e "${GREEN}Starting mining process...${NC}"
    echo -e "${BLUE}$MINING_CMD${NC}"
    eval "$MINING_CMD"
}

# Main script execution
setup_pool_mining_auto
