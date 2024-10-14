local M = {}

function M.list_windows_and_files()
  local win_count = vim.fn.winnr("$")
  local result = {}

  for i = 1, win_count do
    local bufnr = vim.fn.winbufnr(i)
    local filename = vim.fn.bufname(bufnr)
    table.insert(result, (filename == "" and "[No File]" or filename))
  end

  return result
end

function M.get_current_window_file()
  return vim.fn.expand("%:t")
end

return M
