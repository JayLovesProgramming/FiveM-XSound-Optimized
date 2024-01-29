local globalOptionsCache, soundInfo, isPlayerCloseToMusic, disableMusic, config = {}, {}, false, false, require("config")
function getLink(name_)
    return soundInfo[name_].url
end
function getPosition(name_)
    return soundInfo[name_].position
end
function isLooped(name_)
    return soundInfo[name_].loop
end
function getInfo(name_)
    return soundInfo[name_]
end
function soundExists(name_)
    if soundInfo[name_] == nil then
        return false
    end
    return true
end
function isPlaying(name_)
    return soundInfo[name_].playing
end
function isPaused(name_)
    return soundInfo[name_].paused
end
function getDistance(name_)
    return soundInfo[name_].distance
end
function getVolume(name_)
    return soundInfo[name_].volume
end
function isDynamic(name_)
    return soundInfo[name_].isDynamic
end
function getTimeStamp(name_)
    return soundInfo[name_].timeStamp or -1
end
function getMaxDuration(name_)
    return soundInfo[name_].maxDuration or -1
end
function isPlayerInStreamerMode()
    return disableMusic
end
function getAllAudioInfo()
    return soundInfo
end
function isPlayerCloseToAnySound()
    return isPlayerCloseToMusic
end
function onPlayStart(name, delegate)
    globalOptionsCache[name].onPlayStart = delegate
end
function onPlayEnd(name, delegate)
    globalOptionsCache[name].onPlayEnd = delegate
end
function onLoading(name, delegate)
    globalOptionsCache[name].onLoading = delegate
end
function onPlayPause(name, delegate)
    globalOptionsCache[name].onPlayPause = delegate
end
function onPlayResume(name, delegate)
    globalOptionsCache[name].onPlayResume = delegate
end
function onPlayStartSilent(name, delegate)
    globalOptionsCache[name].onPlayStartSilent = delegate
end
function Distance(name_, distance_)
    SendNUIMessage({
        status = "distance",
        name = name_,
        distance = distance_,
    })
    soundInfo[name_].distance = distance_
end
function Position(name_, pos)
    SendNUIMessage({
        status = "soundPosition",
        name = name_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
    })
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
end
function Destroy(name_)
    SendNUIMessage({
        status = "delete",
        name = name_
    })
    soundInfo[name_] = nil
    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayEnd ~= nil then
        globalOptionsCache[name_].onPlayEnd(getInfo(name_))
    end
    globalOptionsCache[name_] = nil
end
function DestroySilent(name)
    SendNUIMessage({
        status = "delete",
        name = name
    })
end
function Resume(name_)
    SendNUIMessage({
        status = "resume",
        name = name_
    })
    soundInfo[name_].playing = true
    soundInfo[name_].paused = false
    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayResume ~= nil then
        globalOptionsCache[name_].onPlayResume(getInfo(name_))
    end
end
function Pause(name_)
    SendNUIMessage({
        status = "pause",
        name = name_
    })
    soundInfo[name_].playing = false
    soundInfo[name_].paused = true
    if globalOptionsCache[name_] ~= nil and globalOptionsCache[name_].onPlayPause ~= nil then
        globalOptionsCache[name_].onPlayPause(getInfo(name_))
    end
