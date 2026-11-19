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

## Typst PDFs in Sioyek

Install the inverse-search compiler once:

```sh
python3 ~/.config/sioyek/commands/install_tinymist.py
```

Saving a Typst file recompiles `main.typ` in the working directory through
Tinymist and registers the PDF with this Neovim session. `Space lo` compiles and
opens the PDF (using the current file if there is no `main.typ`). In Sioyek,
press `sd` and choose a line label, or Cmd+click the text, to jump back to source.
This also works for included `.typ` files. Keep the compiling Neovim session
open; after restarting it, save once to refresh the connection.

The accompanying Sioyek config and application build are required. The helper
runs Tinymist briefly for each lookup; it does not open a browser or leave a
preview service running. Ordinary `typst compile` outputs are not registered.

`work open` in the [scripts repo](https://github.com/mxksm/scripts) uses the same
compile-and-view function automatically. Its `-wd` option opens a separate
Sioyek window. An explicit Typst filename remains the compilation entry point
on subsequent saves, even when there is a neighboring `main.typ`.
