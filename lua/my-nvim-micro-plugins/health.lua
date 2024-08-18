--- @param app_name string
--- @param input string
local function parse_version(app_name, input)
  local version = input:match("(%w+%.%w+%.%w+)")
  if version == nil then
    error(string.format("could not parse '%s' version from input", app_name))
  end

  vim.health.info(
    string.format("found '%s' version `%s`", app_name, vim.inspect(version))
  )

  return vim.version.parse(version)
end

return {
  check = function()
    vim.health.start("my-nvim-micro-plugins")

    local plugin = require("my-nvim-micro-plugins.main")
    local msg = string.format("Running version %s", plugin.version)
    vim.health.info(msg)

    if vim.fn.executable("fd") ~= 1 then
      vim.health.warn("'fd' not found on PATH")
    else
      local fd_version = parse_version("fd", vim.fn.system("fd --version"))

      if not vim.version.ge(fd_version, "8.3.1") then
        vim.health.warn("'fd' version is less than 8.3.1")
      end
    end

    if vim.fn.executable("rg") ~= 1 then
      vim.health.warn("'rg' not found on PATH")
    else
      local rg_version = parse_version("rg", vim.fn.system("rg --version"))

      if not vim.version.ge(rg_version, "13.0.0") then
        vim.health.warn("'rg' version is less than 13.0.0")
      end
    end

    local realpath_command = plugin.config.realpath_command
    if (not realpath_command) or vim.fn.executable(realpath_command) ~= 1 then
      vim.health.warn(
        string.format(
          "realpath_command '%s' not found on PATH",
          realpath_command
        )
      )
    else
      vim.health.info(string.format("found realpath as '%s'", realpath_command))
    end

    vim.health.ok("my-nvim-micro-plugins")
  end,
}
