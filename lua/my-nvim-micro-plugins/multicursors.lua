local M = {}

local visual_block_mode =
  vim.api.nvim_replace_termcodes("<C-v>", true, false, true)
assert(visual_block_mode == "\22", "Visual block mode key is not ^V")

local function get_current_visual_selection_line_numbers()
  local mode = vim.fn.mode()

  -- Ensure we're in Visual mode (either character, line, or block)
  if
    mode:sub(1, 1) == "v"
    or mode:sub(1, 1) == "V"
    or mode:sub(1, 1) == visual_block_mode
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

function M.add_multicursors_at_line_starts()
  local mc = require("multiple-cursors")
  mc.setup()

  local start_line, end_line = get_current_visual_selection_line_numbers()
  local mode = vim.fn.mode()
  mc.normal_escape()

  if mode:sub(1, 1) == visual_block_mode then
    local col = vim.fn.col("v")
    for i = start_line, end_line do
      mc.add_cursor(i, col, col)
    end
    return
  end

  vim.cmd("normal! ^")
  for i = start_line, end_line do
    local first_character_col = vim.fn.indent(i) + 1
    mc.add_cursor(i, first_character_col, 1)
  end
end

function M.add_multicursors_at_line_ends()
  local mc = require("multiple-cursors")
  mc.setup()

  local start_line, end_line = get_current_visual_selection_line_numbers()
  vim.cmd("normal! $")

  mc.normal_escape()
  for i = start_line, end_line do
    local last_character_col = vim.fn.col("$")
    mc.add_cursor(i, last_character_col, last_character_col)
  end
end

return M
