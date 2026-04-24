--地下堡 C_DelvesUI.GetTraitTreeForCompanion()
local function Save()
    return WoWToolsSave['Plus_Gossip']
end
local maxCheck, completeCheck



local function P_Spell(option)
    if not option.spellID then
        return
    end
    SpellEventListener:AddCancelableCallback(option.spellID, function()
        print(
                WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|T'..(option.icon or 0)..':0|t',

                option.spellID and WoWTools_HyperLink:CN_Link(
                    C_Spell.GetSpellLink(option.spellID),
                    {spellID=option.spellID, isName=true}
                )
                or WoWTools_TextMixin:CN(option.name)
            )
    end)
end

local function P_Reward(reward)
    if reward.rewardType == Enum.GossipOptionRewardType.Item then
        ItemEventListener:AddCancelableCallback(reward.id, function()
            print(reward.index..')',
                WoWTools_HyperLink:CN_Link(
                    reward.context and C_Item.GetDelvePreviewItemLink(reward.id, reward.context)
                    or WoWTools_ItemMixin:GetLink(reward.id)
                    or C_Item.GetItemNameByID(reward.id),

                    {isName=true}
                )
                or ('|T'..(select(5, C_Item.GetItemInfoInstant(reward.id)) or 0)..':0|t'),
                ' x'..(reward.quantity or 1)
            )
        end)

    elseif reward.rewardType== Enum.GossipOptionRewardType.Currency then
        print(reward.index..')',
            WoWTools_CurrencyMixin:GetLink(reward.id, nil, nil, true),
            ' x'..(reward.quantity or 1)
        )
    end
end















local function Get_Options(self)
    local gossipOptions= self.gossipOptions or C_GossipInfo.GetOptions() or {}

    local num= #gossipOptions
    local isSetMaxLevel= Save().delvesDifficultyMaxLevel
    local isSetComplete= Save().delvesDifficultyCompleteLevel



    local Option, availableLevel, completeLevel
    for level=num, 1, -1 do
        local option= gossipOptions[level] or {}
        if IsInGroup() then
            C_DelvesUI.RequestPartyEligibilityForDelveTiers(gossipOptions[num].gossipOptionID)
        end

        if option.status == Enum.GossipOptionStatus.AlreadyComplete then
            completeLevel= completeLevel or level
            availableLevel= availableLevel or level
            if isSetComplete then
                Option= Option or option
            end
        elseif option.status == Enum.GossipOptionStatus.Available then
            availableLevel= availableLevel or level
            if isSetMaxLevel then
                Option= Option or option
            end
        end

        if completeLevel and availableLevel then
            break
        end
    end

    return Option, availableLevel, completeLevel, num
end


local function Set_DelvesDifficultyPickerFrame(option)
    if option then
        DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:Hide();
        DelvesDifficultyPickerFrame:SetSelectedLevel(option.orderIndex);
        DelvesDifficultyPickerFrame:UpdateWidgets(option.gossipOptionID);
        DelvesDifficultyPickerFrame:SetSelectedOption(option);
        DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
        DelvesDifficultyPickerFrame:UpdatePortalButtonState();
        local pdeID = C_DelvesUI.GetTieredEntrancePDEID();
        local level= option.orderIndex + 1
        if not InCombatLockdown() then
            SetCVarTableValue('lastSelectedTieredEntranceTier', pdeID, level);
        end
        DelvesDifficultyPickerFrame.Dropdown:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..'|cnGREEN_FONT_COLOR:'
            ..(WoWTools_TextMixin:CN(option.name) or level)
        )
    end
end



local function Run()
    maxCheck:clear()
    if not DelvesDifficultyPickerFrame:IsVisible() or not DelvesDifficultyPickerFrame.EnterDelveButton:IsEnabled() then
        return
    end

    local isEnabled= Save().gossip and not IsModifierKeyDown()
    if isEnabled then
        local Option= Get_Options(DelvesDifficultyPickerFrame)

        Set_DelvesDifficultyPickerFrame(Option)

        Option= Option or DelvesDifficultyPickerFrame:GetSelectedOption()
        if Option and Option.name then
            P_Spell(Option)

            for index, reward in ipairs(Option.rewards or {}) do
                if reward.id then
                    reward.index= index
                    P_Reward(reward)
                end
            end
        end
        DelvesDifficultyPickerFrame.EnterDelveButton:Click()
    end
end















--Menu.ModifyMenu("MENU_DELVES_DIFFICULTY", Init_Menu)
local function Init()
--最高等级
    maxCheck= CreateFrame('CheckButton', 'WoWToolsDelveDifficultyMaxCheck', DelvesDifficultyPickerFrame.CloseButton, 'UICheckButtonTemplate')
    function maxCheck:clear()
        self:UnregisterEvent('MODIFIER_STATE_CHANGED')
        if self.time then
            self.time:Cancel()
            self.time= nil
        end
        WoWTools_CooldownMixin:Setup(DelvesDifficultyPickerFrame)
    end
    function maxCheck:settings()
        if Save().gossip then
            self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        else
            self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        end
    end
    WoWTools_TextureMixin:SetCheckBox(maxCheck)
    maxCheck:SetPoint('TOPLEFT', DelvesDifficultyPickerFrame.Dropdown, "BOTTOMLEFT", 0, -42)
    maxCheck.name=WoWTools_DataMixin.onlyChinese and '最高' or BEST
    maxCheck.Text:SetText(maxCheck.name)
    maxCheck:SetScript('OnLeave', GameTooltip_Hide)
    maxCheck:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_TextMixin:GetEnabeleDisable(Save().gossip))
        GameTooltip:Show()
    end)
    maxCheck:SetScript('OnMouseDown', function(self)
        Save().delvesDifficultyMaxLevel= not Save().delvesDifficultyMaxLevel and true or nil
        Save().delvesDifficultyCompleteLevel= nil
        completeCheck:SetChecked(false)
        self:clear()
    end)
    maxCheck:SetScript('OnHide',  maxCheck.clear)
    maxCheck:SetScript('OnEvent', maxCheck.clear)
    maxCheck:settings()
    maxCheck:SetChecked(Save().delvesDifficultyMaxLevel)
    DelvesDifficultyPickerFrame.Dropdown:HookScript('OnMouseDown', function()
        maxCheck:clear()
    end)










