

local Save={
    aura={
        [16591]=false,--变骷髅
        [16595]=false,--变小
        [16593]=true,
    }
}

local addName
local button
local ItemID= 8529
local ItemName
if LOCALE_zhCN then
    ItemName= '诺格弗格药剂'
elseif LOCALE_zhTW then
    ItemName= '諾格弗格藥劑'
elseif LOCALE_koKR then
    ItemName= '노겐포저의 비약'
elseif LOCALE_frFR then
    ItemName= 'Élixir Brouillecaboche'
elseif LOCALE_deDE then
    ItemName= 'Noggenfoggers Elixier'
elseif LOCALE_esES or LOCALE_esMX then--西班牙语
    ItemName= 'Elixir de Tragonublo'
elseif LOCALE_ruRU then
    ItemName= 'Эликсир Гогельмогеля'
elseif LOCALE_ptBR then--葡萄牙语    
    ItemName= 'Elixir Nublacuca'
elseif LOCALE_itIT then
    ItemName= 'Elisir di Granstrippo'
else
    ItemName= 'Noggenfogger Elixir'
end









local function Set_Aura()--光环取消
    if UnitAffectingCombat('player') then
        return
    end
    for i = 1, 255 do
        local data=C_UnitAuras.GetAuraDataByIndex('player', i, 'HELPFUL')
        if data then
            if Save.aura[data.spellId] then
                CancelUnitBuff("player", i, nil)-- 'CANCELABLE')
                print(addName,
                    WoWTools_Mixin.onlyChinese and '取消光环' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CANCEL, AURAS),
                    WoWTools_SpellMixin:GetLink(data.spellId, true)
                )
                break
            end
        else
            break
        end
    end
end






local function setCount()--设置数量
    local num = C_Item.GetItemCount(ItemID, false, true, true, false) or 0
    button.count:SetText(num~=1 and num or '')
    button.texture:SetDesaturated(num==0)
end




























local function Init_Menu(self, root)
    local sub
    sub=root:CreateTitle(WoWTools_Mixin.onlyChinese and '取消光环' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CANCEL, AURAS))
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '仅限脱战' or format(LFG_LIST_CROSS_FACTION, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT))
    end)
    for spellID in pairs(Save.aura) do
        sub=root:CreateCheckbox(
            WoWTools_SpellMixin:GetName(spellID),
        function(data)
            return Save.aura[data.spellID]
        end, function(data)
            Save.aura[data.spellID]= not Save.aura[data.spellID] and true or false
            Set_Aura()
        end, {spellID=spellID})
        WoWTools_SetTooltipMixin:Set_Menu(sub)
    end

    root:CreateDivider()
    WoWTools_KeyMixin:SetMenu(self, root, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=addName,
        key=Save.KEY,
        GetKey=function(key)
            Save.KEY=key
            WoWTools_KeyMixin:Setup(button)--设置捷键
        end,
        OnAlt=function()
            Save.KEY=nil
            WoWTools_KeyMixin:Setup(button)--设置捷键
        end,
    })

--选项
    WoWTools_ToolsMixin:OpenMenu(root, addName)
end











local function Init()
    WoWTools_KeyMixin:Init(button, function() return Save.KEY end)

    button:SetAttribute('type1','item')
    button:SetAttribute('item1', C_Item.GetItemNameByID(ItemID) or ItemName or ItemID)

    button.texture:SetTexture(C_Item.GetItemIconByID(ItemID) or 134863)
    button.count=WoWTools_LabelMixin:Create(button, {size=12, color={r=1,g=1,b=1}})--10,nil,nil,true)
    button.count:SetPoint('BOTTOMRIGHT')

    setCount()--设置数量
    Set_Aura()--光环取消   

    button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetItemByID(ItemID)
        GameTooltip:AddLine(' ')
        for spellID, type in pairs(Save.aura) do
            GameTooltip:AddDoubleLine( WoWTools_SpellMixin:GetLink(spellID, true), type and	'|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '取消' or CANCEL)..'|r' or '...')
        end
        GameTooltip:AddLine(' ')
        local key= WoWTools_KeyMixin:IsKeyValid(self)
        if key then
            GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL), '|cnGREEN_FONT_COLOR:'..key)
        end

        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        WoWTools_KeyMixin:SetTexture(self)
    end)


    button:SetScript('OnLeave', GameTooltip_Hide)
    button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


end





























--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            --[[print(C_Item.GetItemCount(ItemID))
            if (C_Item.GetItemCount(ItemID)==0) then--没有时,不加载
                self:UnregisterEvent('ADDON_LOADED')
                return
            end]]



            addName= '|T134863:0|t'..(WoWTools_Mixin.onlyChinese and '诺格弗格药剂' or ItemName)

            Save= WoWToolsSave['NoggenfoggerElixir'] or Save
            button= WoWTools_ToolsMixin:CreateButton({
                name='NoggenfoggerElixir',
                tooltip=addName,
            })

            if button then
                ItemName= C_Item.GetItemNameByID(ItemID) or ItemName

                self:RegisterEvent("PLAYER_REGEN_ENABLED")
                self:RegisterEvent("PLAYER_REGEN_DISABLED")
                self:RegisterEvent('BAG_UPDATE_DELAYED')
                self:RegisterUnitEvent("UNIT_AURA", 'player')
                self:RegisterEvent('BAG_UPDATE_COOLDOWN')


                Init()--初始
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['NoggenfoggerElixir']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        self:RegisterUnitEvent("UNIT_AURA", 'player')


    elseif event=='PLAYER_REGEN_DISABLED' then
        self:UnregisterEvent('UNIT_AURA')

    elseif event=='BAG_UPDATE_DELAYED' then
        setCount()--设置数量

    elseif event=='UNIT_AURA' then
        Set_Aura()--光环取消

    elseif event=='BAG_UPDATE_COOLDOWN' then
        WoWTools_CooldownMixin:SetFrame(button, {item=ItemID})
    end
end)