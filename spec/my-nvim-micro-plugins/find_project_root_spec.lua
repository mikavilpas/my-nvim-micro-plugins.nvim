local main = require("my-nvim-micro-plugins.main")

it("can find the root when in a .git directory", function()
  local starting_dir = vim.fn.getcwd()
  vim.cmd("edit .git/file")
  local root = main.find_project_root()
  assert.are.same(starting_dir, root)
end)
