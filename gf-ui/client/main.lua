-- ===== GF UI =====
-- Avisos, barra de progreso y texto de ayuda. Funciona solo (sin framework).
-- Para que ESX y QBCore usen este diseño están las carpetas de "compatibilidad" (mira el LEEME).

local function send(action, data)
    SendNUIMessage({ action = action, data = data })
end

-- La interfaz pide el config al cargar
RegisterNUICallback('ready', function(_, cb)
    cb({
        color = Config.Color,
        notify = Config.Notify.position,
        progress = Config.Progress.position,
        text = Config.Text.position,
        cancelKey = Config.Progress.cancelKey,
        cancelText = Config.Progress.cancelText,
        titles = Config.Notify.titles,
    })
end)

-- ============================================================
--  AVISOS
-- ============================================================

-- Tipos de ESX, QBCore y ox_lib -> los nuestros
local TYPES = {
    success = 'success',
    error = 'error',
    warning = 'warning', warn = 'warning',
    inform = 'inform', info = 'inform', primary = 'inform', police = 'inform', ambulance = 'inform',
}

local function notify(data)
    if type(data) ~= 'table' then return end

    local text = data.description or data.message or data.text
    if not text and not data.title then return end

    send('notify', {
        type = TYPES[data.type] or 'inform',
        title = data.title,
        description = text and tostring(text) or nil,
        duration = tonumber(data.duration) or Config.Notify.duration,
    })

    if Config.Notify.sound then
        PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end
end

-- exports['gf-ui']:Notify({ type = 'success', title = 'Hecho', description = 'Texto', duration = 5000 })
-- También lo usa ESX (esx_notify): Notify(tipo, duracion, mensaje, titulo)
exports('Notify', function(a, b, c, d)
    if type(a) == 'table' then return notify(a) end
    notify({ type = a, duration = b, description = c, title = d })
end)

RegisterNetEvent('gf-ui:notify', notify)

-- ============================================================
--  BARRA DE PROGRESO
-- ============================================================

local progress = nil -- { cancelled = bool, props = {...}, anim = {...} }

local function loadModel(model)
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelValid(model) then return end

    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end

    return HasModelLoaded(model) and model or nil
end

local function loadDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(0) end
    return HasAnimDictLoaded(dict)
end

local function vector(value, default)
    if not value then return default end
    return vec3(value.x or value[1] or 0.0, value.y or value[2] or 0.0, value.z or value[3] or 0.0)
end

local function disableControls(disable)
    if disable.move then
        DisableControlAction(0, 30, true)  -- izquierda/derecha
        DisableControlAction(0, 31, true)  -- delante/detrás
        DisableControlAction(0, 21, true)  -- correr
        DisableControlAction(0, 22, true)  -- saltar
        DisableControlAction(0, 36, true)  -- agacharse
    end

    -- ox_lib: { sprint = true } solo quita correr
    if disable.sprint then
        DisableControlAction(0, 21, true)
    end

    if disable.car then
        DisableControlAction(0, 63, true)
        DisableControlAction(0, 64, true)
        DisableControlAction(0, 71, true)
        DisableControlAction(0, 72, true)
        DisableControlAction(0, 75, true)  -- salir del vehículo
    end

    if disable.combat then
        DisablePlayerFiring(PlayerId(), true)
        for _, control in ipairs({ 24, 25, 37, 140, 141, 142, 257, 263, 264 }) do
            DisableControlAction(0, control, true)
        end
    end

    if disable.mouse then
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 106, true)
    end
end

