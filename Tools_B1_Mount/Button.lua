
local function Save()
    return WoWToolsSave['Tools_Mounts']
end

local function set_ShiJI()--召唤司机 代驾型机械路霸
    ShiJI= WoWTools_DataMixin.Player.Faction=='Horde' and 179244 or (WoWTools_DataMixin.Player.Faction=='Alliance' and 179245) or nil--"Alliance", "Horde", "Neutral"
end






--local ITEMS= ITEMS
--local SPELLS= SPELLS
--local FLOOR= FLOOR
--local MOUNT_JOURNAL_FILTER_GROUND= MOUNT_JOURNAL_FILTER_GROUND
--local MOUNT_JOURNAL_FILTER_FLYING= MOUNT_JOURNAL_FILTER_FLYING
--local MOUNT_JOURNAL_FILTER_AQUATIC= MOUNT_JOURNAL_FILTER_AQUATIC
--local MOUNT_JOURNAL_FILTER_DRAGONRIDING= MOUNT_JOURNAL_FILTER_DRAGONRIDING



local ShiJI
local XD
local MountTab={}


local MountType={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    'Shift', 'Alt', 'Ctrl',
    FLOOR,
}


local function XDInt()--德鲁伊设置
    XD=nil
    if WoWTools_DataMixin.Player.Class=='DRUID' then
        local ground=C_SpellBook.IsSpellInSpellBook(768) and 768
        local flying=C_SpellBook.IsSpellInSpellBook(783) and 783
        if ground then
            XD={
                [MOUNT_JOURNAL_FILTER_GROUND]= ground,
                [MOUNT_JOURNAL_FILTER_AQUATIC]= flying,
                [MOUNT_JOURNAL_FILTER_FLYING]= flying,
            }
        end
    end
end





local function checkSpell(self)--检测法术
    self.spellID2=nil
    if XD and XD[MOUNT_JOURNAL_FILTER_GROUND] then
        self.spellID2=XD[MOUNT_JOURNAL_FILTER_GROUND]
    else
        for spellID, _ in pairs(Save().Mounts[SPELLS]) do
            if C_SpellBook.IsSpellInSpellBook(spellID) then
                self.spellID2=spellID
                break
            end
        end
    end
end


local function checkItem(self)--检测物品
    self.itemID=nil
    for itemID in pairs(Save().Mounts[ITEMS]) do
        if C_Item.GetItemCount(itemID , false, true, true, false)>0 and C_PlayerInfo.CanUseItem(itemID) then
            self.itemID=itemID
            break
        end
    end
end




local function checkMount()--检测坐骑
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图
    for _, type in pairs(MountType) do
        if XD and XD[type] then
            MountTab[type]={XD[type]}


        --[[elseif index<=3 and not OkMount and ShiJI then
            MountTab[type]={ShiJI}]]

        else
            MountTab[type]= {}
            for spellID, tab in pairs(Save().Mounts[type] or {}) do
                spellID= (spellID==179244 or spellID==179245) and ShiJI or spellID
                local mountID = C_MountJournal.GetMountFromSpell(spellID)
                if mountID then
                    local isFactionSpecific, faction, shouldHideOnChar, isCollected= select(8, C_MountJournal.GetMountInfoByID(mountID))
                    if not shouldHideOnChar and isCollected and (not isFactionSpecific or faction==WoWTools_MountMixin.faction) then
                        if type==FLOOR then
                            if uiMapID and tab[uiMapID] and not XD then
                                table.insert(MountTab[type], spellID)
                            end
                        else
                            table.insert(MountTab[type], spellID)
                        end
                    end
                end
            end
        end
    end
end








local function getRandomRoll(type)--随机坐骑
    local tab=MountTab[type] or {}
    local num= #tab
    if num>0 then
        local index= math.random(1, num)

        if C_Spell.IsSpellUsable(tab[index]) and not select(2, C_MountJournal.GetMountUsabilityByID(tab[index], true)) then
            return tab[index]
        end

    end
end














