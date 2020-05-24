#!/bin/bash

DIR="$(dirname "$0")"

installVimPlug()
{
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

installVimRc()
{
    cp ${DIR}/.vimrc ~/
}

installPlugins()
{
    vim +PlugInstall +q
}

installCocConfig()
{
    cp ${DIR}/.coc-settings.json ~/.vim
}

installLanguageServers()
{
    pip3 install pyls
    pip3 install cmake-language-server
    sudo snap install bash-language-server
    sudo apt install clangd-9
}

main()
{
    installVimPlug
    installVimRc
    installPlugins
    installCocConfig
    installLanguageServers
}

main "$@"
