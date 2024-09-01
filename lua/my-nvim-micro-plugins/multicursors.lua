local M = {}

local function get_current_visual_selection_line_numbers()
  local mode = vim.fn.mode()

  -- Ensure we're in Visual mode (either character, line, or block)
  if
    mode:sub(1, 1) == "v"
    or mode:sub(1, 1) == "V"
    or mode:sub(1, 1) == "\22"
  then
    -- Get the line numbers of the start and end of the selection
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    -- Sort the lines to make sure start_line is always less than or equal to end_line
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    return start_line, end_line
  end
end

---@param start_line number
---@param end_line number
---@param motion? string
local function add_line_multicursors(start_line, end_line, motion)
  -- return to normal mode from visual mode
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<esc>", true, false, true),
    "x",
    false
  )

  vim.cmd("normal! " .. start_line .. "G")
  if motion then
    vim.cmd("normal! " .. motion)
  end

  local mc = require("multicursor-nvim")
  for _ = start_line, end_line - 1, 1 do
    mc.addCursor("j" .. (motion or ""))
  end
end

function M.add_multicursors_at_line_starts()
  local mode = vim.fn.mode()
  local is_visual_line = mode:sub(1, 1) == "V"
  local is_visual_block = mode:sub(1, 1) == "\22"

  local start_line, end_line = get_current_visual_selection_line_numbers()

  if is_visual_line then
    add_line_multicursors(start_line, end_line, "_")
  elseif is_visual_block then
    add_line_multicursors(start_line, end_line)
  end
end

function M.add_multicursors_at_line_ends()
  local mode = vim.fn.mode()
  local is_visual_line = mode:sub(1, 1) == "V"
  local is_visual_block = mode:sub(1, 1) == "\22"

  local start_line, end_line = get_current_visual_selection_line_numbers()

  if is_visual_line then
    add_line_multicursors(start_line, end_line, "$")
  elseif is_visual_block then
    add_line_multicursors(start_line, end_line)
  end
end

return M
