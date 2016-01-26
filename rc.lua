-----------------------------
-- AwesomeWM configuration --
--       version 3.5       --
--          by iixv        --
-----------------------------

local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")

-- {{ THEME }}
beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")

--{{ Modules and Widgets }}
local naughty   = require("naughty")
local menubar   = require("menubar")
local vicious   = require("vicious")
local drop      = require("scratchdrop")
local lain      = require("lain")
local wi        = require("wi")
local blackarch = require("blackarch.init")

-- {{{ Error handling
-- Startup
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!",
                   text = awesome.startup_errors })
end

-- Runtime
do
  local in_error = false
  awesome.connect_signal("debug::error",
    function(err)
      if in_error then return end
      in_error = true
      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Oops, an error happened!",
                       text = err })
      in_error = false
    end)
end
-- }}}

-- {{{ Variables
editor     = os.getenv("EDITOR") or "vim"
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "xfce4-terminal"
editor     = os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor
fmng       = "thunar"

-- User Defined
browser    = "luakit"
browser2   = "chromium"
gui_editor = "gvim"
graphics   = "gimp"
mail       = terminal .. " -e mutt "

-- {{{ Layouts
local layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier }
-- }}}

-- {{{ Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Monaco 13"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 120
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 1
naughty.config.defaults.hover_timeout = nil
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
tags = {
  names   = {  " [ ☼ ] ", 	" web ⇨ ",    	" editor Ѻ ", 	" media ➏ ",  	" ☯ " 		},
  layouts = { layouts[5], 	layouts[1], 	layouts[5], 	    layouts[4], 	layouts[1] 	},
  mwfact  = {   .6805,        .6805,        .6805,             .6805,       .6805     }
}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Menu
myawesomemenu = {
    { "manual", terminal .. " -e 'man awesome ;'" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", awesome.quit }
                }

browsermenu = {
    { "firefox", "firefox" },
    { "chromium", "chromium" }
              }

networkmenu = {
    { "Wicd-Curses", terminal .. " -e 'wicd-curses ;'" },
    { "Wicd-GTK", "wicd-gtk" },
    { "Deluge", "deluge" },
    { "Dropbox", "dropbox" },
    { "Skype", "skype" }
              }

pentesters = {
    { "Nmap", "konsole -e 'sudo nmap -h ; zsh ;'" },
}

mymainmenu = awful.menu({ items = { { "Arch", myawesomemenu, beautiful.awesome_arch },
                                    { "open terminal", terminal, beautiful.menu_term },
                                    { "Browsers", browsermenu, beautiful.menu_brow },
                                    { "Network", networkmenu, beautiful.menu_wifi },
                                    { "Apps", require("menugen").build_menu(), beautiful.menu_apps },
                                    --{ "PenTesters", pentesters, beautiful.menu_red }

                                   }
                        })


mylauncher = awful.widget.launcher(
{ 
  image = beautiful.awesome_arch,
  menu = mymainmenu 
})


-- Menubar
menubar.utils.terminal = terminal

-- Clock
--mytextclock = awful.widget.textclock("<span color='" .. beautiful.fg_em ..
--  "'>%a %m/%d</span> @ %I:%M %p")

-- {{{ Initialize wiboxes
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}

-- Taglist
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))

-- Tasklist
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1,
    function(c)
      if c == client.focus then
        c.minimized = true
      else
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, 3,
    function()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=250 })
      end
    end),
  awful.button({ }, 4,
    function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({ }, 5,
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end))
-- }}}

