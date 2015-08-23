-- Configure home path so you don't have too
home_path  = os.getenv('HOME') .. '/'

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout libraries
local wibox = require("wibox")
local vicious = require("vicious")
local lain = require("lain")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")

-- Menubar library
local menubar = require("menubar")

-- My libraries
local keydoc = require("keydoc")


--FreeDesktop
local freedesktop = require('freedesktop')

-- {{{ Local functions

-- run only once!
function run_once(cmd, fake_cmd)
  findme = fake_cmd or cmd
  firstspace = findme:find(" ")
  if firstspace then
     findme = findme:sub(0, firstspace-1)
  end
  pid = awful.util.pread("pgrep -u $USER -x " .. findme)
  if pid == nil or pid == '' then
     awful.util.spawn_with_shell(cmd)
     return true
  else
     return false
  end
end

-- reload geometry for maximized windows
local function reload_maximized_windows(c)
    local maximized_clients = function (c)
        return awful.rules.match(c, {maximized = true})
    end
    
    local maximized_horizontal_clients = function (c)
        return awful.rules.match(c, {maximized_horizontal = true})
    end
    
    local maximized_vertical_clients = function (c)
        return awful.rules.match(c, {maximized_vertical = true})
    end
    
    local fullscreen_clients = function (c)
        return awful.rules.match(c, {fullscreen = true})
    end

    for c in awful.client.iterate(maximized_clients) do
        c.maximized = false
        c.maximized = true
    end
    
    for c in awful.client.iterate(maximized_vertical_clients) do
        c.maximized_vertical = false
        c.maximized_vertical = true
    end
    
    for c in awful.client.iterate(maximized_horizontal_clients) do
        c.maximized_horizontal = false
        c.maximized_horizontal = true
    end
    
    for c in awful.client.iterate(fullscreen_clients) do
        c.fullscreen = false
        c.fullscreen = true
    end
end

-- reload geometry for maximized windows if client's screen changed
local function client_changed_screen(c)
       local c = c or client.focus
       if not c then return end
       if c.maximized then
           c.maximized = false
           c.maximized = true
       else
           if c.maximized_horizontal then
               c.maximized_horizontal = false
               c.maximized_horizontal = true
           end
           if c.maximized_vertical then
               c.maximized_vertical = false
               c.maximized_vertical = true
           end
       end
       if c.fullscreen then
           c.fullscreen = false
           c.fullscreen = true
       end
end

-- Replacement for naughty.notify

local orig = naughty.notify

local function notify(args)
    args.screen = args.screen or mouse.screen
    return orig(args)
end

naughty.notify = notify		-- monkey patch

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers

-- Setup directories
config_dir = (os.getenv("HOME").."/.config/awesome/")
themes_dir = (config_dir .. "themes/orange_energy")

-- For change screen temperature with redshift
redshifted = 0

-- For useless gap toggling
useless_gap = beautiful.useless_gap

-- Unfocused opacity
unfocused_opacity = beautiful.unfocused_opacity

-- Setup theme
beautiful.init(themes_dir .. "/theme.lua")

-- Setup icons for FreeDesktop
freedesktop.utils.icon_theme = 'breeze'

-- Fix for naughty not respecting theme
naughty.config.defaults.bg               = beautiful.naughty_bg
naughty.config.defaults.border_color     = beautiful.border_normal
naughty.config.defaults.border_width     = beautiful.border_width

-- This is used later as the default terminal, browser and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium"

-- applications menu
freedesktop.utils.terminal = terminal

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Setup graphics
blank = wibox.widget.imagebox()
blank:set_image(beautiful.blank)

separator_left = wibox.widget.imagebox()
separator_left:set_image(beautiful.separator_left)

separator_right = wibox.widget.imagebox()
separator_right:set_image(beautiful.separator_right)

blank_bg = wibox.widget.background()
blank_bg:set_bg(beautiful.bg_widget)
blank_bg_image = wibox.widget.imagebox()
blank_bg_image:set_image(beautiful.blank)
blank_bg:set_widget(blank_bg_image)

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom
}

-- }}}

-- {{{ Autostart

-- Set Polish keyboard layout
run_once("setxkbmap pl &")
os.setlocale(os.getenv("LANG"))

-- Disable screen saver blanking
run_once("xset -dpms &")
run_once("xset s off &")

-- Hide cursor after 5 idle seconds
run_once("unclutter -idle 5")

-- Start PulseAudio with the needed the X11 plugins
run_once("start-pulseaudio-x11")

-- Launch composite manager
run_once("compton --config " .. config_dir .. "/compton/comptonrc &")

-- Launch Conky

if screen.count() == 2 then
    run_once("conky --config=.conkyrc_dual &")
else
    run_once("conky &")
end

-- }}}

