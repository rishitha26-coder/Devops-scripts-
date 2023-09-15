shopt -s extglob

[[ -d "/Volumes/Private Keys" ]] || hdiutil attach ~/Desktop/Private\ Keys.dmg
export PATH=/usr/local/opt:/usr/local/bin:$(pyenv root)/shims:/usr/local/opt/perl/bin/:$PATH
export PATH="/${HOME}/repos/scripts:$PATH"
export PATH="$GOENV_ROOT/bin:$PATH"
export PATH=$PATH:$(go env GOPATH)/bin:~/.cargo/bin
export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
#eval "$(rbenv init -)"
. ~/.rvm/bin/rvm-exec
export RBENV_ROOT=/usr/local/var/rbenv
export PATH=$RBENV_ROOT/shims:/versions:$PATH
eval "$(pyenv init -)"
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
eval "$(goenv init -)"
export GOENV_ROOT="$HOME/.goenv"
export GOPATH="$HOME/go"
export PATH=$PATH:"/usr/local/bin/go/golint"
export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
export CFLAGS="-I$(xcrun --show-sdk-path)/usr/include"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
. /Volumes/Private\ Keys/jiratoken.sh
#export PATH=${PATH}:${HOME}/.nodenv/versions/$(node --version | sed 's/v//g')/bin/
export PATH="${HOME}/repos/helper-scripts:${PATH}"
export PATH=/usr/local/opt:/usr/local/bin:$PATH


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

complete -C /usr/local/bin/vault vault

[[ -n "$VAULT_ADDR" ]] || export VAULT_ADDR=https://vault-nonprod.security.mogok8s.net

export GITHUB_TOKEN="$(cat /Volumes/Private\ Keys/github-api-token)"

ulimit -n 10240
