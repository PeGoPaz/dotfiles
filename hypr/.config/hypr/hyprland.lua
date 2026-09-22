--###############
--## MONITORS ###
--###############

-- ASUS TUF A14 (FA401GM) internal panel. No external outputs.
-- Scale 1.6 keeps the logical size whole: 2560/1.6 = 1600, 1600/1.6 = 1000.
-- UNVERIFIED: confirm the mode is accepted with `hyprctl monitors`.
hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@165",
    position = "auto",
    scale = "1.6",
})

--##################
--## MY PROGRAMS ###
--##################

local terminal = "ghostty"
local fileManager = "ghostty -e ranger"
local menu = "fuzzel"
local browser = "firefox"

--#############################
--## ENVIRONMENT VARIABLES ###
--#############################

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Hybrid GPU: Radeon 890M (iGPU) + RTX 5060 (dGPU), modes switched with
-- supergfxctl. Deliberately NOT setting AQ_DRM_DEVICES / WLR_DRM_DEVICES:
-- pinning the compositor to the nvidia node means the session refuses to
-- start once supergfxctl is switched to Integrated. LIBVA_DRIVER_NAME is
-- left unset for the same reason - a fixed value breaks on mode switch,
-- libva picks the driver per device on its own.
hl.env("NVD_BACKEND", "direct")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

--####################
--## LOOK AND FEEL ###
--####################

-- Bezier curves for animations
-- See https://wiki.hypr.land/Configuring/Animations/#curves
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1    }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0,    0    }, { 1,    1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5,  0.5  }, { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0    }, { 0.1,  1 } } })

