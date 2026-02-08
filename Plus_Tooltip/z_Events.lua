--专业
--lizzard_Professions.lua
function WoWTools_TooltipMixin.Events:Blizzard_Professions()
    WoWTools_DataMixin:Hook(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo)
        if currencyInfo then
            local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID()
            local currencyTypesID = nodeID and Professions.GetCurrencyTypesID(nodeID)
            if currencyTypesID then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                self:Set_Currency(GameTooltip, currencyTypesID)--货币
                GameTooltip:AddDoubleLine('nodeID', '|cffffffff'..nodeID..'|r')
            end
        end
    end)

    --专精，技能，查询
    WoWTools_DataMixin:Hook(ProfessionsSpecPathMixin, 'OnEnter', function(f)
        if f.nodeID then--f.nodeInfo.ID
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('nodeID '..f.nodeID, f.entryID and 'entryID '..f.entryID)

            local name= self.WoWHead..'profession-trait/'..(f.nodeID or '')
            self:Set_Web_Link(GameTooltip, {name=name})
            --GameTooltip:Show()
            WoWTools_TooltipMixin:CalculatePadding()
        end
    end)
end













--[[
Blizzard_TalentButtonSpend.lua
TalentButtonSpendMixin
local canPurchase = self:CanPurchaseRank();
local canRefund = self:CanRefundRank();
local canRepurchase = self:CanCascadeRepurchaseRanks();
local isGhosted = self:IsGhosted();
]]
function WoWTools_TooltipMixin.Events:Blizzard_RemixArtifactUI()
    RemixArtifactFrame.Currency:ClearAllPoints()
    RemixArtifactFrame.Currency:SetPoint('RIGHT', RemixArtifactFrame.CommitConfigControls, 'LEFT')
    RemixArtifactFrame.Currency:HookScript('OnEnter', function(f)
        if GameTooltip:IsShown() or not f.traitCurrencyID or f.traitCurrencyID<=0 then
            return
        end
        local overrideIcon = select(4, C_Traits.GetTraitCurrencyInfo(f.traitCurrencyID))

        GameTooltip:SetOwner(f, "ANCHOR_BOTTOM")
        GameTooltip:SetText('traitCurrencyID'..WoWTools_DataMixin.Icon.icon2..f.traitCurrencyID)
        if overrideIcon then
            GameTooltip:AddLine('|T'..overrideIcon..':0|t'..overrideIcon)
        end
        GameTooltip:Show()
    end)


