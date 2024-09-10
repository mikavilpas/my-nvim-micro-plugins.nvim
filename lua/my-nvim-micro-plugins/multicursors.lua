local M = {}

function M.add_multicursors_at_line_starts()
  local mc = require("multicursor-nvim")
  mc.visualToCursors()
end

function M.add_multicursors_at_line_ends()
  local mc = require("multicursor-nvim")
  mc.visualToCursors()
  mc.perform("$")
end

return M
