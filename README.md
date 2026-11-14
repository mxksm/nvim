**This is my nvim config based on NvChad**

Themes use their own opaque background. When running in the accompanying WezTerm
configuration, `Space th` also updates the terminal palette, including previews
and cancellation. This keeps the shell and editor backgrounds matched without
restricting Neovim to the terminal’s preset themes. The integration is in
`lua/configs/wezterm_theme.lua` and activates only inside WezTerm.

The theme picker starts in normal mode: `j`/`k` preview themes, `i` searches,
Enter confirms, and Escape in normal mode closes it. The terminal sync also
checks colors when input settles, covering themes that omit change events.
