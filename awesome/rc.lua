-- awesome_mode: api-level=4:screen=off
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local function debug(key, value)
   -- print(tostring(key) .. " " .. tostring(value))
   -- naughty.notify({ preset = naughty.config.presets.low,
   --                  title = tostring(key),
   --                  text = tostring(value),
   --                  timeout = 60
   -- })
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "zile"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function(a1, a2)
                      print("request::default_layouts " .. tostring(a1, a2))
    awful.layout.append_default_layouts({
        -- awful.layout.suit.floating,
        awful.layout.suit.tile,
        -- awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        -- awful.layout.suit.tile.top,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.fair.horizontal,
        -- awful.layout.suit.spiral,
        -- awful.layout.suit.spiral.dwindle,
         awful.layout.suit.max,
        -- awful.layout.suit.max.fullscreen,
        -- awful.layout.suit.magnifier,
        -- awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wallpaper
-- screen.connect_signal("request::wallpaper", function(s)
--     awful.wallpaper {
--         screen = s,
--         widget = {
--             {
--                 image     = beautiful.wallpaper,
--                 upscale   = true,
--                 downscale = true,
--                 widget    = wibox.widget.imagebox,
--             },
--             valign = "center",
--             halign = "center",
--             tiled  = false,
--             widget = wibox.container.tile,
--         }
--     }
-- end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local function inspect(s)
    if (s == nil) then
       return "nil (inspect bailing)"
    end

    g = s.geometry
    local size = "?x?"
    if g ~= nil then
       size = g.width .. "x" .. g.height
    end
    local f_count = 0
    if s.fakes then
       for _ in pairs(s.fakes) do
          f_count = f_count + 1
       end
    end
    local c_count = 0
    if (s.all_clients ~= nil) then
       gears.debug.dump(s.all_clients, "all_clients")
       for k, c in pairs(s.all_clients) do
          c_count = c_count + 1
       end
    else
       debug(s, "all_clients is nil")
    end
    gears.debug.dump(s.outputs, "screen outputs")
    tail = " has " .. f_count .. " fakes. clients: " .. c_count
    return tostring(s) .." / " .. tostring(s.index) .. "   " .. size .. tail
end

local function nsp(s)
    if (s == nil) then
       return "nil (inspect bailing)"
    end

    g = s.geometry
    local size = "?x?"
    if g ~= nil then
       size = g.width .. "[".. tostring(s.original_w) .. "]" .. "x" .. g.height
    end
    return tostring(s.index) .." / " .. tostring(s.index) .. "   " .. size
end

function restore_windows_to_desired_screen(new_screen)
    print("restore_windows_to_desired_screen")
    debug("added", inspect(new_screen))
    local output = next(new_screen.outputs)

    if (output ~= nil) then
       naughty.notify({ text = output .. " Connected" })
    end

    local i = nil

    for _, c in ipairs(client.get()) do
       if not (c.desired_screen == nil) then
          tag_name = c.first_tag.name
          c:move_to_screen(c.desired_screen)
          tag = awful.tag.find_by_name(c.screen, tag_name)
          if not (tag == nil) then
             c:move_to_tag(tag)
             debug("restoring", tostring(c) .. " -> " .. tostring(tag.name))
          else
             debug("unable to restore", tostring(c))
          end
          -- now clear the "desired_screen"
          c.desired_screen = nil
       end
    end

end


screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.tile)
    restore_windows_to_desired_screen(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                mylauncher,
                s.mytaglist,
                s.mypromptbox,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                mykeyboardlayout,
                wibox.widget.systray(),
                mytextclock,
                s.mylayoutbox,
            },
        }
    }
end)
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    -- awful.button({ }, 4, awful.tag.viewprev),
    -- awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey,           }, "t",      function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "f",      function () awful.spawn("firefox") end,
              {description = "open firefox",    group = "launcher"}),
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})



-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ "Mod1",           }, "Tab",
       function ()
          awful.client.focus.byidx( 1)
          if client.focus then client.focus:raise() end
       end,
       {description = "go back", group = "client"}
    ),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    -- awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    --           {description = "focus the next screen", group = "screen"}),
    -- awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    --           {description = "focus the previous screen", group = "screen"}),

     awful.key({ modkey,           }, "space", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

--    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
--              {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey, "Shift"   }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)



