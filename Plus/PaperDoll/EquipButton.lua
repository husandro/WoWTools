local function Save()
    return WoWToolsSave['Plus_PaperDoll'].EquipSet
end


local TrackButton
local useSecureAction














local function Init_Menu(self, root)
    local sub, sub2
    root:CreateButton(
        WoWTools_DataMixin.Icon.left..MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0"),
    function()
        WoWTools_LoadUIMixin:OpenPaperDoll(1, 3)
        return MenuResponse.Open
    end)

    root:CreateDivider()

--向右
    root:CreateCheckbox(
        '|A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '向右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT),
    function()
        return Save().toRight
    end, function()
        Save().toRight= not Save().toRight and true or nil
        self:settings()
    end)

--装等
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '装等' or ITEM_UPGRADE_STAT_AVERAGE_ITEM_LEVEL,
    function()
        return Save().itemLevel
    end, function()
        Save().itemLevel= not Save().itemLevel and true or nil
        self:settings()
    end)

--缩放, 单行
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().itemLevelScale or 1
    end, function(value)
        Save().itemLevelScale= value
        self:settings()
    end, function()
        Save().itemLevelScale= nil
        self:settings()
    end)





    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
    function()
        return not Save().notNumItem
    end, function()
        Save().notNumItem = not Save().notNumItem and true or nil
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '%d件物品' or ITEMS_VARIABLE_QUANTITY, '16'))
    end)


--打开选项界面
    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName, name2=WoWTools_PaperDollMixin.addName2})

    sub2= sub:CreateCheckbox(
        '|cnWARNING_FONT_COLOR:SecureActionButton',
    function()
        return Save().useSecureAction
    end, function()
        Save().useSecureAction= not Save().useSecureAction and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('SecureActionButtonTemplate')
        GameTooltip_AddHighlightLine(tooltip, WoWTools_DataMixin.onlyChinese and '战斗中可更换武器' or 'Weapons can be switched during combat')
        tooltip:AddLine(' ')
        GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and'友情提示: 可能会出现错误' or 'Note: Errors may occur')
    end)


--缩放
    sub:CreateDivider()
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale
    end, function(value)
        Save().scale= value
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:settings()
    end)

    sub:CreateDivider()

    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
    function()
        StaticPopup_Show('WoWTools_OK',
            WoWTools_PaperDollMixin.addName2..WoWTools_DataMixin.Icon.icon2
            ..'|n|n'
            ..(WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
            nil,
            {SetValue=function()
                WoWToolsSave['Plus_PaperDoll'].EquipSet={}
                self:settings()
            end}
        )
    end)
--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:settings()
        print(
            WoWTools_PaperDollMixin.addName2..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
        )
    end)


--重新加载UI
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)
end























--建立，按钮
local function Create_Button(btn)
    btn.texture= btn:CreateTexture(nil, 'BORDER', nil, 1)
    btn.texture:SetAllPoints()
    WoWTools_ButtonMixin:AddMask(btn, false, btn.texture)



    btn.spec= btn:CreateTexture(nil, 'BORDER', nil, 2)
    btn.spec:SetSize(8,8)
    btn.spec:SetPoint('BOTTOMLEFT', 1,1)


    btn.text= btn:CreateFontString(nil, 'BORDER', 'GameFontHighlightOutline', 3)
    btn.text:SetFontHeight(8)
    btn.text:SetShadowOffset(1,-1)
    btn.text:SetPoint('BOTTOMRIGHT', -1, 1)

    btn.select= btn:CreateTexture(nil, 'ARTWORK', nil, 1)
    --btn.select:SetAllPoints()
    btn.select:SetSize(25,25)
    btn.select:SetPoint('CENTER')
    btn.select:SetAtlas('UI-HUD-ActionBar-IconFrame-Down')
    btn.select:SetVertexColor(0,1,0)


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
                specName='|T'..(icon3 or 0)..':0|t'
                    ..(WoWTools_DataMixin.Icon[role] or '')
                    ..'|cffff00ff'..WoWTools_TextMixin:CN(specName2)
                    ..'|r'
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

    btn:SetScript("OnLeave", GameTooltip_Hide)



    function btn:set_alpha()
        self:SetAlpha(
            (self.isEquipped or not PlayerIsInCombat())-- C_EquipmentSet.CanUseEquipmentSets())
            and 1 or 0.3
        )
    end

