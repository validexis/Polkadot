#!/bin/bash
sudo systemctl stop polkadot.service
cd polkadot-sdk
sudo git fetch
git checkout polkadot-v1.17.1
cargo build --release
sudo systemctl restart polkadot.service
sudo journalctl -u polkadot.service -f
