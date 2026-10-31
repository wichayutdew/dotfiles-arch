function update --description 'Run system and tool updates'
    yay -Syu
    mise upgrade
    mise prune --yes
    npx skills update
    yay -Scc --noconfirm
    yay -Ycc --noconfirm
end