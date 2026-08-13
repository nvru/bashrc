#!/usr/bin/env bash

# =========================
# Interactive shell check
# =========================

[[ $- != *i* ]] && return
[[ -n $PS1 ]] || return

# =========================
# PATH setup
# =========================

path_add() {
	local p=$1 dir=${2:-after} var=${3:-PATH} arr
	[[ -z $p || $p == *:* ]] && {
		echo "path_add: invalid: '$p'" >&2
		return 1
	}
	IFS=: read -ra arr <<<"${!var}:"
	[[ $dir == before ]] && arr=("$p" "${arr[@]}") || arr+=("$p")
	local IFS=:
	read -r "${var?}" <<<"${arr[*]}"
}

path_clean() {
	local var=${1:-PATH} arr newarr=() p
	declare -A seen
	IFS=: read -ra arr <<<"${!var}:"
	for p in "${arr[@]}"; do
		[[ -z $p || ${p:0:1} != '/' ]] && continue
		p=$(cd "$p" &>/dev/null && echo "$PWD")
		[[ -z $p || -n ${seen[$p]} ]] && continue
		seen[$p]=true
		newarr+=("$p")
	done
	local IFS=:
	read -r "${var?}" <<<"${newarr[*]}"
}

# User
for p in \
	"$HOME/bin:before" \
	"$HOME/.local/bin:before"; do
	path_add "${p%:*}" "${p##*:}"
done

# Languages & tools
for p in \
	"$HOME/.cargo/bin:before" \
	"$HOME/go/bin:before" \
	"$HOME/.pdtm/go/bin:before" \
	"$HOME/.local/share/mise/shims:before" \
	"$HOME/.local/share/nvim/mason/bin:before"; do
	path_add "${p%:*}" "${p##*:}"
done

# Compiler cache
for p in \
	"/usr/lib/ccache/bin:before" \
	"/usr/lib64/ccache:before" \
	"/usr/lib/ccache:before"; do
	path_add "${p%:*}" "${p##*:}"
done

# Misc / extra
for p in \
	"/opt/bin" \
	"/opt/homebrew/bin:before"; do
	path_add "${p%:*}" "${p##*:}"
done

# RubyGems
if command -v ruby >/dev/null 2>&1; then
	path_add "$(ruby -e 'print Gem.user_dir')/bin" before
else
	path_add "$HOME/.local/share/gem/ruby/bin" before
fi

# Termux
[[ -n "$TERMUX_VERSION" ]] && path_add "/data/data/com.termux/files/usr/bin" before

export PATH

# =========================
# Shell options
# =========================

export HISTTIMEFORMAT="%F %T "
export HISTCONTROL='ignoredups:erasedups:ignorespace'
PROMPT_COMMAND='history -a'

shopt -s histappend 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s checkwinsize 2>/dev/null
shopt -s extglob 2>/dev/null
shopt -s autocd 2>/dev/null

# =========================
# Source
# =========================