-- {{{ Wallpaper

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.

tags = {
  names  = { 
           ' 1 ',
           ' 2 ', 
           ' 3 ', 
           ' 4 ',  
           ' 5 '
           },
  layout = {
        awful.layout.layouts[2],
        awful.layout.layouts[2],
        awful.layout.layouts[2],
        awful.layout.layouts[2],
        awful.layout.layouts[1]
           }
}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu

menu_items = freedesktop.menu.new()
myawesomemenu = {
   { "manual", terminal .. " -e man awesome", freedesktop.utils.lookup_icon({ icon = 'help-about' }) },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'preferences-desktop' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'system-reboot' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'application-exit' }) }
}
table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon })
table.insert(menu_items, { "shoutdown", function() run_once("oblogout") end, freedesktop.utils.lookup_icon({icon = 'system-shutdown'}) })
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'utilities-terminal'}) })

mymainmenu = awful.menu({ items = menu_items })

mylauncher = wibox.widget.background()
mylauncher:set_bg(beautiful.bg_widget)
mylauncher_widget = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
mylauncher:set_widget(mylauncher_widget)

-- desktop icons

freedesktop.desktop.config.computer = false -- to disabble computer icon
freedesktop.desktop.config.home = false -- to disabble home icon
freedesktop.desktop.config.network = false -- to disabble network icon
freedesktop.desktop.config.trash = false -- to disabble trash icon

freedesktop.desktop.add_desktop_icons({dir = '~/Pulpit/', screen = 1, showlabels = true, open_with = 'dolphin' })

-- Add non-standard directories to menubar
table.insert(menubar.menu_gen.all_menu_dirs, '/usr/share/applications/kde4/')

-- }}}

-- {{{ Wibox

-- Time and Date Widget
tdwidget_text = wibox.widget.textbox()
tdwidget = wibox.widget.background()
tdwidget:set_bg(beautiful.bg_widget)
vicious.register(tdwidget_text, vicious.widgets.date, '<span font="URW Gothic 10"> %b %d %H:%M </span>', 20)
tdwidget:set_widget(tdwidget_text)
clockicon = wibox.widget.background()
clockicon:set_bg(beautiful.bg_widget)
clockicon_widget = wibox.widget.textbox()
clockicon_widget:set_text('')
clockicon_widget:set_font('FontAwesome 13')
clockicon:set_widget(clockicon_widget)

-- Calendar
lain.widgets.calendar:attach(clockicon, { font = "Ubuntu Mono", bg_focus  = beautiful.menu_bg_focus, font_size = 14, bg =  beautiful.naughty_bg })
lain.widgets.calendar:attach(tdwidget, { font = "Ubuntu Mono", bg_focus  = beautiful.menu_bg_focus, font_size = 14, bg =  beautiful.naughty_bg })

-- Tasks
tasks = wibox.widget.background()
tasks_icon = wibox.widget.textbox()
tasks_icon:set_text('')
tasks_icon:set_font('FontAwesome 13')
tasks:set_bg(beautiful.bg_widget)
tasks:set_widget(tasks_icon)
lain.widgets.contrib.task:attach(tasks, {font = "Ubuntu Mono", bg = beautiful.naughty_bg, timeout = 0})

-- Volume Widget
volume_text = wibox.widget.textbox()
volume = wibox.widget.background()
volume:set_bg(beautiful.bg_widget)
volume:set_widget(volume_text)
vicious.register(volume_text, vicious.widgets.volume, '<span font="URW Gothic 10"> $1% </span>', 1, "Master")
volumeicon = wibox.widget.background()
volumeicon:set_bg(beautiful.bg_widget)
volumeicon_widget = wibox.widget.textbox()
volumeicon:set_widget(volumeicon_widget)
volumeicon_widget:set_font('FontAwesome 13')
vicious.register(volumeicon, vicious.widgets.volume, function(widget, args)
        local paraone = tonumber(args[1])
        if args[2] == "♩" or paraone == 0 then
                volumeicon_widget:set_markup('<span color="' .. beautiful.fg_urgent .. '"></span>')
                volume:set_fg(beautiful.fg_urgent)
        elseif paraone >= 50 and paraone <= 100 then
                volumeicon_widget:set_markup('<span color="' .. beautiful.fg_normal .. '"></span>')
                volume:set_fg(beautiful.fg_normal)
        else
                volumeicon_widget:set_markup('<span color="' .. beautiful.fg_normal .. '"></span>')
                volume:set_fg(beautiful.fg_normal)
        end
end, 1, "Master")
-- Buttons for volume widget
volumeicon:buttons(awful.util.table.join(
     awful.button({ }, 1,
     function() awful.util.spawn_with_shell("amixer set Master toggle") end),
     awful.button({ }, 4,
     function() awful.util.spawn_with_shell("amixer set Master 5%+") end),
     awful.button({ }, 5,
     function() awful.util.spawn_with_shell("amixer set Master 5%-") end)
            ))
     volume:buttons(volumeicon:buttons())

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox_widget = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
                    
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              -- Without this, the following
                                              -- :isvisible() makes no sense
                                              c.minimized = false
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              -- This will also un-minimize
                                              -- the client, if needed
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 2, function (c)
                                              c.minimized = not c.minimized
                                              -- After unminimize client gain focus
                                              if not c.minimized then
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 10, function (c)
                                              c:kill()
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = wibox.widget.background()
    mylayoutbox[s]:set_bg(beautiful.bg_widget)
    mylayoutbox_widget[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    mylayoutbox[s]:set_widget(mylayoutbox_widget[s])
                               
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = "18" })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(blank_bg)
    left_layout:add(blank_bg)
    left_layout:add(mylauncher)
    left_layout:add(blank_bg)
    left_layout:add(separator_left)
    left_layout:add(blank)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(blank)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(wibox.widget.systray())
    end
    right_layout:add(blank)
    right_layout:add(separator_right)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(volumeicon)
    right_layout:add(volume)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(clockicon)
    right_layout:add(tdwidget)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(tasks)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)
    right_layout:add(mylayoutbox[s])
    right_layout:add(blank_bg)
    right_layout:add(blank_bg)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- }}}

