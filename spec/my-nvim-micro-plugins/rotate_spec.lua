local rotate = require("my-nvim-micro-plugins.rotate")
local assert = require("luassert")
local reset = require("spec.my-nvim-micro-plugins.helpers.reset")
local windows = require("spec.my-nvim-micro-plugins.helpers.windows")

local a_void_walker = "a_void_walker.txt"
local b_sakura_petals = "b_sakura_petals.txt"
local c_whispering_forest = "c_whispering_forest.txt"

describe("rotating one window", function()
  it("does nothing", function()
    reset.clear_all_buffers()
    reset.close_all_windows()

    vim.cmd("edit " .. a_void_walker)
    assert.are.same({ a_void_walker }, windows.list_windows_and_files())

    -- act
    assert.has_error(function()
      rotate.rotate_window()
    end, "Only one window, no rotation needed")
  end)
end)

describe("rotating 2 windows", function()
  before_each(function()
    reset.clear_all_buffers()
    reset.close_all_windows()

    -- create three windows with different files
    vim.cmd("edit " .. b_sakura_petals)
    vim.cmd("vsplit " .. a_void_walker)

    assert.are.same({
      a_void_walker,
      b_sakura_petals,
    }, windows.list_windows_and_files())
  end)

  it("can rotate the first window with the second", function()
    assert.are.equal(a_void_walker, windows.get_current_window_file())

    -- act
    rotate.rotate_window()

    assert.are.equal(a_void_walker, windows.get_current_window_file())

    assert.are.same({
      b_sakura_petals,
      a_void_walker,
    }, windows.list_windows_and_files())
  end)
end)

describe("rotating 3 windows", function()
  before_each(function()
    reset.clear_all_buffers()
    reset.close_all_windows()

    -- create three windows with different files
    vim.cmd("edit  c_whispering_forest.txt")
    vim.cmd("vsplit " .. b_sakura_petals)
    vim.cmd("vsplit " .. a_void_walker)

    assert.are.same({
      a_void_walker,
      b_sakura_petals,
      c_whispering_forest,
    }, windows.list_windows_and_files())
  end)

  it("can rotate the first window with the second", function()
    assert.are.equal(a_void_walker, windows.get_current_window_file())

    -- act
    rotate.rotate_window()

    assert.are.same({
      b_sakura_petals,
      a_void_walker,
      c_whispering_forest,
    }, windows.list_windows_and_files())
    assert.are.equal(a_void_walker, windows.get_current_window_file())
  end)

  it("can rotate the second window with the third", function()
    vim.cmd("wincmd w")
    assert.are.equal(b_sakura_petals, windows.get_current_window_file())

    -- act
    rotate.rotate_window()

    assert.are.same({
      a_void_walker,
      c_whispering_forest,
      b_sakura_petals,
    }, windows.list_windows_and_files())
    assert.are.equal(b_sakura_petals, windows.get_current_window_file())
  end)

  it("can rotate the third window with the first", function()
    vim.cmd("wincmd w")
    vim.cmd("wincmd w")
    assert.are.equal(c_whispering_forest, windows.get_current_window_file())

    -- act
    rotate.rotate_window()

    assert.are.same({
      a_void_walker,
      c_whispering_forest,
      b_sakura_petals,
    }, windows.list_windows_and_files())
    assert.are.equal(c_whispering_forest, windows.get_current_window_file())
  end)
end)
