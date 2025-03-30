
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end


local SayButton







local function Init()
    if not Save().slotKeystoneSay then
        return
    end


    SayButton= WoWTools_ButtonMixin:Cbtn(nil, {
        isItem=true,
        size=36,
        name='WoWToolsPlusChallengesSayItemLinkButton',
    })
    SayButton.Text= WoWTools_LabelMixin:Create(SayButton)
    SayButton.Text:SetPoint('LEFT', SayButton, 'RIGHT')

    SayButton:Hide()

    SayButton:SetMovable(true)
    SayButton:RegisterForDrag("RightButton")
    SayButton:SetClampedToScreen(true)
    SayButton:SetFrameStrata('HIGH')

    SayButton:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    SayButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().sayButtonPoint={self:GetPoint(1)}
            Save().sayButtonPoint[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
        self:Raise()
    end)

    SayButton:SetScript("OnMouseUp", ResetCursor)
    SayButton:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            self:Settings(true)
        else
             MenuUtil.CreateContextMenu(self, function(_, root)
                local sub, sub2
                root:CreateButton(
                    ( WoWTools_BagMixin:Ceca(nil, {isKeystone=true}) and '' or '|cff828282')
                    ..('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY)),
                function()
                    self:Settings(true)
                    return MenuResponse.Open
                end)

                root:CreateDivider()
                root:CreateButton(
                    WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE,
                self.Hide)

                root:CreateDivider()
                sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ChallengeMixin.addName})
                sub2=sub:CreateCheckbox(
                    WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                function()
                    return Save().slotKeystoneSay
                end, function()
                    Save().slotKeystoneSay= not Save().slotKeystoneSay and true or nil
                end)
                sub2:SetTooltip(function(tooltip)
                    GameTooltip:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY))
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(1, WoWTools_DataMixin.onlyChinese and '插入' or  COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN)
                    GameTooltip:AddDoubleLine(2, WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)
                end)
             end)
        end
    end)
    SayButton:SetScript('OnLeave', GameTooltip_Hide)
    SayButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end)

    if Save().sayButtonPoint then
        SayButton:SetPoint(Save().sayButtonPoint[1], UIParent, Save().sayButtonPoint[3], Save().sayButtonPoint[4], Save().sayButtonPoint[5])
    else
        SayButton:SetPoint('CENTER', 100, 100)
    end


    function SayButton:Settings(isSay)
        local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        local level= C_MythicPlus.GetOwnedKeystoneLevel()
        if bagID and slotID then

           self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
        else
            self:Reset()
            self:SetItemButtonTexture(WoWTools_DataMixin.Icon.icon)
        end
        self:SetItemButtonCount(level)
        self.Text:SetText(info and info.hyperlink or '')
        if isSay and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, nil)
        end
    end

    SayButton:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self:Reset()
        self.Text:SeText('')
    end)
    SayButton:SetScript('OnShow', function(self)
        self:RegisterEvent('BAG_UPDATE_DELAYED')
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        self:Settings()
    end)

    SayButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            C_Timer.After(2, function()
                if not IsInInstance() then
                    self:Hide()
                end
            end)
        else
            self:Settings()
        end
    end)
    SayButton:Show()



    Init=function()
        SayButton:SetShown(Save().slotKeystoneSay)
    end
end














function WoWTools_ChallengeMixin:Say_ChallengeComplete()
    Init()
end