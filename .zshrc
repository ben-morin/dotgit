if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# path+=('/home/ben/pear/bin')
# path=('/home/ben/pear/bin' $path)

path=("$HOME/bin" $path)
[ -d $HOME/.local/bin ] && path=("$HOME/.local/bin" $path)
[ -d $HOME/.krew/bin ] && path+=("$HOME/.krew/bin")
[ -d "$(brew --prefix python)/libexec/bin" ] &&
	path+=("$(brew --prefix python)/libexec/bin")
[ -d /opt/homebrew/opt/mysql-client/bin ] &&
	path+=("/opt/homebrew/opt/mysql-client/bin")
export PATH

[ -f "$HOME/zebraworks-dev/bin/.zw-zshrc" ] &&
	source "$HOME/zebraworks-dev/bin/.zw-zshrc"

[ -f "$HOME/sevence-dev/bin/.bt-zshrc" ] &&
	source "$HOME/sevence-dev/bin/.bt-zshrc"

[ -f "$HOME/.zshrc-secrets" ] &&
	source "$HOME/.zshrc-secrets"

[ -f "$HOME/.zshrc-alias" ] &&
	source "$HOME/.zshrc-alias"

# XDG Base Directories...
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# homebrew
export HOMEBREW_NO_EMOJI=1
export HOMEBREW_NO_ENV_HINTS=1

# competition...
setopt listpacked
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit && compinit -i -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-$USER"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache"

# bash completion...
# autoload -U +X bashcompinit && bashcompinit
# [[ -r /opt/homebrew/etc/bash_completion.d/az ]] && 
#	source /opt/homebrew/etc/bash_completion.d/az

# starship...
if command -v starship >/dev/null 2>&1; then
	export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
	eval "$(starship init zsh)"
else
	[ -f "$HOME/.zshrc-prompt" ] && 
		source "$HOME/.zshrc-prompt"
fi

# atuin...
if command -v atuin >/dev/null 2>&1; then
	if [ -n "$ATUIN_NATIVE" ]; then
		eval "$(atuin init zsh)"
	else
		#eval "$(atuin pty-proxy init zsh)"
		eval "$(atuin init zsh --disable-up-arrow)"
		[ -f "$HOME/.config/atuin/atuin-arrows.zsh" ] && 
			source "$HOME/.config/atuin/atuin-arrows.zsh"
	fi
fi

# zoxide...
if [ -z "$DISABLE_ZOXIDE" ]; then
	if command -v zoxide >/dev/null 2>&1; then
		export _ZO_DATA_DIR="$HOME/.local/share/zoxide"
		eval "$(zoxide init --cmd cd zsh)"
	fi
fi

# command history...
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
export HISTFILE="$HOME/.history/zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
export PYTHON_HISTORY="$HOME/.history/python_history"
export PHP_HISTFILE="$HOME/.history/php_history"
export MYSQL_HISTFILE="$HOME/.history/mysql_history"
export SQLITE_HISTORY="$HOME/.history/sqlite_history"

# allow editing commandline in editor...
export EDITOR="/usr/bin/vim"
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# treat Shift+Enter like Enter (Ghostty sends modifyOtherKeys CSI 27)...
bindkey '\e[27;2;13~' accept-line

# changing directories...
export DIRSTACKSIZE=8
setopt autopushd cdsilent pushdignoredups pushdminus pushdsilent
alias dh='dirs -v'

# xcode sdk root...
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

# java sdk home...
export JAVA_HOME=$(/usr/libexec/java_home -v 21 2> /dev/null)
#export JAVA_HOME=$(/usr/libexec/java_home -v 17 2> /dev/null)
[ "${JAVA_HOME}" = "" ] && unset JAVA_HOME

# mysql...
export MYSQL_HOME="$HOME/.config/mysql"
export MYSQL_TEST_LOGIN_FILE="$MYSQL_HOME/mylogin.cnf"

# meteor...
export PATH="$HOME/.meteor":$PATH

# dolphie...
export DOLPHIE_CONFIG="$HOME/.config/dolphie/dolphie.cnf"

# azure-cli...
export AZURE_CONFIG_DIR="$HOME/.config/azure"

# functions...
[ -f "$HOME/.zshrc-func" ] &&
	source "$HOME/.zshrc-func"