--已完成，这个可能没用
    completeCheck= CreateFrame('CheckButton', 'WoWToolsDelveDifficultyMaxCheck', DelvesDifficultyPickerFrame.CloseButton, 'UICheckButtonTemplate')
    WoWTools_TextureMixin:SetCheckBox(completeCheck)
    completeCheck:SetPoint('TOPLEFT', maxCheck, 'BOTTOMLEFT')
    completeCheck.name=WoWTools_DataMixin.onlyChinese and '已完成' or ACCOUNT_COMPLETED_QUEST_NOTICE_LABEL
    completeCheck.Text:SetText(completeCheck.name)
    completeCheck:SetScript('OnLeave', GameTooltip_Hide)
    completeCheck:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_TextMixin:GetEnabeleDisable(Save().gossip))
        GameTooltip:Show()
    end)
    completeCheck:SetChecked(Save().delvesDifficultyCompleteLevel)
    function completeCheck:settings()
        if Save().gossip then
            self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        else
            self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
        end
        maxCheck:clear()
    end
    completeCheck:settings()
    completeCheck:SetScript('OnMouseDown', function()
        Save().delvesDifficultyCompleteLevel= not Save().delvesDifficultyCompleteLevel and true or nil
        Save().delvesDifficultyMaxLevel= nil
        maxCheck:SetChecked(false)
    end)











--自动选择
    DelvesDifficultyPickerFrame:HookScript('OnShow', function(self)
        if
            not canaccesstable(self.gossipOptions)
            or self.EnterDelveButton:HasSecretValues()
            or (IsInGroup() and not UnitIsGroupLeader('player'))
        then
            return
        end

        local isEnabled= Save().gossip and not IsModifierKeyDown()
        local Option, availableLevel, completeLevel, num= Get_Options(self)
        if Option then
            Set_DelvesDifficultyPickerFrame(Option)
        end
        if isEnabled and self.EnterDelveButton:IsEnabled() then
            WoWTools_CooldownMixin:Setup(self, nil, 3, nil, true, true, nil)--冷却条
            maxCheck:RegisterEvent('MODIFIER_STATE_CHANGED')

            if maxCheck.time then
                maxCheck.time:Cancel()
            end
            maxCheck.time= C_Timer.NewTimer(3, Run)

            local option= Option or self:GetSelectedOption() or {}
            WoWTools_DataMixin:Load(option.spellID, 'spell')

            print( WoWTools_GossipMixin.addName
                ..'|A:NPE_Icon:0:0|aAlt'
                ..GREEN_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '取消' or CANCEL),

                option.spellID and WoWTools_HyperLink:CN_Link(
                    C_Spell.GetSpellLink(option.spellID),
                    {spellID=option.spellID, isName=true}
                )
                or WoWTools_TextMixin:CN(option.name),
                DRAGONFLIGHT_GREEN_COLOR:WrapTextInColorCode((availableLevel or '?')..'/'..(num or '?'))
            )
        end

        maxCheck.Text:SetText(
            (availableLevel and maxCheck.name or DISABLED_FONT_COLOR:WrapTextInColorCode(maxCheck.name))
            ..' '..(availableLevel or '?')..'/'..(num or '?')
        )

        completeCheck.Text:SetText(
            (completeLevel and completeCheck.name or DISABLED_FONT_COLOR:WrapTextInColorCode(completeCheck.name))
            ..' '..(completeLevel or '?')..'/'..(num or '?')
        )
    end)


--等级说明
    DelvesDifficultyPickerFrame.Text2= maxCheck:CreateFontString(nil, 'BORDER', 'ChatFontNormal')
    DelvesDifficultyPickerFrame.Text2:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    DelvesDifficultyPickerFrame.Text2:SetPoint('TOP', DelvesDifficultyPickerFrame.Dropdown, 'BOTTOM', 0, -12)
    WoWTools_DataMixin:Hook(DelvesDifficultyPickerFrame, 'SetSelectedOption', function(self, Option)
        self.Text2:SetText('')
        if Option and Option.spellID then
            local spell = Spell:CreateFromSpellID(Option.spellID)
            spell:ContinueWithCancelOnSpellLoad(function()
                self.Text2:SetText(WoWTools_TextMixin:CN(spell:GetSpellDescription()))
            end)
        end
    end)

    Init=function()
        maxCheck:settings()
        completeCheck:settings()
    end
end



local ownerID
function WoWTools_GossipMixin:Init_Delves()
    if C_AddOns.IsAddOnLoaded('Blizzard_DelvesDifficultyPicker') then
        Init()
    elseif not ownerID then
        ownerID=EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_DelvesDifficultyPicker' then
                Init()
                ownerID= nil
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end
end