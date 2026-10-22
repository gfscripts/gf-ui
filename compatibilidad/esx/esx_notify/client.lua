-- ESX.ShowNotification / xPlayer.showNotification -> gf-ui
exports('Notify', function(notifyType, length, message, title)
    exports['gf-ui']:Notify(notifyType, length, message, title)
end)
