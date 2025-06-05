-- Make sure Lazy can be found
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

require("lazy").setup({
  { "folke/tokyonight.nvim", lazy = false, priority = 1000 },
})

vim.cmd[[colorscheme tokyonight]]

