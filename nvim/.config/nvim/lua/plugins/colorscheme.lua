-- Low saturation rather than pure monochrome: syntax highlighting has to stay
-- readable against the #0f0f0f background the rest of the setup uses.
return {
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "kanagawa-dragon" },
  },
}
