{ config, pkgs, lib, ... }:

{
  programs.neovim = {
	  enable = true;
	  defaultEditor = true;
	  viAlias = true;
	  vimAlias = true;
    plugins = [ pkgs.vimPlugins.lazy-nvim ];
	  extraConfig = ''
		set tabstop=2 softtabstop=2 shiftwidth=2
		set expandtab
		set number ruler
		set autoindent smartindent
		syntax enable
		filetype plugin indent on

	  '';
  };


}