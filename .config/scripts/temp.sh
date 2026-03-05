#!/bin/bash
cat << 'EOF' > ~/.config/nvim/lua/config/autocmds.lua
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  callback = function()
    package.loaded["pywal"] = nil
    package.loaded["pywal.colors"] = nil
    package.loaded["pywal.core"] = nil
    pcall(vim.cmd, "colorscheme pywal")
  end,
})

local uv = vim.uv or vim.loop
local wal_dir = vim.fn.expand("~/.cache/wal")

if vim.fn.isdirectory(wal_dir) == 1 then
  local watcher = uv.new_fs_event()
  watcher:start(wal_dir, {}, function(err, filename, events)
    if not err and filename == "colors.json" then
      vim.schedule(function()
        package.loaded["pywal"] = nil
        package.loaded["pywal.colors"] = nil
        package.loaded["pywal.core"] = nil
        pcall(vim.cmd, "colorscheme pywal")
      end)
    end
  end)
end
EOF