local function setShiftCtrlAltAtt(self)--设置Shift Ctrl Alt 属性
    if not self:CanChangeAttribute() then
        self.Combat=true
        return
    end
    local tab={'Shift', 'Alt', 'Ctrl'}

    for _, type in pairs(tab) do
        self.textureModifier[type]=nil
        local spellID= MountTab[type] and MountTab[type][1]
        if spellID then
            local name= C_Spell.GetSpellName(spellID)
            local icon= C_Spell.GetSpellTexture(spellID)
            self:SetAttribute(type.."-spell1", name or spellID)
            self.textureModifier[type]=icon
            self.spellID=spellID
            --end
        end
    end
    self.Combat=nil
end


local function setTextrue(self)--设置图标
    local icon= self.iconAtt
    if IsMounted() then
        icon=136116
    elseif icon then
        local spellID= self.spellID or (self.itemID and select(2, C_Item.GetItemSpell(self.itemID)))
        if spellID then
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
            if aura and aura.spellId then
                icon=136116
            end
        end
    end
    self.texture:SetTexture(icon or 0)
    WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID, spellID=self.spellID})--设置冷却
end









local function setClickAtt(self)--设置 Click属性
    if not self:CanChangeAttribute() then
        self.Combat=true
        return
    end

    local isFlyableArea= IsFlyableArea()
    local isMoving= IsPlayerMoving()
    local isBat= UnitAffectingCombat('player')
    local spellID
    local isAdvancedFlyableArea = IsAdvancedFlyableArea()


    if XD then
        if IsSubmerged() then
            spellID= 783
        elseif isMoving or isBat then
            spellID= IsIndoors() and 768 or 783
        elseif isAdvancedFlyableArea then
            spellID= getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
        end
        spellID= spellID or (IsIndoors() and 768 or 783)

    elseif not self.itemID or not C_PlayerInfo.CanUseItem(self.itemID) then
        spellID= (IsIndoors() or isMoving or isBat) and self.spellID2
            or getRandomRoll(FLOOR)--区域
            or ((isAdvancedFlyableArea or C_Spell.IsSpellUsable(368896)) and-- [368896]=true,--[复苏始祖幼龙] 
                C_UnitAuras.GetAuraDataBySpellName('player', C_Spell.GetSpellName(404468), 'HELPFUL')--404468/飞行模式：稳定
                    and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING)
                    or getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
                )
            or (IsSubmerged() and getRandomRoll(MOUNT_JOURNAL_FILTER_AQUATIC))--水平中
            or (isFlyableArea and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING))--飞行区域
            or (IsOutdoors() and getRandomRoll(MOUNT_JOURNAL_FILTER_GROUND))--室内
            or self.spellID
            or ShiJI
    end


    local name, icon
    if spellID then
        name= C_Spell.GetSpellName(spellID)
        icon= C_Spell.GetSpellTexture(spellID)
        if name and icon then
            if spellID==6544 or spellID==189110 then--6544英勇飞跃 189110地狱火撞击
                self:SetAttribute("type1", "macro")
                self:SetAttribute("macrotext1", format('/cast [@cursor]%s', name))
                self:SetAttribute('unit', nil)
            else
                self:SetAttribute("type1", "spell")
                self:SetAttribute("spell1", name)
                if spellID==121536 then--天堂之羽 
                    self:SetAttribute('unit', "player")--mouseover player
                else
                    self:SetAttribute('unit', nil)
                end
            end
        else
            WoWTools_DataMixin:Load({id=spellID, type='spell'})
            self.Combat=true
        end



    elseif self.itemID then
        name= C_Item.GetItemNameByID(self.itemID)
        icon= C_Item.GetItemIconByID(self.itemID)
        if name then
            if PlayerHasToy(self.itemID) then
                self:SetAttribute("type1", "macro")
                self:SetAttribute("macrotext1",  '/usetoy '..name)
            else
                self:SetAttribute("type1", "item")
                self:SetAttribute("item1", name)
            end
            self:SetAttribute('unit', nil)
        else
            WoWTools_DataMixin:Load({id=self.itemID, type='item'})
            self.Combat=true
        end
    else
        self:SetAttribute("item1", nil)
        self:SetAttribute("spell1", nil)
        self:SetAttribute('unit', nil)
    end


    self.spellID=spellID
    self.iconAtt=icon
    self.Combat=nil

    setTextrue(self)--设置图标
