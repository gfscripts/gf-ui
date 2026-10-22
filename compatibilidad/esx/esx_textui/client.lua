-- ESX.TextUI / ESX.HideUI -> gf-ui
exports('TextUI', function(message)
    exports['gf-ui']:ShowText(message)
end)

exports('HideUI', function()
    exports['gf-ui']:HideText()
end)
