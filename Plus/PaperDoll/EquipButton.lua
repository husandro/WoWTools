local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end


local TrackButton
local NumButton=0--添加装备管理按钮
local Name='WoWToolsEquipSetButton'














local function Init_Menu(self, root)
    local sub
    root:CreateButton(
        WoWTools_DataMixin.Icon.left..MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0"),
    function()
        WoWTools_LoadUIMixin:OpenPaperDoll(1, 3)
        return MenuResponse.Open
    end)


    root:CreateDivider()



--装等
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '装等' or ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL,
    function()
        return Save().trackButtonShowItemLeve
    end, function()
        Save().trackButtonShowItemLeve= not Save().trackButtonShowItemLeve and true or nil
        TrackButton:set_player_itemLevel()
    end)

--缩放, 单行
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().trackButtonTextScale or 1
    end, function(value)
        Save().trackButtonTextScale= value
        TrackButton:set_text_scale()
    end, function()
        Save().trackButtonTextScale= nil
        TrackButton:set_text_scale()
    end)



--向右
    root:CreateCheckbox(
        '|A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '向右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT),
    function()
        return Save().EquipmentH
    end, function()
        Save().EquipmentH= not Save().EquipmentH and true or nil
        TrackButton:set_to_right()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().equipmentFrameScale
    end, function(value)
        Save().equipmentFrameScale= value
        TrackButton:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        return TrackButton:GetFrameStrata()==data
    end, function(data)
        Save().trackButtonStrata= data
        TrackButton:settings()
    end)


    root:CreateDivider()
--打开选项界面
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName, name2=WoWTools_PaperDollMixin.addName2})

--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().Equipment, function()
        Save().Equipment=nil
        TrackButton:set_point()
        print(WoWTools_PaperDollMixin.addName2.WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
    end)
end














local function Set_Point(button, index)
    local btn= index==1 and TrackButton or _G[Name..(index-1)]
    if Save().EquipmentH then
        button:SetPoint('LEFT', btn, 'RIGHT')
    else
        button:SetPoint('TOP', btn, 'BOTTOM')
    end
end













