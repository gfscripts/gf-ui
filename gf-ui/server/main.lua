-- ===== GF UI (servidor) =====
-- Mandar un aviso a un jugador desde el servidor:
--   exports['gf-ui']:Notify(source, { type = 'success', description = 'Texto' })
--   TriggerClientEvent('gf-ui:notify', source, { type = 'error', description = 'Texto' })

exports('Notify', function(source, data)
    TriggerClientEvent('gf-ui:notify', source, data)
end)
