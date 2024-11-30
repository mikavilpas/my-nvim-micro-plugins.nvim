local M = {}

local function exchange()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-w><C-x>", true, false, true),
    "nx",
    true
  )
end

function M.rotate_window()
  local wind_id = vim.fn.win_getid()

  exchange()

  vim.fn.win_gotoid(wind_id)
end

return M
