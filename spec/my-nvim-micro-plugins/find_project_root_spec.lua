local main = require("my-nvim-micro-plugins.main")
local spy = require("luassert.spy")
local assert = require("luassert")

describe("climbing up from .git", function()
  it(
    "retries with the parent directory if the current directory is .git",
    function()
      local base_dir = vim.fn.tempname()
      vim.fn.mkdir(base_dir, "p")

      local git_root_finder_function = spy.new(function()
        -- simulate the case where the root is found
        return ".git"
      end) --[[@as fun(): string]]

      main.find_project_root(base_dir, git_root_finder_function)

      assert.spy(git_root_finder_function).was_called_with(base_dir)
      assert
        .spy(git_root_finder_function)
        .was_called_with(vim.fs.joinpath(base_dir, ".."))
    end
  )

  it(
    "does not retry with the parent directory if the current directory is not exactly '.git'",
    function()
      local base_dir = vim.fn.tempname()
      vim.fn.mkdir(base_dir, "p")

      local git_root_finder_function = spy.new(function()
        -- simulate the case where the root is found but not exactly '.git'
        return ".gitsomething"
      end) --[[@as fun(): string]]

      main.find_project_root(base_dir, git_root_finder_function)

      assert.spy(git_root_finder_function).was_called_with(base_dir)
      assert
        .spy(git_root_finder_function)
        .was_not_called_with(vim.fs.joinpath(base_dir, ".."))
    end
  )
end)

it("raises an error if the root is not found", function()
  local base_dir = vim.fn.tempname()
  vim.fn.mkdir(base_dir, "p")

  local git_root_finder_function = spy.new(function()
    -- simulate the case where the root is not found
    return nil
  end) --[[@as fun(): string]]

  assert.has_error(function()
    main.find_project_root(base_dir, git_root_finder_function)
  end, "Project root not found in " .. base_dir)
end)
