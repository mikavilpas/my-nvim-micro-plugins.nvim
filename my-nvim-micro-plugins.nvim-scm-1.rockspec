---@diagnostic disable: lowercase-global
rockspec_format = "3.0"
package = "my-nvim-micro-plugins.nvim"
version = "scm-1"
source = {
  url = "git+https://github.com/mikavilpas/my-nvim-micro-plugins.nvim",
}
dependencies = {
  -- Add runtime dependencies here
  -- e.g. "plenary.nvim",
  "plenary.nvim",
  "telescope.nvim",
}
test_dependencies = {
  "nlua",
}
build = {
  type = "builtin",
  copy_directories = {
    -- Add runtimepath directories, like
    -- 'plugin', 'ftplugin', 'doc'
    -- here. DO NOT add 'lua' or 'lib'.
  },
}