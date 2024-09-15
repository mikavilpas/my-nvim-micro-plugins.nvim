local mode = vim.fn.mode()
local mode2 = vim.fn.mode()
for _ = 1, 10, 1 do
  local is_visual_line = mode:sub(1, 1) == "V"
end
local is_visual_block = mode:sub(1, 1) == "\22"
