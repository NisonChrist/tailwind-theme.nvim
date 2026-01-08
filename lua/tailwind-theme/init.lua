local M = {}
local utils = require('tailwind-theme.utils')
local hl = utils.hl

-- Default configuration
M.config = {
  transparent = false, -- Enable transparent background
}

-- Cache for colors and highlights
local _cache = {
  colors = nil,
  highlights_loaded = false,
  plugins_loaded = {},
}

-- Get cached colors or create them
local function get_colors()
  if _cache.colors then
    return _cache.colors
  end

  _cache.colors = {
    -- Background colors (using Tailwind neutral)
    bg_dark = '#0a0a0a',   -- neutral-950
    bg = '#171717',        -- neutral-900
    bg_light = '#262626',  -- neutral-800
    bg_sel = '#404040',    -- neutral-700
    bg_visual = '#1e3a8a', -- blue-900
    border = '#737373',    -- neutral-500

    -- Foreground colors (using Tailwind neutral)
    fg = '#e5e5e5',       -- neutral-200
    fg_dark = '#a3a3a3',  -- neutral-400
    fg_light = '#f5f5f5', -- neutral-100
    linenr = '#737373',   -- neutral-500

    -- Semantic colors (using Tailwind colors)
    red = '#f87171',     -- red-400
    orange = '#eab308',  -- yellow-500 (as orange substitute)
    yellow = '#fde047',  -- yellow-300
    green = '#4ade80',   -- green-400
    cyan = '#93c5fd',    -- blue-300 (as cyan substitute)
    blue = '#60a5fa',    -- blue-400
    magenta = '#c084fc', -- purple-400
    accent = '#f472b6',  -- pink-400

    -- Brighter variants
    red_br = '#fca5a5',     -- red-300
    orange_br = '#fde047',  -- yellow-300
    yellow_br = '#fef08a',  -- yellow-200
    green_br = '#86efac',   -- green-300
    cyan_br = '#bfdbfe',    -- blue-200
    blue_br = '#93c5fd',    -- blue-300
    magenta_br = '#d8b4fe', -- purple-300
  }

  return _cache.colors
end

-- Expose colors as a property
M.colors = setmetatable({}, {
  __index = function(_, key)
    return get_colors()[key]
  end,
  __newindex = function()
    error("Colors table is read-only", 2)
  end,
})