-- data = {
--   duration = 5000, label = 'Reparando...', canCancel = true, useWhileDead = false,
--   disable = { move = true, car = true, combat = true, mouse = false },
--   anim = { dict = '...', clip = '...', flag = 49 }  o  { scenario = 'WORLD_HUMAN_...' },
--   prop = { model = 'prop_tool_spanner01', bone = 57005, pos = vec3(...), rot = vec3(...) }  (o una lista de props)
-- }
-- Devuelve true si se completa y false si se cancela.
local function startProgress(data)
    if progress or type(data) ~= 'table' then return false end

    local ped = PlayerPedId()
    local duration = math.max(tonumber(data.duration) or 3000, 100)
    local canCancel = data.canCancel ~= false
    local disable = data.disable or {}
    local anim = data.anim

    progress = { cancelled = false, props = {}, anim = anim }
    send('progress', { label = data.label or '', duration = duration, canCancel = canCancel })

    -- Animación
    if anim then
        if anim.scenario then
            TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
        elseif anim.dict and anim.clip and loadDict(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 3.0, 3.0, -1, anim.flag or 49, 0, false, false, false)
            RemoveAnimDict(anim.dict)
        end
    end

    -- Objetos en la mano
    local props = progress.props
    local list = type(data.prop) == 'table' and (data.prop.model and { data.prop } or data.prop) or {}

    for _, prop in ipairs(list) do
        local model = type(prop) == 'table' and prop.model and loadModel(prop.model)

        if model then
            local coords = GetEntityCoords(ped)
            local object = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
            local pos = vector(prop.pos, vec3(0.0, 0.0, 0.0))
            local rot = vector(prop.rot, vec3(0.0, 0.0, 0.0))

            AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, prop.bone or 60309), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 0, true)
            SetModelAsNoLongerNeeded(model)
            props[#props + 1] = object
        end
    end

    local finish = GetGameTimer() + duration

    while GetGameTimer() < finish and not progress.cancelled do
        disableControls(disable)

        if canCancel and IsControlJustPressed(0, Config.Progress.cancelControl) then
            progress.cancelled = true
        elseif not data.useWhileDead and IsEntityDead(ped) then
            progress.cancelled = true
        end

        Wait(0)
    end

    -- Limpiar
    if anim then
        if anim.scenario then
            ClearPedTasks(ped)
        elseif anim.dict and anim.clip then
            StopAnimTask(ped, anim.dict, anim.clip, 1.0)
        end
    end

    for _, object in ipairs(props) do
        if DoesEntityExist(object) then DeleteEntity(object) end
    end

    local ok = not progress.cancelled
    progress = nil
    send('progressEnd', { cancelled = not ok })

    return ok
end

-- Formato de la barra de QBCore (progressbar) -> el nuestro
local function fromQb(action)
    local disables = action.controlDisables or {}
    local animation = action.animation or {}
    local anim

    if animation.task then
        anim = { scenario = animation.task }
    elseif animation.animDict and animation.anim then
        anim = { dict = animation.animDict, clip = animation.anim, flag = animation.flags }
    end

    local props = {}

    for _, prop in ipairs({ action.prop, action.propTwo }) do
        if type(prop) == 'table' and prop.model then
            props[#props + 1] = { model = prop.model, bone = prop.bone, pos = prop.coords, rot = prop.rotation }
        end
    end

    return {
        duration = action.duration,
        label = action.label,
        useWhileDead = action.useWhileDead,
        canCancel = action.canCancel,
        disable = {
            move = disables.disableMovement,
            car = disables.disableCarMovement,
            mouse = disables.disableMouse,
            combat = disables.disableCombat,
        },
        anim = anim,
        prop = #props > 0 and props or nil,
    }
end

-- local ok = exports['gf-ui']:Progress({ duration = 5000, label = 'Reparando...' })
-- También lo usa QBCore (progressbar): Progress(action, function(cancelled) end)
exports('Progress', function(data, finish)
    if type(data) ~= 'table' then return false end

    if type(finish) == 'function' or data.controlDisables or data.name then
        local converted = fromQb(data)

        CreateThread(function()
            local ok = startProgress(converted)
            if finish then finish(not ok) end
        end)

        return
    end

    return startProgress(data)
end)

exports('CancelProgress', function()
    if progress then progress.cancelled = true end
end)

exports('IsProgressActive', function()
    return progress ~= nil
end)

-- ESX (esx_progressbar): Progressbar(mensaje, duracion, { FreezePlayer, animation, onFinish, onCancel })
exports('Progressbar', function(message, length, options)
    options = options or {}
    local anim
    local animation = options.animation

    if type(animation) == 'table' then
        if animation.type == 'Scenario' and animation.Scenario then
            anim = { scenario = animation.Scenario }
        elseif animation.dict and animation.lib then
            anim = { dict = animation.dict, clip = animation.lib }
        end
    end

    CreateThread(function()
        local ok = startProgress({
            label = message,
            duration = length,
            canCancel = true,
            anim = anim,
            disable = options.FreezePlayer and { move = true, car = true, combat = true } or {},
        })

        if ok and options.onFinish then
            options.onFinish()
        elseif not ok and options.onCancel then
            options.onCancel()
        end
    end)

    return true
end)

exports('CancelProgressbar', function()
    if progress then progress.cancelled = true end
end)

-- Si se para o reinicia gf-ui en mitad de una barra: quitar los objetos de la mano y la animación
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not progress then return end

    local ped = PlayerPedId()

    for _, object in ipairs(progress.props or {}) do
        if DoesEntityExist(object) then DeleteEntity(object) end
    end

    local anim = progress.anim
    if anim and anim.scenario then
        ClearPedTasks(ped)
    elseif anim and anim.dict and anim.clip then
        StopAnimTask(ped, anim.dict, anim.clip, 1.0)
    end

    progress = nil
end)

-- ============================================================
--  TEXTO DE AYUDA ([E] Abrir)
-- ============================================================

local textShown = false

-- exports['gf-ui']:ShowText('[E] Abrir garaje')   o   ShowText('Abrir garaje', { key = 'E' })
local function showText(text, options)
    options = type(options) == 'table' and options or {}

    -- Posiciones de ox_lib ('right-center', 'left-center', 'top-center', 'bottom-center') -> las nuestras
    local position = options.position

    if type(position) == 'string' then
        position = position:find('right') and 'right' or position:find('left') and 'left' or 'bottom'
    end

    send('text', {
        text = tostring(text or ''),
        key = options.key,
        position = position,
    })

    textShown = true
end

local function hideText()
    if not textShown then return end

    send('text', false)
    textShown = false
end

exports('ShowText', showText)
exports('HideText', hideText)
exports('IsTextShown', function() return textShown end)

-- ESX (esx_textui): TextUI(mensaje, tipo) / HideUI()
exports('TextUI', function(message) showText(message) end)
exports('HideUI', hideText)

-- ============================================================
--  PRUEBA
-- ============================================================

if Config.Debug then
    RegisterCommand('gfui_demo', function()
        CreateThread(function()
        notify({ type = 'success', description = 'Vehículo guardado en el garaje' })
        Wait(400)
        notify({ type = 'error', description = 'No tienes suficiente dinero' })
        Wait(400)
        notify({ type = 'inform', title = 'Policía', description = 'Has entrado de servicio' })
        Wait(400)
        notify({ type = 'warning', description = 'Tu vehículo tiene poca gasolina' })

        showText('[E] Abrir el garaje')

        local ok = startProgress({
            duration = 5000,
            label = 'Reparando el vehículo...',
            disable = { move = true, car = true, combat = true },
            anim = { scenario = 'PROP_HUMAN_BUM_BIN' },
        })

        hideText()
        notify({ type = ok and 'success' or 'error', description = ok and 'Reparación terminada' or 'Reparación cancelada' })
        end)
    end, false)
end
