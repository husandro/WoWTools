if GetItemCount(8529)==0 then--没有时,不加载
    return
end

local id , e = ...
local addName='NoggenfoggerElixir'
local Save={
    aura={
        [16591]=false,--变骷髅
        [16595]=false,--变小
        [16593]=true,
    }
}
local panel=e.Cbtn2(nil, e.toolsFrame, true)
panel.itemID=8529

local function setAura()--光环取消
    for i = 1, 40 do
        local spellID = select(10, UnitBuff('player', i))--, 'CANCELABLE'))
        if not spellID then
            break
        elseif Save.aura[spellID] then
            CancelUnitBuff("player", i)--, 'CANCELABLE')
            print(id, CANCEL, AURAS, GetSpellLink(spellID) or spellID)
            break
        end
    end
end

local function setCount()--设置数量
    local num = GetItemCount(panel.itemID,nil,true,true)
    if num~=1 and not panel.count then
        panel.count=e.Cstr(panel,10,nil,nil,true)
        panel.count:SetPoint('BOTTOMRIGHT',-2, 9)
    end
    if panel.count then
        panel.count:SetText(num~=1 and num or '')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level)--主菜单
    for spellID, type in pairs(Save.aura) do
        local name, _, icon = GetSpellInfo(spellID)
        name= name or AURAS..' '..spellID
        local info={
            text=name,
            icon=icon,
            checked= type,
            func=function()
                Save.aura[spellID] = not type and true or false
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end
--####
--初始
--####
local function Init()
    e.ToolsSetButtonPoint(panel)--设置位置
    --panel.texture:SetShown(true)
    panel:SetAttribute('type','item')
    panel:SetAttribute('item',GetItemInfo(panel.itemID) or panel.itemID)
    panel.texture:SetTexture(C_Item.GetItemIconByID(panel.itemID..''))
    setCount()--设置数量
    setAura()--光环取消

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(panel.itemID)
        e.tips:AddLine(' ')
        for spellID, type in pairs(Save.aura) do
            local name, _, icon = GetSpellInfo(spellID)
            name= name or (AURAS..' ID'..spellID)
            name= (icon and '|T'..icon..':0|t' or '')..name
            e.tips:AddDoubleLine(name, type and	'|cnGREEN_FONT_COLOR:'..CANCEL..'|r' or '...')
        end
        e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
        e.tips:Show()
    end)
    panel:SetScript('OnLeave', function() e.tips:Hide() end)
    panel:SetScript('OnMouseWheel', function(self, d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
   end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent("PLAYER_REGEN_ENABLED")
panel:RegisterEvent("PLAYER_REGEN_DISABLED")
panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterUnitEvent("UNIT_AURA", 'player')
panel:RegisterEvent('BAG_UPDATE_COOLDOWN')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.7, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel:RegisterUnitEvent("UNIT_AURA", 'player')
        if panel.combat then
            Init()
            panel.combat=nil
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        panel:UnregisterEvent('UNIT_AURA')

    elseif event=='BAG_UPDATE_DELAYED' then
        setCount()--设置数量

    elseif event=='UNIT_AURA' then
        setAura()--光环取消

    elseif event=='BAG_UPDATE_COOLDOWN' then
        local startTime, duration = GetItemCooldown(self.itemID)
        e.Ccool(self,startTime, duration,nil, true)        
    end
end)