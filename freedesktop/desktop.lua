local awful = require("awful")
local wibox = require("wibox")
local table = table
local ipairs = ipairs
local os = os
local utils = require("freedesktop.utils")
local beautiful = require("beautiful")
local capi = { screen = screen }

local module = {}

module.config = {
      computer = true,
      home = true,
      network = true,
      trash = true,
 }

local current_pos = {}
local iconsize = { width = 48, height = 48 }
local labelsize = { width = 120, height = 20 }

function module.add_icon(settings)

    local s = settings.screen
	local textbox_context = {dpi=beautiful.xresources.get_dpi(mouse.screen)}

    if not current_pos[s] then
        current_pos[s] = { x = (capi.screen[s].geometry.x + iconsize.width/2 + settings.spacing_x), y = settings.start_position }
    end

    local totheight = (settings.icon and iconsize.height or 0) + (settings.label and labelsize.height or 0)
    if totheight == 0 then return end

    if current_pos[s].y + totheight + 5 > capi.screen[s].geometry.height then
        current_pos[s].x = current_pos[s].x + labelsize.width + settings.spacing_x
        current_pos[s].y = settings.start_position
    end

    if (settings.icon) then
        icon = awful.widget.button({ image = settings.icon })
        icon:buttons(awful.button({ }, 1, nil, settings.click))

        icon_container = wibox({ screen = s, bg = "#00000000",
								 width = iconsize.width, height = iconsize.height,
								 y = current_pos[s].y, x = current_pos[s].x,
								 visible = true, type = "desktop" })
        icon_container:set_widget(icon)
    end

    current_pos[s].y = current_pos[s].y + iconsize.height + 5

    if (settings.label) then
        caption = wibox.widget.textbox()
        caption:fit(textbox_context, labelsize.width, labelsize.height)
        caption:set_align("center")
        caption:set_ellipsize("middle")
        caption:set_text(settings.label)
        caption:buttons(awful.button({ }, 1, settings.click))

        caption_container = wibox({ screen = s, bg = "#00000000",
									width = labelsize.width, height = labelsize.height,
									y = current_pos[s].y, x = current_pos[s].x - (labelsize.width/2) + iconsize.width/2,
									visible = true, type = "desktop" })
        caption_container:set_widget(caption)
    end

    current_pos[s].y = current_pos[s].y + labelsize.height + settings.spacing_y
end


function module.add_base_icons(arg)
    arg.open_with = arg.open_with or 'xdg-open' or 'thunar'
	if module.config.computer then
		module.add_icon({
			label = 'Computer',
			icon = utils.lookup_icon({ icon='computer' }),
			screen = arg.screen,
			click = function () awful.spawn(arg.open_with .. ' "computer://"') end
		}) end
	if module.config.home then
		module.add_icon({
			label = 'Home',
			icon = utils.lookup_icon({ icon='user-home' }),
			screen = arg.screen,
			click = function () awful.spawn(arg.open_with .. ' ' .. os.getenv("HOME")) end
		}) end
	if module.config.network then
		module.add_icon({
			label = 'Network',
			icon = utils.lookup_icon({ icon='network-workgroup' }),
			screen = arg.screen,
			click = function () awful.spawn(arg.open_with .. ' "network://"') end
		}) end
	if module.config.trash then
		module.add_icon({
			label = 'Trash',
			icon = utils.lookup_icon({ icon='user-trash' }),
			screen = arg.screen,
			click = function () awful.spawn(arg.open_with .. ' "trash://"') end
		}) end
end

--- Adds subdirs and files icons to the desktop
-- @param dir The directory to parse, (default is ~/Desktop)
-- @param showlabels Shows icon captions (default is false)
function module.add_applications_icons(arg)
    for i, program in ipairs(utils.parse_desktop_files({
        dir = arg.dir or '~/Desktop/',
        icon_sizes = {
            iconsize.width .. "x" .. iconsize.height,
            "128x128", "96x96", "72x72", "64x64", "48x48",
            "36x36", "32x32", "24x24", "22x22", "16x6"
        }
    })) do
        if program.show and program.Name:sub(1,1) ~= '.' then
            module.add_icon({
                label = arg.showlabels and program.Name or nil,
                icon = program.icon_path,
                screen = arg.screen,
				start_position = arg.start_position or 40,
				spacing_x = arg.spacing_x  or 20,
				spacing_y = arg.spacing_y  or 15,
                click = function () awful.spawn(program.cmdline) end
            })
        end
    end
end

--- Adds subdirs and files icons to the desktop
-- @param dir The directory to parse
-- @param showlabels Shows icon captions
-- @param open_with The program to use to open clicked files and dirs (i.e. xdg_open, thunar, etc.)
function module.add_dirs_and_files_icons(arg)
    arg.open_with = arg.open_with or 'thunar'
    for i, file in ipairs(utils.parse_dirs_and_files({
        dir = arg.dir or '~/Desktop/',
        icon_sizes = {
            iconsize.width .. "x" .. iconsize.height,
            "128x128", "96x96", "72x72", "64x64", "48x48",
            "36x36", "32x32", "24x24", "22x22", "16x6"
        }
    })) do
        if file.show and file.filename:sub(1,1) ~= '.' then
            module.add_icon({
                label = arg.showlabels and file.filename or nil,
                icon = file.icon,
                screen = arg.screen,
				start_position = arg.start_position or 33,
				spacing_x = arg.spacing_x  or 20,
				spacing_y = arg.spacing_y  or 15,
                click = function () awful.spawn(arg.open_with .. ' "' .. file.path .. '"') end
            })
        end
    end
end

function module.add_desktop_icons(arg)
    module.add_base_icons(arg)
    module.add_applications_icons(arg)
    module.add_dirs_and_files_icons(arg)
end

return module
