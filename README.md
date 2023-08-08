# hephy.nvim

[Heavy work in Progress] A plugin manager for Neovim written in Lua.

## Installation

If you wanna try nevertheless then,

```bash
git clone https://github.com/zukijifukato/hephy.nvim.git ~/.local/share/nvim/site/pack/hephy/start/hephy.nvim
```

## Usage

Using lazy loading options like `cmd`, `event`, `key`, `ft` automatically lazy loads the plugin. Here is a demo config.

```lua
require("hephy").setup({
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lsp")
    end,
    event = "InsertEnter"
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust"
  },

  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("treesitter")
    end,
    event = "BufReadPre"
  },

  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("tree")
    end,
    key = { "<leader>ntt" },
    cmd = { "NvimTreeToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },

  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("fuzzyfind")
    end,
    key = { "<leader>ff", "<leader>fg", "<leader>fh" },
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  "nvim-lualine/lualine.nvim",
  "folke/tokyonight.nvim",
})
```

## Inspirations

Heavily inspired from

- [packer.nvim](https://github.com/wbthomason/packer.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
