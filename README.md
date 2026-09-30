# dsrv.nvim

Neovim language support for DSRV, intended to mirror the core features of the DSRV editor extensions.

## Features

- `*.dsrv` filetype detection
- Tree-sitter highlighting using the standalone `tree-sitter-dsrv` grammar
- Vim syntax fallback when tree-sitter is not available
- Basic editor settings for comments and indentation
- LSP startup for `dsrv-lsp`
  - diagnostics
  - hover documentation
  - completions
- Runner commands equivalent to the VS Code extension commands

## Requirements

- Neovim 0.10+ recommended
- `dsrv-lsp` available on `PATH` for LSP features
- Optional: [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) for tree-sitter highlighting; the DSRV parser must then be installed once by hand (see [Tree-sitter setup](#tree-sitter-setup))
- Optional: `trustworthiness_checker` available on `PATH` for run commands

Install the LSP from its repository, or build it from source:

```sh
cargo install --git https://github.com/INTO-CPS-Association/dsrv-lsp.git --locked
```

Make sure `~/.local/bin` is on your `PATH` before starting Neovim.

## Installation

### lazy.nvim

```lua
{
  "INTO-CPS-Association/dsrv.nvim",
  ft = "dsrv",
  config = function()
    require("dsrv").setup({
      lsp = {
        cmd = { "dsrv-lsp" },
      },
      runner = {
        checker_cmd = "trustworthiness_checker",
      },
    })
  end,
}
```

### packer.nvim

```lua
use {
  "INTO-CPS-Association/dsrv.nvim",
  config = function()
    require("dsrv").setup()
  end,
}
```

### Built-in packages

```sh
mkdir -p ~/.local/share/nvim/site/pack/dsrv/start
git clone https://github.com/INTO-CPS-Association/dsrv.nvim.git \
  ~/.local/share/nvim/site/pack/dsrv/start/dsrv.nvim
```

Then restart Neovim.

## Tree-sitter setup

Tree-sitter highlighting needs the DSRV parser, which is **not installed automatically**. Install it once, by hand:

1. Install [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) and its requirements. Both of its branches are supported:
   - `main` (its current default): requires Neovim 0.11+, a C compiler, and the [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter/tree/master/crates/cli) (for example `cargo install tree-sitter-cli --locked`).
   - `master` (legacy): requires a C compiler.
2. Open any `*.dsrv` file. dsrv.nvim registers the `dsrv` parser with nvim-treesitter when it loads; if you lazy-load it with `ft = "dsrv"`, that only happens once a DSRV buffer is open, and `:TSInstall dsrv` fails before then.
3. Run:

   ```vim
   :TSInstall dsrv
   ```

4. Reload the buffer with `:edit`. The plugin starts tree-sitter highlighting for DSRV buffers, and later sessions highlight straight away.

The parser is built from `https://github.com/INTO-CPS-Association/tree-sitter-dsrv.git`. Run `:TSUpdate dsrv` to update it after grammar changes.

Until the parser is installed, or if nvim-treesitter is not installed at all, Neovim uses the Vim syntax fallback in `syntax/dsrv.vim`.

To use a local grammar checkout or fork instead of the default published grammar repository:

```lua
require("dsrv").setup({
  treesitter = {
    parser_url = "/path/to/tree-sitter-dsrv",
  },
})
```

## Configuration

Default configuration:

```lua
require("dsrv").setup({
  lsp = {
    enable = true,
    cmd = { "dsrv-lsp" },
    root_markers = { "dsrv.toml", ".git" },
  },
  treesitter = {
    enable = true,
    register_parser = true,
    parser_url = nil, -- defaults to https://github.com/INTO-CPS-Association/tree-sitter-dsrv.git
  },
  runner = {
    checker_cmd = "trustworthiness_checker",
    parser = "lalr",
    language = "dsrv",
    default_input_extension = ".input",
    terminal_cmd = "botright split | terminal ",
  },
})
```

If the LSP is not on `PATH`, configure an absolute path:

```lua
require("dsrv").setup({
  lsp = {
    cmd = { "/home/you/.local/bin/dsrv-lsp" },
  },
})
```

If the trustworthiness checker is not on `PATH`:

```lua
require("dsrv").setup({
  runner = {
    checker_cmd = "/path/to/trustworthiness_checker",
  },
})
```

## Commands

| Command | Description |
|---|---|
| `:DsrvRun` | Run current `.dsrv` file with sibling `.input` file and untyped semantics |
| `:DsrvRunWithInput` | Prompt for an input file and run with untyped semantics |
| `:DsrvRunTyped` | Run current `.dsrv` file with sibling `.input` file and typed semantics |
| `:DsrvRunTypedWithInput` | Prompt for an input file and run with typed semantics |

The runner commands execute:

```sh
trustworthiness_checker --parser lalr --language dsrv --semantics untimed --input-file INPUT MODEL
```

or:

```sh
trustworthiness_checker --parser lalr --language dsrv --semantics typed-untimed --input-file INPUT MODEL
```

## LSP troubleshooting

Check whether Neovim started the server:

```vim
:LspInfo
```

Check whether the binary is visible to Neovim:

```vim
:echo executable('dsrv-lsp')
```

For hover documentation, diagnostics, and completion to work, the buffer must have filetype `dsrv` and the LSP client must be attached.

Useful commands:

```vim
:set filetype?
:lua print(vim.inspect(vim.lsp.get_clients({ bufnr = 0 })))
:lua vim.lsp.buf.hover()
:lua vim.diagnostic.setqflist()
```

## License

This project is licensed under the INTO-CPS Association Public License (ICAPL). The selected usage mode is documented in `ICA-USAGE-MODE.txt`. See `LICENSE.md`.
