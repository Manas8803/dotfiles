local icons = require("icons")
local colors = require("colors")
-- Expand whitelist to include common media players
local whitelist = {
    ["Spotify"] = true,
    ["Music"] = true,
    ["VLC"] = true,
    ["Firefox"] = true, -- For web-based players
    ["Chrome"] = true,  -- For web-based players
    ["mpv"] = true,
    ["Apple Music"] = true,
    ["iTunes"] = true,
    ["Brave"] = true,    -- For web-based players
    ["chromium"] = true, -- For web-based players
    ["cmus"] = true,     -- Terminal music player
    ["ncmpcpp"] = true,  -- Terminal music player
    ["mplayer"] = true,
    ["rhythmbox"] = true,
    ["clementine"] = true,
    ["audacious"] = true,
}

local media_cover = sbar.add("item", {
    position = "right",
    padding_right = -20,
    background = {
        image = {
            string = "media.artwork",
            scale = 0.95,
        },
        color = colors.transparent,
    },
    label = { drawing = false },
    icon = { drawing = false },
    drawing = false,
    updates = true,
    popup = {
        align = "right",
        horizontal = true,
    }
})

local media_artist = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    width = 0,
    icon = { drawing = false },
    label = {
        width = 0,
        font = { size = 9 },
        color = colors.with_alpha(colors.white, 0.6),
        max_chars = 25,
        y_offset = -8,
    },
})

local media_title = sbar.add("item", {
    position = "right",
    drawing = false,
    padding_left = 3,
    padding_right = 0,
    icon = { drawing = false },
    label = {
        font = { size = 10 },
        width = 0,
        max_chars = 55,
        y_offset = 6,
    },
})

-- Media controls in popup
sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.back },
    label = { drawing = false },
    click_script = "nowplaying-cli previous",
})

sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.play_pause },
    label = { drawing = false },
    click_script = "nowplaying-cli togglePlayPause",
})

sbar.add("item", {
    position = "popup." .. media_cover.name,
    icon = { string = icons.media.forward },
    label = { drawing = false },
    click_script = "nowplaying-cli next",
})

local interrupt = 0
local function animate_detail(detail)
    if (not detail) then interrupt = interrupt - 1 end
    if interrupt > 0 and (not detail) then return end
    sbar.animate("tanh", 30, function()
        media_artist:set({ label = { width = detail and "dynamic" } })
        media_title:set({ label = { width = detail and "dynamic" } })
    end)
end

-- Modified media_change event handler to work with any media player
media_cover:subscribe("media_change", function(env)
    -- Check if any media is playing, regardless of the app
    local drawing = (env.INFO.state == "playing")
    -- Always show media info if something is playing
    media_artist:set({
        drawing = drawing,
        label = env.INFO.artist or "Unknown Artist",
    })
    media_title:set({
        drawing = drawing,
        label = env.INFO.title or "Unknown Title",
    })
    media_cover:set({ drawing = drawing })

    if drawing then
        animate_detail(true)
        interrupt = interrupt + 1
        sbar.delay(5, animate_detail)
    else
        media_cover:set({ popup = { drawing = false } })
    end
end)

-- Mouse event handlers
media_cover:subscribe("mouse.entered", function(env)
    interrupt = interrupt + 1
    animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(env)
    animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(env)
    media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(env)
    media_cover:set({ popup = { drawing = false } })
end)
