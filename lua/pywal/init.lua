local M = {}
local core = require('pywal.core')
local highlights = require('pywal.highlights')

local watcher = nil


function M.set_colors(opts)
  local colors = core.get_colors()
  vim.opt.termguicolors = true
  highlights.highlight_all(colors, opts)
  vim.notify("new colors set", vim.log.levels.INFO)
end

function M.watch_file(filepath)
  if watcher then
    M.stop_watching()
  end

  local expanded_path = vim.fn.expand(filepath)

  if vim.fn.filereadable(expanded_path) == 0 then
    vim.notify("File does not exist:" .. expanded_path, vim.log.levels.WARN)
    return false
  end

  watcher = vim.uv.new_fs_event()

  if not watcher then
    vim.notify("Failed to create watcher", vim.log.levels.ERROR)
    return false
  end

  local success, err = watcher:start(expanded_path, {}, function(err, _fname, events)
    if err then
      vim.notify("File watcher error: " .. err, vim.log.levels.ERROR)
      return
    end

    if events.change then
      vim.defer_fn(function()
        -- do something
        M.set_colors(M.opts)
      end, 100)
    end
  end)

  if not success then
    vim.notify("Failed to start file watcher: " .. (err or "unknown error"), vim.log.levels.ERROR)
    watcher = nil
    return false
  end

  vim.notify("Started watching: " .. expanded_path, vim.log.levels.INFO)
  return true
end

function M.stop_watching()
  if watcher then
    watcher:stop()
    watcher:close()
    watcher = nil
  end
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    M.stop_watching()
  end,
})

function M.setup(opts)
  opts = opts or {
    transparent_bg = true,
    file = "/home/peter/.cache/wal/colors-wal.vim"
  }
  M.opts = opts
  M.set_colors(opts)
  if opts.file then
    M.watch_file(opts.file)
  end
end

return M
