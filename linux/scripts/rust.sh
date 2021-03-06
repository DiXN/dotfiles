#!/bin/sh

echo '== Setup "Rust".'

yay -S --noconfirm rustup

rustup default stable
cargo install cargo-edit