end





















local function Set_Item_Spell_Edit(info)
    if info.type==FLOOR then
        StaticPopup_Show('WoWTools_GetMapID', WoWTools_MountMixin.addName, nil, {
            type=info.type,
            spellID=info.spellID,
            OnShow=function(self, data)
                local text= ''
                local tab= Save().Mounts[FLOOR][data.spellID] or {}
                for uiMapID, _ in pairs(tab) do
                    text= text..uiMapID..', '
                end
                if text=='' then
                    local mapID= C_Map.GetBestMapForUnit("player")
                    text= (mapID and text..mapID or text)..', '
                end
                local edit= self.editBox or self:GetEditBox()
                local b3= self.button3 or self:GetButton3()
                edit:SetText(text)
                b3:SetEnabled(Save().Mounts[FLOOR][data.spellID] and true or false)
                if self.data then
                    self.data.text= text
                end
            end,
            SetValue = function(_, data, tab, text)
                Save().Mounts[FLOOR][data.spellID]= tab
                WoWTools_MountMixin.MountButton:settings()
                if MountJournal_UpdateMountList then WoWTools_DataMixin:Call(MountJournal_UpdateMountList) end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MountMixin.addName, C_Spell.GetSpellLink(data.spellID), '|n', text)

            end,
            OnAlt = function(_, data)
                Save().Mounts[FLOOR][data.spellID]=nil
                checkMount()--检测坐骑
                setClickAtt(WoWTools_MountMixin.MountButton)--设置 Click属性
                if MountJournal_UpdateMountList then WoWTools_DataMixin:Call(MountJournal_UpdateMountList) end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_MountMixin.addName, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE, data.link)
            end
        })
    end


    local name, link, texture, itemRarity, color, type, count, _
    if info.itemID or info.itemLink then
        name, link, itemRarity, _, _, _, _, _, _, texture = C_Item.GetItemInfo(info.itemLink or info.itemID)
        color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()}
        type=info.type
        count=C_Item.GetItemCount(info.itemID, true, false, true,true)
    elseif info.spellID then
        name= C_Spell.GetSpellName(info.spellID)
        texture= C_Spell.GetSpellTexture(info.spellID)
        link=C_Spell.GetSpellLink(info.spellID)
        type=info.type
    end

    StaticPopup_Show('WoWTools_Item', WoWTools_MountMixin.addName, nil, {
        link= info.itemLink or link,
        ID= info.itemID or info.spellID,
        name= name,
        type= type,
        color= color,
        texture= texture,
        count=count,
        OnShow=function(self, data)
            local b1= self.button1 or self:GetButton1()
            local b3= self.button3 or self:GetButton3()
            b3:SetEnabled(Save().Mounts[data.type][data.ID] and true or false)
            b1:SetEnabled(not Save().Mounts[data.type][data.ID] and true or false)
        end,
        SetValue = function(_, data)
            Save().Mounts[data.type][data.ID]=true
            WoWTools_MountMixin.MountButton:settings()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MountMixin.addName, WoWTools_DataMixin.onlyChinese and '添加' or ADD, data.link)
        end,
        OnAlt = function(_, data)
            Save().Mounts[data.type][data.ID]=nil
            WoWTools_MountMixin.MountButton:settings()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MountMixin.addName, WoWTools_DataMixin.onlyChinese and '移除' or REMOVE, data.link)
        end,
    })
end













