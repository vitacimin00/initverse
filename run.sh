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
WORKER_NAME=""
CPU_CORES=2
MINING_SOFTWARE_URL="https://github.com/Project-InitVerse/ini-miner/releases/download/v1.0.0/iniminer-linux-x64"
POOL_ADDRESS="pool-core-testnet.inichain.com:32672"
RESTART_INTERVAL=3600  # 1 hour in seconds

# Function to generate random worker name
generate_worker_name() {
    local syllables=(ka ke ki ko ku ma me mi mo mu na ne ni no nu sa se si so su)
    for i in {1..5}; do
        WORKER_NAME+="${syllables[$((RANDOM % ${#syllables[@]}))]}"
    done
    WORKER_NAME+=$((RANDOM % 100))
}

# Function to print colored header
print_header() {
    echo -e "${PURPLE}=================================================${NC}"
    echo -e "${CYAN}             InitVerse Mining Setup${NC}"
    echo -e "${PURPLE}=================================================${NC}"
}

# Function to validate wallet address
validate_wallet() {
    if [[ ! $1 =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo -e "${RED}Invalid wallet address format${NC}"
        return 1
    fi
    return 0
}

# Function to run mining command with auto-restart
run_with_restart() {
    local cmd="$1"
    while true; do
        echo -e "${GREEN}Starting mining process...${NC}"
        echo -e "${BLUE}$cmd${NC}"
        eval "$cmd"

        # Calculate next restart time
        next_restart=$(date -d "+1 hour" +"%H:%M:%S")
        echo -e "${YELLOW}Mining process will restart at $next_restart${NC}"

        # Sleep for the specified interval
        sleep $RESTART_INTERVAL

        echo -e "${YELLOW}Restarting mining process...${NC}"
        # Kill any remaining mining processes
        pkill -f iniminer-linux-x64
    done
}

# Function to set up mining pool
setup_pool_mining() {
    echo -e "${YELLOW}Setting up Pool Mining...${NC}"

    # Generate random worker name
    generate_worker_name

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

    for ((i=0; i<CPU_CORES; i++)); do
        MINING_CMD+=" --cpu-devices $i"
    done

    # Start mining with auto-restart
    run_with_restart "$MINING_CMD"
}

# Main menu function
main_menu() {
    clear
    print_header
    echo -e "${YELLOW}Defaulting to Setup Pool Mining...${NC}"
    setup_pool_mining
}

# Start the script
main_menu