[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

[[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.bash
[[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]] && source /opt/homebrew/opt/fzf/shell/completion.bash

[[ -f /usr/local/opt/fzf/shell/key-bindings.bash ]] && source /usr/local/opt/fzf/shell/key-bindings.bash
[[ -f /usr/local/opt/fzf/shell/completion.bash ]] && source /usr/local/opt/fzf/shell/completion.bash

[[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
[[ -f /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash

[[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && source /usr/share/doc/fzf/examples/key-bindings.bash
[[ -f /usr/share/doc/fzf/examples/completion.bash ]] && source /usr/share/doc/fzf/examples/completion.bash

# =========================
# Exports
# =========================

export LD_PRELOAD=""
if command -v nvim >/dev/null 2>&1; then
	export EDITOR="nvim"
	export VISUAL="nvim"
	export MANPAGER="nvim +Man!"
else
	export EDITOR="vim"
	export VISUAL="vim"
	export MANPAGER="less"
fi

export GREP_COLORS='mt=1;36'
export HISTSIZE=5000
export HISTFILESIZE=5000
export CLICOLOR=1
export TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'
# export TZ=''
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

if command -v fd >/dev/null 2>&1; then
	export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

[ -n "$TERM" ] && infocmp "$TERM" >/dev/null 2>&1 || export TERM=xterm

# =========================
# Prompt
# =========================

black="\[\e[30m\]"
red="\[\e[31m\]"
green="\[\e[32m\]"
yellow="\[\e[33m\]"
blue="\[\e[34m\]"
magenta="\[\e[35m\]"
cyan="\[\e[36m\]"
white="\[\e[97m\]"
reset="\[\e[0m\]"

fg_light='\[\e[38;5;111m\]'
blue_soft='\[\e[38;5;75m\]'
light_green='\[\e[38;5;113m\]'
light_purple='\[\e[38;5;189m\]'

if [[ $EUID -eq 0 ]]; then
	prompt_symbol="#"
else
	prompt_symbol="$"
fi

case "$XDG_CURRENT_DESKTOP" in
dwm) theme="ohmyposh" ;;
dwl) theme="ash" ;;
i3) theme="ash-full" ;;
*) [[ -n "$SWAYSOCK" ]] && theme="tokyonight" || theme="ash-full" ;;
esac

case "$theme" in
ash)
	PS1="\w ${prompt_symbol} "
	;;
ash-full)
	PS1="\w\$(git_branch) ${prompt_symbol} "
	;;
tokyonight)
	PS1="${blue_soft}\u@\h ${light_green}\w ${light_purple}\${prompt_symbol} ${reset}"
	;;
basic)
	PS1="${green}\u${reset} in ${blue}\w${reset} \$ "
	;;
basic2)
	PS1="${fg_light}\u${reset} in ${blue_soft}\w${reset} \$ "
	;;
root)
	PS1="\u@\h: ${red}\w ${reset}${prompt_symbol} ${reset}"
	;;
red)
	PS1='\[\e[0;31m\][\[\e[1;37m\]\u\[\e[0;90m\]@\[\e[1;37m\]\h\[\e[0;31m\]]-\[\e[0;31m\][\[\e[1;37m\]\w\[\e[0;31m\]]\n\[\e[0;31m\]>>>\[\e[0m\] '
	;;
blackarch_zsh)
	PS1='\[\e[1;34m\][\[\e[0;36m\]\u\[\e[0;90m\]@\[\e[0;36m\]\h\[\e[1;34m\]]-\[\e[1;34m\][\[\e[0;37m\]\w\[\e[1;34m\]]\n\[\e[1;36m\]>>>\[\e[0m\] '
	;;
blackarch)
	grey="\[\e[0;37m\]"
	white="\[\e[1;37m\]"
	blue="\[\e[1;34m\]"
	cyan="\[\e[0;36m\]"
	nc="\[\e[0m\]"
	PS1="${blue}[ ${cyan}\H ${grey}\w${blue} ]${cyan}\$ ${nc}"
	;;
starship)
	eval "$(starship init bash)"
	;;
*)
	PS1="${fg_light}\u${reset} in ${blue_soft}\w${reset}${white}\$(git_branch) ${prompt_symbol} "
	;;
esac

# =========================
# Aliases
# =========================

command -v doas >/dev/null 2>&1 && alias sudo='doas' root='doas env PATH="$PATH"' || alias root='sudo -E env "PATH=$PATH"'
command -v vim >/dev/null 2>&1 && alias vi="vim"

alias r="reset" c="clear" open="xdg-open"
alias ip='ip --color=auto' dir="dir --color=auto" vdir="vdir --color=auto"
alias fgrep="fgrep --color=auto" egrep="egrep --color=auto" grep='grep --color=auto'
alias dd="dd status=progress" cp="cp -i -v" rm="rm -i -v" mv="mv -i -v" shred="shred -zf"
alias df="df -h" free="free -h" du="du -h"
alias wget="wget -U 'noleak'" curl="curl --user-agent 'noleak'"
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

if command -v eza >/dev/null 2>&1 && eza --version >/dev/null 2>&1; then
	alias l='eza -lahg --icons --group-directories-first'
	alias ls='eza -g --icons --group-directories-first'
	alias sl='eza -g --icons --group-directories-first'
	alias ll='eza -lhg --icons --group-directories-first'
	alias la='eza -lahg --icons --group-directories-first'
	alias lt='eza --tree --icons'
	alias l2='eza --tree --level=2 --icons'
	alias l3='eza --tree --level=3 --icons'
	alias lnew='eza -lahg --sort=modified --icons'
	alias lold='eza -lahg --sort=modified --reverse --icons'