local function Init(btn)
    WoWTools_KeyMixin:Init(btn, function() return Save().KEY end)



    btn:SetAttribute("type1", "spell")
    btn:SetAttribute("alt-type1", "spell")
    btn:SetAttribute("shift-type1", "spell")
    btn:SetAttribute("ctrl-type1", "spell")

    btn.textureModifier=btn:CreateTexture(nil,'OVERLAY')--提示 Shift, Ctrl, Alt
    btn.textureModifier:SetAllPoints(btn.texture)
    btn.textureModifier:AddMaskTexture(btn.IconMask)

    btn.textureModifier:SetShown(false)

    btn.Up=btn:CreateTexture(nil,'OVERLAY')
    btn.Up:SetPoint('TOP',-1, 9)
    btn.Up:SetAtlas('NPE_ArrowUp')
    btn.Up:SetSize(20,20)










    btn:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID then
            Set_Item_Spell_Edit({itemID=itemID, itemLink=itemLink, type=ITEMS})
            ClearCursor()
            return
        elseif infoType =='spell' and spellID then
            Set_Item_Spell_Edit({spellID=spellID, type=SPELLS})
            ClearCursor()
            return

        elseif d=='RightButton' and not IsModifierKeyDown() then
            WoWTools_MountMixin:Init_Menu(self)
        elseif d=='LeftButton' then
            if IsMounted() then
                C_MountJournal.Dismiss()

            --战斗中，可用，驭空术
            elseif UnitAffectingCombat('player') and not IsPlayerMoving() and  C_Spell.IsSpellUsable(368896) then
                local spellID2= getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
                local mountID= spellID2 and C_MountJournal.GetMountFromSpell(spellID2) or 368896
                if mountID then
                    C_MountJournal.SummonByID(mountID)
                end
            end
        end
        self.border:SetAtlas('bag-border')
    end)

    btn:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' then
            self.border:SetAtlas('bag-reagent-border')
        end
    end)

    btn:SetScript('OnMouseWheel',function(self, d)
        if d==1 then--坐骑秀
            _G['WoWToolsToolsMountFrame']:initMountShow()
        elseif d==-1 then--坐骑特效
            _G['WoWToolsToolsMountFrame']:initSpecial()
        end
    end)

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local infoType, itemID, _, spellID= GetCursorInfo()
        local name, col, exits
        if infoType == "item" and itemID then
            name, col= WoWTools_ItemMixin:GetName(itemID)
            exits= Save().Mounts[ITEMS][itemID] and true or false

        elseif infoType =='spell' and spellID then
            name, col= WoWTools_SpellMixin:GetName(spellID)
            exits=Save().Mounts[SPELLS][spellID] and true or false
        end

        if name and exits~=nil then
            GameTooltip:AddDoubleLine(name,
                (col or '')
                ..(exits and
                    (WoWTools_DataMixin.onlyChinese and '修改' or EDIT)
                    or ('|A:bags-icon-addslots:0:0|a'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD))
                ))

        else
            local key= WoWTools_KeyMixin:IsKeyValid(self)
            GameTooltip:AddDoubleLine(
                WoWTools_ItemMixin:GetName(self.itemID) or WoWTools_SpellMixin:GetName(self.spellID),
                (key and '|cnGREEN_FONT_COLOR:'..key or '')..WoWTools_DataMixin.Icon.left
            )
            GameTooltip:AddLine(' ')

            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '坐骑秀' or 'Mount show', '|A:bags-greenarrow:0:0|a')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '坐骑特效' or EMOTE171_CMD2:gsub('/',''), '|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a')

            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        end
        GameTooltip:Show()
    end

    btn:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        setClickAtt(self)--设置属性
        ResetCursor()
        self.border:SetAtlas('bag-reagent-border')
        self:SetScript('OnUpdate',nil)
    end)

    btn:SetScript('OnEnter', function(self)
        WoWTools_KeyMixin:SetTexture(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltip()
        local Elapsed= 0.3
        self:SetScript('OnUpdate', function (s, elapsed)
            Elapsed = Elapsed + elapsed
            if Elapsed > 0.3 and GameTooltip:IsOwned(s) then-- and (s.spellID or s.itemID) then
                Elapsed = 0
                s:set_tooltip()
            end
        end)
    end)




    function btn:settings()
        set_ShiJI()--召唤司机
        --set_OkMout()--是否已学, 骑术
        XDInt()--德鲁伊设置
        checkSpell(self)--检测法术
        checkItem(self)--检测物品
        checkMount()--检测坐骑
        setClickAtt(self)--设置
        setShiftCtrlAltAtt(self)--设置Shift Ctrl Alt 属性
    end

    btn:settings()

    C_Timer.After(4, function()
        if btn:CanChangeAttribute() then
            setShiftCtrlAltAtt(btn)--设置Shift Ctrl Alt 属性
            setClickAtt(btn)--设置
            WoWTools_CooldownMixin:SetFrame(btn, {itemID=btn.itemID, spellID=btn.spellID})--设置冷却
        end
    end)

    Init=function()end
end










local function Init_Event(btn)
    btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    btn:RegisterEvent('SPELLS_CHANGED')
    btn:RegisterEvent('SPELL_DATA_LOAD_RESULT')
    btn:RegisterEvent('BAG_UPDATE_DELAYED')
    btn:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
    btn:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
    btn:RegisterEvent('NEW_MOUNT_ADDED')
    btn:RegisterEvent('MODIFIER_STATE_CHANGED')
    btn:RegisterEvent('ZONE_CHANGED')
    btn:RegisterEvent('ZONE_CHANGED_INDOORS')
    btn:RegisterEvent('ZONE_CHANGED_NEW_AREA')
    btn:RegisterEvent('SPELL_UPDATE_COOLDOWN')
    btn:RegisterEvent('SPELL_UPDATE_USABLE')
    btn:RegisterEvent('PET_BATTLE_CLOSE')
    btn:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")
    btn:RegisterEvent('PLAYER_STOPPED_MOVING')
    btn:RegisterEvent('PLAYER_STARTED_MOVING')--设置, TOOLS 框架,隐藏
    btn:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')


    btn:SetScript("OnEvent", function(self, event, arg1, arg2)
        if event=='PLAYER_REGEN_DISABLED' then
                setClickAtt(self)--设置属性

        elseif event=='PLAYER_REGEN_ENABLED' then
            if self.Combat then
                C_Timer.After(0.3, function()
                    setClickAtt(self)--设置属性
                    setShiftCtrlAltAtt(self)--设置Shift Ctrl Alt 属性
                    self.Combat=nil
                end)
            end

        elseif event=='SPELLS_CHANGED' or (event=='SPELL_DATA_LOAD_RESULT' and arg1 and arg2) then
            checkSpell(self)--检测法术
            XDInt()--德鲁伊设置
            checkMount()--检测坐骑
            setClickAtt(self)--设置属性   

        elseif event=='BAG_UPDATE_DELAYED' then
            checkItem(self)--检测物品

        elseif event=='NEW_MOUNT_ADDED' then
            checkMount()--检测坐骑

        elseif event=='ZONE_CHANGED' or event=='ZONE_CHANGED_INDOORS' or event=='ZONE_CHANGED_NEW_AREA' then
            if not XD then
                checkMount()--检测坐骑
            end
        elseif event=='MOUNT_JOURNAL_USABILITY_CHANGED'
            or event=='PLAYER_MOUNT_DISPLAY_CHANGED'
            or event=='PET_BATTLE_CLOSE'
            or event=='UNIT_EXITED_VEHICLE'
            or event=='PLAYER_STOPPED_MOVING'
            or event=='PLAYER_STARTED_MOVING'
        then-- or event=='AREA_POIS_UPDATED' then
            setClickAtt(self)--设置属性

        elseif event=='MODIFIER_STATE_CHANGED' then
            local icon
            if arg2==1 then
                icon = arg1:find('SHIFT') and self.textureModifier.Shift
                    or arg1:find('CTRL') and self.textureModifier.Ctrl
                    or arg1:find('ALT') and self.textureModifier.Alt
            end
            if icon then
                self.textureModifier:SetTexture(icon)
            end
            self.textureModifier:SetShown(icon)

        elseif event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID, spellID=self.spellID})--设置冷却

        elseif event=='SPELL_UPDATE_USABLE' then
            setTextrue(self)--设置图标

        elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
            WoWTools_MountMixin.faction= WoWTools_DataMixin.Player.Faction=='Horde' and 0 or (WoWTools_DataMixin.Player.Faction=='Alliance' and 1)
            self:settings()
        end
    end)


    Init_Event=function()end
end













function WoWTools_MountMixin:Init_Button()
    Init(self.MountButton)
    Init_Event(self.MountButton)
    WoWTools_MountMixin:Init_Mount_Show()--坐骑秀
end

function WoWTools_MountMixin:Set_Item_Spell_Edit(...)
    Set_Item_Spell_Edit(...)
end

function WoWTools_MountMixin:Get_MountTab(type)
    return MountTab[type]
end