end
function setVolume(name_, vol)
    SendNUIMessage({
        status = "volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end
function setVolumeMax(name_, vol)
    SendNUIMessage({
        status = "max_volume",
        volume = vol,
        name = name_,
    })
    soundInfo[name_].volume = vol
end
function setTimeStamp(name_, timestamp)
    getInfo(name_).timeStamp = timestamp
    SendNUIMessage({
        name = name_,
        status = "timestamp",
        timestamp = timestamp,
    })
end
function destroyOnFinish(id, bool)
    soundInfo[id].destroyOnFinish = bool
end
function setSoundLoop(name, value)
    SendNUIMessage({
        status = "loop",
        name = name,
        loop = value,
    })
    soundInfo[name].loop = value
end
function repeatSound(name)
    if soundExists(name) then
        SendNUIMessage({
            status = "repeat",
            name = name,
        })
    end
end
function setSoundDynamic(name, bool)
    if soundExists(name) then
        soundInfo[name].isDynamic = bool
        SendNUIMessage({
            status = "changedynamic",
            name = name,
            bool = bool,
        })
    end
end
function setSoundURL(name, url)
    if soundExists(name) then
        soundInfo[name].url = url
        SendNUIMessage({
            status = "changeurl",
            name = name,
            url = url,
        })
    end
end


function getDefaultInfo()
    return {
        volume = 1.0,
        url = "",
        id = "",
        position = nil,
        distance = 10,
        playing = false,
        paused = false,
        loop = false,
        isDynamic = false,
        timeStamp = 0,
        maxDuration = 0,
        destroyOnFinish = true,
    }
end

function UpdatePlayerPositionInNUI()
    Wait(2000)
    local pos = GetEntityCoords(cache.ped)
    SendNUIMessage({
        status = "position",
        x = pos.x,
        y = pos.y,
        z = pos.z
    })
end

function PlayMusicFromCache(data)
    local musicCache = soundInfo[data.id]
    if musicCache then
        musicCache.SkipEvents = true
        musicCache.SkipTimeStamp = true
        PlayUrlPosSilent(data.id, data.url, data.volume, data.position, data.loop)
        onPlayStartSilent(data.id, function()
            if getInfo(data.id).maxDuration then
                setTimeStamp(data.id, data.timeStamp or 0)
            end
            Distance(data.id, data.distance)
        end)
    end
end

function CheckForCloseMusic()
    local playerPos = GetEntityCoords(cache.ped)
    isPlayerCloseToMusic = false
    for k, v in pairs(soundInfo) do
        if v.position ~= nil and v.isDynamic then
            if #(v.position - playerPos) < v.distance + config.distanceBeforeUpdatingPos then
                isPlayerCloseToMusic = true
                break
            end
        end
    end
end
function PlayUrl(name_, url_, volume_, loop_, options)
    if disableMusic then return end
    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
    soundInfo[name_].isDynamic = false
    globalOptionsCache[name_] = options or { }
    if loop_ then
        soundInfo[name_].destroyOnFinish = false
    else
        soundInfo[name_].destroyOnFinish = true
    end
    CheckForCloseMusic()
    UpdatePlayerPositionInNUI()
    SendNUIMessage({ status = "unmuteAll" })
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = 0,
        y = 0,
        z = 0,
        dynamic = false,
        volume = volume_,
        loop = loop_ or false,
    })
end
function PlayUrlPos(name_, url_, volume_, pos, loop_, options)
    if disableMusic then return end
    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
    soundInfo[name_].isDynamic = true
    globalOptionsCache[name_] = options or { }
    CheckForCloseMusic()
    if #(GetEntityCoords(cache.ped) - pos) < 10.0 + config.distanceBeforeUpdatingPos then
        print("Updating")
        UpdatePlayerPositionInNUI()
        SendNUIMessage({ status = "unmuteAll" })
    end
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume_,
        loop = loop_ or false,
    })
    if loop_ then
        soundInfo[name_].destroyOnFinish = false
    else
        soundInfo[name_].destroyOnFinish = true
    end
end
function PlayUrlPosSilent(name_, url_, volume_, pos, loop_)
    if disableMusic then return end
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume_,
        loop = loop_ or false,
    })
end
-- updating position on html side so we can count how much volume the sound needs.
CreateThread(function()
    local refresh = config.RefreshTime
    local pos = GetEntityCoords(cache.ped)
    local lastPos = pos
    local changedPosition = false
    while true do
        Wait(refresh)
        if not disableMusic and isPlayerCloseToMusic then
            pos = GetEntityCoords(cache.ped)
            -- we will update position only when player have moved
            if #(lastPos - pos) >= 0.1 then
                lastPos = pos

                UpdatePlayerPositionInNUI()
            end
            if changedPosition then
                UpdatePlayerPositionInNUI()
                SendNUIMessage({ status = "unmuteAll" })
            end
            changedPosition = false
        else
            if not changedPosition then
                changedPosition = true
                SendNUIMessage({ status = "position", x = -900000, y = -900000, z = -900000 })
                SendNUIMessage({ status = "muteAll" })
            end
            Wait(1000)

        local playerPos = GetEntityCoords(cache.ped)
            local destroyedMusicList = {}
            Wait(500)
            playerPos = GetEntityCoords(cache.ped)
        end
    end
end)
-- If player is far away from music we will just delete it.
CreateThread(function()
    local playerPos = GetEntityCoords(cache.ped)
    local destroyedMusicList = {}
    while true do
        Wait(500)
        playerPos = GetEntityCoords(cache.ped)
        for k, v in pairs(soundInfo) do
            if v.position ~= nil and v.isDynamic then
                if #(v.position - playerPos) < (v.distance + config.distanceBeforeUpdatingPos) then
                    if destroyedMusicList[v.id] then
                        destroyedMusicList[v.id] = nil
                        v.wasSilented = true
                        PlayMusicFromCache(v)
                    end
                else
                    if not destroyedMusicList[v.id] then
                        destroyedMusicList[v.id] = true
                        v.wasSilented = false
                        DestroySilent(v.id)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        CheckForCloseMusic()
    end
end)
-- updating timeStamp
CreateThread(function()
    Wait(1100)
    while true do
        Wait(1000)
        for k, v in pairs(soundInfo) do
            if v.playing or v.wasSilented then
                if getInfo(v.id).timeStamp ~= nil and getInfo(v.id).maxDuration ~= nil then
                    if getInfo(v.id).timeStamp < getInfo(v.id).maxDuration then
                        getInfo(v.id).timeStamp = getInfo(v.id).timeStamp + 1
                    end
                end
            end
        end
    end
end)

