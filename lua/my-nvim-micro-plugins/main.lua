---@module "plenary"
---@module "telescope"

local plugin = require("my-nvim-micro-plugins")

local M = {}

-- Copy the relative path of the selected file to the system clipboard.
-- Can only be used in a file picker.
function M.my_copy_relative_path(prompt_bufnr)
  local current_file_dir = vim.fn.expand("#:p:h")
  if current_file_dir == nil then
    error("no current_file_dir, cannot do anything")
  end

  local Path = require("plenary.path")
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local picker = action_state.get_current_picker(prompt_bufnr)

  local multi_selection = picker:get_multi_selection()

  local selected_files = nil

  if multi_selection ~= nil and #multi_selection > 0 then
    selected_files = vim
      .iter(multi_selection)
      :map(function(entry)
        assert(
          type(entry) == "table",
          "entry is not a table - it's " .. vim.inspect(entry)
        )
        local filename = entry.filename
        return Path:new(entry.cwd, filename):__tostring()
      end)
      :totable()
  else
    -- single selection
    local selection = action_state.get_selected_entry()

    if selection == nil then
      error("no selection, cannot continue")
    end

    selected_files =
      { Path:new(selection.cwd, selection.filename):__tostring() }
  end

  ---@type string[]
  local relative_paths = {}
  for _, selected_file in ipairs(selected_files) do
    local relative_path =
      M.relative_path_to_file(current_file_dir, selected_file)
    table.insert(relative_paths, relative_path)
  end
  local text = table.concat(relative_paths, "\n")

  vim.fn.setreg(plugin.config.clipboard_register, text)

  -- display a message with the relative paths
  -- vim.api.nvim_echo({ { "Copied: ", "Normal" }, { text, "String" } }, true, {})

  actions.close(prompt_bufnr)
end

---@param current_file_dir string
---@param selected_file string
---@return string
function M.relative_path_to_file(current_file_dir, selected_file)
  local telescopeUtils = require("telescope.utils")
  local stdout, ret, stderr = telescopeUtils.get_os_command_output({
    plugin.config.realpath_command,
    "--relative-to",
    current_file_dir,
    selected_file,
  })

  if ret ~= 0 or stdout == nil or stdout == "" then
    print(vim.inspect(stderr))
    error("error running command, exit code " .. ret)
  end

  local relative_path = stdout[1]

  return relative_path
end

---@param cwd string
local function find_git_root(cwd)
  local obj = vim
    .system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = cwd })
    :wait()

  if obj.code == 0 then
    local lines = vim.split(obj.stdout, "\n")
    return lines[1]
  end
end

---@param current_file_dir? string
---@param git_root_finder_function? fun(path: string): string # strategy to find the git root when given a directory
function M.find_project_root(current_file_dir, git_root_finder_function)
  git_root_finder_function = git_root_finder_function or find_git_root
  current_file_dir = current_file_dir or vim.fn.expand("%:p:h")
  assert(
    vim.fn.isdirectory(current_file_dir) == 1,
    "current_file_dir is not a directory: " .. current_file_dir
  )

  local found = git_root_finder_function(current_file_dir)

  if found == nil then
    error(string.format("Project root not found in %s", current_file_dir))
  elseif found:match(".git$") then
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

  require("telescope.builtin").find_files({
    find_command = { "fd", "--hidden" },
    prompt_title = "Find files in " .. cwd,
    cwd = cwd,
    search_file = selection,
  })
end

-- Search for the current visual mode selection.
-- Like the built in live_grep but with the options that I like, plus some
-- documentation on how the whole thing works.
---@param options { cwd: string? }
function M.my_live_grep(options)
  local cwd = (options or {}).cwd or M.find_project_root()
  local selection = M.get_visual()

  -- pro tip: search for an initial, wide result with this, and then hit
  -- c-spc to use fuzzy matching to narrow it down
  require("telescope.builtin").live_grep({
    cwd = cwd,
    prompt_title = "Live grep in " .. cwd,
    default_text = selection,
    only_sort_text = true,
    additional_args = function()
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
      return { "--pcre2", "--hidden", "--smart-case" }
    end,
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
