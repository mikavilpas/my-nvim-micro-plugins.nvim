local mode = vim.fn.mode()
local is_visual_line = mode:sub(1, 1) == "V"
local is_visual_block = mode:sub(1, 1) == "\22"
