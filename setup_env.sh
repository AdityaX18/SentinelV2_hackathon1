#!/bin/bash
echo "Setting up Sentinel CLI Environment..."

# 1. Install Python Dependencies
echo "Installing Python dependencies..."
/opt/homebrew/Caskroom/miniconda/base/bin/pip install click requests

# 2. Build Rust Binary in Lima
echo "Building Rust binary in Lima..."
limactl shell default bash -c "cd sentinel_v2/linux-backend && cargo build --release"

# 3. Set Environment Variables (Ideally these go in .zshrc)
# export VT_API_KEY="your_virustotal_api_key_here"
# export HF_TOKEN="your_huggingface_token_here"

echo "Setup Complete!"