-- Apply the colorscheme
function M.setup(opts)
  opts = opts or {}

  -- Store previous transparent setting to detect changes
  local prev_transparent = M.config.transparent

  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend('force', M.config, opts)

  -- Force reload if transparent setting changed
  local config_changed = prev_transparent ~= M.config.transparent

  -- Check if already loaded and not forcing reload
  if _cache.highlights_loaded and not opts.force and not config_changed then
    return
  end

  -- Clear plugin cache when config changes
  if config_changed then
    _cache.plugins_loaded = {}
  end

  -- Reset colors
  vim.cmd('highlight clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end

  vim.g.colors_name = 'tailwind-theme'
  vim.o.background = 'dark'
  vim.o.termguicolors = true

  local c = get_colors()

  -- Transparent background helper
  -- Note: Popups/floats keep their background even in transparent mode for visibility
  local transparent = M.config.transparent
  local bg_main = transparent and 'NONE' or c.bg_dark
  local bg_sidebar = transparent and 'NONE' or c.bg
  local bg_float = c.bg_light -- Always opaque for popups
  local bg_popup = c.bg_light -- Always opaque for menus

  -- ============================================================================
  -- EDITOR UI
  -- ============================================================================

  hl('Normal', { fg = c.fg, bg = bg_main })
  hl('NormalFloat', { fg = c.fg, bg = bg_float })
  hl('FloatBorder', { fg = c.border, bg = bg_float })
  hl('FloatTitle', { fg = c.blue, bg = bg_float, bold = true })

  hl('Cursor', { fg = c.bg, bg = c.fg })
  hl('lCursor', { fg = c.bg, bg = c.fg })
  hl('CursorLine', { bg = transparent and 'NONE' or c.bg_sel })
  hl('CursorColumn', { bg = transparent and 'NONE' or c.bg_sel })
  hl('ColorColumn', { bg = transparent and 'NONE' or c.bg_dark })

  hl('LineNr', { fg = c.linenr, bg = bg_sidebar })
  hl('CursorLineNr', { fg = c.fg_dark, bg = bg_sidebar, bold = true })
  hl('SignColumn', { bg = bg_sidebar })
  hl('FoldColumn', { fg = c.fg_dark, bg = bg_sidebar })
  hl('Folded', { fg = c.fg_dark, bg = transparent and 'NONE' or c.bg_sel })

  -- Status line
  hl('StatusLine', { fg = c.fg_dark, bg = bg_main })
  hl('StatusLineNC', { fg = c.bg, bg = c.fg_dark })
  hl('VertSplit', { fg = c.border, bg = bg_main })
  hl('WinSeparator', { fg = c.border, bg = bg_main })

  -- Search and selection
  hl('Visual', { bg = c.bg_visual })
  hl('VisualNOS', { bg = c.bg_visual })
  hl('Search', { fg = c.bg, bg = c.yellow, bold = true })
  hl('IncSearch', { fg = c.bg, bg = c.orange, bold = true })
  hl('CurSearch', { fg = c.bg, bg = c.orange_br, bold = true })
  hl('Substitute', { fg = c.bg, bg = c.red, bold = true })

  -- Messages and prompts
  hl('ErrorMsg', { fg = c.red_br, bold = true })
  hl('WarningMsg', { fg = c.orange, bold = true })
  hl('ModeMsg', { fg = c.green, bold = true })
  hl('MoreMsg', { fg = c.green, bold = true })
  hl('Question', { fg = c.blue, bold = true })
  hl('Title', { fg = c.blue, bold = true })
  hl('Directory', { fg = c.blue })
  hl('NonText', { fg = c.fg_dark })
  hl('EndOfBuffer', { fg = transparent and c.fg_dark or c.bg })
  hl('SpecialKey', { fg = c.fg_dark })
  hl('Whitespace', { fg = c.bg_sel })

  -- Popup menu
  hl('Pmenu', { fg = c.fg, bg = bg_popup })
  hl('PmenuSel', { fg = c.bg, bg = c.blue, bold = true })
  hl('PmenuKind', { fg = c.yellow, bg = bg_popup })
  hl('PmenuKindSel', { fg = c.bg, bg = c.blue, bold = true }) -- Darker fg for AA compliance
  hl('PmenuExtra', { fg = c.fg_dark, bg = bg_popup })
  hl('PmenuExtraSel', { fg = c.bg, bg = c.blue })             -- Darker fg for AA compliance
  hl('PmenuSbar', { bg = bg_popup })
  hl('PmenuThumb', { fg = c.border, bg = bg_popup })          -- Fixed for AA compliance

  -- Tabs
  hl('TabLine', { fg = c.fg_dark, bg = transparent and 'NONE' or c.bg_sel })
  hl('TabLineFill', { bg = bg_sidebar })
  hl('TabLineSel', { fg = c.green, bg = bg_sidebar, bold = true })

  -- Diffs
  hl('DiffAdd', { fg = c.green, bg = c.bg_sel })
  hl('DiffChange', { fg = c.orange, bg = c.bg_sel })
  hl('DiffDelete', { fg = c.red, bg = c.bg_sel })
  hl('DiffText', { fg = c.yellow, bg = c.bg_sel, bold = true })

  hl('diffAdded', { fg = c.green })
  hl('diffRemoved', { fg = c.red })
  hl('diffChanged', { fg = c.orange })
  hl('diffOldFile', { fg = c.red })
  hl('diffNewFile', { fg = c.green })
  hl('diffFile', { fg = c.blue })
  hl('diffLine', { fg = c.cyan })
  hl('diffIndexLine', { fg = c.magenta })

  -- ============================================================================
  -- SYNTAX HIGHLIGHTING
  -- ============================================================================

  hl('Comment', { fg = c.fg_dark, italic = true })
  hl('SpecialComment', { fg = c.cyan, italic = true })

  hl('Constant', { fg = c.fg })
  hl('String', { fg = c.fg })
  hl('Character', { fg = c.fg })
  hl('Number', { fg = c.fg })
  hl('Boolean', { fg = c.fg })
  hl('Float', { fg = c.fg })

  hl('Identifier', { fg = c.fg })
  hl('Function', { fg = c.blue })

  hl('Statement', { fg = c.accent, italic = true })
  hl('Conditional', { fg = c.accent, italic = true })
  hl('Repeat', { fg = c.accent, italic = true })
  hl('Label', { fg = c.accent, italic = true })
  hl('Operator', { fg = c.fg })
  hl('Keyword', { fg = c.accent, italic = true })
  hl('Exception', { fg = c.red, italic = true })

  hl('PreProc', { fg = c.cyan })
  hl('Include', { fg = c.accent, italic = true })
  hl('Define', { fg = c.accent, italic = true })
  hl('Macro', { fg = c.cyan })
  hl('PreCondit', { fg = c.cyan })

  hl('Type', { fg = c.accent })
  hl('StorageClass', { fg = c.accent, italic = true })
  hl('Structure', { fg = c.accent })
  hl('Typedef', { fg = c.accent, italic = true })

  hl('Special', { fg = c.cyan })
  hl('SpecialChar', { fg = c.accent })
  hl('Tag', { fg = c.fg })
  hl('Delimiter', { fg = c.fg })
  hl('Debug', { fg = c.red })

  hl('Underlined', { fg = c.blue, underline = true })
  hl('Ignore', { fg = c.bg })
  hl('Error', { fg = c.red_br, bg = bg_main, bold = true })
  hl('Todo', { fg = c.yellow, bg = transparent and 'NONE' or c.bg_sel, bold = true })

  -- ============================================================================
  -- DIAGNOSTICS
  -- ============================================================================

  hl('DiagnosticError', { fg = c.red })
  hl('DiagnosticWarn', { fg = c.orange })
  hl('DiagnosticInfo', { fg = c.blue })
  hl('DiagnosticHint', { fg = c.cyan })
  hl('DiagnosticOk', { fg = c.green })

  hl('DiagnosticSignError', { fg = c.red, bg = bg_sidebar })
  hl('DiagnosticSignWarn', { fg = c.orange, bg = bg_sidebar })
  hl('DiagnosticSignInfo', { fg = c.blue, bg = bg_sidebar })
  hl('DiagnosticSignHint', { fg = c.cyan, bg = bg_sidebar })
  hl('DiagnosticSignOk', { fg = c.green, bg = bg_sidebar })

  hl('DiagnosticVirtualTextError', { fg = c.red })
  hl('DiagnosticVirtualTextWarn', { fg = c.orange })
  hl('DiagnosticVirtualTextInfo', { fg = c.blue })
  hl('DiagnosticVirtualTextHint', { fg = c.cyan })

  hl('DiagnosticUnderlineError', { sp = c.red, underline = true })
  hl('DiagnosticUnderlineWarn', { sp = c.orange, underline = true })
  hl('DiagnosticUnderlineInfo', { sp = c.blue, underline = true })
  hl('DiagnosticUnderlineHint', { sp = c.cyan, underline = true })

  hl('DiagnosticFloatingError', { fg = c.red, bg = bg_float })
  hl('DiagnosticFloatingWarn', { fg = c.orange, bg = bg_float })
  hl('DiagnosticFloatingInfo', { fg = c.blue, bg = bg_float })
  hl('DiagnosticFloatingHint', { fg = c.cyan, bg = bg_float })

  -- ============================================================================
  -- LSP
  -- ============================================================================

  hl('LspReferenceText', { bg = c.bg_sel })
  hl('LspReferenceRead', { bg = c.bg_sel })
  hl('LspReferenceWrite', { bg = c.bg_sel, bold = true })
  hl('LspCodeLens', { fg = c.fg_dark, italic = true })
  hl('LspCodeLensSeparator', { fg = c.fg_dark })
  hl('LspSignatureActiveParameter', { fg = c.yellow, bold = true })

  -- LSP Semantic tokens
  hl('LspInlayHint', { fg = c.fg_dark, bg = bg_sidebar, italic = true })
  hl('@lsp.type.namespace', { fg = c.cyan })
  hl('@lsp.type.type', { fg = c.blue })
  hl('@lsp.type.class', { fg = c.blue })
  hl('@lsp.type.enum', { fg = c.blue })
  hl('@lsp.type.interface', { fg = c.blue, italic = true })
  hl('@lsp.type.struct', { fg = c.blue })
  hl('@lsp.type.parameter', { fg = c.cyan })
  hl('@lsp.type.variable', { fg = c.fg })
  hl('@lsp.type.property', { fg = c.fg })
  hl('@lsp.type.enumMember', { fg = c.cyan })
  hl('@lsp.type.function', { fg = c.blue })
  hl('@lsp.type.method', { fg = c.blue })
  hl('@lsp.type.macro', { fg = c.cyan })
  hl('@lsp.type.decorator', { fg = c.cyan })
  hl('@lsp.mod.readonly', { fg = c.accent })
  hl('@lsp.mod.typeHint', { fg = c.fg_dark, italic = true })
  hl('@lsp.mod.defaultLibrary', { fg = c.cyan, italic = true })
  hl('@lsp.typemod.function.defaultLibrary', { fg = c.cyan })
  hl('@lsp.typemod.variable.defaultLibrary', { fg = c.orange })
  hl('@lsp.typemod.variable.global', { fg = c.orange })
  hl('@lsp.typemod.variable.static', { fg = c.orange, italic = true })

  -- ============================================================================
  -- TREESITTER
  -- ============================================================================

  -- Variables
  hl('@variable', { fg = c.fg })
  hl('@variable.builtin', { fg = c.fg, italic = true })
  hl('@variable.parameter', { fg = c.fg })
  hl('@variable.parameter.builtin', { fg = c.fg })
  hl('@variable.member', { fg = c.blue })

  -- Constants
  hl('@constant', { fg = c.accent })
  hl('@constant.builtin', { fg = c.accent })
  hl('@constant.macro', { fg = c.cyan })
  hl('@module', { fg = c.fg })
  hl('@module.builtin', { fg = c.fg })

  -- Strings
  hl('@string', { fg = c.green })
  hl('@string.documentation', { fg = c.green, italic = true })
  hl('@string.escape', { fg = c.cyan })
  hl('@string.regexp', { fg = c.cyan })
  hl('@string.special', { fg = c.accent })
  hl('@string.special.symbol', { fg = c.red })
  hl('@string.special.url', { fg = c.blue, underline = true })
  hl('@string.special.path', { fg = c.cyan })

  -- Characters and Numbers
  hl('@character', { fg = c.green })
  hl('@character.special', { fg = c.cyan })
  hl('@number', { fg = c.fg })
  hl('@number.float', { fg = c.fg })
  hl('@boolean', { fg = c.fg })

  -- Functions
  hl('@function', { fg = c.blue })
  hl('@function.builtin', { fg = c.cyan })
  hl('@function.call', { fg = c.blue })
  hl('@function.macro', { fg = c.cyan })
  hl('@function.method', { fg = c.blue })
  hl('@function.method.call', { fg = c.blue })
  hl('@constructor', { fg = c.cyan })

  -- Keywords
  hl('@keyword', { fg = c.accent, italic = true })
  hl('@keyword.coroutine', { fg = c.accent, italic = true })
  hl('@keyword.function', { fg = c.accent, italic = true })
  hl('@keyword.operator', { fg = c.accent, italic = true })
  hl('@keyword.import', { fg = c.accent, italic = true })
  hl('@keyword.type', { fg = c.accent, italic = true })
  hl('@keyword.modifier', { fg = c.accent, italic = true })
  hl('@keyword.repeat', { fg = c.accent, italic = true })
  hl('@keyword.return', { fg = c.accent, italic = true })
  hl('@keyword.debug', { fg = c.red, italic = true })
  hl('@keyword.exception', { fg = c.red, italic = true })
  hl('@keyword.conditional', { fg = c.accent, italic = true })
  hl('@keyword.conditional.ternary', { fg = c.accent })
  hl('@keyword.directive', { fg = c.accent, italic = true })
  hl('@keyword.directive.define', { fg = c.accent, italic = true })

  -- Control flow
  hl('@conditional', { fg = c.accent, italic = true })
  hl('@repeat', { fg = c.accent, italic = true })
  hl('@label', { fg = c.accent })
  hl('@operator', { fg = c.fg })
  hl('@exception', { fg = c.red, italic = true })

  -- Types
  hl('@type', { fg = c.yellow })
  hl('@type.builtin', { fg = c.yellow, italic = true })
  hl('@type.definition', { fg = c.yellow })
  hl('@type.qualifier', { fg = c.accent, italic = true })
  hl('@attribute', { fg = c.cyan })
  hl('@attribute.builtin', { fg = c.cyan })

  -- Properties and fields
  hl('@property', { fg = c.blue })
  hl('@field', { fg = c.blue })
  hl('@parameter', { fg = c.blue })

  -- Comments
  hl('@comment', { fg = c.fg_dark, italic = true })
  hl('@comment.documentation', { fg = c.cyan, italic = true })
  hl('@comment.error', { fg = c.red, bold = true, italic = true })
  hl('@comment.warning', { fg = c.orange, bold = true, italic = true })
  hl('@comment.todo', { fg = c.yellow, bold = true, italic = true })
  hl('@comment.note', { fg = c.blue, bold = true, italic = true })

  -- Punctuation
  hl('@punctuation.delimiter', { fg = c.accent })
  hl('@punctuation.bracket', { fg = c.fg })
  hl('@punctuation.special', { fg = c.cyan })

  -- Markup (Markdown, etc.)
  hl('@markup.strong', { fg = c.fg, bold = true })
  hl('@markup.italic', { fg = c.fg, italic = true })
  hl('@markup.strikethrough', { fg = c.fg_dark, strikethrough = true })
  hl('@markup.underline', { fg = c.fg, underline = true })
  hl('@markup.heading', { fg = c.blue, bold = true })
  hl('@markup.heading.1', { fg = c.blue, bold = true })
  hl('@markup.heading.2', { fg = c.cyan, bold = true })
  hl('@markup.heading.3', { fg = c.green, bold = true })
  hl('@markup.heading.4', { fg = c.yellow, bold = true })
  hl('@markup.heading.5', { fg = c.orange, bold = true })
  hl('@markup.heading.6', { fg = c.magenta, bold = true })
  hl('@markup.quote', { fg = c.fg_dark, italic = true })
  hl('@markup.math', { fg = c.cyan })
  hl('@markup.link', { fg = c.blue, underline = true })
  hl('@markup.link.label', { fg = c.cyan })
  hl('@markup.link.url', { fg = c.blue, underline = true })
  hl('@markup.raw', { fg = c.green })
  hl('@markup.raw.block', { fg = c.green })
  hl('@markup.list', { fg = c.magenta })
  hl('@markup.list.checked', { fg = c.green })
  hl('@markup.list.unchecked', { fg = c.fg_dark })

  -- Tags (HTML, JSX, etc.)
  hl('@tag', { fg = c.accent })
  hl('@tag.builtin', { fg = c.accent })
  hl('@tag.attribute', { fg = c.yellow })
  hl('@tag.delimiter', { fg = c.fg })

  -- Diff
  hl('@diff.plus', { fg = c.green })
  hl('@diff.minus', { fg = c.red })
  hl('@diff.delta', { fg = c.orange })

  -- ============================================================================
  -- GIT SIGNS & GIT GUTTER
  -- ============================================================================

  hl('GitSignsAdd', { fg = c.green, bg = c.bg })
  hl('GitSignsChange', { fg = c.orange, bg = c.bg })
  hl('GitSignsDelete', { fg = c.red, bg = c.bg })
  hl('GitSignsAddNr', { fg = c.green })
  hl('GitSignsChangeNr', { fg = c.orange })
  hl('GitSignsDeleteNr', { fg = c.red })
  hl('GitSignsAddLn', { bg = c.bg_sel })
  hl('GitSignsChangeLn', { bg = c.bg_sel })
  hl('GitSignsDeleteLn', { bg = c.bg_sel })

  -- Mark highlights as loaded
  _cache.highlights_loaded = true

  -- Load plugin highlights lazily if not disabled
  if not opts.disable_plugin_highlights then
    M.load_plugin_highlights(opts.plugins)
  end
end

-- Load plugin highlights on demand
function M.load_plugin_highlights(plugins)
  -- Lazy load plugin highlights
  vim.defer_fn(function()
    local c = get_colors()
    require('tailwind-theme.plugins').setup(c, plugins, _cache.plugins_loaded)
  end, 0)
end

-- Load specific plugin highlight on demand
function M.load_plugin(plugin_name)
  if _cache.plugins_loaded[plugin_name] then
    return -- Already loaded
  end

  local c = get_colors()
  local plugins = require('tailwind-theme.plugins')

  if plugins.loaders[plugin_name] then
    plugins.loaders[plugin_name](c)
    _cache.plugins_loaded[plugin_name] = true
  end
end

-- Clear cache (useful for theme development)
function M.clear_cache()
  _cache = {
    colors = nil,
    highlights_loaded = false,
    plugins_loaded = {},
  }
end

-- Reload theme with cache clearing
function M.reload()
  M.clear_cache()
  M.setup({ force = true })
end

-- Load the colorscheme (called by colorscheme command)
-- Forces reload to apply any config changes
function M.load()
  _cache.highlights_loaded = false
  M.setup({ force = true })
end

return M
