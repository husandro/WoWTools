--地下堡 C_DelvesUI.GetTraitTreeForCompanion()

local function Save()
    return WoWToolsSave['Plus_Gossip']
end





local function Init_OnShow(self)
    if not Save().gossip or IsModifierKeyDown() or not self.gossipOptions then
        return
    end
    local num= #self.gossipOptions
    if num==0 then
        return
    end
    local Option
    do
        if Save().delvesDifficultyMaxLevel then
            for i=num, 1, -1 do
                local option= self.gossipOptions[i] or {}
                if IsInGroup() then
                    C_DelvesUI.RequestPartyEligibilityForDelveTiers(self.gossipOptions[num].gossipOptionID)
                end

                if option.status == Enum.GossipOptionStatus.Available or option.status == Enum.GossipOptionStatus.AlreadyComplete then
                    DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:Hide();
                    DelvesDifficultyPickerFrame:SetSelectedLevel(option.orderIndex);
                    DelvesDifficultyPickerFrame:UpdateWidgets(option.gossipOptionID);
                    DelvesDifficultyPickerFrame:SetSelectedOption(option);
                    DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:SetRewards();
                    DelvesDifficultyPickerFrame:UpdatePortalButtonState();

                    if not InCombatLockdown() then
                        SetCVar('lastSelectedDelvesTier', option.orderIndex + 1)
                    end

                    Option=option
                    break
                end
            end
        end
    end



    if self.EnterDelveButton and self.EnterDelveButton:IsEnabled() then
        local option= Option or self:GetSelectedOption()
        if option and option.name then

            print(
                WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|T'..(option.icon or 0)..':0|t',

                option.spellID and WoWTools_HyperLink:CN_Link(
                    C_Spell.GetSpellLink(option.spellID),
                    {spellID=option.spellID, isName=true}
                )
                or WoWTools_TextMixin:CN(option.name)
            )

            for _, reward in ipairs(option.rewards or {}) do
                if reward.rewardType == Enum.GossipOptionRewardType.Item and reward.id then
                    WoWTools_DataMixin:Load({type='item', id=reward.id})
                    print(
                        WoWTools_HyperLink:CN_Link(
                            WoWTools_ItemMixin:GetLink(reward.id) or C_Item.GetItemNameByID(reward.id),
                            {isName=true}
                        )
                        or ('|T'..(C_Item.GetItemIconByID(reward.id) or 0)..':0|t'),
                        ' x'..(reward.quantity or 1)
                    )
                end
            end
        end
        self.EnterDelveButton:Click()

        print(
            '    |cff828282|A:NPE_Icon:0:0|aAlt',
            WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
            WoWTools_DataMixin.Icon.icon2
        )
    end
end












local function Init_Menu(_, root)
    local options = DelvesDifficultyPickerFrame:GetOptions();
    if not options then
        return;
    end
    root:CreateDivider()
    local sub= root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '最高等级' or BEST, function()
        return Save().delvesDifficultyMaxLevel
    end, function()
        Save().delvesDifficultyMaxLevel= not Save().delvesDifficultyMaxLevel and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.addName)
        tooltip:AddDoubleLine(WoWTools_GossipMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(Save().delvesDifficultyMaxLevel))
    end)
    sub:SetEnabled(Save().gossip and true or false)
end













function WoWTools_GossipMixin:Init_Delves()
    DelvesDifficultyPickerFrame:HookScript('OnShow', Init_OnShow)
    Menu.ModifyMenu("MENU_DELVES_DIFFICULTY", function(...) Init_Menu(...) end)
    WoWTools_GossipMixin.Init_Delves=function()end
end