elif command -v exa >/dev/null 2>&1 && exa --version >/dev/null 2>&1; then
	alias l='exa -lahg --icons --group-directories-first'
	alias ls='exa -g --icons --group-directories-first'
	alias sl='exa -g --icons --group-directories-first'
	alias ll='exa -lhg --icons --group-directories-first'
	alias la='exa -lahg --icons --group-directories-first'
	alias lt='exa --tree --icons'
	alias l2='exa --tree --level=2 --icons'
	alias l3='exa --tree --level=3 --icons'
	alias lnew='exa -lahg --sort=modified --icons'
	alias lold='exa -lahg --sort=modified --reverse --icons'
else
	alias l='ls -lahg --color=auto --group-directories-first'
	alias ls='ls -g --color=auto --group-directories-first'
	alias sl='ls'
	alias ll='ls -lhg --color=auto --group-directories-first'
	alias la='ls -lahg --color=auto --group-directories-first'
	alias lt='tree -a --dirsfirst'
	alias l2='tree -a --dirsfirst -L 2'
	alias l3='tree -a --dirsfirst -L 3'
	alias lnew='ls -lahgt --color=auto --group-directories-first'
	alias lold='ls -lahgtr --color=auto --group-directories-first'
fi

# =========================
# Functions
# =========================

git_branch() {
	local branch
	branch=$(git branch --show-current 2>/dev/null)
	[[ -n $branch ]] && printf " %s" "$branch"
}

vf() {
	local file
	file=$(fzf --preview "bat --color=always {} 2>/dev/null || cat {}") && ${EDITOR:-vim} "$file"
}

fkill() {
	local pid
	pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
	[[ -n $pid ]] && echo "$pid" | xargs kill -${1:-9}
}

colordiff() {
	local red green cyan reset
	red=$(tput setaf 1 2>/dev/null)
	green=$(tput setaf 2 2>/dev/null)
	cyan=$(tput setaf 6 2>/dev/null)
	reset=$(tput sgr0 2>/dev/null)

	diff -u "$@" | awk -v red="$red" -v green="$green" -v cyan="$cyan" -v reset="$reset" '
        /^\-/ { printf("%s", red) }
        /^\+/ { printf("%s", green) }
        /^@/ { printf("%s", cyan) }
        { print $0 reset }'

	return "${PIPESTATUS[0]}"
}

interfaces() {
	node <<-EOF
		var os = require('os');
		var i = os.networkInterfaces();
		Object.keys(i).forEach(function(name) {
			i[name].forEach(function(int) {
				if (int.family === 'IPv4') {
					console.log('%s: %s', name, int.address);
				}
			});
		});
	EOF
}

load() {
	node -p <<-EOF
		var os = require('os');
		var c = os.cpus().length;
		os.loadavg().map(function(l) {
			return (l/c).toFixed(2);
		}).join(' ');
	EOF
}

meminfo() {
	node <<-EOF
		var os = require('os');
		var free = os.freemem();
		var total = os.totalmem();
		var used = total - free;
		console.log('memory: %dmb / %dmb (%d%%)',
		    Math.round(used / 1024 / 1024),
		    Math.round(total / 1024 / 1024),
		    Math.round(used * 100 / total));
	EOF
}

mk() { mkdir -p nmap content creds misc exploits scripts; }

rmk() {
	scrub -p dod "$1"
	shred -zun 10 -v "$1"
}

# =========================
# Shell integration
# =========================

command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

if command -v nala >/dev/null 2>&1; then
	apt() {
		if [ "$(id -u)" -eq 0 ]; then
			command nala "$@"
		elif command -v doas >/dev/null 2>&1; then
			command doas nala "$@"
		else
			command sudo nala "$@"
		fi
	}

	\sudo() {
		if [ "$1" = "apt" ]; then
			shift
			if [ "$(id -u)" -eq 0 ]; then
				command nala "$@"
			elif command -v doas >/dev/null 2>&1; then
				command doas nala "$@"
			else
				command sudo nala "$@"
			fi
		else
			command sudo "$@"
		fi
	}
fi

command -v cargo >/dev/null 2>&1 && [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

[[ "$TERM" = "linux" && -f /usr/share/kbd/consolefonts/ter-119b.psf.gz ]] && setfont ter-119b

if command -v startx >/dev/null && [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
	startx
fi

path_clean
