local ls = require('luasnip')

local i = ls.insert_node
local s = ls.snippet
local t = ls.text_node


return {
	s('flake', {
		t({
			'{',
			'  description = "'
		}),
		i(1, 'Your flake description...'),
		t({
			'";',
			'',
			'  inputs = {',
			'    flake-utils.url = "github:numtide/flake-utils";',
			'    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";',
			'  };',
			'',
			'  outputs = { self, flake-utils, nixpkgs }:',
			'    flake-utils.lib.eachDefaultSystem (system:',
			'      let',
			'        pkgs = nixpkgs.legacyPackages.${system};',
			'      in {',
			'        '
		}),
		i(2),
		t({
			'',
			'    });',
			'}',
		}),
	}),


	s('shell-flake', {
		t({
			'{',
			'  description = "'
		}),
		i(1, 'Your flake description...'),
		t({
			'";',
			'',
			'  inputs = {',
			'    flake-utils.url = "github:numtide/flake-utils";',
			'    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";',
			'  };',
			'',
			'  outputs = { self, flake-utils, nixpkgs }:',
			'    flake-utils.lib.eachDefaultSystem (system:',
			'      let',
			'        pkgs = nixpkgs.legacyPackages.${system};',
			'      in {',
			'        devShells.default = pkgs.mkShell {',
			'          packages = with pkgs; [',
			'            '
		}),
		i(2),
		t({
			'',
			'          ];',
			'        };',
			'    });',
			'}',
		}),
	}),
}