--建立，按钮
local function Create_Button(index)
    --[[local btn=WoWTools_ButtonMixin:Cbtn(TrackButton, {
        size=22,
        name=Name..index
    })]]
    local btn= CreateFrame('Button', Name..index, TrackButton, 'WoWToolsButtonTemplate')

    btn.texture= btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.texture:SetSize(28,28)
    btn.texture:SetPoint('CENTER')
    btn.texture:SetAtlas('AlliedRace-UnlockingFrame-GenderMouseOverGlow')
    btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontHighlightSmall') --WoWTools_LabelMixin:Create(btn, {size=10, color={r=1,g=1,b=1}})
    btn.text:SetPoint('BOTTOMRIGHT')

    Set_Point(btn, index)--设置位置

    btn:SetScript("OnClick",function(self)
        if self.setID and not C_EquipmentSet.EquipmentSetContainsLockedItems(self.setID) then--装备管理，能否装备
            C_EquipmentSet.UseEquipmentSet(self.setID)

            if TrackButton.HelpTips then
                TrackButton.HelpTips:SetShown(false)
            end
            C_Timer.After(2, function()
                WoWTools_PaperDollMixin:Settings_Tab1()--修改总装等
            end)
        end
    end)
    btn:SetScript("OnEnter", function(self)
        if not self.setID then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetEquipmentSet(self.setID)

        if C_EquipmentSet.EquipmentSetContainsLockedItems(self.setID) then
            GameTooltip:AddLine(' ')
            GameTooltip_AddErrorLine(
                GameTooltip,
                WoWTools_DataMixin.onlyChinese and '你还不能那样做。' or ERR_CLIENT_LOCKED_OUT,
                true
            )
        end

        local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(self.setID)
        local specName
        if specIndex then
            local _, specName2, _, icon3, role = GetSpecializationInfo(specIndex)
            if specName2 then
                specName='|T'..(icon3 or 0)..':0|t'.. (WoWTools_DataMixin.Icon[role] or '').. '|cffff00ff'..WoWTools_TextMixin:CN(specName2)..'|r'
            end
        end

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '指定专精：' or EQUIPMENT_SET_ASSIGN_TO_SPEC)
            ..(specName or DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '无' or NONE))
        )
        GameTooltip:Show()

        self:SetAlpha(1)
    end)

    btn:SetScript("OnLeave",function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    function btn:set_shown()
        self:SetShown(self.setID and (self.isEquipped or not PlayerIsInCombat()))
    end
    function btn:set_alpha()
        self:SetAlpha((self.numItems==0 and not self.isEquipped) and 0.3 or 1)
    end
    btn:SetScript('OnEvent', btn.set_shown)

    NumButton= index

    return btn
end










--设置，初始，按钮
local function Init_buttons()
    if not TrackButton:IsShown() then
        return
    end


    local setIDs= SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs() or {})--PaperDollFrame.lua
    local numIndex=0
    for index, setID in pairs(setIDs) do
        local texture, _, isEquipped, numItems, _, _, numLost= select(2, C_EquipmentSet.GetEquipmentSetInfo(setID))

        local btn= _G[Name..index] or Create_Button(index)
        if numItems==0 then
            btn:SetNormalAtlas('groupfinder-eye-highlight')
        else
            if texture==134400 then--?图标
                local specIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(setID)
                if specIndex then
                    texture= select(4, GetSpecializationInfo(specIndex))
                end
            end
            btn:SetNormalTexture(texture or 0)
        end
        if numItems==0 then
            btn.text:SetText('')
        else
            btn.text:SetText(numLost>0 and '|cnWARNING_FONT_COLOR:'..numLost or numItems)
        end
        btn.texture:SetShown(isEquipped)
        btn.setID=setID
        btn.isEquipped= isEquipped
        btn.numItems=numItems
        numIndex=index
        btn:set_shown()
        btn:set_alpha()
    end

    for index= numIndex+1, NumButton, 1 do
        local btn= _G[Name..index]
        btn.setID=nil
        btn.isEquipped=nil
        btn.numItems=0
        btn:set_shown()
    end
end






















--#######
--装备管理
--#######
local function Init()--添加装备管理框
    if not Save().equipment then
        return
    end

    TrackButton= CreateFrame('Button', Name, UIParent, 'WoWToolsButtonTemplate') --WoWTools_ButtonMixin:Cbtn(UIParent, {size={23, 16}})--添加移动按钮
    --TrackButton:SetHeight(16)

    TrackButton.texture= TrackButton:CreateTexture(nil, 'BACKGROUND')
    TrackButton.texture:SetTexture(WoWTools_DataMixin.Icon.icon)
    TrackButton.texture:SetSize(14,14)
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetAlpha(0.5)

    TrackButton.text= TrackButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2') -- WoWTools_LabelMixin:Create(TrackButton, {size=Save().trackButtonFontSize or 10, color=true, justifyH='CENTER'})
    WoWTools_ColorMixin:SetLabelColor(TrackButton.text)

    TrackButton.text:SetPoint('CENTER')
    TrackButton:Hide()

--装等
    function TrackButton:set_player_itemLevel()
        local text
        local isEquipmentH= Save().EquipmentH

        if Save().trackButtonShowItemLeve then
            text= format('%i', select(2, GetAverageItemLevel()) or 0)
            if isEquipmentH then
                text=WoWTools_TextMixin:Vstr(text)
            end
        end

        self.text:SetText(text or '')
        self.texture:SetShown(not text)

        if isEquipmentH then
            self:SetSize(16, 23)
        else
            self:SetSize(23, 16)
        end
    end


--位置保存
    function TrackButton:set_point()
        self:ClearAllPoints()
        if Save().Equipment then
            self:SetPoint(Save().Equipment[1], UIParent, Save().Equipment[3], Save().Equipment[4], Save().Equipment[5])
        elseif WoWTools_DataMixin.Player.husandro then
            self:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.FrameTexture, 'TOPRIGHT',-4,-3)
        else
            self:SetPoint('CENTER', UIParent)
        end
    end

