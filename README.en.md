# GF UI · Notifications, progress bar & help text for FiveM

![GF UI](docs/cover.jpg)

**[Versión en español](README.md)** · **[⬇ Download the latest version](../../releases/latest)** · [Website](https://gfscripts.github.io) · [Discord](https://discord.gg/nR78WKsqf)

GF UI is a **free and open source** interface by **GF Scripts** for your FiveM server. It replaces three things players see all the time:

- **Notifications**: "Vehicle stored", "Not enough money"...
- **Progress bar**: "Repairing vehicle... 74%".
- **Help text**: `[E] Open garage`.

One clean design for all of them. Works with **ESX**, **QBCore** or standalone. No build step and no dependencies.

> The default texts are in Spanish. Change them in `config.lua` (`Config.Notify.titles`, `Config.Progress.cancelText`).

## Screenshots

| Notifications | Progress bar | Help text |
|---|---|---|
| ![Notifications](docs/ui-toasts.png) | ![Progress bar](docs/ui-progress.png) | ![Help text](docs/ui-text.png) |

<!--
| In game: notifications | In game: progress bar | In game: help text |
|---|---|---|
| ![Notifications in game](docs/ingame-avisos.jpg) | ![Progress bar in game](docs/ingame-barra.jpg) | ![Help text in game](docs/ingame-texto.jpg) |
-->

## Install

1. Download `gf-ui-1.0.0.zip` from [Releases](../../releases/latest) and unzip it.
2. Copy the **`gf-ui`** folder into your server's `resources` folder.
3. In `server.cfg`, add this line **before** your framework and other scripts:
   ```
   ensure gf-ui
   ```
4. Restart the server.
5. In game, type **`/gfui_demo`** in chat. You should see four notifications, the help text and a progress bar.
6. When everything works, set `Config.Debug = false` in `gf-ui/config.lua`.

### ESX

Back up your `esx_notify`, `esx_progressbar` and `esx_textui` folders (usually in `resources/[core]`) and replace them with the ones in `compatibilidad/esx`. Every script using `ESX.ShowNotification`, `xPlayer.showNotification`, `ESX.Progressbar` or `ESX.TextUI` will use GF UI.

### QBCore

**Progress bar:** replace the `progressbar` resource with `compatibilidad/qbcore/progressbar` (gf-ui must start first).

**Notifications:** in `qb-core/client/functions.lua`, replace the whole `QBCore.Functions.Notify` function with:

```lua
function QBCore.Functions.Notify(text, texttype, length, icon)
    local title, message = nil, text
    if type(text) == 'table' then
        title, message = text.caption, text.text
    end
    exports['gf-ui']:Notify({ type = texttype, title = title, description = message, duration = length })
end
```

**Help text (optional):** in `qb-core/client/drawtext.lua`, replace `hideText`, `drawText` and `changeText` with:

```lua
local function hideText()
    exports['gf-ui']:HideText()
end

local function drawText(text, position)
    exports['gf-ui']:ShowText(text, { position = (position == 'right' and 'right') or 'left' })
end

local function changeText(text, position)
    drawText(text, position)
end
```

### ox_lib (recommended)

Many scripts use ox_lib notifications, progress bars and text UI. Follow [`compatibilidad/OX_LIB.md`](compatibilidad/OX_LIB.md) (in Spanish, but it is just copy and paste): one line at the top of a few ox_lib functions.

## Configuration

Everything is in `gf-ui/config.lua`: main colour (`#rrggbb`), positions, duration, sound, titles and the cancel key. The design is plain CSS in `gf-ui/html/style.css`.

## Compatibility

| | Status |
|---|---|
| ESX Legacy | ✅ With `compatibilidad/esx` |
| QBCore | ✅ With the folder and functions above |
| ox_lib | ✅ With `OX_LIB.md` |
| Qbox | ⚠️ Uses ox_lib notifications, so it should work with `OX_LIB.md`. **Not tested** |
| Standalone | ✅ With the exports below |

## Use it in your scripts

```lua
-- Client
exports['gf-ui']:Notify({ type = 'success', title = 'Garage', description = 'Vehicle stored', duration = 5000 })
local ok = exports['gf-ui']:Progress({ duration = 5000, label = 'Repairing vehicle...', canCancel = true })
exports['gf-ui']:ShowText('[E] Open garage')
exports['gf-ui']:HideText()

-- Server
exports['gf-ui']:Notify(source, { type = 'error', description = 'No permission' })
```

Full list of options: see the [Spanish README](README.md#usarlo-en-tus-scripts) (the code is the same).

## Support

- **Discord:** [discord.gg/nR78WKsqf](https://discord.gg/nR78WKsqf)
- **Bugs:** open an [issue](../../issues).

Please include your framework and version, what you did, and anything shown in **red** in the server console or F8. GF UI is free, so support is best effort.

## License

Code: [MIT](LICENSE). Fonts (Barlow, Bebas Neue): SIL Open Font License 1.1, see `gf-ui/LICENCIAS/FUENTES.txt`.

Made by **GF Scripts**. Not affiliated with Rockstar Games, Take-Two Interactive or Cfx.re.
