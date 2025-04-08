
local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end


local SayButton



local function Init_Menu(self, root)
    local sub
    sub=root:CreateButton(
        ( WoWTools_BagMixin:Ceca(nil, {isKeystone=true}) and '' or '|cff828282')
        ..('|A:transmog-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY)),
    function()
        self:Settings(true)
        return MenuResponse.Open
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().endKeystoneSayScale or 1
    end, function(value)
        Save().endKeystoneSayScale= value
        self:set_scale()
    end)

    root:CreateDivider()
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE,
    function()
        self:Hide()
    end)

    --WoWTools_ChallengeMixin:ChallengesKeystoneFrame_Menu(self, sub)
end









local function Init()
    if Save().hideEndKeystoneSay then
        return
    end


    SayButton= WoWTools_ButtonMixin:Cbtn(nil, {
        isItem=true,
        name='WoWToolsPlusChallengesSayItemLinkButton',
    })

    SayButton.Text= WoWTools_LabelMixin:Create(SayButton)
    SayButton.Text:SetPoint('BOTTOM', SayButton, 'TOP',0, 4)


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
        Save().sayButtonPoint={self:GetPoint(1)}
        self:Raise()
    end)

    SayButton:SetScript("OnMouseUp", ResetCursor)
    SayButton:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            self:Settings(true)
        else
             MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
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
    function SayButton:set_scale()
        self:SetScale(Save().endKeystoneSayScale or 1)
    end

    function SayButton:Settings(isSay)
        local info, bagID, slotID= WoWTools_BagMixin:Ceca(nil, {isKeystone=true})
        local level= C_MythicPlus.GetOwnedKeystoneLevel()
        if bagID and slotID then

           self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
        else
            self:Reset()
            local icon = GetItemButtonIconTexture(self)
            if icon then
                icon:SetAtlas(WoWTools_DataMixin.Icon.icon)
            end
        end
        self:SetItemButtonCount(level)
        self.Text:SetText(info and info.hyperlink or (WoWTools_DataMixin.onlyChinese and '无' or NONE))

        if isSay and info and info.hyperlink then
            WoWTools_ChatMixin:Chat(info.hyperlink, nil, nil)
        end
    end

    SayButton:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self:Reset()
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

    SayButton:set_scale()

    Init=function()
        SayButton:SetShown(not Save().hideEndKeystoneSay)
    end
end














function WoWTools_ChallengeMixin:Say_ChallengeComplete()
    Init()
end

function WoWTools_ChallengeMixin:Say_ChallengeComplete_Menu(_, root)
    if SayButton then
       -- Init_Menu(SayButton, root)
    end
end