-- {{{ Mouse bindings

root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(
    keydoc.group("Global keys"),
    awful.key({ modkey,           }, "F1",     keydoc.display, "Show this help"),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore, "Focus previously selected tag set"),
    
    awful.key({                   }, "Print",
        function ()
            awful.util.spawn("scrot") 
    end),
    
    awful.key({modkey, "Shift"    }, "Escape",
        function ()
            awful.util.spawn("xkill") 
    end, "Choose client to kill"),
    
    awful.key({ modkey,           }, "b",
        function ()
            mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
            reload_maximized_windows(c)
        end, "Toggle panel"),
        
    awful.key({ modkey,           }, "c",
        function ()
            
            local focusable_clients = function (c)
                return awful.rules.match(c, {focusable = true})
            end
            
            if  beautiful.useless_gap > 0 then
                beautiful.useless_gap = 0
            else
                beautiful.useless_gap = useless_gap
            end
            
            if  beautiful.unfocused_opacity == 1 then
                beautiful.unfocused_opacity = unfocused_opacity
            else
                beautiful.unfocused_opacity = 1
            end
            
            for c in awful.client.iterate(focusable_clients) do
                c.opacity = beautiful.unfocused_opacity
                client.focus.opacity = 1
            end
            
            for s = 1, screen.count() do
                awful.layout.arrange(s)
            end
        end, "Toggle useless beautification"),
    
    awful.key({ }, "XF86AudioRaiseVolume", function ()
    awful.util.spawn_with_shell("amixer set Master 5%+") end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
    awful.util.spawn_with_shell("amixer set Master 5%-") end),
    awful.key({ }, "XF86AudioMute", function ()
    awful.util.spawn_with_shell("amixer set Master toggle") end),
 
    -- Cmus control
    awful.key({ }, "XF86AudioPlay", function ()
        if run_once(terminal .. " -e cmus", "cmus") then
            awful.util.spawn_with_shell("sleep 2; cmus-remote -u")
        else
            awful.util.spawn_with_shell("cmus-remote -u")
        end
    end),
    awful.key({ }, "XF86AudioNext", function ()
        awful.util.spawn_with_shell("cmus-remote -n")
    end),
    awful.key({ }, "XF86AudioPrev", function ()
        awful.util.spawn_with_shell("cmus-remote -r")
    end),
    awful.key({ }, "XF86AudioStop", function ()
        awful.util.spawn_with_shell("cmus-remote -s")
        awful.util.spawn_with_shell("cmus-remote -C q")
    end),
    
    awful.key({ }, "XF86PowerOff", function ()
    run_once("oblogout") end),

    awful.key({ modkey,           }, "Right",
        function ()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end, "Focus client on the right of active client"),
    awful.key({ modkey,           }, "Left",
        function ()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end, "Focus client on the left of active client"),
    awful.key({ modkey,           }, "Up",
        function ()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end, "Focus client above active client"),
    awful.key({ modkey,           }, "Down",
        function ()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end, "Focus client below active client"),
        
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end, "Open main menu"),
        
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.global_bydirection("right")    end, "Switch active client with client on the right"),
    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.global_bydirection("left")    end, "Switch active client with client on the left"),
    awful.key({ modkey, "Shift"   }, "Up", function () awful.client.swap.global_bydirection("up")    end, "Switch active client with client above"),
    awful.key({ modkey, "Shift"   }, "Down", function () awful.client.swap.global_bydirection("down")    end, "Switch active client with client below"),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto, "Focus first urgent client"),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end, "Focus previously selected client"),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end, "Spawn terminal emulator"),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal .. " -e mc") end, "Spawn Midnight Commander"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "Restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "Quit awesome"),
    awful.key({ modkey,           }, "=",     function () awful.tag.incmwfact( 0.05)    end, "Increase master width factor by 5%"),
    awful.key({ modkey,           }, "-",     function () awful.tag.incmwfact(-0.05)    end, "Decrease master width factor by 5%"),
    awful.key({ modkey, "Shift"   }, "=",     function () awful.tag.incnmaster( 1)      end, "Increase number of master windows"),
    awful.key({ modkey, "Shift"   }, "-",     function () awful.tag.incnmaster(-1)      end, "Decrease number of master windows"),
    awful.key({ modkey, "Control" }, "=",     function () awful.tag.incncol( 1)         end, "Increase number of columns for non-master windows"),
    awful.key({ modkey, "Control" }, "-",     function () awful.tag.incncol(-1)         end, "Decrease number of columns for non-master windows"),
    awful.key({ modkey,           }, "#86",     function () awful.tag.incmwfact(0.05)    end),
    awful.key({ modkey,           }, "#82",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "#86",     function () awful.tag.incnmaster(1)      end),
    awful.key({ modkey, "Shift"   }, "#82",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "#86",     function () awful.tag.incncol(1)         end),
    awful.key({ modkey, "Control" }, "#82",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(1) end, "Switch to next layout"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end, "Switch to previous layout"),

    awful.key({ modkey, "Control" }, "n", awful.client.restore, "Restore client"),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end, "Run prompt"),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end, "Run Lua code prompt"),
              
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end, "Show menubar")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end, "Go to given tag ", i ~= 1),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end, "Toggle given tag ", i ~= 1),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end, "Move client to given tag ", i ~= 1),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end, "Add client to given tag ", i ~= 1))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ modkey }, 8, function() awful.client.swap.byidx(1) end),
    awful.button({ modkey }, 9, function() awful.client.swap.byidx(-1) end),
    awful.button({ modkey }, 10, function (c) c:kill() end))

