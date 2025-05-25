local M = {}
local core = require('pywal.core')
local highlights = require('pywal.highlights')

-- Default configuration
local default_config = {
  transparent_bg = false
}

-- User configuration
local user_config = default_config

function M.setup(opts)
  -- Merge user options with defaults
  if opts then
    user_config = vim.tbl_deep_extend("force", default_config, opts)
  end

  local colors = core.get_colors()
  vim.opt.termguicolors = true
  highlights.highlight_all(colors, user_config)
end

return M