--需要花费，提示
    local function Setup_Coat(frame, treeID)
        if not treeID or not frame:IsShown() then
            return
        end
        local needCost=0
        for btn in frame:EnumerateAllTalentButtons() do
            local nodeID = btn:GetNodeID()
            local cost = nodeID and frame:GetNodeCost(nodeID)--amount ID
            local amount
            local levelText
            local data= btn:GetNodeInfo()
            local scale=1
            if data and data.currentRank and data.maxRanks and data.currentRank< data.maxRanks then
                if not data.canRefundRank then
                    for _, traitCurrencyCost in ipairs(cost) do
                        local treeCurrency = frame.treeCurrencyInfoMap[traitCurrencyCost.ID];
                        amount =  WoWTools_DataMixin:MK(traitCurrencyCost.amount, 3)
                        if amount then
                            needCost= needCost+ traitCurrencyCost.amount
                            if treeCurrency and treeCurrency.quantity < traitCurrencyCost.amount then
                                amount = WARNING_FONT_COLOR:WrapTextInColorCode(amount)
                            elseif data.canPurchaseRank then
                                amount= '|cnGREEN_FONT_COLOR:'..amount..'|r'
                                scale=1.5
                            end
                            break
                        end
                    end
                end

                if data.currentRank>0 then
                    levelText= '/'..data.maxRanks
                end

            end

            if amount and not btn.costLabel then
                btn.costLabel= WoWTools_LabelMixin:Create(btn)
                btn.costLabel:SetPoint('TOP', btn, 'BOTTOM')
            end
            if btn.costLabel then
                btn.costLabel:SetText(amount or '')
                btn.costLabel:SetScale(scale)
            end

            if levelText and not btn.levelLabel then
                btn.levelLabel= WoWTools_LabelMixin:Create(btn, {color={r=1,g=0,b=1}})
                btn.levelLabel:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            end
            if btn.levelLabel then
                btn.levelLabel:SetText(levelText or '')
            end
        end

        frame.NeedostLabe.needCost= needCost

        frame.NeedostLabe:SetText(
            needCost>0 and
            (WoWTools_DataMixin.onlyChinese and '需求' or NEED)..' '..WoWTools_DataMixin:MK(needCost, 3)
            or ''
        )
    end

    RemixArtifactFrame.NeedostLabe= WoWTools_LabelMixin:Create(RemixArtifactFrame.CloseButton, {name='WoWToolsRemixArtifactNeetCostLable', mouse=true, color={r=1,g=1,b=1}})
    RemixArtifactFrame.NeedostLabe:SetPoint('TOPRIGHT', RemixArtifactFrame.Currency, 'BOTTOMRIGHT')
    RemixArtifactFrame.NeedostLabe:SetScript('OnLeave', function(f)
        GameTooltip:Hide()
        f:SetAlpha(1)
    end)
    RemixArtifactFrame.NeedostLabe:SetScript('OnEnter', function(f)
        GameTooltip:SetOwner(f, "ANCHOR_BOTTOM")
        GameTooltip:SetText(WoWTools_TooltipMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(
            format(
                WoWTools_DataMixin.onlyChinese and "还需要再花费%i点%s" or GARRISON_TALENT_TREE_REQUIRED_CURRENCY_SPENT_FORMAT,
                f.needCost or 0,
                WoWTools_DataMixin.onlyChinese and '解锁' or UNLOCK
            )
        )

        GameTooltip:Show()
        f:SetAlpha(0.5)
    end)

    RemixArtifactFrame:HookScript('OnShow', function(frame)
        Setup_Coat(frame, frame:GetTalentTreeID())
    end)
    RemixArtifactFrame:HookScript('OnEvent', function(frame, event, treeID)
        if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" and treeID == frame:GetTalentTreeID() then
            C_Timer.After(0.3, function()
                Setup_Coat(frame, treeID)
            end)
        end
    end)


--学习, 还原 按钮
    local b= WoWTools_ButtonMixin:Cbtn(RemixArtifactFrame.CloseButton, {
        atlas='common-dropdown-icon-play',
        size=23,
        name= 'WoWToolsRemixArtifactAutoAceButton'
    })
    b:SetPoint('LEFT', RemixArtifactFrame.CommitConfigControls.UndoButton, 'RIGHT', 6, 0)
    b:SetPushedAtlas('common-dropdown-icon-next')

    b:SetScript('OnLeave', function() GameTooltip:Hide() end)
    b:SetScript('OnEnter', function(f)
        GameTooltip:SetOwner(f, 'ANCHOR_BOTTOM')
        GameTooltip:SetText(
            (InCombatLockdown() and '|cff606060' or '')
            ..(WoWTools_DataMixin.onlyChinese and '学习' or LEARN)
            ..WoWTools_DataMixin.Icon.left
            ..WoWTools_DataMixin.Icon.icon2
            ..WoWTools_DataMixin.Icon.right
            ..(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
        )
        GameTooltip:Show()
    end)

    b:SetScript('OnClick', function(_, d)
        if InCombatLockdown() then
            return
        end

        for btn in RemixArtifactFrame:EnumerateAllTalentButtons() do
            local data= btn:GetNodeInfo()
            if d=='LeftButton' then
                if data.canPurchaseRank then
                    btn:Click(d)
                end
            elseif d=='RightButton' then
                if data.canRefundRank then
                    btn:Click(d)
                end
            end
        end
    end)

--为最高级，添加 一键升级按钮
C_Timer.After(0.5, function()
    for btn in RemixArtifactFrame:EnumerateAllTalentButtons() do
        local data= btn:GetNodeInfo() or {}

        if data.maxRanks and data.maxRanks>20 then
            b= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
            b:SetNormalAtlas('plunderstorm-icon-upgrade')
            b:SetPoint('LEFT', btn, 'RIGHT', 4,0)
            b:SetScript('OnClick', function(f)
                if f.isIn then
                    f.isStop= true
                    return
                end
                local function setting()
                    if not f.isStop
                        and f:IsVisible()
                        and not IsModifierKeyDown()
                        and f:GetParent():GetNodeInfo().canPurchaseRank
                        and not InCombatLockdown()
                        and C_Traits.PurchaseRank(RemixArtifactFrame:GetConfigID(), f:GetParent():GetNodeID())
                    then
                        f.isIn= true
                        C_Timer.After(0.1, setting)
                    else
                        f.isIn= nil
                        f.isStop= nil
                    end
                end
                setting()
            end)
            b:SetScript('OnEnter', function(f)
                GameTooltip:SetOwner(f, 'ANCHOR_RIGHT')
                GameTooltip:SetText(
                    WoWTools_DataMixin.Icon.icon2
                    ..(WoWTools_DataMixin.onlyChinese and '升到最高级' or format(LEARN_SKILL_TEMPLATE, HONOR_HIGHEST_RANK))
                )
                GameTooltip:Show()
            end)
        end
    end
end)


end















function WoWTools_TooltipMixin.Events:Blizzard_PlayerChoice()
    WoWTools_DataMixin:Hook(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(f)
        if f.optionInfo and f.optionInfo.spellID then
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(f.optionInfo.spellID)
            WoWTools_TooltipMixin:CalculatePadding()
        end
    end)
end

















--要塞，技能树
function WoWTools_TooltipMixin.Events:Blizzard_OrderHallUI()

    WoWTools_DataMixin:Hook(GarrisonTalentButtonMixin, 'OnEnter', function(f)--Blizzard_OrderHallTalents.lua
        local info=f.talent--C_Garrison.GetTalentInfo(f.talent.id)
        if not info or not info.id then
            return
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('talentID '..info.id, info.icon and '|T'..info.icon..':0|t'..info.icon)
        if info.ability and info.ability.id and info.ability.id>0 then
            GameTooltip:AddDoubleLine('ability '..info.ability.id, info.ability.icon and '|T'..info.ability.icon..':0|t'..info.ability.icon)
        end
        WoWTools_TooltipMixin:CalculatePadding()
    end)
    WoWTools_DataMixin:Hook(GarrisonTalentButtonMixin, 'SetTalent', function(f)--是否已激活, 和等级
        local info= f.talent
        if not info or not info.id then
            return
        end

        if info.researched and not f.researchedTexture then
            f.researchedTexture= f:CreateTexture(nil, 'OVERLAY')
            local w,h= f:GetSize()
            f.researchedTexture:SetSize(w/3, h/3)
            f.researchedTexture:SetPoint('BOTTOMRIGHT')
            f.researchedTexture:SetAtlas('common-icon-checkmark')
        end
        if f.researchedTexture then
            f.researchedTexture:SetShown(info.researched)
        end

        local rank
        if info.talentMaxRank and info.talentMaxRank>1 and info.talentRank~= info.talentMaxRank then
            if not info.rankText then
                info.rankText= WoWTools_LabelMixin:Create(f)
                info.rankText:SetPoint('BOTTOMLEFT')
            end
            rank= '|cnGREEN_FONT_COLOR:'..(info.talentRank or 0)..'|r/'..info.talentMaxRank
        end
        if info.rankText then
            info.rankText:SetText(rank or '')
        end
    end)
end























function WoWTools_TooltipMixin.Events:Blizzard_GenericTraitUI()
    GenericTraitFrame.Currency:HookScript('OnLeave', function(f)
        f:SetAlpha(1)
    end)
    GenericTraitFrame.Currency:HookScript('OnEnter', function(f)
        local currencyInfo = f:GetParent().treeCurrencyInfo and f:GetParent().treeCurrencyInfo[1] or {}

        if not currencyInfo.traitCurrencyID or currencyInfo.traitCurrencyID<1 then
            return
        end

        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(f, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine()
        end

        local icon = select(4, C_Traits.GetTraitCurrencyInfo(currencyInfo.traitCurrencyID))

        GameTooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..HEADER_COLON
            ..(currencyInfo.quantity or 0)
            ..'/'
            ..(currencyInfo.maxQuantity or (WoWTools_DataMixin.onlyChinese and '无限' or UNLIMITED)),

            (WoWTools_DataMixin.onlyChinese and '总花费：' or ITEM_UPGRADE_COST_LABEL)..(currencyInfo.spent or 0)
        )
        GameTooltip:AddDoubleLine(
            icon and '|T'..icon..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..icon,
            'traitCurrencyID|cffffffff'..WoWTools_DataMixin.Icon.icon2..currencyInfo.traitCurrencyID
        )

        GameTooltip:Show()
        f:SetAlpha(0.5)
    end)

end

















































--挑战, AffixID
function WoWTools_TooltipMixin.Events:Blizzard_ChallengesUI()
    WoWTools_DataMixin:Hook(ChallengesKeystoneFrameAffixMixin, 'OnEnter',function(f)
        if not f.affixID then
            return
        end
        local name, description, filedataid = C_ChallengeMode.GetAffixInfo(f.affixID)
        if (f.affixID or f.info) then
            if (f.info) then
                local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[f.info.key]
                name = tbl.name
                description = string.format(tbl.desc, f.info.pct)
            else
                name= WoWTools_TextMixin:CN(name)
                description= WoWTools_TextMixin:CN(description)
            end
            GameTooltip:SetText(name, 1, 1, 1, 1, true)
            GameTooltip:AddLine(description, nil, nil, nil, true)
        end
        GameTooltip:AddDoubleLine('affixID '..f.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
        self:Set_Web_Link(GameTooltip, {type='affix', id=f.affixID, name=name, isPetUI=false})--取得网页，数据链接
        WoWTools_TooltipMixin:CalculatePadding()
        --GameTooltip:Show()
    end)
end






--商店
function WoWTools_TooltipMixin.Events:Blizzard_AccountStore()
    WoWTools_DataMixin:Hook(AccountStoreBaseCardMixin, 'OnEnter', function(frame)
        local info= frame.itemInfo
        if not info or not info.id then
            return
        end
        local tooltip = GetAppropriateTooltip()
        tooltip:AddDoubleLine(
            'ID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.id,

            info.creatureDisplayID and 'creatureDisplayID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.creatureDisplayID
        )
        tooltip:AddDoubleLine(
            info.displayIcon and '|T'..info.displayIcon..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..info.displayIcon,
            info.transmogSetID and 'transmogSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..info.transmogSetID
        )
        tooltip:Show()
    end)

--霸业商店
    AccountStoreFrame.StoreDisplay.Footer.CurrencyAvailable:HookScript('OnEnter', function()
        local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
        if accountStoreCurrencyID then
            WoWTools_TooltipMixin:Set_Currency(GetAppropriateTooltip(), accountStoreCurrencyID)
        end
    end)
end




--ActionButton.lua
function WoWTools_TooltipMixin.Events:Blizzard_OverrideActionBar()
    for i= 1, NUM_OVERRIDE_BUTTONS do
        if _G['OverrideActionBarButton'..i] then
            WoWTools_DataMixin:Hook(_G['OverrideActionBarButton'..i], 'SetTooltip', function(frame)
                if not frame.action then
                    return
                end
                local actionType, ID, subType = GetActionInfo(frame.action)
                if actionType and ID then
                        GameTooltip:AddDoubleLine(
                            'action|cffffffff'..WoWTools_DataMixin.Icon.icon2..frame.action,
                            'ID|cffffffff'..WoWTools_DataMixin.Icon.icon2..ID
                        )
                        GameTooltip:AddDoubleLine(
                            actionType and 'actionType|cffffffff'..WoWTools_DataMixin.Icon.icon2..actionType,
                            subType and 'subType|cffffffff'..WoWTools_DataMixin.Icon.icon2..subType
                        )
                    --end
                    WoWTools_TooltipMixin:CalculatePadding()
                end
            end)
        end
    end
end





--挑战, AffixID Blizzard_ScenarioObjectiveTracker.lua
function WoWTools_TooltipMixin.Events:Blizzard_ObjectiveTracker()
    WoWTools_DataMixin:Hook(ScenarioChallengeModeAffixMixin, 'OnEnter', function(frame)--ScenarioObjectiveTracker 12.0 才有
        if frame.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
            GameTooltip:SetText(WoWTools_TextMixin:CN(name), 1, 1, 1, 1, true)
            GameTooltip:AddLine(WoWTools_TextMixin:CN(description), nil, nil, nil, true)
            GameTooltip:AddDoubleLine(
                filedataid and '|T'..filedataid..':'..WoWTools_TooltipMixin.iconSize..'|t|cffffffff'..filedataid,
                'affixID|cffffffff'..WoWTools_DataMixin.Icon.icon2..frame.affixID
            )
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=frame.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
end