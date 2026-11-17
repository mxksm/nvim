**Neovim configuration based on NvChad, with Sioyek's theme collection.**

`Space th` lists the same 26 themes as Sioyek, with the same display names.
The editor background and main text match the PDF page colors; floating panels
use Sioyek's panel colors. Syntax colors are derived from the annotation palette,
softened and adjusted for readability on both dark and light backgrounds.

The picker starts in normal mode: `j`/`k` preview themes, `/` or `i` searches,
Enter keeps the choice, and Escape in normal mode restores the saved theme.
Search ignores capitalization, spaces, hyphens, and underscores. The saved
theme is selected and scrolled into view when the picker opens.

The choice is stored locally in `stdpath("state")/sioyek-theme`, not in
`chadrc.lua`. The initial theme is Catppuccin Latte. Theme changes no longer
modify tracked configuration or interfere with pulling updates.

With the accompanying WezTerm configuration, previewing or selecting a theme
also updates the terminal palette. Cancelling restores it. This integration
is in `lua/configs/wezterm_theme.lua` and activates only inside WezTerm.

The imported catalog is bundled with Neovim, so Sioyek does not need to be
installed for these themes to work. To refresh it after editing Sioyek's themes,
run from the dotfiles directory:

```sh
python3 nvim/scripts/sync-sioyek-themes.py
```

Use `--source /path/to/sioyek/themes` if the repositories are not siblings.
To verify the catalog and theme behavior:

```sh
python3 nvim/scripts/sync-sioyek-themes.py --check
nvim --headless -u NONE -i NONE -l nvim/tests/sioyek_themes.lua
nvim --headless -u NONE -i NONE -l nvim/tests/theme_picker_input.lua
```
