script_name('Admin Tools')
script_version("29.05.2020")
script_author('Alonso_Whittaker')
script_description('Alonso_Whittaker')
----------------------
airbreak_coords = {}
speed = 1
----------------------
require "lib.moonloader" -- ����������� ����������
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
--//////////////////////��������������////////////////////////
update_state = false

local script_vers = 0.2
local script_vers_text = "0.2"

local update_url = "https://raw.githubusercontent.com/AlonsoCapaldi/Admin-Tools/master/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "https://github.com/AlonsoCapaldi/Admin-Tools/blob/master/Admin%20Tools.luac?raw=true" -- ��� ���� ������
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
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}����� ������� ������� {408ad8}Alonso_Whittaker. {FFFFFF}������: {408ad8} " .. script_vers, -1)
    sampAddChatMessage("{408ad8}[Admin Tools]: {FFFFFF}���������� ������ ������ � ������� Admin Tools`a: {408ad8}/acmd", -1)

    repeat wait(0) until isSampAvailable()
    if not checkip() then
        sampAddChatMessage('{408ad8}[Admin Tools]:{FFFFFF} �� ������� ���������. �������� ������ �� {408ad8}Monser DeathMatch | Three', -1)
        error()
    end
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}������� ��������.', -1)
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
--//////////////////////��������������////////////////////////
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.update.vers) > script_vers then
                sampAddChatMessage("���� ����������! ������: " .. updateIni.update.vers_text, -1)
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
                    sampAddChatMessage("������ ������� ��������!", -1)
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
      --- ����� AirBrake
   end
