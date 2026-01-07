" Tailwind-theme - A colorful theme
" Inspired by: Tailwindcss colors
" License: MIT
"
" This is a compatibility shim that loads the Lua version of the theme

lua << EOF
-- Don't clear package cache to preserve user config from setup()
require('tailwind-theme').load()
EOF