-- Animations. Speed is in deciseconds, so 2 is the ~200ms target.
-- See https://wiki.hypr.land/Configuring/Animations/
hl.animation({ leaf = "global",        enabled = true, speed = 2,   bezier = "default"      })
hl.animation({ leaf = "border",        enabled = true, speed = 2, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 2, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 2,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 1.5, bezier = "quick"        })
hl.animation({ leaf = "layers",        enabled = true, speed = 2, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 2,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 2,    bezier = "quick"        })

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    --####################
    --## LOOK AND FEEL ###
    --####################

    -- Refer to https://wiki.hypr.land/Configuring/Variables/
    -- https://wiki.hypr.land/Configuring/Variables/#general
    general = {
        gaps_in = 2,
        gaps_out = 1,
        border_size = 1,
        -- The accent marks focus and nothing else.
        col = {
            active_border   = "rgba(c678ddff)",
            inactive_border = "rgba(2a2a2aff)",
        },
        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,
        -- Required for the `immediate` window rule below to do anything.
        allow_tearing = true,
        layout = "dwindle",
    },

    -- https://wiki.hypr.land/Configuring/Variables/#decoration
    decoration = {
        -- Sharp corners, fully opaque, no blur and no shadows.
        rounding = 0,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        },
    },

    -- https://wiki.hypr.land/Configuring/Variables/#animations
    animations = {
        enabled = true,
    },

    -- Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
    -- "Smart gaps" / "No gaps when only"
    -- uncomment all if you wish to use that.
    -- workspace = w[tv1], gapsout:0, gapsin:0
    -- workspace = f[1], gapsout:0, gapsin:0
    -- windowrule {
    --     name = no-gaps-wtv1
    --     match:float = false
    --     match:workspace = w[tv1]
    --     border_size = 0
    --     rounding = 0
    -- }
    -- windowrule {
    --     name = no-gaps-f1
    --     match:float = false
    --     match:workspace = f[1]
    --     border_size = 0
    --     rounding = 0
    -- }

    -- See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
    -- dwindle = {
    --     pseudotile    = true, -- Master switch for pseudotiling. Enabling is bound to mainMod + P below
    --     preserve_split = true, -- You probably want this
    -- },

    -- See https://wiki.hypr.land/Configuring/Master-Layout/ for more
    master = {
        new_status = "master",
    },

    -- https://wiki.hypr.land/Configuring/Variables/#misc
    misc = {
        force_default_wallpaper = 0,    -- 0 disables the bundled default wallpapers
        disable_hyprland_logo   = true, -- If true disables the random Hyprland logo / anime girl background :(
    },

    --############
    --## INPUT ###
    --############

    -- https://wiki.hypr.land/Configuring/Variables/#input
    input = {
        kb_layout  = "us,ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "grp:alt_shift_toggle",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.
        -- UNVERIFIED: these three key names are the highest-risk guess in this
        -- file. hyprlang spells the middle one tap-to-click, which is not a
        -- valid Lua identifier, so the underscore form is the assumption. If
        -- Hyprland refuses to start, check the log for this block first.
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,
            disable_while_typing = true,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

--##################
--## KEYBINDINGS ###
--##################

-- See https://wiki.hypr.land/Configuring/Keywords/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- See https://wiki.hypr.land/Configuring/Binds/ for more
hl.bind(mainMod .. " + return",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
-- bind = $mainMod, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
hl.bind(mainMod .. " + E",            hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + W",            hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + A",            hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd('cliphist list | fuzzel --dmenu --prompt "clipboard: " | cliphist decode | wl-copy'))
hl.bind(mainMod .. " + P",            hl.dsp.window.pseudo()) -- dwindle
-- bind = $mainMod, J, togglesplit, # dwindle
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd("hyprlock"))

-- Reload Waybar with Super + Shift + W
hl.bind(mainMod .. " + SHIFT + W",    hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))

-- Power Menu (Super + Backspace)
hl.bind(mainMod .. " + Backspace",    hl.dsp.exec_cmd("~/.config/hypr/scripts/powermenu.sh"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",         hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right",        hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",           hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",         hl.dsp.focus({ direction = "down"  }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1",            hl.dsp.focus({ workspace = 1  }))
hl.bind(mainMod .. " + 2",            hl.dsp.focus({ workspace = 2  }))
hl.bind(mainMod .. " + 3",            hl.dsp.focus({ workspace = 3  }))
hl.bind(mainMod .. " + 4",            hl.dsp.focus({ workspace = 4  }))
hl.bind(mainMod .. " + 5",            hl.dsp.focus({ workspace = 5  }))
hl.bind(mainMod .. " + 6",            hl.dsp.focus({ workspace = 6  }))
hl.bind(mainMod .. " + 7",            hl.dsp.focus({ workspace = 7  }))
hl.bind(mainMod .. " + 8",            hl.dsp.focus({ workspace = 8  }))
hl.bind(mainMod .. " + 9",            hl.dsp.focus({ workspace = 9  }))
hl.bind(mainMod .. " + 0",            hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1",    hl.dsp.window.move({ workspace = 1  }))
hl.bind(mainMod .. " + SHIFT + 2",    hl.dsp.window.move({ workspace = 2  }))
hl.bind(mainMod .. " + SHIFT + 3",    hl.dsp.window.move({ workspace = 3  }))
hl.bind(mainMod .. " + SHIFT + 4",    hl.dsp.window.move({ workspace = 4  }))
hl.bind(mainMod .. " + SHIFT + 5",    hl.dsp.window.move({ workspace = 5  }))
hl.bind(mainMod .. " + SHIFT + 6",    hl.dsp.window.move({ workspace = 6  }))
hl.bind(mainMod .. " + SHIFT + 7",    hl.dsp.window.move({ workspace = 7  }))
hl.bind(mainMod .. " + SHIFT + 8",    hl.dsp.window.move({ workspace = 8  }))
hl.bind(mainMod .. " + SHIFT + 9",    hl.dsp.window.move({ workspace = 9  }))
hl.bind(mainMod .. " + SHIFT + 0",    hl.dsp.window.move({ workspace = 10 }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",            hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272",    hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273",    hl.dsp.window.resize())

-- Laptop multimedia keys for volume and LCD brightness (locked = bindl, repeating = bindel)
hl.bind("XF86AudioRaiseVolume",       hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",       hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",              hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",        hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",      hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                   { locked = true, repeating = true })

-- Screenshot (Print Screen)
hl.bind("Print",                      hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh"))

-- Requires playerctl
hl.bind("XF86AudioNext",              hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause",             hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",              hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",              hl.dsp.exec_cmd("playerctl previous"),     { locked = true })

-- Lid switch handling
-- If plugged in (systemd-ac-power returns 0/true) -> Turn screen off
-- If on battery  (systemd-ac-power returns 1/false) -> Suspend
hl.bind("switch:on:Lid Switch",
    hl.dsp.exec_cmd("systemd-ac-power && hyprctl dispatch dpms off || systemctl suspend"),
    { locked = true })

-- When opening lid -> Turn screen back on
hl.bind("switch:off:Lid Switch",
    hl.dsp.exec_cmd('hyprctl dispatch dpms on && hyprctl keyword monitor "eDP-1, 2560x1600@165, auto, 1.6"'),
    { locked = true })

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more
-- See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Games. idle_inhibit keeps the screen from blanking mid-session, immediate
-- lets frames tear for latency (needs general.allow_tearing, set above), and
-- fullscreen skips the windowed first frame.
-- UNVERIFIED: field names are the snake_case of the hyprlang rules, matching
-- no_focus / suppress_event below. Confirm against `hyprctl clients` classes.
hl.window_rule({
    name = "steam-games",
    match = {
        class = "^steam_app_\\d+$",
    },
    idle_inhibit = "always",
    immediate    = true,
    fullscreen   = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run",
    },
    move  = "20 monitor_h-120",
    float = true,
})

--#################
--## AUTOSTART ####
--#################

-- Only what this config owns. The polkit agent, xdg-desktop-portal, the
-- greeter and audio are left to CachyOS - starting them twice causes more
-- trouble than it solves.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")   -- Stores only text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store")  -- Stores only image data
end)
