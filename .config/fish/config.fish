# ---- ASDF ----
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

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

# ---- RESHIM AFTER INSTALL, TO PREVENT MISSING $HOME PATH ---
# Auto-reshim after cargo install
function cargo
    command cargo $argv
    and if test "$argv[1]" = "install"
        asdf reshim rust
    end
end

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
