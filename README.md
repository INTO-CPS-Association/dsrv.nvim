# dsrv.nvim

Neovim language support for DSRV, intended to mirror the core features of the Zed extension in this repository.

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
- Optional: [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) for tree-sitter highlighting
- Optional: `trustworthiness_checker` available on `PATH` for run commands

Build and install the LSP from the repository root:

```sh
cargo build --release -p DSRV-lsp
cp target/release/dsrv-lsp ~/.local/bin/dsrv-lsp
```

Make sure `~/.local/bin` is on your `PATH` before starting Neovim.

## Installation

### lazy.nvim

```lua
{
  dir = "/home/au759518/Documents/Research/Repositories/dsrv.nvim",
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
  "/home/au759518/Documents/Research/Repositories/dsrv.nvim",
  config = function()
    require("dsrv").setup()
  end,
}
```

### Built-in packages

```sh
mkdir -p ~/.local/share/nvim/site/pack/dsrv/start
ln -s /home/au759518/Documents/Research/Repositories/dsrv.nvim \
  ~/.local/share/nvim/site/pack/dsrv/start/dsrv.nvim
```

Then restart Neovim.

## Tree-sitter setup

The plugin registers the DSRV parser with `nvim-treesitter` if `nvim-treesitter` is installed. In this split repository layout it defaults to the sibling `../tree-sitter-dsrv` directory.

After installing the plugin, run:

```vim
:TSInstall dsrv
```

Then open `*.dsrv` files. The plugin also calls `vim.treesitter.start()` for DSRV buffers.

If tree-sitter is unavailable or the parser is not installed, Neovim falls back to `syntax/dsrv.vim`.

To use a published grammar repository instead of the sibling local checkout:

```lua
require("dsrv").setup({
  treesitter = {
    parser_url = "https://github.com/YOUR_ORG/tree-sitter-dsrv",
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
    parser_url = nil, -- defaults to ../tree-sitter-dsrv relative to this plugin
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
