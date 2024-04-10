if C_Item.GetItemCount(8529)==0 then--没有时,不加载
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
local button--button.itemID=8529
local panel= CreateFrame("Frame")

local function setAura()--光环取消
    if UnitAffectingCombat('player') then
        return
    end
    for i = 1, 40 do
        local spellID = select(10, UnitBuff('player', i))--, 'CANCELABLE'))
        if not spellID then
            break
        elseif Save.aura[spellID] then
            CancelUnitBuff("player", i, nil)-- 'CANCELABLE')
            print(id, e.onlyChinese '取消光环' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CANCEL, AURAS), GetSpellLink(spellID) or spellID)
            break
        end
    end
end

local function setCount()--设置数量
    local num = C_Item.GetItemCount(button.itemID, false, true, true)
    if num~=1 and not button.count then
        button.count=e.Cstr(button, {size=10, color=true})--10,nil,nil,true)
        button.count:SetPoint('TOPRIGHT',-2,-2)
    end
    if button.count then
        button.count:SetText(num~=1 and num or '')
    end
end


--######
--快捷键
--######
local function set_KEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(button, true, Save.KEY)
        if #Save.KEY==1 then
            if not button.KEY then
                button.KEYstring=e.Cstr(button, {size=10, color=true})--10, nil, nil, true, 'OVERLAY')
                button.KEYstring:SetPoint('BOTTOMRIGHT', button.border, 'BOTTOMRIGHT',-4,4)
            end
            button.KEYstring:SetText(Save.KEY)
            if button.KEYtexture then
                button.KEYtexture:SetShown(false)
            end
        else
            if not button.KEYtexture then
                button.KEYtexture=button:CreateTexture(nil,'OVERLAY')
                button.KEYtexture:SetPoint('BOTTOM', button.border,'BOTTOM',-1,-5)
                button.KEYtexture:SetAtlas('NPE_ArrowDown')
                if not e.Player.useColor then
                    button.KEYtexture:SetDesaturated(true)
                end
                button.KEYtexture:SetSize(20,15)
            end
            button.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(button)
        if button.KEYstring then
            button.KEYstring:SetText('')
        end
        if button.KEYtexture then
            button.KEYtexture:SetShown(false)
        end
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level)--主菜单
    for spellID, type in pairs(Save.aura) do
        local name, _, icon = GetSpellInfo(spellID)
        name= name or (e.onlyChinese and '光环' or AURAS)..' '..spellID
        local info={
            text=name,
            icon=icon,
            checked= type,
            tooltipOnButton=true,
            keepShownOnClick=true,
            tooltipTitle=  e.onlyChinese and '脱离战斗' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT,
            func=function()
                Save.aura[spellID] = not type and true or false
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    local info={--快捷键,设置对话框
        text= e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
        checked=Save.KEY and true or nil,
        disabled=UnitAffectingCombat('player'),
        keepShownOnClick=true,
        func=function()
            StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
                text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=1,
                button1=SETTINGS,
                button2=CANCEL,
                button3=REMOVE,
                OnShow = function(self2, data)
                    self2.editBox:SetText(Save.KEY or ';')
                    if Save.KEY then
                        self2.button1:SetText(SLASH_CHAT_MODERATE2:gsub('/', ''))--修该
                    end
                    self2.button3:SetEnabled(Save.KEY)
                end,
                OnHide= function(self2)
                    self2.editBox:SetText("")
                    e.call('ChatEdit_FocusActiveWindow')
                end,
                OnAccept = function(self2, data)
                    local text= self2.editBox:GetText()
                    text=text:gsub(' ','')
                    text=text:gsub('%[','')
                    text=text:gsub(']','')
                    text=text:upper()
                    Save.KEY=text
                    set_KEY()--设置捷键
                end,
                OnAlt = function()
                    Save.KEY=nil
                    set_KEY()--设置捷键
                end,
                EditBoxOnTextChanged=function(self2, data)
                    local text= self2:GetText()
                    text=text:gsub(' ','')
                    self2:GetParent().button1:SetEnabled(text~='')
                end,
                EditBoxOnEscapePressed = function(s)
                    s:SetAutoFocus(false)
                    s:ClearFocus()
                    s:GetParent():Hide()
                end,
            }
            StaticPopup_Show(id..addName..'KEY')
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end


--####
--初始
--####
local function Init()
    e.ToolsSetButtonPoint(button)--设置位置
    
    button:SetAttribute('type','item')
    button:SetAttribute('item', C_Item.GetItemInfo(button.itemID) or button.itemID)
    button.texture:SetTexture(C_Item.GetItemIconByID(button.itemID..''))

    setCount()--设置数量
    setAura()--光环取消   

    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(button.itemID)
        e.tips:AddLine(' ')
        for spellID, type in pairs(Save.aura) do
            local name, _, icon = GetSpellInfo(spellID)
            name= name or (AURAS..' ID'..spellID)
            name= (icon and '|T'..icon..':0|t' or '')..name
            e.tips:AddDoubleLine(name, type and	'|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r' or '...')
        end
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.mid)
        e.tips:Show()
    end)
    button:SetScript('OnLeave', GameTooltip_Hide)
    button:SetScript('OnMouseWheel', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
   end)

   if Save.KEY then set_KEY() end--设置捷键
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                button= e.Cbtn2({
                    name= id..e.cn(addName),
                    parent= e.toolsFrame,
                    click=true,-- right left
                    notSecureActionButton=nil,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                button.itemID=8529

                panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                panel:RegisterEvent("PLAYER_REGEN_DISABLED")
                panel:RegisterEvent('BAG_UPDATE_DELAYED')
                panel:RegisterUnitEvent("UNIT_AURA", 'player')
                panel:RegisterEvent('BAG_UPDATE_COOLDOWN')
                panel:RegisterEvent('PLAYER_LOGOUT')

                C_Timer.After(2.5, function()
                    if UnitAffectingCombat('player') then
                        panel.combat= true
                    else
                        Init()--初始
                    end
                end)
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
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
        e.SetItemSpellCool({frame=button, item=button.itemID})
    end
end)