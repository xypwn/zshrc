# My config for the Zoomer Shell (based on Luke's <lukesmith.xyz>).

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
[ ! -e ~/.cache/zsh ] && mkdir ~/.cache/zsh
HISTFILE=~/.cache/zsh/history

# Load aliases and shortcuts if existent.
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
[ -f "${XDG_CONFIG_HOME}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
 zle-line-init() {
 	# Switch to insert mode when a new line or a new prompt is initiated.
    zle -K viins
}
zle -N zle-line-init
zle-line-finish() {
	echo -ne '\e[1 q'
}
zle -N zle-line-finish

bindkey -s '^a' 'bc -lq\n'

bindkey '^[[P' delete-char

# Bookmarks
getbms() {
	cat "${XDG_CONFIG_HOME}/shell/bookmarks" | while read l; do
		readlink -f "`eval echo $l`"
	done
}
hasbm() {
	getbms | grep "^$(readlink -f "$PWD")$" > /dev/null
}
# cd into bookmarked directories with Ctrl+f.
cdbm() {
	cd "$(getbms | fzf --preview "sh -c 'echo Directory contents:; echo; ls --color=always {}'")"
}
bindkey -s '^f' "cdbm\n"
# Add directory bookmark with Ctrl+b.
addbm() {
	if hasbm; then
		echo "'$PWD' is already in bookmarks"
	else
		echo "$PWD" >> "${XDG_CONFIG_HOME}/shell/bookmarks"
		echo "Added '$PWD' to bookmarks"
	fi
}
bindkey -s '^b' "addbm\n"
# Remove directory bookmark with Ctrl+n.
delbm() {
	if hasbm; then
		while read l; do
			echo "$(readlink -f "`eval echo $l`")" | grep "^$(readlink -f "$PWD")$" > /dev/null || echo "$l"
		done < "${XDG_CONFIG_HOME}/shell/bookmarks" > "${XDG_CONFIG_HOME}/shell/.bookmarks.new"
		mv -f "${XDG_CONFIG_HOME}/shell/.bookmarks.new" "${XDG_CONFIG_HOME}/shell/bookmarks"
		echo "Deleted bookmark '$PWD'"
	else
		echo "'$PWD' is not bookmarked"
	fi
}
bindkey -s '^n' "delbm\n"

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Load syntax highlighting; should be last.
source "$HOME/build/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
