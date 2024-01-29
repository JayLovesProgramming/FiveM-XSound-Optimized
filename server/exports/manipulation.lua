local function Position(source, name_, pos)
    TriggerClientEvent("xsound:stateSound", source, "position", {
        soundId = name_,
        position = pos,
    })
end
exports('Position', Position)

local function Distance(source, name_, distance_)
    TriggerClientEvent("xsound:stateSound", source, "distance", {
        soundId = name_,
        distance = distance_,
    })
end
exports('Distance', Distance)

local function Destroy(source, name_)
    TriggerClientEvent("xsound:stateSound", source, "destroy", {
        soundId = name_,
    })
end
exports('Destroy', Destroy)

local function Pause(source, name_)
    TriggerClientEvent("xsound:stateSound", source, "pause", {
        soundId = name_,
    })
end
exports('Pause', Pause)

local function Resume(source, name_)
    TriggerClientEvent("xsound:stateSound", source, "resume", {
        soundId = name_,
    })
end
exports('Resume', Resume)

local function setVolume(source, name_, vol)
    TriggerClientEvent("xsound:stateSound", source, "volume", {
        soundId = name_,
        volume = vol,
    })
end
exports('setVolume', setVolume)

local function setTimeStamp(source, name_, time_)
    TriggerClientEvent("xsound:stateSound", source, "timestamp", {
        soundId = name_,
        time = time_
    })
end
exports('setTimeStamp', setTimeStamp)

local function destroyOnFinish(id, bool)
    TriggerClientEvent("xsound:stateSound", source, "destroyOnFinish", {
        soundId = id,
        value = bool
    })
end
exports('destroyOnFinish', destroyOnFinish)