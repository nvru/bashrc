# bashrc

My bash configuration. Built to be portable and auto-adapt to available tools and language environments.

## Features

- **Language Toolchains Out-of-the-Box:** Automatically sets up binary PATHs for Rust (`cargo`), Go, Ruby (`gems`), Mise (`shims`), and Neovim (`mason`) whenever available.
- **Tool Fallbacks:** Prefers modern tools (`eza`/`exa`, `nvim`, `doas`, `nala`) when installed, falling back to standard defaults.
- **Dynamic PATH Management:** Prepends custom binary directories and strips duplicate PATH entries automatically on shell launch.
- **Dynamic Prompt:** Adapts PS1 styling based on the active window manager or desktop environment (`dwm`, `i3`, `sway`).
- **Integrations & Utilities:** `zoxide` navigation, `fzf` fuzzy completion, process handling, system stats, and directory scaffolding.

## Installation

Copy the file to your home directory:

```sh
cp bashrc ~/.bashrc
```
