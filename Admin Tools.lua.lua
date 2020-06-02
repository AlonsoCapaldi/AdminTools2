script_name('Admin Tools')
script_version("29.05.2020")
script_author('Alonso_Whittaker')
script_description('Alonso_Whittaker')
----------------------
airbreak_coords = {}
speed = 1
----------------------
require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local keys = require "vkeys"
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

--local directiIni = "moonloader\\Admin Tools.ini"
--local mainIni = inicfg.load(nil, directiIni)
---------------------------------------------------------------
--//////////////////////Автообновление////////////////////////
update_state = false

local script_vers = 0.2
local script_vers_text = "0.2"

local update_url = "https://raw.githubusercontent.com/AlonsoCapaldi/Admin-Tools/master/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/AlonsoCapaldi/Admin-Tools/blob/master/Admin%20Tools.luac?raw=true" -- тут свою ссылку
local script_path = thisScript().path
---------------------------------------------------------------
local label = 0
local main_color = 0x5A90CE
local main_color_text = "{5A90CE}"
local white_color = "{FFFFFF}"
    ---------------------------------------------------------------
local secondary_window_state = imgui.ImBool(false)
local pm_report = imgui.ImBool(false)
local ban_menu = imgui.ImBool(false)
local mute_menu = imgui.ImBool(false)
local prison_menu = imgui.ImBool(false)
local guns_menu = imgui.ImBool(false)
local help_menu = imgui.ImBool(false)
local p_menu = imgui.ImBool(false)
local mp_menu = imgui.ImBool(false)
local nakm_menu = imgui.ImBool(false)
local atp_menu = imgui.ImBool(false)
    ---------------------------------------------------------------
local text_buffer_age = imgui.ImBuffer(256)
local text_buffer_name = imgui.ImBuffer(256)
    ---------------------------------------------------------------
local sw, sh = getScreenResolution()
------------------------AirBrake-----------------------------------
local function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    -- from SAMP.Lua
    local raknet = require 'lib.samp.raknet'
    require 'lib.samp.synchronization'

    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    -- copy player's sync data to the allocated memory
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    -- function to send packet
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    -- metatable to access sync data and 'send' function
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end
    ---------------------------------------------------------------
local ips = {
    '176.32.36.229:7777',
    '127.0.0.1:7777',
}
local function checkip()
    local ip, port = sampGetCurrentServerAddress()
    for i = 1, #ips do
        if ips[i] == ip..':'..port then return true end
    end
    return false
end
---------------------------------------------------------------
function main()
  if not isSampLoaded() or not isSampfuncsLoaded() then return end
  while not isSampAvailable() do wait(100) end

  wait(1000)
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}Автор данного скрипта {408ad8}Alonso_Whittaker. {FFFFFF}Версия: {408ad8} " .. script_vers, -1)
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}Посмотреть список команд и функции Admin Tools`a: {408ad8}/acmd", -1)

    repeat wait(0) until isSampAvailable()
    if not checkip() then
        sampAddChatMessage('{408ad8}[Admin Tools]:{FFFFFF} Не удалось загрузить. Работает только на {408ad8}Monser DeathMatch | Three', -1)
        error()
    end
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Успешно загружен.', -1)
    wait(1)

    style()

  ---------------------------------------------------------------
  sampRegisterChatCommand("th", cmd_th)
    ---------------------------------------------------------------
  sampRegisterChatCommand("m", cmd_m)
    ---------------------------------------------------------------
  sampRegisterChatCommand("bm", cmd_ban)
    ---------------------------------------------------------------
  sampRegisterChatCommand("mtm", cmd_mute)
    ---------------------------------------------------------------
  sampRegisterChatCommand("jm", cmd_prison)
    ---------------------------------------------------------------
  sampRegisterChatCommand("gunm", cmd_guns)
    ---------------------------------------------------------------
  sampRegisterChatCommand("acmd", cmd_help)
    ---------------------------------------------------------------
  sampRegisterChatCommand("p", cmd_p)
    ---------------------------------------------------------------
  sampRegisterChatCommand("mnak", cmd_mnak)
    ---------------------------------------------------------------
  sampRegisterChatCommand("atp", cmd_atp)
    ---------------------------------------------------------------
  sampRegisterChatCommand("faim", cmd_faim)
    ---------------------------------------------------------------
  sampRegisterChatCommand("aim", cmd_aim)
    ---------------------------------------------------------------
  sampRegisterChatCommand("saim", cmd_saim)
    ---------------------------------------------------------------
  sampRegisterChatCommand("or", cmd_oskrod)
    ---------------------------------------------------------------
  sampRegisterChatCommand("osk", cmd_oskig)
    ---------------------------------------------------------------
  sampRegisterChatCommand("up", cmd_uprod)
    ---------------------------------------------------------------
  sampRegisterChatCommand("fjail", cmd_fjail)
    ---------------------------------------------------------------
  sampRegisterChatCommand("ajail", cmd_ajail)
    ---------------------------------------------------------------
  sampRegisterChatCommand("caps", cmd_caps)
    ---------------------------------------------------------------
  sampRegisterChatCommand("flood", cmd_flood)
    ---------------------------------------------------------------
  sampRegisterChatCommand("stan", cmd_stan)
    ---------------------------------------------------------------
  sampRegisterChatCommand("+c", cmd_c)
    ---------------------------------------------------------------
  sampRegisterChatCommand("ws", cmd_ws)
    ---------------------------------------------------------------

  _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
  nick = sampGetPlayerNickname(id)
---------------------------------------------------------------
--//////////////////////Автообновление////////////////////////
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.update.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.update.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)

  while true do
    wait(0)

        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end

        imgui.Process = secondary_window_state.v or pm_report.v or ban_menu.v or prison_menu.v or guns_menu.v or help_menu.v or mute_menu.v or p_menu.v or nakm_menu.v or atp_menu.v
        if not secondary_window_state.v and not pm_report.v and not ban_menu.v and not prison_menu.v and not guns_menu.v and not help_menu.v and not mute_menu.v and not p_menu.v and not nakm_menu.v and not atp_menu.v then
            imgui.ShowCursor = false
        end
---AirBrake
            if activation then
            local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
            local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
            local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
            local heading = getCharHeading(playerPed)
            setCharCoordinates(playerPed, airbreak_coords[1], airbreak_coords[2], airbreak_coords[3] - 1)
            if isKeyDown(VK_W) then
                airbreak_coords[1] = airbreak_coords[1] + speed * math.sin(-math.rad(angle))
                airbreak_coords[2] = airbreak_coords[2] + speed * math.cos(-math.rad(angle))
                setCharHeading(playerPed, angle)
            elseif isKeyDown(VK_S) then
                airbreak_coords[1] = airbreak_coords[1] - speed * math.sin(-math.rad(heading))
                airbreak_coords[2] = airbreak_coords[2] - speed * math.cos(-math.rad(heading))
            end
           
            if isKeyDown(VK_A) then
                airbreak_coords[1] = airbreak_coords[1] - speed * math.sin(-math.rad(heading - 90))
                airbreak_coords[2] = airbreak_coords[2] - speed * math.cos(-math.rad(heading - 90))
            elseif isKeyDown(VK_D) then
                airbreak_coords[1] = airbreak_coords[1] - speed * math.sin(-math.rad(heading + 90))
                airbreak_coords[2] = airbreak_coords[2] - speed * math.cos(-math.rad(heading + 90))
            end
           
            if isKeyDown(VK_UP) then airbreak_coords[3] = airbreak_coords[3] + speed / 2.0 end
            if isKeyDown(VK_DOWN) and airbreak_coords[3] > -95.0 then airbreak_coords[3] = airbreak_coords[3] - speed / 2.0 end
        end
       
        if isKeyJustPressed(VK_RCONTROL) and isCharOnFoot(playerPed) then
            activation = not activation
            local posX, posY, posZ = getCharCoordinates(playerPed)
            airbreak_coords = {posX, posY, posZ, getCharHeading(playerPed)}
        end

        if isKeyJustPressed(0x6B) then
            speed = speed + 0.1
            printStringNow("speed~r~ "..speed, 1337)
        end

        if isKeyJustPressed(0x6D) then
            speed = speed - 0.1
            printStringNow("speed~r~ "..speed, 1337)
      end
      --- Конец AirBrake
   end
end
function cmd_ws(autuc)
  if ws ~= nil and ws:len() > 0 then
        sampSendChat("/ban " .. ws .. " 10 Extra WS.")
        ws = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/ws [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_c(autuc)
  if autuc ~= nil and autuc:len() > 0 then
        sampSendChat("/ban " .. autuc .. " 15 Auto +c.")
        autuc = 0
  elses
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/+c [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_stan(anti)
  if anti ~= nil and anti:len() > 0 then
        sampSendChat("/ban " .. anti .. " 15 Antistun.")
        anti = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/stan [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_caps(caps)
  if caps ~= nil and caps:len() > 0 then
        sampSendChat("/mute " .. caps .. " 30 Caps Lock.")
        caps = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/caps [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_flood(flood)
  if flood ~= nil and flood:len() > 0 then
        sampSendChat("/mute " .. flood .. " 30 Flood.")
        flood = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/flood [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_ajail(afjail)
  if afjail ~= nil and afjail:len() > 0 then
        sampSendChat("/jail " .. afjail .. " 60 Aim.")
        afjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/ajail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_fjail(fjail)
  if fjail ~= nil and fjail:len() > 0 then
        sampSendChat("/a /jail " .. fjail .. " 60 Aim.")
        fjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/fjail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_faim(faim)
  if faim ~= nil and faim:len() > 0 then
        sampSendChat("/a /ban " .. faim .. " 60 Aim.")
        faim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/faim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_aim(aim)
  if aim ~= nil and aim:len() > 0 then
        sampSendChat("/ban " .. aim .. " 30 Aim.")
        aim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/aim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_saim(saim)
  if saim ~= nil and saim:len() > 0 then
        sampSendChat("/cban " .. saim .. " 30 Aim.")
        saim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/saim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskrod(oskrod)
  if oskrod ~= nil and oskrod:len() > 0 then
        sampSendChat("/ban " .. oskrod .. " 30 Оскорбление родителей.")
        oskrod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/or [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskig(oskig)
  if oskig ~= nil and oskig:len() > 0 then
        sampSendChat("/mute " .. oskig .. " 30 Оскорбление игрока.")
        oskig = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/osk [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_uprod(uprod)
  if uprod ~= nil and uprod:len() > 0 then
        sampSendChat("/mute " .. uprod .. " 180 Упоминание родителей.")
        uprod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/up [id]', -1)
  end
end
---------------------------------------------------------------
---------------------------------------------------------
function cmd_th(arg)
  secondary_window_state.v = not secondary_window_state.v
end

function cmd_m(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        pm_report.v = not pm_report.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/m [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_ban(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        ban_menu.v = not ban_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/bm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mute(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        mute_menu.v = not mute_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/mtm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_prison(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        prison_menu.v = not prison_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/jm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_guns(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        guns_menu.v = not guns_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/gunm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_help(arg)
  help_menu.v = not help_menu.v
end
---------------------------------------------------------------
function cmd_p(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        p_menu.v = not p_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_p(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        p_menu.v = not p_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mnak(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        nakm_menu.v = not nakm_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Используйте: {408ad8}/mnak [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_atp(arg)
  atp_menu.v = not atp_menu.v
end
---------------------------------------------------------------
---------------------------------------------------------------
function imgui.OnDrawFrame()
  if secondary_window_state.v then
    imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Таблица наказаний | Alonso_Whittaker", secondary_window_state, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)

        imgui.Text(u8'Помехи игровому процессу:\nПомеха — /kick.\nПомеха в работе администратора — /kick.\nПомеха на каптах — /kick.\nПомеха на мероприятиях — /kick.\nСлив территорий - /jail от 120 до 180 минут.')
        imgui.Text(u8'Нецензурная лексика и другое:\nФлуд в чат — /mute от 10 до 30 минут.\nФлуд составом в репорт — /mute от 30 до 60 минут.\nСпам — /mute от 10 до 30 минут.\nCaps Lock — /mute от 10 до 30 минут.\nОскорбление игроков — /mute от 10 до 30 минут.\nОффтоп в репорт — /mute от 10 до 30 минут.\nОбман администрации сервера — /mute от 120 до 180 минут, /ban от 5 до 30 дней, черный список проекта.\nОбман администрации сервера на форуме — /ban от 5 до 30 дней, черный список проекта.\nОскорбление администрации на форуме — /ban от 5 до 30 дней, черный список проекта.\nВыдача себя за администратора — /mute от 30 минут до 120 (в зависимости от ситуации).\nУпоминание родных — /mute от 60 до 180 минут.\nОскорбление/неуважительное отношение родных — /ban 30 дней, удаление аккаунта (выдаётся в самом крайнем случае)/черный список проекта.\nУпоминание родных, розжиг, реклама, оскорбление в ник-нейме — /mute 180 минут, /ban 30 дней, удаление аккаунта/черный список проекта (в зависимости от ник-нейма).\nЖелание смерти родным — /ban 30 дней, удаление аккаунта с занесением в черный список проекта на пожизненный срок.\nОскорбление, неуважительное отношение в сторону администрации — /mute от 90 до 180 минут, /ban от 1 до 30 дней, удаление аккаунта с занесением в черный список проекта (в зависимости от ситуации).\nОскорбление с мульти-аккаунта — /ban основного аккаунта от 15 до 30 дней (мульти-аккаунт удаляется).\nЖелание смерти в сторону администрации — /mute 180 минут, /ban от 1 до 30 дней, удаление аккаунта с занесением в черный список проекта (в зависимости от ситуации).\nОскорбление в ник-нейме — просьба смены ник-нейма, /sban на 15-30 дней, удаление аккаунта/черный список проекта.\nРозжиг межнациональной розни — /ban на 30 дней (пример: чурка е*аная, хач е*аный, москаль е*аный, хохол е*аный и тому подобное), черный список сервера. Без мата - /mute 180 минут.\nОскорбление проекта/сервера — /mute 180 минут /cban от 1 до 30 дней, удаление аккаунта/черный список проекта.')
        imgui.Text(u8'DeathMatch и другое:\nDriveBy — /kick, /jail от 15 до 60 минут (если один игрок оставил свой транспорт на другом игроке, или же массовое DriveBy).\nSpawnKill — /jail от 30 до 120 минут.\nTeamKill — /jail от 30 до 120 минут.')
        imgui.Text(u8'AFK with out ESC:\nAFK без ESC (накрутка PAYDAY) — /kick.\nAFK в бою — /jail от 30 до 90 минут.')
        imgui.Text(u8'Багоюзы:\nБагоюз — /jail от 30 до 120 минут.\nБагоюз на деньги — /ban на 30 дней (после чего сразу удаляется аккаунт).\nБагоюз на мероприятии (анимация в стену) — /kick.\nБагоюз с машиной (игрок садится на водительское кресло, после чего зажимает клавишу /shift + пробел) — /jail от 30 до 90.\nИспользование макросов на +C — /ban от 5 до 7 дней.')
        imgui.Text(u8'Развод игроков:\nВзлом форумного аккаунта — /ban на форуме, /ban на сервере от 1 до 30 дней, черный список проекта.\nПокупка игровой валюты за рубли — /ban 30 дней, обнуление всех денег и всего имущества.\nПродажа игровой валюты за рубли — Вечная блокировка.\nПродажа/покупка/передача игрового форумного аккаунта — удаление форумного аккаунта, черный список проекта.')
        imgui.Text(u8'Использование посторонних программ:\nSpeedHack — /ban на 10 (в случае, если игрок сильно гадит серверу, можно выдать /ban от 20 до 30 дней).\nКоллизия — /ban на 10 дней.\nМетла — /ban от 10 до 20 дней.\nТелепортация — /ban от 10 до 15 дней.\nGodMode — /cban от 30 дней.\nGodMode car — /ban от 10 до 20 дней.\nAim — /cban от 20 до 30.\nWallHack — /ban от 10 до 20 дней.\nSobeit — /cban на 20 дней (в случае, если игрок сильно гадит серверу, можно выдать /ban 30 дней).\nРванка — /cban на 30 дней, удаление аккаунта.\nSpider (паучок) — /ban на 3 дня.\nSpreed — /ban 15 дней.\nDgun — /cban от 20 до 30 дней.\nAirBrake — /ban от 10 до 20 дней.\nAntistun — /ban от 10 до 15 дней.\nCleo Slap — /ban от 3 до 10 дней (выдавать 10 дней в случае того, если игрок выполняет это для получения материальной выгоды).\nCleo +C — /ban на 15 дней.\nExtra WS — /ban на 10 дней.\nАнтипадение с байка — /ban на 5 дней.\nCamHack — /ban на 3 дня (можно использовать с одобрения главной администрации).\nАдмин-чекер — /ban на 3 дня.\nCleo Fake Chat — /ban 10 дней, удаление аккаунта с занесением в черный список сервера, или же проекта в случае подставы.\nCleo анимации — не наказываем, если не имеет преимущества, /ban на 3 дня.\nCleo Fake Death — /ban на 5 дней, /ban на 30 дней (в случае подставы с занесением в черный список сервера).\nCleo Spawn Vehicle — /ban 5 дней.\nCleo Crashes.asi — v.2.51 разрешен. Более ранние версии - /ban 5 дней.\nSandboxie (песочница) — /ban 30 дней.\nAnti-AFK — /ban 5 дней.\nТурбо маркус (B1-6) - /ban от 10 до 15 дней.')
        imgui.End()
    end
---------------------------------------------------------------
  if ban_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню блокировки игроков | Alonso_Whittaker", ban_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"Телепортация", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 Телепорт")
            end

            if imgui.Button(u8"AirBrake", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 20 AirBraker")
            end
  
            if imgui.Button(u8"GodMode", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 GodMode")
            end
  
            if imgui.Button(u8"Sobeit", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 20 Sobeit.")
            end
  
            if imgui.Button(u8"Рванка ", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Рванка.")
            end
  
            if imgui.Button(u8"Auto +C", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 Auto +C.")
            end
  
            if imgui.Button(u8"Spreed", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 Spreed.")
            end

            if imgui.Button(u8"Antistun", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 Antistun.")
            end

            if imgui.Button(u8"Extra WS", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 10 Extra WS.")
            end

            if imgui.Button(u8"Метла", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 20 Метла.")
            end

            if imgui.Button(u8"Коллизия", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 10 Коллизия.")
            end

            if imgui.Button(u8"Cleo анимации", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 3 Cleo анимации.")
            end
  
            if imgui.Button(u8"Оскорбление родителей", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Оскорбление родителей")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if mute_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню блокировки чата игроку | Alonso_Whittaker", mute_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Упоминание родителей", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 180 Упоминание родителей.")
            end

            if imgui.Button(u8"Оскорбление игрока", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 Оскорбление игрока.")
            end

            if imgui.Button(u8"Caps Lock", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 Caps Lock.")
            end

            if imgui.Button(u8"Flood", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 Flood.")
            end

            if imgui.Button(u8"Offtop", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 Offtop.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if prison_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню отправки игрока в тюрьму | Alonso_Whittaker", prison_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"DriveBy", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 DriveBy.")
            end

            if imgui.Button(u8"SpawnKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 SpawnKill.")
            end

            if imgui.Button(u8"TeamKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 TeamKill.")
            end

            if imgui.Button(u8"Слив территорий", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 120 Слив территорий.")
            end

            if imgui.Button(u8"AFK в бою", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 AFK в бою.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if guns_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню оружие | Alonso_Whittaker", guns_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Пистолет Дезерт Игл", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 24 999")
            end

            if imgui.Button(u8"M4", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 31 999")
            end

            if imgui.Button(u8"Обычный дробовик", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 25 999")
            end

            if imgui.Button(u8"Бензопила", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 9 999")
            end

            if imgui.Button(u8"АК-47", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 30 999")
            end

            if imgui.Button(u8"Скорострельный дробовик", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 27 999")
            end

            if imgui.Button(u8"Самонаводящиеся ракеты HS", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 36 999")
            end

            if imgui.Button(u8"Огнемет", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 37 999")
            end

            if imgui.Button(u8"Миниган", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 38 999")
            end

            if imgui.Button(u8"Обрез", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 26 999")
            end

            if imgui.Button(u8"Узи", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 28 999")
            end

            if imgui.Button(u8"MP5", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 29 999")
            end

            if imgui.Button(u8"Снайперская винтовка", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 34 999")
            end

      imgui.End()
      end

---------------------------------------------------------------
  if p_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 210), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню быстрого ответа | Alonso_Whittaker", p_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Слежу за указанным игроком", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Начал работать по Вашей жалобе.")
            end

            if imgui.Button(u8"Нарушений не обнаружено", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Нарушений не обнаружено.")
            end

            if imgui.Button(u8"Игрок был наказан", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Игрок, по Вашей жалобе был наказан.")
            end

            if imgui.Button(u8"Игрок стоит в AFK", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Игрок, указанный в Вашей жалобе стоит в AFK.")
            end

            if imgui.Button(u8"Игрок вышел из игры", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Игрок, указанный в Вашей жалобе вышел из игры.")
            end

            if imgui.Button(u8"Пишите жалобу на администратора", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Пишите жалобу на администратора на форум сервера.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if nakm_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню наказаний для мл.адм | Alonso_Whittaker", nakm_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Попросить заблокировать за Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"Попросить заблокировать за телепортацию", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Телепорт")
            end

            if imgui.Button(u8"Попросить заблокировать за AirBrake", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 AirBraker")
            end
  
            if imgui.Button(u8"Попросить заблокировать за GodMode", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 GodMode")
            end
  
            if imgui.Button(u8"Попросить заблокировать за Sobeit", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 Sobeit.")
            end
  
            if imgui.Button(u8"Попросить заблокировать за Рванку ", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Рванка.")
            end
  			
            if imgui.Button(u8"Попросить заблокировать за Extra WS", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 Extra WS.")
            end

            if imgui.Button(u8"Попросить заблокировать за Метлу", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 Метла.")
            end

            if imgui.Button(u8"Попросить заблокировать за Коллизию", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 Коллизия.")
            end

            if imgui.Button(u8"Попросить заблокировать за Cleo анимации", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 3 Cleo анимации.")
            end

            if imgui.Button(u8"Попросить заблокировать за Auto +C", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Auto +C.")
            end
  
            if imgui.Button(u8"Попросить заблокировать за Spreed", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Spreed.")
            end
  
            if imgui.Button(u8"Оскорбление родителей", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Оскорбление родителей")
            end

      imgui.End()
      end
---------------------------------------------------------------
if atp_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 120), imgui.Cond.FirstUseEver)
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Панель телепорта | Alonso_Whittaker", atp_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(u8"Aztecas", imgui.ImVec2(190, 25)) then
                mainIni = inicfg.load(nil, directiIni)
                sampSendChat("/atp 4", -1)
        end

        imgui.SameLine()

        if imgui.Button(u8"Vagos", imgui.ImVec2(190, 25)) then
                mainIni = inicfg.load(nil, directiIni)
                sampSendChat("/atp 3", -1)
        end

        if imgui.Button(u8"Ballas", imgui.ImVec2(190, 25)) then
                mainIni = inicfg.load(nil, directiIni)
                sampSendChat("/atp 2", -1)
        end

        imgui.SameLine()

        if imgui.Button(u8"Grove", imgui.ImVec2(190, 25)) then
                mainIni = inicfg.load(nil, directiIni)
                sampSendChat("/atp 1", -1)
        end

        imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
        if imgui.Button(u8"Admin int", imgui.ImVec2(190, 25)) then
                mainIni = inicfg.load(nil, directiIni)
                sampSendChat("/aint", -1)
        end

        imgui.End()
        end
---------------------------------------------------------------
  if help_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(450, 480), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Команды и функции Admin Tools`a | Alonso_Whittaker", help_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

      imgui.Text(u8"Команда Admin Tools`a v.0.1")

    imgui.Text(u8"Команда: /p [player id]- возможность отвечать игроку")
    imgui.Text(u8"Команда: /m [player id]- панель взаимодействия с игроком.")
    imgui.Text(u8"Команда: /th - можно посмотреть таблицу наказания для игроков.")
    imgui.Text(u8"Команда: /bm [player id]- быстро отправляет игрока в бан.")
    imgui.Text(u8"Команда: /mtm [player id]- быстро блокирует чат у игрока.")
    imgui.Text(u8"Команда: /jm [player id]- быстро отправляет игрока в тюрьму.")
    imgui.Text(u8"Команда: /acmd - посмотреть все команды Admin Tools`a.")
    imgui.Text(u8"Команда: /mnak - меню наказаний для мл.администрации.")

      imgui.Text(u8"Команда Admin Tools`a v.0.2")

    imgui.Text(u8"Команда: /ajail [id] - Посадить игрока в тюрьму за AIM")
    imgui.Text(u8"Команда: /fjail [id] - Попросить посадить игрока за AIM.")
    imgui.Text(u8"Команда: /faim [id] - Попросить забанить игрока за AIM.")
    imgui.Text(u8"Команда: /aim [id] - Забанить игрока за AIM.")
    imgui.Text(u8"Команда: /saim [id] - Заблокировать аккаунт игрока и IP. (для 5 лвл)")
    imgui.Text(u8"Команда: /or [id] - Забанить игрока за оскорбление родителей.")
    imgui.Text(u8"Команда: /stan [id] - Забанить игрока за Antistun.")
    imgui.Text(u8"Команда: /+c [id] - Забанить игрока за Авто +С.")
    imgui.Text(u8"Команда: /up [id] - Дать мут игроку за упоминание родителей.")
    imgui.Text(u8"Команда: /osk [id] - Дать мут игроку за оскорбление игрока.")
    imgui.Text(u8"Команда: /flood [id] - Дать мут игроку за флуд.")
    imgui.Text(u8"Команда: /caps [id] - Дать мут игроку за капс.")
    imgui.Text(u8"Читы:")
    imgui.Text(u8"AirBrake: Активация | Деактивация: Правый Shift.")
    imgui.End()
  end
---------------------------------------------------------------
  if pm_report.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Меню взаимодействие | Alonso_Whittaker", pm_report, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(u8"Заблокировать игрока", imgui.ImVec2(334, 25)) then
            ban_menu.v = not ban_menu.v
          end

          if imgui.Button(u8"Заблокировать чат игроку", imgui.ImVec2(334, 25)) then
            mute_menu.v = not mute_menu.v
          end

          if imgui.Button(u8"Отправить в тюрьму игрока", imgui.ImVec2(334, 25)) then
            prison_menu.v = not prison_menu.v
          end

          if imgui.Button(u8"Выдать оружие игроку", imgui.ImVec2(334, 25)) then
            guns_menu.v = not guns_menu.v
          end

          if imgui.Button(u8"Дать пинка игроку", imgui.ImVec2(334, 25)) then
            sampSendChat("/slap "..banId)
          end

          if imgui.Button(u8"Отправить игрока на место спавна", imgui.ImVec2(334, 25)) then
            sampSendChat("/spawn "..banId)
          end

          if imgui.Button(u8"Телепортировать игрока к себе", imgui.ImVec2(334, 25)) then
            sampSendChat("/tpks "..banId)
          end

          if imgui.Button(u8"Телепортироваться к игру", imgui.ImVec2(334, 25)) then
            sampSendChat("/tpkn "..banId)
          end

      imgui.End()
      end
  end
---------------------------------------------------------------
function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

  colors[clr.Text]                 = ImVec4(0.95, 0.96, 0.98, 1.00)
  colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
  colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
  colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
  colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
  colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
  colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
  colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.TitleBgActive]        = ImVec4(0.08, 0.10, 0.12, 1.00)
  colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
  colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
  colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
  colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
  colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.CheckMark]            = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.SliderGrab]           = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.SliderGrabActive]     = ImVec4(0.37, 0.61, 1.00, 1.00)
  colors[clr.Button]               = ImVec4(0.20, 0.25, 0.29, 1.00)
  colors[clr.ButtonHovered]        = ImVec4(0.28, 0.56, 1.00, 1.00)
  colors[clr.ButtonActive]         = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
  colors[clr.HeaderHovered]        = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive]         = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
  colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
  colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
  colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
  colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end