--向右，向下
    function TrackButton:set_to_right()
        for i=1, NumButton do
            local btn= _G[Name..i]
            btn:ClearAllPoints()
            Set_Point(btn, i)--设置位置
        end
        self:set_player_itemLevel()
    end

--缩放
    function TrackButton:set_scale()
        self:SetScale(Save().equipmentFrameScale or 1)
    end

--FrameStrata
    function TrackButton:set_strata()
        local strata= Save().trackButtonStrata
        if strata then
            self:SetFrameStrata(strata)
        end
    end


--设置，显示
    function TrackButton:set_shown()
        self:SetShown(
            Save().equipment
            and not C_PetBattles.IsInBattle()
            and not UnitHasVehicleUI('player')
        )
    end

--提示，没有装上
    function TrackButton:tips_not_equipment()
        if not IsInInstance() or not self:IsShown() then-- or not IsInGroup() then
            return
        end
        local equipped
        local num=0
        for _, setID in pairs(C_EquipmentSet.GetEquipmentSetIDs() or {}) do
            local isEquipped, numItems= select(4, C_EquipmentSet.GetEquipmentSetInfo(setID))
            if numItems>0 then
                num= num+1
                if isEquipped then
                    equipped=true
                    break
                end
            end
        end
        WoWTools_FrameMixin:HelpFrame({frame=self, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show= not equipped and num>0, hideTime=10})
    end

    function TrackButton:set_event()
        self:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
        self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('READY_CHECK')
        self:RegisterEvent('PET_BATTLE_OPENING_DONE')
        self:RegisterEvent('PET_BATTLE_CLOSE')
        self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
        self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
        Init_buttons()
        self:set_player_itemLevel()
    end

    function TrackButton:set_text_scale()
        self.text:SetScale(Save().trackButtonTextScale or 1)
    end

    function TrackButton:settings()
        self:set_shown()
        self:set_point()
        self:set_scale()
        self:set_player_itemLevel()
        self:tips_not_equipment()
        self:set_strata()
        self:set_text_scale()
    end






    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetMovable(true)

    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().Equipment={self:GetPoint(1)}
            Save().Equipment[2]=nil
        end
    end)
    TrackButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动图标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    TrackButton:SetScript("OnMouseUp", ResetCursor)

    TrackButton:SetScript("OnClick", function(self, d)
        if IsModifierKeyDown() then
            return
        end
        if d=='LeftButton' then
            WoWTools_LoadUIMixin:OpenPaperDoll(1,3)--打开/关闭角色界面

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    TrackButton:SetScript("OnEnter", function (self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")

        GameTooltip:SetText(WoWTools_PaperDollMixin.addName2..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')

        WoWTools_DurabiliyMixin:OnEnter()--耐久度, 提示

        GameTooltip:AddLine(' ')
        GameTooltip_AddInstructionLine(
            GameTooltip,
            WoWTools_DataMixin.Icon.left..MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0")
        )

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL),
            'Alt+'..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE),
            0,1,0, 0,1,0
        )
        GameTooltip:Show()
    end)

    TrackButton:SetScript("OnLeave", function()
        ResetCursor()
        GameTooltip:Hide()
    end)

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' or event=='READY_CHECK' then
            self:tips_not_equipment()

        elseif event=='PET_BATTLE_CLOSE'
            or event=='PET_BATTLE_OPENING_DONE'
            or event=='UNIT_ENTERED_VEHICLE'
            or event=='UNIT_EXITED_VEHICLE'
        then
            self:set_shown()

        elseif not self.time then
            self.time= C_Timer.NewTimer(0.6, function()
                Init_buttons()
                self:set_player_itemLevel()
                self.time:Cancel()
                self.time=nil
            end)

        end
    end)

    TrackButton:SetScript('OnHide', TrackButton.UnregisterAllEvents)
    TrackButton:SetScript('OnShow', TrackButton.set_event)

--更新
    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_Update',  Init_buttons)
    TrackButton:settings()

    Init=function()
        TrackButton:settings()
    end
end














function WoWTools_PaperDollMixin:Init_EquipButton()
    Init()
end









