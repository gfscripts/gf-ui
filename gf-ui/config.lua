Config = {}

-- Color principal (barra, tecla, avisos de información)
Config.Color = '#3b82f6'

-- /gfui_demo para ver todo funcionando (ponlo en false en tu servidor)
Config.Debug = true

Config.Notify = {
    position = 'top',     -- 'top', 'top-right', 'center-right', 'bottom-right', 'top-left'
    duration = 4000,      -- milisegundos por defecto
    sound = true,         -- pequeño sonido al aparecer
    titles = {            -- título de cada tipo de aviso (si el aviso no trae uno)
        success = 'Hecho',
        error = 'Error',
        inform = 'Información',
        warning = 'Aviso',
    },
}

Config.Progress = {
    position = 'bottom',  -- 'bottom' o 'center'
    cancelControl = 73,   -- control de GTA para cancelar (73 = X)
    cancelKey = 'X',      -- lo que se ve en pantalla
    cancelText = 'Cancelar',
}

Config.Text = {
    position = 'left',    -- 'left', 'right' o 'bottom'
}
