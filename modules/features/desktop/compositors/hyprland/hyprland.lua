
@monitors@
@env@
hl.config({
    general = {
        gaps_in = @gaps_in@,
        gaps_out = @gaps_out@,
        border_size = @border_size@,
        col = {
            active_border = "@active_border@",
            inactive_border = "@inactive_border@",
        },
        layout = "scrolling",
        resize_on_border = true,
    },

    decoration = {
        rounding = @rounding@,
        active_opacity = @active_opacity@,
        inactive_opacity = @inactive_opacity@,
        shadow = { enabled = false },
    },

    animations = { enabled = true },

    input = {
        kb_layout = "@kb_layout@",
        follow_mouse = 1,
        touchpad = {@touchpad@},
    },

    cursor = {
        hide_on_touch = true,
        inactive_timeout = 3,
    },

    misc = {
        disable_hyprland_logo = true,
        focus_on_activate = true,
    },
})

hl.config({
    scrolling = {
        direction = "right",
        follow_focus = true,
        fullscreen_on_one_column = true,
    },
})
@gesture@
hl.on("hyprland.start", function()
@autostart@end)

hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ name = "browser-opaque", match = { class = "^(com\\.brave\\.Browser|brave-browser)$" }, opacity = "1.0 1.0" })
hl.window_rule({ name = "term-halfcol", match = { class = "^@term_class@$" }, scrolling_width = 0.5 })
hl.window_rule({ name = "pip", match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true, size = "640 360" })
hl.window_rule({ name = "dialogs-float", match = { title = "^(Open File|Save As|termfilechooser)$" }, float = true })
hl.window_rule({ name = "bitwarden-float", match = { title = "Bitwarden" }, float = true, size = "1024 768" })

local mod = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd([[@term@]]))
hl.bind(mod .. " + E", hl.dsp.exec_cmd([[@yazi@]]))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + C", hl.dsp.window.center())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + Escape", hl.dsp.exit())

hl.bind(mod .. " + H", hl.dsp.layout("focus l"))
hl.bind(mod .. " + L", hl.dsp.layout("focus r"))
hl.bind(mod .. " + J", hl.dsp.layout("focus d"))
hl.bind(mod .. " + K", hl.dsp.layout("focus u"))

hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))

hl.bind(mod .. " + comma",  hl.dsp.layout("consume"))
hl.bind(mod .. " + period", hl.dsp.layout("expel"))

hl.bind(mod .. " + CTRL + H", hl.dsp.layout("colresize -0.1"))
hl.bind(mod .. " + CTRL + L", hl.dsp.layout("colresize +0.1"))
hl.bind(mod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -36, relative = true }))
hl.bind(mod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 36, relative = true }))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

@extrabinds@
