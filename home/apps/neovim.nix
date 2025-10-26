{ config, pkgs, lib, ... }:

let
	app = "nvim";

in {

	home.packages = [
		pkgs.ripgrep
    pkgs.tree-sitter
    pkgs.fd
	];
  programs.neovim = {
	  enable = true;
	  defaultEditor = true;
	  viAlias = true;
	  vimAlias = true;
		withPython3 = true;
		withNodeJs = true;
		withRuby = true;
    plugins = with pkgs.vimPlugins; [ 
			lazy-nvim 
			# nvim-treesitter.withPlugins
      claude-code-nvim
      nvim-treesitter-parsers.nix
      nvim-treesitter.withAllGrammars
		];
	  extraConfig = ''
			set tabstop=2 softtabstop=2 shiftwidth=2
			set expandtab
			set number ruler
			set autoindent smartindent
			syntax enable
			filetype plugin indent on
	  '';
		extraLuaConfig = 	
		# lua
		''
			require("config.lazy")
		'';
  };

	home.file = {
		"${app}/lua"= {
			enable = true;
			source = config.lib.meta.mkDotfilesSymLink ".config/${app}/lua";
			target = "${config.xdg.configHome}/${app}/lua";
		};

		"${app}/.neoconf.json"= {
			enable = true;
			source = config.lib.meta.mkDotfilesSymLink ".config/${app}/.neoconf.json";
			target = "${config.xdg.configHome}/${app}/.neoconf.json";
		};
	};


}
