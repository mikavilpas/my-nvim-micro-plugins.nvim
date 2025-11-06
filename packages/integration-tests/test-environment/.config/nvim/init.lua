-- renovate: datasource=github-releases depName=folke/lazy.nvim
local lazy_version = "v11.17.5"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=" .. lazy_version,
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.swapfile = false

-- install the following plugins
---@type LazySpec
local plugins = {
  { "nvim-lua/plenary.nvim" },
  {
    "folke/snacks.nvim",
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      picker = {
        -- give more space for cypress to see the screen
        layout = {
          fullscreen = true,
        },
        formatters = {
          file = {
            -- make sure the text is not truncated in a narrow cypress window
            filename_first = true,
          },
        },
        win = {
          input = {
            keys = {
              ["<C-y>"] = { "my_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
  {
    "mikavilpas/my-nvim-micro-plugins.nvim",
    event = "VeryLazy",
    dir = "../../../",
    ---@type my-nvim-micro-plugins.Config
    opts = {
      -- in github actions, we don't have access to the clipboard, so just use
      -- some other register
      clipboard_register = "z",
    },
    keys = {
      {
        "<down>",
        mode = { "n", "v" },
        function()
          require("my-nvim-micro-plugins.main").my_find_file_in_project()
        end,
      },
      {
        "<leader>/",
        mode = { "n", "v" },
        function()
          require("my-nvim-micro-plugins.main").my_live_grep()
        end,
      },
      {
        "<c-w><c-r>",
        mode = { "n" },
        function()
          require("my-nvim-micro-plugins.rotate").rotate_window()
        end,
      },
    },
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")

      mc.setup()

      vim.keymap.set({ "v" }, "I", function()
        require("my-nvim-micro-plugins.multicursors").add_multicursors_at_line_starts()
      end)

      vim.keymap.set({ "v" }, "A", function()
        require("my-nvim-micro-plugins.multicursors").add_multicursors_at_line_ends()
      end)
    end,
  },
}
require("lazy").setup({ spec = plugins })

vim.cmd.colorscheme("catppuccin-macchiato")