local function wide_split_layout()
   if (screen.count() ~= 1) then
      debug("more than 1 screen, bailing on main layout", screen.count())
      return
   end
   local geo = screen[1].geometry
   local new_width = math.ceil(3*geo.width/4) - 30  -- personal sweet spot for main screen size
   local new_width2 = geo.width - new_width
   local parent = screen[1]
   parent.original_w = geo.width
   parent.original_h = geo.height
   parent:fake_resize(geo.x, geo.y, new_width, geo.height)
   fake = screen.fake_add(geo.x + new_width, geo.y, new_width2, geo.height)
   debug("new fake: "..fake.index, inspect(fake))
   if (parent.fakes == nil) then
      debug("no fakes")
      parent.fakes = {}
   end
   parent.fakes[fake.index] = fake
   for k, v in pairs(fake.tags) do
      v.layout = awful.layout.suit.tile.bottom
   end
   debug("parent.fakes", #(parent.fakes))
   debug("parent", inspect(parent))
   collectgarbage('collect')
end


local function resize_fake_screen(delta)
   if (screen.count() ~= 2) then
      return
   end
   local geo1 = screen[1].geometry
   local geo2 = screen[2].geometry
   screen[1]:fake_resize(geo1.x, geo1.y, geo1.width+delta, geo1.height)
   screen[2]:fake_resize(geo2.x+delta, geo2.y, geo2.width-delta, geo2.height)
end


local function dmp()
   print("dumping \n")
   for _, c in ipairs(client.get()) do
      -- debug(
      --    "dump",
      --    tostring(c) .. " wants to be"
      -- )
      s = "X"
      if not (c.desired_screen == nil) then
         s = c.desired_screen
      end
      debug(
         "w: ",
         tostring(c) .. " on " .. c.screen.index .. " wants to be on disp: " .. tostring(s) .. " tag: " .. tostring(c.first_tag.name)
      )
   end

   print("screens")
   for s in screen do
      debug("screen " .. s.index, inspect(s))
   end
   print("end screens\n")

   debug("count", screen.count())
   debug("instances", screen.instances())

   print("end dump")
end


local function non_wide_layout()
   for s in screen do
      if s.fakes then
         for _, f in pairs(s.fakes) do
            f:fake_remove()
         end

         s.fakes = nil

         local geo = s.geometry
         s:fake_resize(geo.x, geo.y, s.original_w, geo.height)
      end
   end
end



globalkeys = gears.table.join(
    globalkeys,
    awful.key({ modkey,           }, "#73",   function() non_wide_layout() end,
              {description="single screen layout", group="layouts"}),
    awful.key({ modkey,           }, "#72",   function() wide_split_layout() end,
              {description="wide screen split layout", group="layouts"}),
    awful.key({ modkey,           }, "#71",   function() resize_fake_screen(-15) end,
              {description="resize screen -5", group="layouts"}),
    awful.key({ modkey,           }, "#74",   function() resize_fake_screen( 15) end,
              {description="resize screen +5", group="layouts"}),
    awful.key({ modkey,           }, "#75",   function() dmp() end,
              {description = "Dump debug info.", group = "debug"})
)


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- }}}

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)


-- rciorba custom screen handling

-- Handle screen being removed.
-- We'll look for same tag names and move clients there, but preserve
-- the "desired_screen" so we can move them back when it's connected.
tag.connect_signal("request::screen", function(t)
    local fallback_tag = nil

    debug("request::screen for", t.screen.index .. "/" .. t.name)
    -- find tag with same name on any other screen
    for other_screen in screen do
        if other_screen ~= t.screen then
            fallback_tag = awful.tag.find_by_name(other_screen, t.name)
            if fallback_tag ~= nil then
                break
            end
        end
    end

    -- no tag with same name exists, chose random one
    if fallback_tag == nil then
        fallback_tag = awful.tag.find_fallback()
    end

    if not (fallback_tag == nil) then

        clients = t:clients()

        for _, c in ipairs(clients) do
           debug("tag screen", inspect(t.screen))
           debug("relocation", c.name .. " moving from " .. c.screen.index .. " to " .. fallback_tag.index)
           c:move_to_tag(fallback_tag)
           -- preserve info about which screen the window was originally on, so
           -- we can restore it if the screen is reconnected.
           c.desired_screen = t.screen.index
        end
    end
end)

-- screen.connect_signal("added", on_new_screen)


screen.connect_signal("removed", function(old_screen)
    print("")
    debug("removed", inspect(old_screen))
    print("")
    fakes = old_screen.fakes or {}
    for _, fake in pairs(fakes) do
       fake:fake_remove()
    end
    old_screen.fakes = nil
    collectgarbage('collect')
end)

screen.connect_signal(
   "request::resize",
   function(old, new, reason)
      print("request::resize")
      gears.debug.dump(reason, "reason")
      gears.debug.dump(old, "old geo")
      gears.debug.dump(new, "new geo")

      for s in screen do
         print("inspecting screen: "..s.index .. " original_w "..tostring(s.original_w))
         print(nsp(s))
         if (s.original_w == old.geometry.width) and (s.original_h == old.geometry.height) then
            print("fixing original_w for " .. s.index)
            s.original_w = new.geometry.width
            s.original_h = new.geometry.height
         end
      end

      if new.geometry.width == 3440 then
         print("going to wide layout")
         wide_split_layout()
      end
      if new.geometry.width == 1920 then
         print("going to regular layout")
         non_wide_layout()
      end


      print("end request::resize")
end)
