local M = {}
local config = require('pywal.config')

function M.highlight_all(colors, user_config)
  local base_highlights = config.highlights_base(colors)
  
  -- Apply transparent background if enabled
  if user_config and user_config.transparent_bg then
    for group, properties in pairs(base_highlights) do
      if properties.bg and properties.bg == colors.background then
        properties.bg = "none"
      end
    end
  end
  
  -- Apply highlights
  for group, properties in pairs(base_highlights) do
    vim.api.nvim_set_hl(0, group, properties)
  end
end

return M
