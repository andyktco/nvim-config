-- Auto-reload files changed outside nvim (e.g. by Claude, git, scripts).
-- Buffers with unsaved changes are never overwritten: nvim asks first (W12).

vim.o.autoread = true

local function check()
  -- not while typing a command or answering a prompt
  local mode = vim.api.nvim_get_mode().mode
  if mode:match '^[cr]' or vim.fn.getcmdwintype() ~= '' then return end
  vim.cmd 'checktime'
end

local group = vim.api.nvim_create_augroup('custom-autoreload', { clear = true })

-- instant check when coming back to nvim or switching buffer/window
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  group = group,
  callback = check,
})

-- check every second, also when nvim is not focused (Claude editing in the next tmux pane)
local timer = vim.uv.new_timer()
if timer then timer:start(1000, 1000, vim.schedule_wrap(check)) end
vim.api.nvim_create_autocmd('VimLeavePre', {
  group = group,
  callback = function()
    if timer then timer:close() end
  end,
})

-- tell me when a file was reloaded
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = group,
  callback = function(args) vim.notify(vim.fn.fnamemodify(args.file, ':.') .. ' reloaded (changed on disk)', vim.log.levels.INFO) end,
})