if not useSecureAction then
    btn:SetScript("OnClick",function(self)
        if self.setID
            and not C_EquipmentSet.EquipmentSetContainsLockedItems(self.setID)
            and not InCombatLockdown()
        then--装备管理，能否装备
            C_EquipmentSet.UseEquipmentSet(self.setID)
            if TrackButton.HelpTips then
                TrackButton.HelpTips:SetShown(false)
            end
        end
    end)
end

    function btn:settings()
        if not self.setID then
            return
        end

        local name, iconFileID, _, isEquipped, numItems, _, _, numLost = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
        local specIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(self.setID)

        numItems= numItems or 0

        self.spec:SetTexture(
            specIndex and select(4, GetSpecializationInfo(specIndex))
            or 0
        )

        if numItems==0 or Save().notNumItem then
            self.text:SetText('')
        else
            self.text:SetText(
                (numLost and numLost>0 and '|cnWARNING_FONT_COLOR:' or '')
                ..numItems
            )
        end

        self.select:SetShown(isEquipped)
        self.isEquipped= isEquipped

        if numItems==0 then
            self.texture:SetAtlas('groupfinder-eye-highlight')
        else
            self.texture:SetTexture(iconFileID or 134400)
        end
        self.texture:SetAlpha((numItems==0 and not isEquipped) and 0.5 or 1)
        self:set_alpha()

        if useSecureAction and self:CanChangeAttribute() then
            self:SetAttribute('equipmentset', name)
        end
    end

    function btn:set_event()
        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    end

    btn:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_EQUIPMENT_CHANGED'
            or event=='PLAYER_REGEN_ENABLED'
        then
            self:settings()
        else
            self:set_alpha()
        end
    end)

    btn:set_event()
    btn:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.texture:SetTexture(0)
        self.spec:SetTexture(0)
        self.text:SetText('')
        self.isEquipped= nil
    end)
    btn:SetScript('OnShow', function(self)
        self:set_event()
        self:settings()
    end)
end





--设置，初始，按钮
local function Init_buttons()
    if WoWTools_FrameMixin:IsLocked(TrackButton) then
        TrackButton:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    TrackButton.pool:ReleaseAll()
    local setIDs= C_EquipmentSet.GetEquipmentSetIDs()

    if not setIDs then
        return
    end

    setIDs= SortEquipmentSetIDs(setIDs)--PaperDollFrame.lua
    local toRight= Save().toRight
    local last= TrackButton

    for _, setID in pairs(setIDs) do

        local btn= TrackButton.pool:Acquire()
        btn.setID=setID

        if not btn.settings then
            Create_Button(btn)

            if useSecureAction then
                btn:SetAttribute('type', 'equipmentset')
                btn:SetAttribute('unit', 'player')
            end
        end

        if toRight then
            btn:SetPoint('LEFT', last, 'RIGHT')
        else
            btn:SetPoint('TOP', last, 'BOTTOM')
        end

        btn:SetShown(true)

        last= btn
    end
end






















--#######
--装备管理
--#######
local function Init()--添加装备管理框
    if Save().disabled then
        return
    end

    useSecureAction= Save().useSecureAction


    TrackButton= CreateFrame('Button', 'WoWToolsEquipSetMainButton', UIParent, 'WoWToolsButtonTemplate') --WoWTools_ButtonMixin:Cbtn(UIParent, {size={23, 16}})--添加移动按钮
    if useSecureAction then
        TrackButton.pool= CreateFramePool('Button', TrackButton, 'WoWToolsButtonTemplate SecureActionButtonTemplate')
    else
        TrackButton.pool= CreateFramePool('Button', TrackButton, 'WoWToolsButtonTemplate')
    end

