local M = {}

M.version = "1.7.2" -- x-release-please-version

---@class (exact) my-nvim-micro-plugins.Config
---@field realpath_command? string the realpath (linux) / grealpath (osx) command to use on your system
---@field clipboard_register? string the register to use for the clipboard, defaults to "*"
M.config = {
  realpath_command = vim.uv.os_uname().sysname == "Darwin" and "grealpath"
    or "realpath",
  clipboard_register = "*",
}

---@param config my-nvim-micro-plugins.Config
function M.setup(config)
  M.config = vim.tbl_extend("force", M.config, config or {})

  require("snacks.picker").actions["my_copy_relative_path"] =
    require("my-nvim-micro-plugins.main").my_copy_relative_path
end

return M