clientkeys = awful.util.table.join(
    keydoc.group("Client keys"),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end, "Toggle client fullscreen"),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end, "Kill client window"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle, "Toggle client floating status"),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen, "Send client to next screen"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, "Toggle client on top"),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end, "Minimize client"),
    awful.key({ modkey,           }, "m",
        function (c)
            if c.maximized_horizontal or c.maximized_vertical then
                c.maximized_horizontal = false
                c.maximized_vertical   = false
            else
                c.maximized_horizontal = true
                c.maximized_vertical   = true
            end
        end, "Maximize client"),
    awful.key({ modkey, "Shift" }, "t", function (c)
    -- toggle titlebar
    if (c:titlebar_top():geometry()['height'] > 0) then
        awful.titlebar(c, {size = 0})
    else
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end))
 
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:add(awful.titlebar.widget.floatingbutton(c))
        left_layout:add(awful.titlebar.widget.ontopbutton(c))
        left_layout:add(awful.titlebar.widget.stickybutton(c))
 
        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.minimizebutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))
 
        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)
 
        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)
 
        awful.titlebar(c, {size = 18}):set_widget(layout)
    end
end, "Toggle client titlebar")
)
    
-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false} },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Minetest" },
      properties = {
      screen = 1,
      fullscreen = true
      } },
    { rule = { class = "Qjackctl" },
      properties = { floating = true } },
    { rule = { class = "kcalc" },
      properties = { floating = true } },
    { rule = { name = "Kopiowanie" },
      properties = { floating = true } },
    { rule = { name = "Rozpakowywanie pliku..." },
      properties = { floating = true } },
    { rule = { name = "Okno postępu" },
      properties = { floating = true } },
    { rule = { class = "Conky" },
      properties = {
      floating = true,
      sticky = true,
      ontop = false,
      focusable = false,
      border_width = 0,
      size_hints = {"program_position", "program_size"}
    } },
    {   rule = { name = "LibreOffice 5", class = "Soffice", type = "normal"},
        properties = { 
            screen = screen.count()>1 and 2 or 1,
            fullscreen = true, 
            skip_taskbar = true,
            focusable = true}
    },
    { rule = { class = "Oblogout" },
      properties = {
      skip_taskbar = true,
      sticky = true,
      screen = 1,
      fullscreen = true,
      ontop = true,
      border_width = 0
    } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}

-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
   
-- Connect change screen signal to a resize function
client.connect_signal("property::screen", client_changed_screen)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    c.opacity = 1
    end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    c.opacity = beautiful.unfocused_opacity
    end)

-- }}}
