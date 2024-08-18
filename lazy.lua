---@module "lazy"

---@type LazySpec
return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "nvim-telescope/telescope.nvim", lazy = true },
  {
    "mikavilpas/my-nvim-micro-plugins.nvim",
    lazy = true,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
  },
}