end
function cmd_ws(autuc)
  if ws ~= nil and ws:len() > 0 then
        sampSendChat("/ban " .. ws .. " 10 Extra WS.")
        ws = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/ws [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_c(autuc)
  if autuc ~= nil and autuc:len() > 0 then
        sampSendChat("/ban " .. autuc .. " 15 Auto +c.")
        autuc = 0
  elses
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/+c [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_stan(anti)
  if anti ~= nil and anti:len() > 0 then
        sampSendChat("/ban " .. anti .. " 15 Antistun.")
        anti = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/stan [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_caps(caps)
  if caps ~= nil and caps:len() > 0 then
        sampSendChat("/mute " .. caps .. " 30 Caps Lock.")
        caps = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/caps [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_flood(flood)
  if flood ~= nil and flood:len() > 0 then
        sampSendChat("/mute " .. flood .. " 30 Flood.")
        flood = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/flood [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_ajail(afjail)
  if afjail ~= nil and afjail:len() > 0 then
        sampSendChat("/jail " .. afjail .. " 60 Aim.")
        afjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/ajail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_fjail(fjail)
  if fjail ~= nil and fjail:len() > 0 then
        sampSendChat("/a /jail " .. fjail .. " 60 Aim.")
        fjail = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/fjail [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_faim(faim)
  if faim ~= nil and faim:len() > 0 then
        sampSendChat("/a /ban " .. faim .. " 60 Aim.")
        faim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/faim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_aim(aim)
  if aim ~= nil and aim:len() > 0 then
        sampSendChat("/ban " .. aim .. " 30 Aim.")
        aim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/aim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_saim(saim)
  if saim ~= nil and saim:len() > 0 then
        sampSendChat("/cban " .. saim .. " 30 Aim.")
        saim = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/saim [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskrod(oskrod)
  if oskrod ~= nil and oskrod:len() > 0 then
        sampSendChat("/ban " .. oskrod .. " 30 ����������� ���������.")
        oskrod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/or [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_oskig(oskig)
  if oskig ~= nil and oskig:len() > 0 then
        sampSendChat("/mute " .. oskig .. " 30 ����������� ������.")
        oskig = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/osk [id]', -1)
  end
end
---------------------------------------------------------------
function cmd_uprod(uprod)
  if uprod ~= nil and uprod:len() > 0 then
        sampSendChat("/mute " .. uprod .. " 180 ���������� ���������.")
        uprod = 0
  else
    sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/up [id]', -1)
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
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/m [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_ban(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        ban_menu.v = not ban_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/bm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mute(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        mute_menu.v = not mute_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/mtm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_prison(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        prison_menu.v = not prison_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/jm [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_guns(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        guns_menu.v = not guns_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/gunm [id]', -1)
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
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_p(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        p_menu.v = not p_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/p [id]', -1)
    end
end
---------------------------------------------------------------
function cmd_mnak(arg)
    if arg:match("%d") and arg:len() > 0 then
        banId = arg
        nakm_menu.v = not nakm_menu.v
    else
        sampAddChatMessage('{408ad8}[Admin Tools]: {FFFFFF}�����������: {408ad8}/mnak [id]', -1)
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
    imgui.Begin(u8"������� ��������� | Alonso_Whittaker", secondary_window_state, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)

        imgui.Text(u8'������ �������� ��������:\n������ � /kick.\n������ � ������ �������������� � /kick.\n������ �� ������ � /kick.\n������ �� ������������ � /kick.\n���� ���������� - /jail �� 120 �� 180 �����.')
        imgui.Text(u8'����������� ������� � ������:\n���� � ��� � /mute �� 10 �� 30 �����.\n���� �������� � ������ � /mute �� 30 �� 60 �����.\n���� � /mute �� 10 �� 30 �����.\nCaps Lock � /mute �� 10 �� 30 �����.\n����������� ������� � /mute �� 10 �� 30 �����.\n������ � ������ � /mute �� 10 �� 30 �����.\n����� ������������� ������� � /mute �� 120 �� 180 �����, /ban �� 5 �� 30 ����, ������ ������ �������.\n����� ������������� ������� �� ������ � /ban �� 5 �� 30 ����, ������ ������ �������.\n����������� ������������� �� ������ � /ban �� 5 �� 30 ����, ������ ������ �������.\n������ ���� �� �������������� � /mute �� 30 ����� �� 120 (� ����������� �� ��������).\n���������� ������ � /mute �� 60 �� 180 �����.\n�����������/�������������� ��������� ������ � /ban 30 ����, �������� �������� (������� � ����� ������� ������)/������ ������ �������.\n���������� ������, ������, �������, ����������� � ���-����� � /mute 180 �����, /ban 30 ����, �������� ��������/������ ������ ������� (� ����������� �� ���-�����).\n������� ������ ������ � /ban 30 ����, �������� �������� � ���������� � ������ ������ ������� �� ����������� ����.\n�����������, �������������� ��������� � ������� ������������� � /mute �� 90 �� 180 �����, /ban �� 1 �� 30 ����, �������� �������� � ���������� � ������ ������ ������� (� ����������� �� ��������).\n����������� � ������-�������� � /ban ��������� �������� �� 15 �� 30 ���� (������-������� ���������).\n������� ������ � ������� ������������� � /mute 180 �����, /ban �� 1 �� 30 ����, �������� �������� � ���������� � ������ ������ ������� (� ����������� �� ��������).\n����������� � ���-����� � ������� ����� ���-�����, /sban �� 15-30 ����, �������� ��������/������ ������ �������.\n������ ��������������� ����� � /ban �� 30 ���� (������: ����� �*����, ��� �*����, ������� �*����, ����� �*���� � ���� ��������), ������ ������ �������. ��� ���� - /mute 180 �����.\n����������� �������/������� � /mute 180 ����� /cban �� 1 �� 30 ����, �������� ��������/������ ������ �������.')
        imgui.Text(u8'DeathMatch � ������:\nDriveBy � /kick, /jail �� 15 �� 60 ����� (���� ���� ����� ������� ���� ��������� �� ������ ������, ��� �� �������� DriveBy).\nSpawnKill � /jail �� 30 �� 120 �����.\nTeamKill � /jail �� 30 �� 120 �����.')
        imgui.Text(u8'AFK with out ESC:\nAFK ��� ESC (�������� PAYDAY) � /kick.\nAFK � ��� � /jail �� 30 �� 90 �����.')
        imgui.Text(u8'�������:\n������ � /jail �� 30 �� 120 �����.\n������ �� ������ � /ban �� 30 ���� (����� ���� ����� ��������� �������).\n������ �� ����������� (�������� � �����) � /kick.\n������ � ������� (����� ������� �� ������������ ������, ����� ���� �������� ������� /shift + ������) � /jail �� 30 �� 90.\n������������� �������� �� +C � /ban �� 5 �� 7 ����.')
        imgui.Text(u8'������ �������:\n����� ��������� �������� � /ban �� ������, /ban �� ������� �� 1 �� 30 ����, ������ ������ �������.\n������� ������� ������ �� ����� � /ban 30 ����, ��������� ���� ����� � ����� ���������.\n������� ������� ������ �� ����� � ������ ����������.\n�������/�������/�������� �������� ��������� �������� � �������� ��������� ��������, ������ ������ �������.')
        imgui.Text(u8'������������� ����������� ��������:\nSpeedHack � /ban �� 10 (� ������, ���� ����� ������ ����� �������, ����� ������ /ban �� 20 �� 30 ����).\n�������� � /ban �� 10 ����.\n����� � /ban �� 10 �� 20 ����.\n������������ � /ban �� 10 �� 15 ����.\nGodMode � /cban �� 30 ����.\nGodMode car � /ban �� 10 �� 20 ����.\nAim � /cban �� 20 �� 30.\nWallHack � /ban �� 10 �� 20 ����.\nSobeit � /cban �� 20 ���� (� ������, ���� ����� ������ ����� �������, ����� ������ /ban 30 ����).\n������ � /cban �� 30 ����, �������� ��������.\nSpider (������) � /ban �� 3 ���.\nSpreed � /ban 15 ����.\nDgun � /cban �� 20 �� 30 ����.\nAirBrake � /ban �� 10 �� 20 ����.\nAntistun � /ban �� 10 �� 15 ����.\nCleo Slap � /ban �� 3 �� 10 ���� (�������� 10 ���� � ������ ����, ���� ����� ��������� ��� ��� ��������� ������������ ������).\nCleo +C � /ban �� 15 ����.\nExtra WS � /ban �� 10 ����.\n����������� � ����� � /ban �� 5 ����.\nCamHack � /ban �� 3 ��� (����� ������������ � ��������� ������� �������������).\n�����-����� � /ban �� 3 ���.\nCleo Fake Chat � /ban 10 ����, �������� �������� � ���������� � ������ ������ �������, ��� �� ������� � ������ ��������.\nCleo �������� � �� ����������, ���� �� ����� ������������, /ban �� 3 ���.\nCleo Fake Death � /ban �� 5 ����, /ban �� 30 ���� (� ������ �������� � ���������� � ������ ������ �������).\nCleo Spawn Vehicle � /ban 5 ����.\nCleo Crashes.asi � v.2.51 ��������. ����� ������ ������ - /ban 5 ����.\nSandboxie (���������) � /ban 30 ����.\nAnti-AFK � /ban 5 ����.\n����� ������ (B1-6) - /ban �� 10 �� 15 ����.')
        imgui.End()
    end
---------------------------------------------------------------
  if ban_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� ���������� ������� | Alonso_Whittaker", ban_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"������������", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 15 ��������")
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
  
            if imgui.Button(u8"������ ", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 ������.")
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

            if imgui.Button(u8"�����", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 20 �����.")
            end

            if imgui.Button(u8"��������", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 10 ��������.")
            end

            if imgui.Button(u8"Cleo ��������", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 3 Cleo ��������.")
            end
  
            if imgui.Button(u8"����������� ���������", imgui.ImVec2(334, 25)) then
                sampSendChat("/ban "..banId.." 30 ����������� ���������")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if mute_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� ���������� ���� ������ | Alonso_Whittaker", mute_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"���������� ���������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 180 ���������� ���������.")
            end

            if imgui.Button(u8"����������� ������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/mute "..banId.. " 30 ����������� ������.")
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
    imgui.Begin(u8"���� �������� ������ � ������ | Alonso_Whittaker", prison_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"DriveBy", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 DriveBy.")
            end

            if imgui.Button(u8"SpawnKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 SpawnKill.")
            end

            if imgui.Button(u8"TeamKill ", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 TeamKill.")
            end

            if imgui.Button(u8"���� ����������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 120 ���� ����������.")
            end

            if imgui.Button(u8"AFK � ���", imgui.ImVec2(334, 25)) then
        		sampSendChat("/jail "..banId.. " 30 AFK � ���.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if guns_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.3), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� ������ | Alonso_Whittaker", guns_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"�������� ������ ���", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 24 999")
            end

            if imgui.Button(u8"M4", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 31 999")
            end

            if imgui.Button(u8"������� ��������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 25 999")
            end

            if imgui.Button(u8"���������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 9 999")
            end

            if imgui.Button(u8"��-47", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 30 999")
            end

            if imgui.Button(u8"�������������� ��������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 27 999")
            end

            if imgui.Button(u8"��������������� ������ HS", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 36 999")
            end

            if imgui.Button(u8"�������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 37 999")
            end

            if imgui.Button(u8"�������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 38 999")
            end

            if imgui.Button(u8"�����", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 26 999")
            end

            if imgui.Button(u8"���", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 28 999")
            end

            if imgui.Button(u8"MP5", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 29 999")
            end

            if imgui.Button(u8"����������� ��������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/givegun " .. banId .. " 34 999")
            end

      imgui.End()
      end

---------------------------------------------------------------
  if p_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 210), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� �������� ������ | Alonso_Whittaker", p_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"����� �� ��������� �������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " ����� �������� �� ����� ������.")
            end

            if imgui.Button(u8"��������� �� ����������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " ��������� �� ����������.")
            end

            if imgui.Button(u8"����� ��� �������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " �����, �� ����� ������ ��� �������.")
            end

            if imgui.Button(u8"����� ����� � AFK", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " �����, ��������� � ����� ������ ����� � AFK.")
            end

            if imgui.Button(u8"����� ����� �� ����", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " �����, ��������� � ����� ������ ����� �� ����.")
            end

            if imgui.Button(u8"������ ������ �� ��������������", imgui.ImVec2(334, 25)) then
        		sampSendChat("/pm " .. banId .. " ������ ������ �� �������������� �� ����� �������.")
            end

      imgui.End()
      end
---------------------------------------------------------------
  if nakm_menu.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 400), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� ��������� ��� ��.��� | Alonso_Whittaker", nakm_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

            if imgui.Button(u8"��������� ������������� �� Aim", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 Aim.")
            end

            if imgui.Button(u8"��������� ������������� �� ������������", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 ��������")
            end

            if imgui.Button(u8"��������� ������������� �� AirBrake", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 AirBraker")
            end
  
            if imgui.Button(u8"��������� ������������� �� GodMode", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 GodMode")
            end
  
            if imgui.Button(u8"��������� ������������� �� Sobeit", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 Sobeit.")
            end
  
            if imgui.Button(u8"��������� ������������� �� ������ ", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 ������.")
            end
  			
            if imgui.Button(u8"��������� ������������� �� Extra WS", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 Extra WS.")
            end

            if imgui.Button(u8"��������� ������������� �� �����", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 20 �����.")
            end

            if imgui.Button(u8"��������� ������������� �� ��������", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 10 ��������.")
            end

            if imgui.Button(u8"��������� ������������� �� Cleo ��������", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 3 Cleo ��������.")
            end

            if imgui.Button(u8"��������� ������������� �� Auto +C", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Auto +C.")
            end
  
            if imgui.Button(u8"��������� ������������� �� Spreed", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 15 Spreed.")
            end
  
            if imgui.Button(u8"����������� ���������", imgui.ImVec2(334, 25)) then
                sampSendChat("/a /ban "..banId.." 30 ����������� ���������")
            end

      imgui.End()
      end
---------------------------------------------------------------
if atp_menu.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 120), imgui.Cond.FirstUseEver)
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"������ ��������� | Alonso_Whittaker", atp_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

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
    imgui.Begin(u8"������� � ������� Admin Tools`a | Alonso_Whittaker", help_menu, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

      imgui.Text(u8"������� Admin Tools`a v.0.1")

    imgui.Text(u8"�������: /p [player id]- ����������� �������� ������")
    imgui.Text(u8"�������: /m [player id]- ������ �������������� � �������.")
    imgui.Text(u8"�������: /th - ����� ���������� ������� ��������� ��� �������.")
    imgui.Text(u8"�������: /bm [player id]- ������ ���������� ������ � ���.")
    imgui.Text(u8"�������: /mtm [player id]- ������ ��������� ��� � ������.")
    imgui.Text(u8"�������: /jm [player id]- ������ ���������� ������ � ������.")
    imgui.Text(u8"�������: /acmd - ���������� ��� ������� Admin Tools`a.")
    imgui.Text(u8"�������: /mnak - ���� ��������� ��� ��.�������������.")

      imgui.Text(u8"������� Admin Tools`a v.0.2")

    imgui.Text(u8"�������: /ajail [id] - �������� ������ � ������ �� AIM")
    imgui.Text(u8"�������: /fjail [id] - ��������� �������� ������ �� AIM.")
    imgui.Text(u8"�������: /faim [id] - ��������� �������� ������ �� AIM.")
    imgui.Text(u8"�������: /aim [id] - �������� ������ �� AIM.")
    imgui.Text(u8"�������: /saim [id] - ������������� ������� ������ � IP. (��� 5 ���)")
    imgui.Text(u8"�������: /or [id] - �������� ������ �� ����������� ���������.")
    imgui.Text(u8"�������: /stan [id] - �������� ������ �� Antistun.")
    imgui.Text(u8"�������: /+c [id] - �������� ������ �� ���� +�.")
    imgui.Text(u8"�������: /up [id] - ���� ��� ������ �� ���������� ���������.")
    imgui.Text(u8"�������: /osk [id] - ���� ��� ������ �� ����������� ������.")
    imgui.Text(u8"�������: /flood [id] - ���� ��� ������ �� ����.")
    imgui.Text(u8"�������: /caps [id] - ���� ��� ������ �� ����.")
    imgui.Text(u8"����:")
    imgui.Text(u8"AirBrake: ��������� | �����������: ������ Shift.")
    imgui.End()
  end
---------------------------------------------------------------
  if pm_report.v then
    imgui.SetNextWindowSize(imgui.ImVec2(350, 265), imgui.Cond.FirstUseEver)
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8"���� �������������� | Alonso_Whittaker", pm_report, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(u8"������������� ������", imgui.ImVec2(334, 25)) then
            ban_menu.v = not ban_menu.v
          end

          if imgui.Button(u8"������������� ��� ������", imgui.ImVec2(334, 25)) then
            mute_menu.v = not mute_menu.v
          end

          if imgui.Button(u8"��������� � ������ ������", imgui.ImVec2(334, 25)) then
            prison_menu.v = not prison_menu.v
          end

          if imgui.Button(u8"������ ������ ������", imgui.ImVec2(334, 25)) then
            guns_menu.v = not guns_menu.v
          end

          if imgui.Button(u8"���� ����� ������", imgui.ImVec2(334, 25)) then
            sampSendChat("/slap "..banId)
          end

          if imgui.Button(u8"��������� ������ �� ����� ������", imgui.ImVec2(334, 25)) then
            sampSendChat("/spawn "..banId)
          end

          if imgui.Button(u8"��������������� ������ � ����", imgui.ImVec2(334, 25)) then
            sampSendChat("/tpks "..banId)
          end

          if imgui.Button(u8"����������������� � ����", imgui.ImVec2(334, 25)) then
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