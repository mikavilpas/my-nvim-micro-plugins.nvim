-- This files defines how to initialize the test environment for the
-- integration tests. It should be executed before running the tests.

---@module "lazy"

-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.repro", ":p")
vim.env.LAZY_STDPATH = ".repro"

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v11.14.1",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.rtp:prepend("../../../lua")

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
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<down>",
        mode = { "n", "v" },
        function()
          require("my-nvim-micro-plugins.main").my_find_file_in_project()
        end,
        { desc = "Find files (including in git submodules)" },
      },
      {
        "<leader>/",
        mode = { "n", "v" },
        function(...)
          require("my-nvim-micro-plugins.main").my_live_grep(...)
        end,
        desc = "search project 🤞🏻",
      },
    },
    opts = {
      defaults = {
        preview = false,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },

        mappings = {
          n = {
            ["<C-y>"] = function(...)
              require("my-nvim-micro-plugins.main").my_copy_relative_path(...)
            end,
          },
          i = {
            ["<C-y>"] = function(...)
              require("my-nvim-micro-plugins.main").my_copy_relative_path(...)
            end,
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
