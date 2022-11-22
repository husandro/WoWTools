local id, e = ...
local addName= COMBAT..TIME_LABEL:gsub(':','')
local Save= {Say=120, insTime=true, insKill=true, insDead=true, col=true}
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

local OnLineTime=GetTime()

local function getTime(value, chat, time)
    time= time or GetTime()
    time= time < value and time + 86400 or time
    time= time - value;
    if chat or not Save.Type then 
        return SecondsToClock(time):gsub('：',':'), time;
    else
        return SecondsToTime(time), time;
    end
end

local function setTexture()--设置,图标
    local specializationID=GetSpecialization()--当前专精
    if specializationID then
        local texture = select(4, GetSpecializationInfo(specializationID))
        if texture then
            panel.texture:SetTexture(texture)
            return
        end
    end
    panel.texture:SetAtlas('Mobile-MechanicIcon-Powerful')
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type then
    else
        info={--在线时间
            text=GUILD_ONLINE_LABEL..e.Icon.clock2..TIME_LABEL..' '..getTime(OnLineTime),
            isTitle=true,
            notCheckable=true
        }
    end
end
--####
--初始
--####
local function Init()
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    end

    panel.texture2=panel:CreateTexture(nil, 'OVERLAY')
    panel.texture2:SetAllPoints(panel)
    panel.texture2:AddMaskTexture(panel.mask)
    local r,g,b=GetClassColor(UnitClassBase('player'))
    panel.texture2:SetColorTexture(r,g,b)
    panel.texture2:SetShown(false)

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    C_Timer.After(2, function()
        setTexture()--设置,图标
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        if Save.disabled then
            self:SetShown(false)
            panel:UnregisterAllEvents()
        else
           Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel.texture2:SetShown(false)

    elseif event=='PLAYER_REGEN_DISABLED' then
        panel.texture2:SetShown(true)

    elseif event=='PLAYER_SPECIALIZATION_CHANGED' then
        setTexture()--设置,图标

    elseif event=='PLAYER_ENTERING_WORLD' then

    end
end)

