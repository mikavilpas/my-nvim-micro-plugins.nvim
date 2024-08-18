return {
  check = function()
    vim.health.start("my-nvim-micro-plugins")

    local plugin = require("my-nvim-micro-plugins.main")
    local msg = string.format("Running version %s", plugin.version)
    vim.health.info(msg)

    if vim.fn.executable("fd") ~= 1 then
      vim.health.warn("fd not found on PATH")
    end

    if vim.fn.executable("rg") ~= 1 then
      vim.health.warn("rg not found on PATH")
    end

    local realpath_command = plugin.config.realpath_command
    if vim.fn.executable(realpath_command) ~= 1 then
      vim.health.warn(
        string.format(
          "realpath_command '%s' not found on PATH",
          realpath_command
        )
      )
    end

    vim.health.ok("my-nvim-micro-plugins")
  end,
}
