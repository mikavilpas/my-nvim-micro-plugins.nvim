local M = {}

local function exchange()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-w><C-x>", true, false, true),
    "nx",
    true
  )
end

function M.rotate_window()
  -- Get the total number of windows
  local win_count = vim.fn.winnr("$")

  if win_count == 1 then
    error("Only one window, no rotation needed")
  end

  -- Get the current window number
  local start_win = vim.fn.winnr()

  if start_win < win_count then
    -- need to swap with the next window.
    exchange()
    vim.cmd("wincmd w")
  else
    -- need to swap with the previous window
    exchange()
    vim.cmd("wincmd W")
  end
end

return M
