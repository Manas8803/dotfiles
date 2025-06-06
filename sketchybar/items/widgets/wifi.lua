local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sbar.exec(
  "killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0")

local popup_width = 250

local wifi_up = sbar.add("item", "widgets.wifi1", {
  position = "right",
  padding_left = -10,
  padding_right = 10,
  width = "dynamic",
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    color = colors.red,
    string = "Disconnected",
  },
  y_offset = 0,
})
-- wifi:subscribe({"wifi_change", "system_woke"}, function(env)
--   sbar.exec("ipconfig getifaddr en0", function(ip)
--     local connected = not (ip == "")
--     wifi:set({
--       icon = {
--         string = connected and icons.wifi.connected or icons.wifi.disconnected,
--         color = connected and colors.white,
--       },
--     })
--   end)
-- end)


local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  padding_right = 6,
  label = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
  wifi_up.name,
}, {
  background = { color = colors.bg1 },
  popup = { align = "center", height = 30 }
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  }
})

local ip = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local mask = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  }
})

local router = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

sbar.add("item", { position = "right", width = "dynamic" })
wifi_up:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec("networksetup -getairportnetwork en0 | awk -F ': ' '{print $2}'", function(result)
    local ssid = result:gsub("\n", "") -- Remove newline characters
    local connected = ssid ~= "" and not ssid:match("not associated")

    wifi_up:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.white
      },
      label = {
        string = connected and ssid or "Disconnected",
        color = connected and colors.magenta or colors.red
      }
    })
  end)
end)

-- WIFI SPEED :
-- wifi_up:subscribe("network_update", function(env)
--   local up_color = (env.upload == "000 Bps") and colors.grey or colors.white
--   wifi_up:set({
--     icon = { color = up_color },
--     label = {
--       string = env.upload,
--       color = colors.red
--     }
--   })
-- end)


local function hide_details()
  wifi_bracket:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true } })
    sbar.exec("networksetup -getcomputername", function(result)
      hostname:set({ label = result })
    end)
    sbar.exec("ipconfig getifaddr en0", function(result)
      ip:set({ label = result })
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set({ label = result })
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set({ label = result })
    end)
  else
    hide_details()
  end
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec("echo \"" .. label .. "\" | pbcopy")
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
