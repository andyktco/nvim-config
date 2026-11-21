-- PhpStorm-like git diff: list of changed files + side-by-side diff
-- https://github.com/dlyongemallo/diffview.nvim (maintained fork of sindrets/diffview.nvim)
vim.pack.add { 'https://github.com/dlyongemallo/diffview.nvim' }

require('diffview').setup {
  enhanced_diff_hl = true, -- better colors for changed lines
  view = {
    merge_tool = { layout = 'diff3_mixed' }, -- conflicts: ours | result | theirs
  },
}

vim.keymap.set('n', '<leader>gd', '<Cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff (changed files)' })
vim.keymap.set('n', '<leader>gh', '<Cmd>DiffviewFileHistory %<CR>', { desc = '[G]it [H]istory of current file' })
vim.keymap.set('n', '<leader>gH', '<Cmd>DiffviewFileHistory<CR>', { desc = '[G]it [H]istory of the repo' })
vim.keymap.set('n', '<leader>gq', '<Cmd>DiffviewClose<CR>', { desc = '[G]it diff [Q]uit' })