-- Events -- 
RegisterNUICallback("init", function(data, cb)
    SendNUIMessage({
        status = "init",
        time = config.RefreshTime,
    })
    if cb then cb('ok') end
end)

RegisterNUICallback("data_status", function(data, cb)
    if soundInfo[data.id] ~= nil then
        if data.type == "finished" then
            if not soundInfo[data.id].loop then
                soundInfo[data.id].playing = false
            end
            TriggerEvent("xSound:songStopPlaying", data.id)
        end
        if data.type == "maxDuration" then
            if not soundInfo[data.id].SkipTimeStamp then
                soundInfo[data.id].timeStamp = 0
            end
            soundInfo[data.id].maxDuration = data.time

            soundInfo[data.id].SkipTimeStamp = nil
        end
    end
    if cb then cb('ok') end
end)

RegisterNUICallback("events", function(data, cb)
    local id = data.id
    local type = data.type
    if type == "resetTimeStamp" then
        if soundInfo[id] then
            soundInfo[id].timeStamp = 0
            soundInfo[id].maxDuration = data.time
            soundInfo[id].playing = true
        end
    end
    if type == "onPlay" then
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onPlayStartSilent then
                globalOptionsCache[id].onPlayStartSilent(getInfo(id))
            end
            if globalOptionsCache[id].onPlayStart and not soundInfo[id].SkipEvents then
                globalOptionsCache[id].onPlayStart(getInfo(id))
            end
            soundInfo[id].SkipEvents = nil
        end
    end
    if type == "onEnd" then
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onPlayEnd then
                globalOptionsCache[id].onPlayEnd(getInfo(id))
            end
        end
        if soundInfo[id] then
            if soundInfo[id].loop then
                soundInfo[id].timeStamp = 0
            end
            if soundInfo[id].destroyOnFinish and not soundInfo[id].loop then
                Destroy(id)
            end
        end
    end
    if type == "onLoading" then
        if globalOptionsCache[id] then
            if globalOptionsCache[id].onLoading then
                globalOptionsCache[id].onLoading(getInfo(id))
            end
        end
    end
    if cb then cb('ok') end
end)

RegisterNetEvent("xsound:stateSound", function(state, data)
    local soundId = data.soundId
    if state == "destroyOnFinish" then
        if soundExists(soundId) then
            destroyOnFinish(soundId, data.value)
        end
    end
    if state == "timestamp" then
        if soundExists(soundId) then
            setTimeStamp(soundId, data.time)
        end
    end
    if state == "texttospeech" then
        TextToSpeech(soundId, data.lang, data.url, data.volume, data.loop or false)
    end
    if state == "texttospeechpos" then
        TextToSpeechPos(soundId, data.lang, data.url, data.volume, data.position, data.loop or false)
    end
    if state == "play" then
        PlayUrl(soundId, data.url, data.volume, data.loop or false)
    end
    if state == "playpos" then
        PlayUrlPos(soundId, data.url, data.volume, data.position, data.loop or false)
    end
    if state == "position" then
        if soundExists(soundId) then
            Position(soundId, data.position)
        end
    end
    if state == "distance" then
        if soundExists(soundId) then
            Distance(soundId, data.distance)
        end
    end
    if state == "destroy" then
        if soundExists(soundId) then
            Destroy(soundId)
        end
    end
    if state == "pause" then
        if soundExists(soundId) then
            Pause(soundId)
        end
    end
    if state == "resume" then
        if soundExists(soundId) then
            Resume(soundId)
        end
    end
    if state == "volume" then
        if soundExists(soundId) then
            if isDynamic(soundId) then
                setVolumeMax(soundId, data.volume)
            else
                setVolume(soundId, data.volume)
            end
        end
    end
end)

-- Simple command for streamers to cancel all "third-party" sounds
RegisterCommand("streamermode", function(source, args, rawCommand)
    disableMusic = not disableMusic
    TriggerEvent("xsound:streamerMode", disableMusic)
    if disableMusic then
        TriggerEvent('chat:addMessage', { args = { "", "Streamer mode is on. From now you will not hear any music/sound." } })
    else
        TriggerEvent('chat:addMessage', { args = { "", "Streamer mode is off. From now you will be able to listen to music that players might play." } })
    end
end, false)

AddEventHandler("xsound:streamerMode", function(status)
    if status then
        for k, v in pairs(soundInfo) do
            Destroy(v.id)
        end
    end
end)

