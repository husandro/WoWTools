
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local TrackButton
local EquipButton
local Buttons={}--添加装备管理按钮
local addName
















local function Init_Menu(_, root)
    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return Save().equipment
    end, function()
        EquipButton:set_show_hide()
    end)
    root:CreateDivider()

    root:CreateCheckbox(
        e.Icon.toRight..(e.onlyChinese and '向右' or BINDING_NAME_STRAFERIGHT) or ('|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'),
    function()

    end, function()
        Save().EquipmentH= not Save().EquipmentH and true or nil
        TrackButton:set_toright_point()
    end)

    --缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save().equipmentFrameScale
    end, function(value)
        Save().equipmentFrameScale= value
        TrackButton:set_scale()
    end)


--重置位置
    root:CreateDivider()
    WoWTools_MenuMixin:RestPoint(root, Save().Equipment, function()
        Save().Equipment=nil
        TrackButton:set_point()
        print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
    end)
end














local function Set_Point(button, index)
    local btn= index==1 and TrackButton or Buttons[index-1]
    if Save().EquipmentH then
        button:SetPoint('LEFT', btn, 'RIGHT')
    else
        button:SetPoint('TOP', btn, 'BOTTOM')
    end
end





--建立，按钮
local function Create_Button(index)
    local btn=WoWTools_ButtonMixin:Cbtn(TrackButton, {icon='hide',size=22})
    btn.texture= btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.texture:SetSize(28,28)
    btn.texture:SetPoint('CENTER')
    btn.texture:SetAtlas('AlliedRace-UnlockingFrame-GenderMouseOverGlow')
    btn.text= WoWTools_LabelMixin:CreateLabel(btn, {size=10, color={r=1,g=1,b=1}})
    btn.text:SetPoint('BOTTOMRIGHT')

    Set_Point(btn, index)--设置位置

    btn:SetScript("OnClick",function(self)
        if not C_EquipmentSet.CanUseEquipmentSets() then
            C_EquipmentSet.UseEquipmentSet(self.setID)
            if TrackButton.HelpTips then
                TrackButton.HelpTips:SetShown(false)
            end
            C_Timer.After(2, function()
                WoWTools_PaperDollMixin:Set_Tab1_ItemLevel()--修改总装等
            end)
        else
            print(e.addName, addName, RED_FONT_COLOR_CODE, e.onlyChinese and '你无法在战斗中实施那个动作' or ERR_NOT_IN_COMBAT)
        end
    end)
    btn:SetScript("OnEnter", function(self)
        if ( self.setID ) then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:SetEquipmentSet(self.setID)
            if C_EquipmentSet.CanUseEquipmentSets() then
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '你无法在战斗中实施那个动作' or ERR_NOT_IN_COMBAT))
            end
            local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(self.setID)
            if specIndex then
                local _, specName2, _, icon3 = GetSpecializationInfo(specIndex)
                if icon3 and specName2 then
                    e.tips:AddLine(' ')
                    e.tips:AddLine(format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, '|T'..icon3..':0|t|cffff00ff'..specName2..'|r'))
                end
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.addName, addName)
            e.tips:Show()
            EquipButton:SetButtonState('PUSHED')
            EquipButton:SetAlpha(1)
        end
        self:SetAlpha(1)
    end)

    btn:SetScript("OnLeave",function(self)
        e.tips:Hide()
        self:set_alpha()
    end)
    btn:RegisterEvent('PLAYER_REGEN_DISABLED')
    btn:RegisterEvent('PLAYER_REGEN_ENABLED')
    function btn:set_shown()
        self:SetShown(self.setID and (self.isEquipped or not UnitAffectingCombat('player')))
    end
    function btn:set_alpha()
        self:SetAlpha((self.numItems==0 and not self.isEquipped) and 0.3 or 1)
    end
    btn:SetScript('OnEvent', btn.set_shown)
    Buttons[index]=btn
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

        local btn= Buttons[index] or Create_Button(index)
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
            btn.text:SetText(numLost>0 and '|cnRED_FONT_COLOR:'..numLost or numItems)
        end
        btn.texture:SetShown(isEquipped)
        btn.setID=setID
        btn.isEquipped= isEquipped
        btn.numItems=numItems
        numIndex=index
        btn:set_shown()
        btn:set_alpha()
    end

    for index= numIndex+1, #Buttons, 1 do
        Buttons[index].setID=nil
        Buttons[index].isEquipped=nil
        Buttons[index].numItems=0
        Buttons[index]:set_shown()
    end
end






















--#######
--装备管理
--#######
local function Init_TrackButton()--添加装备管理框
    TrackButton=WoWTools_ButtonMixin:Cbtn(UIParent, {icon='hide', size={23, 16}})--添加移动按钮
    TrackButton.text= WoWTools_LabelMixin:CreateLabel(TrackButton, {color=true, justifyH='CENTER'})
    TrackButton.text:SetPoint('CENTER')
    TrackButton:Hide()

