#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git make clang pkg-config libssl-dev build-essential -y
sudo apt install golang-go -y
sudo apt install apt-transport-https gnupg cmake protobuf-compiler -y

curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg
sudo mv bazel-archive-keyring.gpg /usr/share/keyrings

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup update
rustup component add rust-src
rustup target add wasm32-unknown-unknown
rustup install nightly-2024-01-21
rustup target add wasm32-unknown-unknown --toolchain nightly-2024-01-21

git clone https://github.com/paritytech/polkadot-sdk.git
cd polkadot-sdk
git checkout polkadot-v1.17.1
cargo build --release

current_user=$(whoami)
STARTNAME="Your_Node_Name"

sudo tee /etc/systemd/system/polkadot.service > /dev/null <<EOF
[Unit]
Description=Polkadot Validator Node
After=network.target
[Service]
Type=simple
User=$current_user
ExecStart=$HOME/polkadot-sdk/target/release/polkadot \
  --validator \
  --name "$STARTNAME" \
  --chain=polkadot \
  --database RocksDb \
  --state-pruning 1000 \
  --prometheus-external \
  --prometheus-port=9615 \
  --unsafe-force-node-key-generation \
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable polkadot.service
sudo systemctl restart polkadot.service
