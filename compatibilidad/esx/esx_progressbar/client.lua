-- ESX.Progressbar -> gf-ui
exports('Progressbar', function(message, length, options)
    return exports['gf-ui']:Progressbar(message, length, options)
end)

exports('CancelProgressbar', function()
    exports['gf-ui']:CancelProgress()
end)
