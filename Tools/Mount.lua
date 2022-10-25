local id, e = ...
local Save={Shift={}, Alt={}, Ctrl={}}
local addName=MOUNT
local panel=CreateFrame("Frame")

--Blizzard_MountCollection.lua
local function setMountJournal_InitMountButton(button, elementData)
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    if not button or not button.spellID or Save.disabled then
        return
    end
    local text=''
    if Save.Shift[button.spellID] then
        text='Shift'
    end
    if Save.Ctrl[button.spellID] then
        text=text~='' and text..'\n' or ''
        text=text..'Ctrl'
    end
    if Save.Alt[button.spellID] then
        text=text~='' and text..'\n' or ''
        text=text..'Alt'
    end
    if text~='' and not button.text then
        button.text=e.Cstr(button, 12,button.name,nil,nil,nil,'RIGHT')--self, size, fontType, ChangeFont, color, layer, justifyH)
        button.text:SetPoint('RIGHT')
        button.text:SetFontObject('GameFontNormal')
        button.text:SetAlpha(0.3)
    end
    if button.text then
        button.text:SetText(text)
    end
end


local function setMountJournal_ShowMountDropdown(index, anchorTo)
    if not index and Save.disabled then
        return
    end
    UIDropDownMenu_AddSeparator()
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(index)
    local tab={'Shift', 'Ctrl', 'Alt'}
    for _, type in pairs(tab) do
        local info={}
        info.text=SETTINGS..' '..type..'+'..e.Icon.left
        info.checked=Save[type][spellID] and true or false
        info.func=function()
            if Save[type][spellID] then
                Save[type][spellID]=nil
            else
                Save[type][spellID]=true
            end
            local spellLink=GetSpellLink(spellID)
            print(id, addName, 'Shift + '..e.Icon.left, Save[type][spellID] and '|cnGREEN_FONT_COLOR:'..ADD..'|r' or '|cnRED_FONT_COLOR:'..REMOVE..'|r', spellLink)
        end
        info.tooltipOnButton=true
        info.tooltipTitle=id
        info.tooltipText=addName
        UIDropDownMenu_AddButton(info, level);
    end
end

--###########
--加载保存数据
--###########
panel=CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
--[[            local check=e.CPanel(addName, not Save.disabled, true)
            check:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(id, addName, e.GetEnabeleDisable(not Save.disabled))
        end)]]
    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('MountJournal_InitMountButton',setMountJournal_InitMountButton)
        hooksecurefunc('MountJournal_ShowMountDropdown',setMountJournal_ShowMountDropdown)
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)

local function setShitMenu(type)
    local tabList= type=='Shift' and Save.Shift or type=='Ctrl' and Save.Ctrl or Save.Alt
    local tab={}
    for spellID, _ in pairs(tabList) do
        local info={}
        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        local name, _, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        info.text=name..(not isActive and e.Icon.O2 or '')
        info.icon=icon
        info.checked=true
        info.func=function()
            if Save[type][spellID] then
                Save[type][spellID]=nil
            else
                Save[type][spellID]=true
            end
            local spellLink=GetSpellLink(spellID)
            print(id, addName, 'Shift', Save[type][spellID] and '|cnGREEN_FONT_COLOR:'..ADD..'|r' or '|cnRED_FONT_COLOR:'..REMOVE..'|r', spellLink)
        end
        table.insert(tab, info)
        --UIDropDownMenu_AddButton(info, level);
    end
    return tab
end

local function setSettingMenu(index, level, menuList)
    UIDropDownMenu_AddSeparator()
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(index)
    local tab={'Shift', 'Ctrl', 'Alt'}
    for _, type in pairs(tab) do
        local info={}
        info.text=type
        info.checked=Save[type][spellID] and true or false
        info.func=function()
            if Save[type][spellID] then
                Save[type][spellID]=nil
            else
                Save[type][spellID]=true
            end
            local spellLink=GetSpellLink(spellID)
            print(id, addName, 'Shift', Save[type][spellID] and '|cnGREEN_FONT_COLOR:'..ADD..'|r' or '|cnRED_FONT_COLOR:'..REMOVE..'|r', spellLink)
        end
        info.tooltipOnButton=true
        info.tooltipTitle=id
        info.tooltipText=addName
        info.hasArrow=true
        --info.menuList=setShitMenu(type)
        UIDropDownMenu_AddButton(info, level);
    end
end