# Tailwind theme for Neovim/Vim

A tailwind CSS inspired color scheme for Neovim/Vim, designed to provide a visually appealing and consistent coding experience. 

## Preview
<img src="./imgs/tailwind-theme.png " alt="Preview" width="500" height="300">

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'nisonchrist/tailwind-theme.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    -- Optional: configure before loading
    -- require('tailwind-theme').setup({ transparent = true })
    vim.cmd.colorscheme('tailwind-theme')
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'nisonchrist/tailwind-theme.nvim',
  config = function()
    vim.cmd.colorscheme('tailwind-theme')
  end
}
```

### Using Vim-Plug

```vim
Plug 'nisonchrist/tailwind-theme.nvim'
```

Then in your `init.vim` or `init.lua`:

```vim
colorscheme tailwind-theme
```

## Advanced Configuration

```lua
-- Load with options
require('tailwind-theme').setup({
  -- Enable transparent background
  transparent = true,

  -- Disable plugin highlights for faster load times
  disable_plugin_highlights = false,

  -- Load only specific plugin highlights (improves performance)
  plugins = { 'lazy', 'mason', 'telescope' },

  -- Force reload (clears cache)
  force = false,
})
```

## Acknowledgments

- This theme is highly inspired by the Tailwind CSS color palette
- The code structure is inspired by another Neovim/Vim theme [mapledark.nvim](https://github.com/abhilash26/mapledark.nvim) by [abhilash26](https://github.com/abhilash26)
- Built for the Neovim community

## License

This project is licensed under the MIT License - see the [LICENSE](#license) file for details.