--装等
    function TrackButton:set_player_itemLevel()
        local text= format('%i', select(2, GetAverageItemLevel()) or 0)
        if Save().EquipmentH then
            self:SetSize(16, 23)
            self:SetText(WoWTools_TextMixin:Vstr(text))
        else
            self:SetSize(23, 16)
            self.text:SetText(text)
        end
    end


--位置保存
    function TrackButton:set_point()
        self:ClearAllPoints()
        if Save().Equipment then
            self:SetPoint(Save().Equipment[1], UIParent, Save().Equipment[3], Save().Equipment[4], Save().Equipment[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.FrameTexture, 'TOPRIGHT',-4,-3)
        else
            self:SetPoint('BOTTOMRIGHT', PaperDollItemsFrame, 'TOPRIGHT')
        end
    end

--向右，向下
    function TrackButton:set_toright_point()
        for index, btn in pairs(self.buttons) do
            btn:ClearAllPoints()
            self:set_button_point(btn, index)--设置位置
        end
        TrackButton:set_player_itemLevel()
    end

--缩放
    function TrackButton:set_scale()
        self:SetScale(Save().equipmentFrameScale or 1)
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
    end

    function TrackButton:settgins()
        self:set_shown()
        self:set_point()
        self:set_scale()
        self:set_player_itemLevel()
        self:tips_not_equipment()
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
        self:StopMovingOrSizing()
        Save().Equipment={self:GetPoint(1)}
        Save().Equipment[2]=nil
    end)
    TrackButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动图标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    TrackButton:SetScript("OnMouseUp", ResetCursor)

    TrackButton:SetScript("OnClick", function(_, d)
        if d=='RightButton' and IsControlKeyDown() then--图标横,或 竖
            Save().EquipmentH= not Save().EquipmentH and true or nil
            for index, btn in pairs(Buttons) do
                btn:ClearAllPoints()
                Set_Point(btn, index)--设置位置
            end

        elseif d=='LeftButton' and not IsModifierKeyDown() then--打开/关闭角色界面
            ToggleCharacter("PaperDollFrame")
            if PaperDollFrame:IsShown() then
                PaperDollFrame_SetSidebar(PaperDollFrame, 3)
            end
        end
    end)

    TrackButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, e.onlyChinese and '装备管理'or EQUIPMENT_MANAGER)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(MicroButtonTooltipText('角色信息', "TOGGLECHARACTER0"), e.Icon.left)
        e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:Show()
        EquipButton:SetButtonState('PUSHED')

    end)

    TrackButton:SetScript("OnLeave", function()
        ResetCursor()
        e.tips:Hide()
        EquipButton:SetButtonState('NORMAL')
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

        elseif not self.time or self.time:IsCancelled() then
            self.time= C_Timer.NewTimer(0.6, function()
                Init_buttons()
                self:set_player_itemLevel()
                self.time:Cancel()
            end)

        end
    end)

    TrackButton:SetScript('OnHide', TrackButton.UnregisterAllEvents)
    TrackButton:SetScript('OnShow', TrackButton.set_event)

--更新
    hooksecurefunc('PaperDollEquipmentManagerPane_Update',  Init_buttons)
    TrackButton:settgins()
end






















--装备管理, 总开关, 显示/隐藏装备管理框选项
function Init_EquipButton()
    EquipButton = WoWTools_ButtonMixin:Cbtn(PaperDollFrame.EquipmentManagerPane, {size={20,20},icon='hide'})
    EquipButton:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    EquipButton:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    EquipButton:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    EquipButton:SetAlpha(0.3)


    function EquipButton:set_texture()
        self:SetNormalAtlas(Save().equipment and 'auctionhouse-icon-favorite' or e.Icon.disabled)
    end

    function EquipButton:set_shown()
        self:SetShown(not Save().hide)
    end

    function EquipButton:settings()
        self:set_shown()
        self:set_texture()
    end

    function EquipButton:set_show_hide()
        Save().equipment= not Save().equipment and true or nil
        self:set_texture()
        TrackButton:set_shown()
    end

    EquipButton:SetScript("OnClick", function(self, d)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)

    EquipButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER, e.Icon.left..e.GetShowHide(Save().equipment))
        local col= not (self.btn and Save().Equipment) and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '重置位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
        if TrackButton then
            TrackButton:SetButtonState('PUSHED')
        end
    end)
    EquipButton:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        if TrackButton then
            TrackButton:SetButtonState("NORMAL")
        end
        self:SetAlpha(0.3)
    end)

    EquipButton:settings()
end













function WoWTools_PaperDollMixin:TrackButton_Settings()
    EquipButton:settgins()
    TrackButton:settgins()
end

function WoWTools_PaperDollMixin:Init_TrackButton()
    addName= '|A:bags-icon-equipment:0:0|a'..(e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)

    Init_EquipButton()
    Init_TrackButton()
end