-- Effects --
-- For now these are the default Xsound effects. Boring and not useful.. I will add more effects later down the line
function volumeType(name, volume)
    if isDynamic(name) then
        setVolumeMax(name,volume)
        setVolume(name,volume)
    else
        setVolume(name,volume)
    end
end
function fadeIn(name, time, volume_)
    if soundExists(name) then
        volumeType(name, 0)
        local addVolume = (volume_ / time) * 100
        local called = 0
        local volume = volume_
        while true do
            volume = volume - addVolume
            if volume < 0 then volume = 0 end
            if volume == 0 then break end
            called = called + 1
        end
        volume = getVolume(name)
        while true do
            Wait(time / called)
            volume = volume + addVolume
            if volume > volume_ then
                volume = volume_
                volumeType(name, volume)
                break
            end
            volumeType(name, volume)
        end
    end
end
function fadeOut(name, time)
    if soundExists(name) then
        local volume = getVolume(name)
        local addVolume = (volume / time) * 100
        local called = 0
        while true do
            volume = volume - addVolume
            if volume < 0 then volume = 0 end
            if volume == 0 then break end
            called = called + 1
        end
        volume = getVolume(name)
        while true do
            Wait(time / called)
            volume = volume - addVolume
            if volume < 0 then
                volume = 0
                volumeType(name, volume)
                break
            end
            volumeType(name, volume)
        end
    end
end

-- Exports -- 
exports('fadeIn', fadeIn)
exports('fadeOut', fadeOut)
exports('getLink', getLink)
exports('getPosition', getPosition)
exports('isLooped', isLooped)
exports('getInfo', getInfo)
exports('soundExists', soundExists)
exports('isPlaying', isPlaying)
exports('isPaused', isPaused)
exports('getDistance', getDistance)
exports('getVolume', getVolume)
exports('isDynamic', isDynamic)
exports('getTimeStamp', getTimeStamp)
exports('getMaxDuration', getMaxDuration)
exports('isPlayerInStreamerMode', isPlayerInStreamerMode)
exports('getAllAudioInfo', getAllAudioInfo)
exports('isPlayerCloseToAnySound', isPlayerCloseToAnySound)
exports('onPlayStart', onPlayStart)
exports('onPlayEnd', onPlayEnd)
exports('onLoading', onLoading)
exports('onPlayPause', onPlayPause)
exports('onPlayResume', onPlayResume)
exports('Distance', Distance)
exports('Position', Position)
exports('Destroy', Destroy)
exports('Resume', Resume)
exports('Pause', Pause)
exports('setVolume', setVolume)
exports('setVolumeMax', setVolumeMax)
exports('setTimeStamp', setTimeStamp)
exports('destroyOnFinish', destroyOnFinish)
exports('setSoundLoop', setSoundLoop)
exports('repeatSound', repeatSound)
exports('setSoundDynamic', setSoundDynamic)
exports('setSoundURL', setSoundURL)
exports('PlayUrl', PlayUrl)
exports('PlayUrlPos', PlayUrlPos)

--function TextToSpeech(name_, lang, text, volume_)
--    if disableMusic then return end
--    SendNUIMessage({
--        status = "textSpeech",
--        name = name_,
--        text = text,
--        lang = lang,
--        x = 0,
--        y = 0,
--        z = 0,
--        dynamic = false,
--        volume = volume_,
--    })
--
--    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
--
--    soundInfo[name_].volume = volume_
--    soundInfo[name_].url = "is text to speech"
--    soundInfo[name_].id = name_
--    soundInfo[name_].playing = true
--    soundInfo[name_].loop = false
--    soundInfo[name_].isDynamic = false
--    soundInfo[name_].destroyOnFinish = true
--
--
--    globalOptionsCache[name_] = options or { }
--end
--
--exports('TextToSpeech', TextToSpeech)

--function TextToSpeechPos(name_, lang, text, volume_, pos)
--    if disableMusic then return end
--    SendNUIMessage({
--        status = "textSpeech",
--        name = name_,
--        text = text,
--        lang = lang,
--        x = pos.x,
--        y = pos.y,
--        z = pos.z,
--        dynamic = true,
--        volume = volume_,
--    })
--
--    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
--
--    soundInfo[name_].volume = volume_
--    soundInfo[name_].url = "is text to speech"
--    soundInfo[name_].position = pos
--    soundInfo[name_].id = name_
--    soundInfo[name_].playing = true
--    soundInfo[name_].loop = false
--    soundInfo[name_].isDynamic = true
--    soundInfo[name_].destroyOnFinish = true
--
--
--    globalOptionsCache[name_] = options or { }
--end
--
--exports('TextToSpeechPos', TextToSpeechPos)
