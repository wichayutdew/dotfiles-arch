# ---- MISE ----
mise activate fish | source

# ---- FISH ----
set fish_greeting ''
set --global fish_key_bindings fish_vi_key_bindings
bind -M insert \t accept-autosuggestion

# ---- STARSHIP ----
starship init fish | source

# ---- Zoxide Initialization ----
zoxide init fish | source

# ---- FZF ----
fzf --fish | source

# ---- YAZI OPEN IN NVIM ----
set -gx EDITOR 'nvim'

# ---- ALIASES ----
alias leet 'nvim leetcode.nvim'
alias cfg 'nvim ~/.config/fish/config.fish'
alias so 'source ~/.config/fish/config.fish'
alias cl 'clear'

# ---- SHORT_HAND_ALIASES ----
alias v 'nvim'
alias l 'eza --color=always --long --git --icons=always --no-time --no-user'
alias g 'lazygit'
alias t 'tmux'
alias ci 'zi'
alias c 'z'
alias y 'yazi'
alias cc 'pi --plan'
alias q 'pi -p --model big-pickle'
