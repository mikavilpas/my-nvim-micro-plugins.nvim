local main = require("my-nvim-micro-plugins.main")
local assert = require("luassert")

describe("comment_line", function()
  before_each(function()
    -- remove all buffers from other tests
    vim.cmd("silent! %bwipeout!")

    vim.cmd("new test.lua")
    vim.cmd("set filetype=lua")
    vim.o.commentstring = "-- %s"
  end)

  it("can comment the current line", function()
    vim.cmd("normal! ihello")
    main.comment_line()
    assert.are_same(
      { "-- hello", "hello" },
      vim.api.nvim_buf_get_lines(0, 0, -1, false)
    )
  end)

  it("makes the cursor stay in the same position", function()
    vim.cmd("normal! ihello, world")
    vim.cmd("normal! $bi|")

    assert.are_same(
      { "hello, |world" },
      vim.api.nvim_buf_get_lines(0, 0, -1, false)
    )

    main.comment_line()
    vim.cmd("normal xi|")

    assert.are_same({
      "-- hello, |world",
      "hello, |world",
    }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end)
end)