-- {{{ Create wiboxes
for s = 1, screen.count() do
  mypromptbox[s] = awful.widget.prompt()

  -- Layoutbox
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))

  -- Taglist
  mytaglist[s] = awful.widget.taglist(s,
    awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Tasklist
  mytasklist[s] = awful.widget.tasklist(s,
    awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Wibox
  mywibox[s] = awful.wibox({ position = "top", height = 18, screen = s })

  local left_wibox = wibox.layout.fixed.horizontal()
  left_wibox:add(mylauncher)
  

  local middle_wibox = wibox.layout.fixed.horizontal()
  --middle_wibox:add(mytextclock)
  left_wibox:add(mytaglist[s])
  left_wibox:add(space)
  left_wibox:add(mypromptbox[s])

  local right_wibox = wibox.layout.fixed.horizontal()
  right_wibox:add(space)
  right_wibox:add(mpdicon)
  right_wibox:add(mpdwidget)
  right_wibox:add(space)
  right_wibox:add(volumewidget)
  right_wibox:add(space)
  right_wibox:add(kbdcfg.widget)

  local wibox_layout = wibox.layout.align.horizontal()
  wibox_layout:set_left(left_wibox)
  wibox_layout:set_middle(mytasklist[s])
  wibox_layout:set_right(right_wibox)

  mywibox[s]:set_widget(wibox_layout)


  -- Graphbox
  mygraphbox[s] = awful.wibox({ position = "bottom", height = 18, screen = s })

  local left_graphbox = wibox.layout.fixed.horizontal()
  if s == 1 
    then 
      left_graphbox:add(wibox.widget.systray()) 
  end
  
  

  local right_graphbox = wibox.layout.fixed.horizontal()
  right_graphbox:add(space)
  right_graphbox:add(mylayoutbox[s])
  

  local middle_graphbox = wibox.layout.fixed.horizontal()
  middle_graphbox:add(space)
  middle_graphbox:add(wifiicon)
  middle_graphbox:add(wifiwidget)
  middle_graphbox:add(tab)
  middle_graphbox:add(netdownicon)
  middle_graphbox:add(netdowninfo)
  middle_graphbox:add(netupicon)
  middle_graphbox:add(netupinfo)
  middle_graphbox:add(tab)
  middle_graphbox:add(baticon)
  middle_graphbox:add(batpct)
  middle_graphbox:add(tab)
  middle_graphbox:add(pacicon)
  middle_graphbox:add(pacwidget)
  middle_graphbox:add(tab)
  middle_graphbox:add(mytextclock)
  middle_graphbox:add(tab)
  middle_graphbox:add(cpuicon2)
  middle_graphbox:add(cpuwidget)
  middle_graphbox:add(tab)
  middle_graphbox:add(fsicon)
  middle_graphbox:add(fswidget)
  middle_graphbox:add(tab)
  middle_graphbox:add(fsicon)
  middle_graphbox:add(fs3widget)
  middle_graphbox:add(tab)
  middle_graphbox:add(memicon)
  middle_graphbox:add(memwidget)
 

  local graphbox_layout = wibox.layout.align.horizontal()
  graphbox_layout:set_left(left_graphbox)
  graphbox_layout:set_middle(middle_graphbox)
  graphbox_layout:set_right(right_graphbox)

  mygraphbox[s]:set_widget(graphbox_layout)
end
-- }}}

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- {{{ Global keybindings
globalkeys = awful.util.table.join(
  -- Tag navigation
    awful.key({ altkey }, "p", function() os.execute("scrot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mygraphbox[mouse.screen].visible = not mygraphbox[mouse.screen].visible
    end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "o", function () awful.util.spawn(fmng) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,           }, "e",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "h",      function () fswidget.show(7) end),
    awful.key({ altkey,           }, "w",      function () yawn.show(7) end),
    
 

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            awful.util.spawn("amixer -q set Master 1%+")
            volumewidget.update()
        end),
    awful.key({ altkey }, "Down",
        function ()
            awful.util.spawn("amixer -q set Master 1%-")
            volumewidget.update()
        end),
    awful.key({ altkey }, "m",
        function ()
            awful.util.spawn("amixer -q set Master playback toggle")
            volumewidget.update()
        end),
    awful.key({ altkey, "Control" }, "m",
        function ()
            awful.util.spawn("amixer -q set Master playback 100%")
            volumewidget.update()
        end),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
            mpdwidget.update()
        end),

    -- keyboard map change
    awful.key({ modkey }, "Shift_R", function () kbdcfg.switch() end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- {{{ Rules
awful.rules.rules = {
  { rule = { },
    properties = { border_width = beautiful.border_width,
                   border_color = beautiful.border_normal,
                   focus = awful.client.focus.filter,
                   keys = clientkeys,
                   buttons = clientbuttons } },
  { rule = { class = "MPlayer" },
   properties = { tag = tags[1][4] } },
  { rule = { class = "Skype" },
    properties = { floating = true, tag = tags[1][5] } },
  { rule = { class = "Godesk" },
    properties = { floating = true } },
  { rule = { class = "Pinentry" },
    properties = { floating = true } },
  { rule = { class = "Chromium" },
    properties = { floating = true, tag = tags[1][2] } },
  { rule = { class = "luakit" },
    properties = { tag = tags[1][2] } },
  { rule = { class = "Atom" },
    properties = { tag = tags[1][3] } },
  { rule = { class = "Brackets" },
    properties = { tag = tags[1][3] } },
  { rule = { class = "Thunderbird", instance = "Mail" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Calendar" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Msgcompose" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunar" },
    properties = { tag = tags[1][5] } },
  { rule = { class = "Bluefish" },
    properties = { tag = tags[1][3] } },
  { rule = { class = "Gimp-2.8" },
    properties = { floating = true, tag = tags[1][5] } }, 
  { rule = { class = "Ettercap" },
    properties = { tag = tags[1][1] } },
  { rule = { class = "messengerfordesktop" },
    properties = { tag = tags[1][5] } },
  { rule = { class = "Playonlinux" },
    properties = { tag = tags[1][5] } } }

-- }}}

-- {{{ Signals
client.connect_signal("manage",
  function(c, startup)
    c.size_hints_honor = false

    -- Sloppy focus
    c:connect_signal("mouse::enter",
      function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
          client.focus = c
        end
      end)

    if not startup then
      -- Set the windows at the slave
      awful.client.setslave(c)

      -- Place windows in a smart way, only if they do not set an initial position
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))

      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      local title = awful.titlebar.widget.titlewidget(c)
      title:buttons(awful.util.table.join(
        awful.button({ }, 1,
          function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
          end),
        awful.button({ }, 3,
          function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
          end)))

      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(title)

      awful.titlebar(c):set_widget(layout)
    end
  end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- vim:set ts=2 sw=2 sts=2 et:
