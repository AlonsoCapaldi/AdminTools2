script_name('Admin Tools')
script_version("29.05.2020")
script_author('Alonso_Whittaker')
script_description('Alonso_Whittaker')
----------------------
airbreak_coords = {}
speed = 1
----------------------
require "lib.moonloader" -- ïîäêëþ÷åíèå áèáëèîòåêè
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
--//////////////////////Àâòîîáíîâëåíèå////////////////////////
update_state = false

local script_vers = 0.2
local script_vers_text = "0.2"

local update_url = "https://raw.githubusercontent.com/AlonsoCapaldi/Admin-Tools/master/update.ini" -- òóò òîæå ñâîþ ññûëêó
local update_path = getWorkingDirectory() .. "/update.ini" -- è òóò ñâîþ ññûëêó

local script_url = "https://github.com/AlonsoCapaldi/Admin-Tools/blob/master/Admin%20Tools.luac?raw=true" -- òóò ñâîþ ññûëêó
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
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}Àâòîð äàííîãî ñêðèïòà {408ad8}Alonso_Whittaker. {FFFFFF}Âåðñèÿ: {408ad8} " .. script_vers, -1)
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}Ïîñìîòðåòü ñïèñîê êîìàíä è ôóíêöèè Admin Tools`a: {408ad8}/acmd", -1)

    repeat wait(0) until isSampAvailable()
    if not checkip() then
        sampAddChatMessage('{408ad8}[Admin Tools]:{FFFFFF} Íå óäàëîñü çàãðóçèòü. Ðàáîòàåò òîëüêî íà {408ad8}Monser DeathMatch | Three', -1)
        error()
    end
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Óñïåøíî çàãðóæåí.', -1)
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
--//////////////////////Àâòîîáíîâëåíèå////////////////////////
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.update.vers) > script_vers then
                sampAddChatMessage("Åñòü îáíîâëåíèå! Âåðñèÿ: " .. updateIni.update.vers_text, -1)
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
                    sampAddChatMessage("Ñêðèïò óñïåøíî îáíîâëåí!", -1)
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
      --- Êîíåö AirBrake
   end
end
function cmd_ws(autuc)
  if ws ~= nil and ws:len() > 0 then
        sampSendChat("/ban " .. ws .. " 10 Extra WS.")
        ws = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/ws [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_c(autuc)
  if autuc ~= nil and autuc:len() > 0 then
        sampSendChat("/ban " .. autuc .. " 15 Auto +c.")
        autuc = 0
  elses
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/+c [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_stan(anti)
  if anti ~= nil and anti:len() > 0 then
        sampSendChat("/ban " .. anti .. " 15 Antistun.")
        anti = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/stan [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_caps(caps)
  if caps ~= nil and caps:len() > 0 then
        sampSendChat("/mute " .. caps .. " 30 Caps Lock.")
        caps = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/caps [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_flood(flood)
  if flood ~= nil and flood:len() > 0 then
        sampSendChat("/mute " .. flood .. " 30 Flood.")
        flood = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/flood [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_ajail(afjail)
  if afjail ~= nil and afjail:len() > 0 then
        sampSendChat("/jail " .. afjail .. " 60 Aim.")
        afjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/ajail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_fjail(fjail)
  if fjail ~= nil and fjail:len() > 0 then
        sampSendChat("/a /jail " .. fjail .. " 60 Aim.")
        fjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/fjail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_faim(faim)
  if faim ~= nil and faim:len() > 0 then
        sampSendChat("/a /ban " .. faim .. " 60 Aim.")
        faim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/faim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_aim(aim)
  if aim ~= nil and aim:len() > 0 then
        sampSendChat("/ban " .. aim .. " 30 Aim.")
        aim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/aim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_saim(saim)
  if saim ~= nil and saim:len() > 0 then
        sampSendChat("/cban " .. saim .. " 30 Aim.")
        saim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/saim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskrod(oskrod)
  if oskrod ~= nil and oskrod:len() > 0 then
        sampSendChat("/ban " .. oskrod .. " 30 Îñêîðáëåíèå ðîäèòåëåé.")
        oskrod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/or [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskig(oskig)
  if oskig ~= nil and oskig:len() > 0 then
        sampSendChat("/mute " .. oskig .. " 30 Îñêîðáëåíèå èãðîêà.")
        oskig = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/osk [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_uprod(uprod)
  if uprod ~= nil and uprod:len() > 0 then
        sampSendChat("/mute " .. uprod .. " 180 Óïîìèíàíèå ðîäèòåëåé.")
        uprod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/up [id]', -1)
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
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/m [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_ban(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        ban_menu.v = not ban_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/bm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mute(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        mute_menu.v = not mute_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/mtm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_prison(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        prison_menu.v = not prison_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/jm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_guns(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        guns_menu.v = not guns_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/gunm [id]', -1)
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
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_p(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        p_menu.v = not p_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mnak(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        nakm_menu.v = not nakm_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}Èñïîëüçóéòå: {408ad8}/mnak [id]', -1)
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
    imgui.Begin(u8"Òàáëèöà íàêàçàíèé | Alonso_Whittaker", secondary_window_state, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)

        imgui.Text(u8'Ïîìåõè èãðîâîìó ïðîöåññó:\nÏîìåõà  /kick.\nÏîìåõà â ðàáîòå àäìèíèñòðàòîðà  /kick.\nÏîìåõà íà êàïòàõ  /kick.\nÏîìåõà íà ìåðîïðèÿòèÿõ  /kick.\nÑëèâ òåððèòîðèé - /jail îò 120 äî 180 ìèíóò.')
        imgui.Text(u8'Íåöåíçóðíàÿ ëåêñèêà è äðóãîå:\nÔëóä â ÷àò  /mute îò 10 äî 30 ìèíóò.\nÔëóä ñîñòàâîì â ðåïîðò  /mute îò 30 äî 60 ìèíóò.\nÑïàì  /mute îò 10 äî 30 ìèíóò.\nCaps Lock  /mute îò 10 äî 30 ìèíóò.\nÎñêîðáëåíèå èãðîêîâ  /mute îò 10 äî 30 ìèíóò.\nÎôôòîï â ðåïîðò  /mute îò 10 äî 30 ìèíóò.\nÎáìàí àäìèíèñòðàöèè ñåðâåðà  /mute îò 120 äî 180 ìèíóò, /ban îò 5 äî 30 äíåé, ÷åðíûé ñïèñîê ïðîåêòà.\nÎáìàí àäìèíèñòðàöèè ñåðâåðà íà ôîðóìå  /ban îò 5 äî 30 äíåé, ÷åðíûé ñïèñîê ïðîåêòà.\nÎñêîðáëåíèå àäìèíèñòðàöèè íà ôîðóìå  /ban îò 5 äî 30 äíåé, ÷åðíûé ñïèñîê ïðîåêòà.\nÂûäà÷à ñåáÿ çà àäìèíèñòðàòîðà  /mute îò 30 ìèíóò äî 120 (â çàâèñèìîñòè îò ñèòóàöèè).\nÓïîìèíàíèå ðîäíûõ  /mute îò 60 äî 180 ìèíóò.\nÎñêîðáëåíèå/íåóâàæèòåëüíîå îòíîøåíèå ðîäíûõ  /ban 30 äíåé, óäàëåíèå àêêàóíòà (âûäà¸òñÿ â ñàìîì êðàéíåì ñëó÷àå)/÷åðíûé ñïèñîê ïðîåêòà.\nÓïîìèíàíèå ðîäíûõ, ðîçæèã, ðåêëàìà, îñêîðáëåíèå â íèê-íåéìå  /mute 180 ìèíóò, /ban 30 äíåé, óäàëåíèå àêêàóíòà/÷åðíûé ñïèñîê ïðîåêòà (â çàâèñèìîñòè îò íèê-íåéìà).\nÆåëàíèå ñìåðòè ðîäíûì  /ban 30 äíåé, óäàëåíèå àêêàóíòà ñ çàíåñåíèåì â ÷åðíûé ñïèñîê ïðîåêòà íà ïîæèçíåííûé ñðîê.\nÎñêîðáëåíèå, íåóâàæèòåëüíîå îòíîøåíèå â ñòîðîíó àäìèíèñòðàöèè  /mute îò 90 äî 180 ìèíóò, /ban îò 1 äî 30 äíåé, óäàëåíèå àêêàóíòà ñ çàíåñåíèåì â ÷åðíûé ñïèñîê ïðîåêòà (â çàâèñèìîñòè îò ñèòóàöèè).\nÎñêîðáëåíèå ñ ìóëüòè-àêêàóíòà  /ban îñíîâíîãî àêêàóíòà îò 15 äî 30 äíåé (ìóëüòè-àêêàóíò óäàëÿåòñÿ).\nÆåëàíèå ñìåðòè â ñòîðîíó àäìèíèñòðàöèè  /mute 180 ìèíóò, /ban îò 1 äî 30 äíåé, óäàëåíèå àêêàóíòà ñ çàíåñåíèåì â ÷åðíûé ñïèñîê ïðîåêòà (â çàâèñèìîñòè îò ñèòóàöèè).\nÎñêîðáëåíèå â íèê-íåéìå  ïðîñüáà ñìåíû íèê-íåéìà, /sban íà 15-30 äíåé, óäàëåíèå àêêàóíòà/÷åðíûé ñïèñîê ïðîåêòà.\nÐîçæèã ìåæíàöèîíàëüíîé ðîçíè  /ban íà 30 äíåé (ïðèìåð: ÷óðêà å*àíàÿ, õà÷ å*àíûé, ìîñêàëü å*àíûé, õîõîë å*àíûé è òîìó ïîäîáíîå), ÷åðíûé ñïèñîê ñåðâåðà. Áåç ìàòà - /mute 180 ìèíóò.\nÎñêîðáëåíèå ïðîåêòà/ñåðâåðà  /mute 180 ìèíóò /cban îò 1 äî 30 äíåé, óäàëåíèå àêêàóíòà/÷åðíûé ñïèñîê ïðîåêòà.')
        imgui.Text(u8'DeathMatch è äðóãîå:\nDriveBy  /kick, /jail îò 15 äî 60 ìèíóò (åñëè îäèí èãðîê îñòàâèë ñâîé òðàíñïîðò íà äðóãîì èãðîêå, èëè æå ìàññîâîå DriveBy).\nSpawnKill  /jail îò 30 äî 120 ìèíóò.\nTeamKill  /jail îò 30 äî 120 ìèíóò.')
        imgui.Text(u8'AFK with out ESC:\nAFK áåç ESC (íàêðóòêà PAYDAY)  /kick.\nAFK â áîþ  /jail îò 30 äî 90 ìèíóò.')
        imgui.Text(u8'Áàãîþçû:\nÁàãîþç  /jail îò 30 äî 120 ìèíóò.\nÁàãîþç íà äåíüãè  /ban íà 30 äíåé (ïîñëå ÷åãî ñðàçó óäàëÿåòñÿ àêêàóíò).\nÁàãîþç íà ìåðîïðèÿòèè (àíèìàöèÿ â ñòåíó)  /kick.\nÁàãîþç ñ ìàøèíîé (èãðîê ñàäèòñÿ íà âîäèòåëüñêîå êðåñëî, ïîñëå ÷åãî çàæèìàåò êëàâèøó /shift + ïðîáåë)  /jail îò 30 äî 90.\nÈñïîëüçîâàíèå ìàêðîñîâ íà +C  /ban îò 5 äî 7 äíåé.')
        imgui.Text(u8'Ðàçâîä èãðîêîâ:\nÂçëîì ôîðóìíîãî àêêàóíòà  /ban íà ôîðóìå, /ban íà ñåðâåðå îò 1 äî 30 äíåé, ÷åðíûé ñïèñîê ïðîåêòà.\nÏîêóïêà èãðîâîé âàëþòû çà ðóáëè  /ban 30 äíåé, îáíóëåíèå âñåõ äåíåã è âñåãî èìóùåñòâà.\nÏðîäàæà èãðîâîé âàëþòû çà ðóáëè  Âå÷íàÿ áëîêèðîâêà.\nÏðîäàæà/ïîêóïêà/ïåðåäà÷à èãðîâîãî ôîðóìíîãî àêêàóíòà  óäàëåíèå ôîðóìíîãî àêêàóíòà, ÷åðíûé ñïèñîê ïðîåêòà.')
        imgui.Text(u8'Èñïîëüçîâàíèå ïîñòîðîííèõ ïðîãðàìì:\nSpeedHack  /ban íà 10 (â ñëó÷àå, åñëè èãðîê ñèëüíî ãàäèò ñåðâåðó, ìîæíî âûäàòü /ban îò 20 äî 30 äíåé).\nÊîëëèçèÿ  /ban íà 10 äíåé.\nÌåòëà  /ban îò 10 äî 20 äíåé.\nÒåëåïîðòàöèÿ  /ban îò 10 äî 15 äíåé.\nGodMode  /cban îò 30 äíåé.\nGodMode car  /ban îò 10 äî 20 äíåé.\nAim  /cban îò 20 äî 30.\nWallHack  /ban îò 10 äî 20 äíåé.\nSobeit  /cban íà 20 äíåé (â ñëó÷àå, åñëè èãðîê ñèëüíî ãàäèò ñåðâåðó, ìîæíî âûäàòü /ban 30 äíåé).\nÐâàíêà  /cban íà 30 äíåé, óäàëåíèå àêêàóíòà.\nSpider (ïàó÷îê)  /ban íà 3 äíÿ.\nSpreed  /ban 15 äíåé.\nDgun  /cban îò 20 äî 30 äíåé.\nAirBrake  /ban îò 10 äî 20 äíåé.\nAntistun  /ban îò 10 äî 15 äíåé.\nCleo Slap  /ban îò 3 äî 10 äíåé (âûäàâàòü 10 äíåé â ñëó÷àå òîãî, åñëè èãðîê âûïîëíÿåò ýòî äëÿ ïîëó÷åíèÿ ìàòåðèàëüíîé âûãîäû).\nCleo +C  /ban íà 15 äíåé.\nExtra WS  /ban íà 10 äíåé.\nÀíòèïàäåíèå ñ áàéêà  /ban íà 5 äíåé.\nCamHack  /ban íà 3 äíÿ (ìîæíî èñïîëüçîâàòü ñ îäîáðåíèÿ ãëàâíîé àäìèíèñòðàöèè).\nÀäìèí-÷åêåð  /ban íà 3 äíÿ.\nCleo Fake Chat  /ban 10 äíåé, óäàëåíèå àêêàóíòà ñ çàíåñåíèåì â ÷åðíûé ñïèñîê ñåðâåðà, èëè æå ïðîåêòà â ñëó÷àå ïîäñòàâû.\nCleo àíèìàöèè  íå íàêàçûâàåì, åñëè íå èìååò ïðåèìóùåñòâà, /ban íà 3 äíÿ.\nCleo Fake Death  /ban íà 5 äíåé, /ban íà 30 äíåé (â ñëó÷àå ïîäñòàâû ñ çàíåñåíèåì â ÷åðíûé ñïèñîê ñåðâåðà).\nCleo Spawn Vehicle  /ban 5 äíåé.\nCleo Crashes.asi  v.2.51 ðàçðåøåí. Áîëåå ðàííèå âåðñèè - /ban 5 äíåé.\nSandboxie (ïåñî÷íèöà)  /ban 30 äíåé.\nAnti-AFK  /ban 5 äíåé.\nÒóðáî ìàðêóñ (B1-6) - /ban îò 10 äî 15 äíåé.')
        imgui.End()
    end
---------------------------------------------------------------
  if ban_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ áëîêèðîâêè èãðîêîâ | Alonso_Whittaker", ban_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"Òåëåïîðòàöèÿ", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 Òåëåïîðò")
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
  
            if imgui.Button(u8"Ðâàíêà ", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Ðâàíêà.")
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

            if imgui.Button(u8"Ìåòëà", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 20 Ìåòëà.")
            end

            if imgui.Button(u8"Êîëëèçèÿ", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 10 Êîëëèçèÿ.")
            end

            if imgui.Button(u8"Cleo àíèìàöèè", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 3 Cleo àíèìàöèè.")
            end
  
            if imgui.Button(u8"Îñêîðáëåíèå ðîäèòåëåé", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Îñêîðáëåíèå ðîäèòåëåé")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if mute_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ áëîêèðîâêè ÷àòà èãðîêó | Alonso_Whittaker", mute_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Óïîìèíàíèå ðîäèòåëåé", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 180 Óïîìèíàíèå ðîäèòåëåé.")
            end

            if imgui.Button(u8"Îñêîðáëåíèå èãðîêà", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 Îñêîðáëåíèå èãðîêà.")
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
    imgui.Begin(u8"Ìåíþ îòïðàâêè èãðîêà â òþðüìó | Alonso_Whittaker", prison_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"DriveBy", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 DriveBy.")
            end

            if imgui.Button(u8"SpawnKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 SpawnKill.")
            end

            if imgui.Button(u8"TeamKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 TeamKill.")
            end

            if imgui.Button(u8"Ñëèâ òåððèòîðèé", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 120 Ñëèâ òåððèòîðèé.")
            end

            if imgui.Button(u8"AFK â áîþ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 AFK â áîþ.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if guns_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ îðóæèå | Alonso_Whittaker", guns_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Ïèñòîëåò Äåçåðò Èãë", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 24 999")
            end

            if imgui.Button(u8"M4", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 31 999")
            end

            if imgui.Button(u8"Îáû÷íûé äðîáîâèê", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 25 999")
            end

            if imgui.Button(u8"Áåíçîïèëà", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 9 999")
            end

            if imgui.Button(u8"ÀÊ-47", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 30 999")
            end

            if imgui.Button(u8"Ñêîðîñòðåëüíûé äðîáîâèê", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 27 999")
            end

            if imgui.Button(u8"Ñàìîíàâîäÿùèåñÿ ðàêåòû HS", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 36 999")
            end

            if imgui.Button(u8"Îãíåìåò", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 37 999")
            end

            if imgui.Button(u8"Ìèíèãàí", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 38 999")
            end

            if imgui.Button(u8"Îáðåç", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 26 999")
            end

            if imgui.Button(u8"Óçè", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 28 999")
            end

            if imgui.Button(u8"MP5", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 29 999")
            end

            if imgui.Button(u8"Ñíàéïåðñêàÿ âèíòîâêà", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 34 999")
            end

      imgui.End()
      end

---------------------------------------------------------------
  if p_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 210), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ áûñòðîãî îòâåòà | Alonso_Whittaker", p_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Ñëåæó çà óêàçàííûì èãðîêîì", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Íà÷àë ðàáîòàòü ïî Âàøåé æàëîáå.")
            end

            if imgui.Button(u8"Íàðóøåíèé íå îáíàðóæåíî", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Íàðóøåíèé íå îáíàðóæåíî.")
            end

            if imgui.Button(u8"Èãðîê áûë íàêàçàí", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Èãðîê, ïî Âàøåé æàëîáå áûë íàêàçàí.")
            end

            if imgui.Button(u8"Èãðîê ñòîèò â AFK", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Èãðîê, óêàçàííûé â Âàøåé æàëîáå ñòîèò â AFK.")
            end

            if imgui.Button(u8"Èãðîê âûøåë èç èãðû", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Èãðîê, óêàçàííûé â Âàøåé æàëîáå âûøåë èç èãðû.")
            end

            if imgui.Button(u8"Ïèøèòå æàëîáó íà àäìèíèñòðàòîðà", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " Ïèøèòå æàëîáó íà àäìèíèñòðàòîðà íà ôîðóì ñåðâåðà.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if nakm_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ íàêàçàíèé äëÿ ìë.àäì | Alonso_Whittaker", nakm_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà òåëåïîðòàöèþ", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Òåëåïîðò")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà AirBrake", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 AirBraker")
            end
  
            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà GodMode", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 GodMode")
            end
  
            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Sobeit", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 Sobeit.")
            end
  
            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Ðâàíêó ", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Ðâàíêà.")
            end
  			
            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Extra WS", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 Extra WS.")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Ìåòëó", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 Ìåòëà.")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Êîëëèçèþ", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 Êîëëèçèÿ.")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Cleo àíèìàöèè", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 3 Cleo àíèìàöèè.")
            end

            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Auto +C", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Auto +C.")
            end
  
            if imgui.Button(u8"Ïîïðîñèòü çàáëîêèðîâàòü çà Spreed", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Spreed.")
            end
  
            if imgui.Button(u8"Îñêîðáëåíèå ðîäèòåëåé", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Îñêîðáëåíèå ðîäèòåëåé")
            end

      imgui.End()
      end
---------------------------------------------------------------
if atp_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 120), imgui.Cond.FirstUseEver)
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Ïàíåëü òåëåïîðòà | Alonso_Whittaker", atp_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

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
    imgui.Begin(u8"Êîìàíäû è ôóíêöèè Admin Tools`a | Alonso_Whittaker", help_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

      imgui.Text(u8"Êîìàíäà Admin Tools`a v.0.1")

    imgui.Text(u8"Êîìàíäà: /p [player id]- âîçìîæíîñòü îòâå÷àòü èãðîêó")
    imgui.Text(u8"Êîìàíäà: /m [player id]- ïàíåëü âçàèìîäåéñòâèÿ ñ èãðîêîì.")
    imgui.Text(u8"Êîìàíäà: /th - ìîæíî ïîñìîòðåòü òàáëèöó íàêàçàíèÿ äëÿ èãðîêîâ.")
    imgui.Text(u8"Êîìàíäà: /bm [player id]- áûñòðî îòïðàâëÿåò èãðîêà â áàí.")
    imgui.Text(u8"Êîìàíäà: /mtm [player id]- áûñòðî áëîêèðóåò ÷àò ó èãðîêà.")
    imgui.Text(u8"Êîìàíäà: /jm [player id]- áûñòðî îòïðàâëÿåò èãðîêà â òþðüìó.")
    imgui.Text(u8"Êîìàíäà: /acmd - ïîñìîòðåòü âñå êîìàíäû Admin Tools`a.")
    imgui.Text(u8"Êîìàíäà: /mnak - ìåíþ íàêàçàíèé äëÿ ìë.àäìèíèñòðàöèè.")

      imgui.Text(u8"Êîìàíäà Admin Tools`a v.0.2")

    imgui.Text(u8"Êîìàíäà: /ajail [id] - Ïîñàäèòü èãðîêà â òþðüìó çà AIM")
    imgui.Text(u8"Êîìàíäà: /fjail [id] - Ïîïðîñèòü ïîñàäèòü èãðîêà çà AIM.")
    imgui.Text(u8"Êîìàíäà: /faim [id] - Ïîïðîñèòü çàáàíèòü èãðîêà çà AIM.")
    imgui.Text(u8"Êîìàíäà: /aim [id] - Çàáàíèòü èãðîêà çà AIM.")
    imgui.Text(u8"Êîìàíäà: /saim [id] - Çàáëîêèðîâàòü àêêàóíò èãðîêà è IP. (äëÿ 5 ëâë)")
    imgui.Text(u8"Êîìàíäà: /or [id] - Çàáàíèòü èãðîêà çà îñêîðáëåíèå ðîäèòåëåé.")
    imgui.Text(u8"Êîìàíäà: /stan [id] - Çàáàíèòü èãðîêà çà Antistun.")
    imgui.Text(u8"Êîìàíäà: /+c [id] - Çàáàíèòü èãðîêà çà Àâòî +Ñ.")
    imgui.Text(u8"Êîìàíäà: /up [id] - Äàòü ìóò èãðîêó çà óïîìèíàíèå ðîäèòåëåé.")
    imgui.Text(u8"Êîìàíäà: /osk [id] - Äàòü ìóò èãðîêó çà îñêîðáëåíèå èãðîêà.")
    imgui.Text(u8"Êîìàíäà: /flood [id] - Äàòü ìóò èãðîêó çà ôëóä.")
    imgui.Text(u8"Êîìàíäà: /caps [id] - Äàòü ìóò èãðîêó çà êàïñ.")
    imgui.Text(u8"×èòû:")
    imgui.Text(u8"AirBrake: Àêòèâàöèÿ | Äåàêòèâàöèÿ: Ïðàâûé Shift.")
    imgui.End()
  end
---------------------------------------------------------------
  if pm_report.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"Ìåíþ âçàèìîäåéñòâèå | Alonso_Whittaker", pm_report, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(u8"Çàáëîêèðîâàòü èãðîêà", imgui.ImVec2(334, 25)) then
            ban_menu.v = not ban_menu.v
          end

          if imgui.Button(u8"Çàáëîêèðîâàòü ÷àò èãðîêó", imgui.ImVec2(334, 25)) then
            mute_menu.v = not mute_menu.v
          end

          if imgui.Button(u8"Îòïðàâèòü â òþðüìó èãðîêà", imgui.ImVec2(334, 25)) then
            prison_menu.v = not prison_menu.v
          end

          if imgui.Button(u8"Âûäàòü îðóæèå èãðîêó", imgui.ImVec2(334, 25)) then
            guns_menu.v = not guns_menu.v
          end

          if imgui.Button(u8"Äàòü ïèíêà èãðîêó", imgui.ImVec2(334, 25)) then
            sampSendChat("/slap "..banId)
          end

          if imgui.Button(u8"Îòïðàâèòü èãðîêà íà ìåñòî ñïàâíà", imgui.ImVec2(334, 25)) then
            sampSendChat("/spawn "..banId)
          end

          if imgui.Button(u8"Òåëåïîðòèðîâàòü èãðîêà ê ñåáå", imgui.ImVec2(334, 25)) then
            sampSendChat("/tpks "..banId)
          end

          if imgui.Button(u8"Òåëåïîðòèðîâàòüñÿ ê èãðó", imgui.ImVec2(334, 25)) then
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
