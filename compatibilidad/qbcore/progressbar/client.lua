-- QBCore.Functions.Progressbar -> gf-ui
exports('Progress', function(action, finish)
    exports['gf-ui']:Progress(action, finish)
end)

exports('isDoingSomething', function()
    return exports['gf-ui']:IsProgressActive()
end)

exports('cancel', function()
    exports['gf-ui']:CancelProgress()
end)

exports('ProgressWithStartEvent', function(action, start, finish)
    if start then start() end
    exports['gf-ui']:Progress(action, finish)
end)

exports('ProgressWithTickEvent', function(action, _, finish)
    exports['gf-ui']:Progress(action, finish)
end)

exports('ProgressWithStartAndTick', function(action, start, _, finish)
    if start then start() end
    exports['gf-ui']:Progress(action, finish)
end)