--图标
    TrackButton.texture= TrackButton:CreateTexture(nil, 'BORDER')
    TrackButton.texture:SetTexture(WoWTools_DataMixin.Icon.icon)
    TrackButton.texture:SetSize(12,12)
    TrackButton.texture:SetPoint('CENTER')
    TrackButton.texture:SetAlpha(0.3)

--装等
    TrackButton.frame= CreateFrame('Frame', nil, TrackButton)
    TrackButton.frame:SetAllPoints()
    TrackButton.frame.text= TrackButton.frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2') -- WoWTools_LabelMixin:Create(TrackButton, {size=Save().trackButtonFontSize or 10, color=true, justifyH='CENTER'})
    TrackButton.frame.text:SetShadowOffset(1,-1)

    WoWTools_ColorMixin:SetLabelColor(TrackButton.frame.text)
    TrackButton.frame.text:SetPoint('CENTER')

    function TrackButton.frame:set_itemleve()
        self.text:SetFormattedText('%i', select(2, GetAverageItemLevel()) or 0)
    end

    function TrackButton.frame:settings()
        local isShowItemLevel= Save().itemLevel and TrackButton:IsShown()

        if isShowItemLevel then
            self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            self.text:ClearAllPoints()
            if Save().toRight then
                self.text:SetPoint('RIGHT', -2, 0)
                self.text:SetJustifyH('RIGHT')
            else
                self.text:SetPoint('BOTTOM', 0, 2)
                self.text:SetJustifyH('CENTER')
            end
            self.text:SetScale(Save().itemLevelScale or 1)
            self:set_itemleve()
        else
            self:UnregisterAllEvents()
            self.text:SetText('')
        end
        self:GetParent().texture:SetShown(not isShowItemLevel)

    end

    TrackButton.frame:SetScript('OnEvent', TrackButton.frame.set_itemleve)















--设置，显示
    function TrackButton:main_shown(sceneType)
        if WoWTools_FrameMixin:IsLocked(self) then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        self:SetShown(
            not C_PetBattles.IsInBattle()
            and not UnitHasVehicleUI('player')
            and sceneType~= Enum.ClientSceneType.MinigameSceneType
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








    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetMovable(true)

    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        if not WoWTools_FrameMixin:IsLocked(self) then
            self:StopMovingOrSizing()
        end
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
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





    TrackButton:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' or event=='READY_CHECK' then
            self:tips_not_equipment()

        --elseif event=='EQUIPMENT_SETS_CHANGED' then
            --Init_buttons()

        elseif event=='CLIENT_SCENE_OPENED' then
            self:main_shown(arg1)

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:settings()
            self:UnregisterEvent(event)

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:StopMovingOrSizing()
            self:UnregisterEvent(event)
        else
            self:main_shown()
        end
    end)

    function TrackButton:settings()
        if WoWTools_FrameMixin:IsLocked(self) then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        self:UnregisterAllEvents()
        if Save().disabled then
            self.pool:ReleaseAll()
            self:SetShown(false)
            self.frame:settings()
            return
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('READY_CHECK')
            --self:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
            --self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
            --self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
            --self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
            self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
            self:RegisterEvent('CLIENT_SCENE_OPENED')
            self:RegisterEvent('CLIENT_SCENE_CLOSED')
        end

        self:main_shown()

        self:ClearAllPoints()

        local p= Save().point
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])

        elseif WoWTools_DataMixin.Player.husandro then
            self:SetPoint('TOPLEFT', PlayerFrame, 'TOPRIGHT', -20,-15)

        else
            self:SetPoint('CENTER', UIParent, -150, -150)
        end


        self:tips_not_equipment()


        if Save().toRight then
            self:SetSize(12, 23)
        else
            self:SetSize(23, 12)
        end

        self:SetScale(Save().scale or 1)
        self:SetFrameStrata(Save().strata or 'MEDIUM')

        self.frame:settings()
        Init_buttons()
    end


--更新
    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_Update',  function()
        if TrackButton:IsShown() then
            Init_buttons()
        end
    end)

    TrackButton:settings()

    Init=function()
        TrackButton:settings()
    end
end














function WoWTools_PaperDollMixin:Init_EquipButton()
    Init()
end









