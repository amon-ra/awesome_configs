---------------------------
--- Orange Energy theme ---
---------------------------

theme = {}

-- Setup Paths 
pathToConfig = os.getenv("HOME") .. "/.config/awesome/themes/orange_energy"

theme.font                      = "Liberation Sans 9"

theme.bg_normal                 = "#2222226F"
theme.bg_focus                  = "#3636366F"
theme.bg_urgent                 = theme.bg_normal 
theme.bg_systray                = theme.bg_normal
theme.naughty_bg                = "#222222"

theme.fg_normal                 = "#B4B4B4"
theme.fg_focus                  = "#FFFFFF"
theme.fg_important              = "#FF6F0E"
theme.fg_urgent                 = "#BB4444"
theme.useless_gap               = 4
theme.border_width              = 1
theme.border_normal             = "#626262"
theme.border_focus              = "#FF6F0E"
theme.border_marked             = theme.fg_urgent

theme.unfocused_opacity         = 0.75

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_bg_normal            = "#222222"
theme.menu_bg_focus             = "#363636"
theme.menu_submenu_icon         = pathToConfig .. "/submenu.png"
theme.menu_height               = 18
theme.menu_width                = 180

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.titlebar_bg_normal              = "png:" .. pathToConfig .. "/titlebar/bg_normal.png"
theme.titlebar_bg_focus               = "png:" .. pathToConfig .. "/titlebar/bg_focus.png"

theme.awesome_icon = pathToConfig .. "/icons/awesome16.png"

-- Display the taglist squares
theme.taglist_squares_sel   = pathToConfig .. "/icons/square_sel.png"
theme.taglist_squares_unsel = pathToConfig .. "/icons/square_unsel.png"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.bg_widget = "png:" .. pathToConfig .. "/icons/widget_bg.png"

-- Define the image to load
theme.titlebar_close_button_normal = pathToConfig .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = pathToConfig .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = pathToConfig .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = pathToConfig .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = pathToConfig .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = pathToConfig .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = pathToConfig .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = pathToConfig .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = pathToConfig .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = pathToConfig .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = pathToConfig .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = pathToConfig .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = pathToConfig .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = pathToConfig .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = pathToConfig .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = pathToConfig .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = pathToConfig .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = pathToConfig .. "/titlebar/maximized_focus_active.png"

theme.titlebar_minimize_button_normal_inactive = pathToConfig .. "/titlebar/minimize_normal_inactive.png"
theme.titlebar_minimize_button_focus_inactive  = pathToConfig .. "/titlebar/minimize_focus_inactive.png"

theme.wallpaper = pathToConfig .. "/bg.png"

-- You can use your own layout icons like this:
theme.layout_floating  = pathToConfig .. "/layouts/floating.png"
theme.layout_uselesstilebottom = pathToConfig  .. "/layouts/tilebottom.png"
theme.layout_uselesstileleft   = pathToConfig .. "/layouts/tileleft.png"
theme.layout_uselesstile = pathToConfig .. "/layouts/tile.png"
theme.layout_uselesstiletop = pathToConfig .. "/layouts/tiletop.png"
theme.layout_tilebottom = pathToConfig  .. "/layouts/tilebottom.png"
theme.layout_tileleft   = pathToConfig .. "/layouts/tileleft.png"
theme.layout_tile = pathToConfig .. "/layouts/tile.png"
theme.layout_tiletop = pathToConfig .. "/layouts/tiletop.png"

-- Separators
theme.blank = pathToConfig .. "/icons/blank.png"
theme.separator_left = pathToConfig .. "/icons/separator_left.png"
theme.separator_right = pathToConfig .. "/icons/separator_right.png"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
