#!/bin/bash

DIR="$(dirname "$0")"
VIM_FILE_TYPE_DIR="~/.vim/ftplugin/"

installVimPlug()
{
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

installVimRc()
{
    cp ${DIR}/.vimrc ~/
    mkdir -f "${VIM_FILE_TYPE_DIR}"
    cp ${DIR}/kssLanguage.vim "${VIM_FILE_TYPE_DIR}"
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
    sudo apt install hoogle
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
