# Que ox_lib use el diseño de gf-ui

Muchos scripts (garajes, inventario, trabajos...) no usan los avisos de ESX o QBCore, sino los de **ox_lib**.
Para que también salgan con el diseño de gf-ui, añade estas líneas en tres archivos de ox_lib.

> Si actualizas ox_lib, se pierden: vuelve a añadirlas.
> Si algún día quitas gf-ui, ox_lib vuelve solo a su diseño (las líneas solo actúan si gf-ui está encendido).

---

## 1. Avisos — `ox_lib/resource/interface/client/notify.lua`

Busca `function lib.notify(data)` y añade la línea marcada justo debajo:

```lua
function lib.notify(data)
    if GetResourceState('gf-ui') == 'started' then return exports['gf-ui']:Notify(data) end -- gf-ui
    local sound = settings.notification_audio and data.sound
```

## 2. Barra de progreso — `ox_lib/resource/interface/client/progress.lua`

Busca `function lib.progressBar(data)` y añade la línea marcada:

```lua
function lib.progressBar(data)
    if GetResourceState('gf-ui') == 'started' then data.canCancel = data.canCancel == true; return exports['gf-ui']:Progress(data) end -- gf-ui
    while progress ~= nil do Wait(0) end
```

Busca `function lib.progressCircle(data)` y añade la misma línea:

```lua
function lib.progressCircle(data)
    if GetResourceState('gf-ui') == 'started' then data.canCancel = data.canCancel == true; return exports['gf-ui']:Progress(data) end -- gf-ui
```

Busca `function lib.cancelProgress()` y `function lib.progressActive()` y añade:

```lua
function lib.cancelProgress()
    if GetResourceState('gf-ui') == 'started' then exports['gf-ui']:CancelProgress() end -- gf-ui
```

```lua
function lib.progressActive()
    if GetResourceState('gf-ui') == 'started' and exports['gf-ui']:IsProgressActive() then return true end -- gf-ui
```

## 3. Texto de ayuda — `ox_lib/resource/interface/client/textui.lua`

```lua
function lib.showTextUI(text, options)
    if GetResourceState('gf-ui') == 'started' then return exports['gf-ui']:ShowText(text, options) end -- gf-ui
```

```lua
function lib.hideTextUI()
    if GetResourceState('gf-ui') == 'started' then return exports['gf-ui']:HideText() end -- gf-ui
```

```lua
function lib.isTextUIOpen()
    if GetResourceState('gf-ui') == 'started' then return exports['gf-ui']:IsTextShown() end -- gf-ui
```

---

Guarda, reinicia el servidor y listo: los avisos, barras y textos de ox_lib de **todos** los scripts saldrán con el diseño de gf-ui.
