#!/bin/bash

brew tap hashicorp/tap
brew install hashicorp/tap/vault

brew install joemiller/taps/vault-token-helper

vault -h && vault-token-helper -h || exit 1

vault-token-helper enable || exit 1

security delete-generic-password -a ${USER} -s github-vault > /dev/null 2>&1

echo "Enter your github api token for use with vault (password will not show during entry)"
stty -echo

read GITHUB_API_TOKEN

stty echo

security add-generic-password -a ${USER} -s github-vault -w $GITHUB_API_TOKEN || exit 1

vault -autocomplete-install > /dev/null 2>&1

sed -i .bk '/^export VAULT/d' ${HOME}/.bashrc

echo export VAULT_ADDR=https://vault-nonprod.security.mogok8s.net >> ~/.bashrc

echo "Success! Exit and restart your shell, then use the vaultLogin.sh script to log into vault."
