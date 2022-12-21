local id, e = ...
local addName= e.onlyChinse and '战场' or BATTLEFIELDS
local Save={ReMe}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function set_ReMe_Texture()--设置图标
    
end

local function set_ReMe()--释放, 复活
    if not Save.ReMe or not (C_PvP.IsBattleground() or C_PvP.IsArena()) then
        return
    end
    RepopMe()--死后将你的幽灵释放到墓地。
    RetrieveCorpse()--当玩家站在它的尸体附近时复活。
    AcceptAreaSpiritHeal()--在范围内时在战场上注册灵魂治疗师的复活计时器
end
--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type then

    else
        info={
            text=id
        }
        UIDropDownMenu_AddButton(info, level)
        --UIDropDownMenu_AddSeparator(level)
    end
end
--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel.texture:SetTexture('Interface\\PVPFrame\\RandomPVPIcon')
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

--panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:RegisterEvent('PLAYER_DEAD')
panel:RegisterEvent('AREA_SPIRIT_HEALER_IN_RANGE')
panel:RegisterEvent('CORPSE_IN_RANGE')

panel:RegisterEvent('PVP_MATCH_COMPLETE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    --elseif event=='PLAYER_ENTERING_WORLD' then
    elseif event=='CORPSE_IN_RANGE' or event=='PLAYER_DEAD' or event=='AREA_SPIRIT_HEALER_IN_RANGE' then--释放, 复活
        set_ReMe()

    elseif event=='PVP_MATCH_COMPLETE' then--离开战 

    end
end)