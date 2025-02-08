---@module "plenary"
---@module "snacks"

local plugin = require("my-nvim-micro-plugins")

local M = {}

-- Copy the relative path of the selected file to the system clipboard.
---@param picker snacks.Picker
function M.my_copy_relative_path(picker)
  local current_file_dir = vim.fn.expand("#:p:h")
  if current_file_dir == nil then
    error("no current_file_dir, cannot do anything")
  end
  local cwd = picker.finder.filter.cwd
  assert(cwd, "cwd is nil")

  -- local multi_selection = picker:get_multi_selection()
  local selected_files = picker:selected({ fallback = true })

  ---@type string[]
  local relative_paths = {}
  for _, selected_file in ipairs(selected_files) do
    local full_path = vim.fs.joinpath(cwd, assert(selected_file.file))
    local relative_path = M.relative_path_to_file(current_file_dir, full_path)
    table.insert(relative_paths, relative_path)
  end
  local text = table.concat(relative_paths, "\n")

  vim.fn.setreg(plugin.config.clipboard_register, text)

  -- display a message with the relative paths
  -- vim.api.nvim_echo({ { "Copied: ", "Normal" }, { text, "String" } }, true, {})

  picker:close()
end

---@param current_file_dir string
---@param selected_file string
---@return string
function M.relative_path_to_file(current_file_dir, selected_file)
  local result = vim
    .system({
      plugin.config.realpath_command,
      "--relative-to",
      current_file_dir,
      selected_file,
    }, {
      text = true,
      cwd = vim.uv.cwd(),
    })
    :wait(1000)

  if result.code ~= 0 or result.stdout == nil or result.stdout == "" then
    print(vim.inspect(result.stderr))
    error("error running command, exit code " .. result.code)
  end

  local relative_path = assert(result.stdout)
  -- remove the trailing newline
  relative_path = string.gsub(relative_path, "\n$", "")

  return relative_path
end

---@param current_file_dir? string
---@param git_root_finder_function? fun(path: string): string # strategy to find the git root when given a directory
function M.find_project_root(current_file_dir, git_root_finder_function)
  git_root_finder_function = git_root_finder_function
    or require("snacks.git").get_root
  current_file_dir = current_file_dir or vim.fn.expand("%:p:h")
  assert(
    vim.fn.isdirectory(current_file_dir) == 1,
    "current_file_dir is not a directory: " .. current_file_dir
  )

  local found = git_root_finder_function(current_file_dir)

  if found == nil then
    error(string.format("Project root not found in %s", current_file_dir))
  elseif found:match("%.git$") then
    return git_root_finder_function(vim.fs.joinpath(current_file_dir, ".."))
  else
    return found
  end
end

--
-- search for the current visual mode selection
-- https://github.com/nvim-telescope/telescope.nvim/issues/2497#issuecomment-1676551193
function M.get_visual()
  vim.cmd('noautocmd normal! "vy"')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text or "", "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end

-- Find files from the root of the current repository.
-- Does not search parents if we're currently in a submodule.
function M.my_find_file_in_project()
  local cwd = M.find_project_root()
  local selection = M.get_visual()

  require("snacks.picker").files({
    cmd = "fd",
    title = "🔎 " .. cwd,
    search = selection,
    args = { "--hidden" },
    actions = {
      ["my_copy_relative_path"] = M.my_copy_relative_path,
    },
  })
end

-- Search for the current visual mode selection.
-- Like the built in live_grep but with the options that I like, plus some
-- documentation on how the whole thing works.
---@param options? { cwd: string? }
function M.my_live_grep(options)
  local cwd = (options or {}).cwd or M.find_project_root()
  local selection = M.get_visual()

  require("snacks.picker").grep({
    search = selection,
    cwd = cwd,
    title = "🔎 " .. cwd,

    -- --pcre2
    -- The --pcre2 flag in ripgrep is used to enable the PCRE2 (Perl
    -- Compatible Regular Expressions) engine for pattern matching.
    -- PCRE2 is an optional feature in ripgrep that provides more
    -- advanced regex features such as look-around and backreferences,
    -- which are not supported by ripgrep's default regex engine 134.

    -- --smart-case
    -- This flag instructs ripgrep to searches case insensitively if
    -- the pattern is all lowercase. Otherwise, ripgrep will search
    -- case sensitively.

    -- NOTE: the ~/.gitignore and ~/.rgignore files will have an effect on
    -- what is ignored
    -- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering
    args = { "--pcre2", "--hidden", "--smart-case" },
    actions = {
      ["my_copy_relative_path"] = M.my_copy_relative_path,
    },
  })
end

-- comment the current line, copy it, and keep the cursor in the same position
--
-- -- hello, |world
-- hello, |world
function M.comment_line()
  local current_column = vim.fn.virtcol(".")
  -- yank the current line and paste it below
  vim.cmd("normal yypk")

  -- comment the current line and indent
  vim.cmd("normal gccV=")

  -- move the cursor down
  vim.cmd("normal j")

  -- move the cursor to the same column as before
  vim.cmd("normal " .. current_column .. "|")
end

return M
