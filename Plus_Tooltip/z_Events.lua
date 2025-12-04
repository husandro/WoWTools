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
            WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
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
            WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
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
        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
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






























--天赋 ClassTalentSpecTabMixin
function WoWTools_TooltipMixin.Events:Blizzard_PlayerSpells()
    WoWTools_DataMixin:Hook(PlayerSpellsFrame.SpecFrame, 'UpdateSpecFrame', function(btn)
        if not C_SpecializationInfo.IsInitialized() then
            return
        end

        for frame in btn.SpecContentFramePool:EnumerateActive() do
            if not frame.specIDLabel then
                frame.specIcon= frame:CreateTexture(nil, 'BORDER')
                frame.specIcon:SetPoint('TOP', frame.RoleIcon, 'BOTTOM', -2, -4)
                frame.specIcon:SetSize(22,22)

                frame.specIconBorder= frame:CreateTexture(nil, 'ARTWORK')
                frame.specIconBorder:SetPoint('CENTER', frame.specIcon,1.2,-1.2)
                frame.specIconBorder:SetAtlas('bag-border')
                frame.specIconBorder:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
                frame.specIconBorder:SetSize(32,32)

                frame.specIDLabel= frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed2') --WoWTools_LabelMixin:Create(frame, {mouse=true, size=18, copyFont=frame.RoleName})
                frame.specIDLabel:SetPoint('LEFT', frame.specIcon, 'RIGHT', 12, 0)
                frame.specIDLabel:SetScript('OnLeave', function(s) s:SetAlpha(1) GameTooltip_Hide() end)
                frame.specIDLabel:SetScript('OnEnter', function(s)
                    GameTooltip:SetOwner(s, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    local specIndex= s:GetParent().specIndex
                    if specIndex then
                        local specID, name, _, icon= GetSpecializationInfo(specIndex)
                        if specID then
                            GameTooltip:AddDoubleLine(
                                WoWTools_TextMixin:CN(name),
                                icon and '|T'..icon..':0|t|cffffffff'..icon
                            )
                            GameTooltip:AddDoubleLine(
                                'specID|cffffffff'..WoWTools_DataMixin.Icon.icon2..specID,
                                'Index |cffffffff'..(specIndex or '')
                            )
                        end
                    end
                    GameTooltip:Show()
                    s:SetAlpha(0.5)
                end)
            end
            local specID, icon, _
            if frame.specIndex then
                specID, _, _, icon= GetSpecializationInfo(frame.specIndex)
            end
            frame.specIDLabel:SetText(specID or '')
            frame.specIcon:SetTexture(icon or 0)
        end
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
        WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
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
                    WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', GameTooltip)
                end
            end)
        end
    end
end





--挑战, AffixID Blizzard_ScenarioObjectiveTracker.lua
function WoWTools_TooltipMixin.Events:Blizzard_ObjectiveTracker()
    WoWTools_DataMixin:Hook(ScenarioChallengeModeAffixMixin, 'OnEnter', function(frame)
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

    if ScenarioChallengeModeBlock and ScenarioChallengeModeBlock.Affixes and ScenarioChallengeModeBlock.Affixes[1] then--11.2.7没发现
        ScenarioChallengeModeBlock.Affixes[1]:HookScript('OnEnter', function(frame)
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
end


function WoWTools_TooltipMixin.Events:Blizzard_HousingTemplates()
--Blizzard_HousingCatalogEntry.lua
    WoWTools_DataMixin:Hook(HousingCatalogEntryMixin, 'OnLoad', function(btn)
        btn.InfoText:SetFontObject('GameFontWhite')--有点大
--空间，大小
        btn.placementCostLabel= btn:CreateFontString(nil, nil, 'GameFontWhite')
        btn.placementCostLabel:SetPoint('BOTTOMRIGHT', btn.InfoText, 'TOPRIGHT')
--添加，追踪，按钮
        btn.trackableButton= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
        btn.trackableButton:SetSize(18,18)
        btn.trackableButton:SetPoint('TOPLEFT', 3., -2)
        btn.trackableButton.texture= btn.trackableButton:CreateTexture(nil, 'BORDER')
        btn.trackableButton.texture:SetAllPoints()
        btn.trackableButton.texture:SetAtlas('Waypoint-MapPin-Tracked')
        btn.trackableButton:SetScript('OnLeave', GameTooltip_Hide)
        btn.trackableButton.tooltip= self.addName..WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
        btn.trackableButton:SetScript('OnClick', function(b)
            local recordID= b:GetParent().entryInfo.entryID.recordID
            if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID) then
                C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, recordID, Enum.ContentTrackingStopType.Manual)
            else
                C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, recordID)
            end
            C_Timer.After(0.2, function()
                local isTrackable = C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID)
                b.texture:SetDesaturated(not isTrackable)
                b.texture:SetAlpha(isTrackable and 1 or 0.5)
            end)
        end)
--可获得首次收集奖励
        btn.firstXP= btn:CreateTexture()
        btn.firstXP:SetPoint('BOTTOM', btn.placementCostLabel)
        btn.firstXP:SetSize(23,23)
        btn.firstXP:SetAtlas('GarrMission_CurrencyIcon-Xp')
        btn.firstXP:SetAlpha(0.7)

        btn.Outdoors= btn:CreateTexture()
        btn.Outdoors:SetPoint('BOTTOM', btn.CustomizeIcon, 'TOP')
        btn.Outdoors:SetSize(23,23)
        btn.Outdoors:SetAtlas('house-outdoor-budget-icon')

        btn.Indoors= btn:CreateTexture()
        btn.Indoors:SetPoint('BOTTOM', btn.Outdoors, 'TOP')
        btn.Indoors:SetSize(23,23)
        btn.Indoors:SetAtlas('house-room-limit-icon')
    end)
    WoWTools_DataMixin:Hook(HousingCatalogEntryMixin, 'UpdateVisuals', function(btn)
        local placementCost, r,g,b
        local isTrackable= nil
        local show, xp, indoors, outdoors
        if btn:HasValidData() then

            show= ContentTrackingUtil.IsContentTrackingEnabled()--追踪当前可用
                and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, btn.entryInfo.entryID.recordID)--追踪功能对此物品可用

            isTrackable= show and C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, btn.entryInfo.entryID.recordID)--正在追踪

            r,g,b= WoWTools_ItemMixin:GetColor(btn.entryInfo.quality)
            placementCost= btn.entryInfo.placementCost

            if btn:IsBundleEntry() then
                --self.InfoText:SetText(self.bundleEntryInfo.quantity)
            elseif btn:IsInMarketView() then
            else
                local numPlaced= btn.entryInfo.numPlaced or 0--已放置
                local numStored=  btn.entryInfo.numStored or 0--储存空间
                if numPlaced>0 or numStored>0 then
                    btn.InfoText:SetText(numPlaced..'/'..numStored)
                end
            end

            xp= btn.entryInfo.firstAcquisitionBonus and btn.entryInfo.firstAcquisitionBonus>0
            indoors= btn.entryInfo.isAllowedIndoors
            outdoors= btn.entryInfo.isAllowedOutdoors
        end

        btn.Background:SetVertexColor(r or 1, g or 1, b or 1, 1)
        btn.placementCostLabel:SetText(placementCost and placementCost..'|A:House-Decor-budget-icon:0:0|a' or '')

        btn.trackableButton:SetShown(show)
        btn.trackableButton.texture:SetDesaturated(isTrackable==false)
        btn.trackableButton.texture:SetAlpha(isTrackable==true and 1 or 0.5)

        btn.firstXP:SetShown(xp)
        btn.Indoors:SetShown(indoors)
        btn.Outdoors:SetShown(outdoors)
    end)



    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'AddTooltipTrackingLines', function(btn, tooltip)
        local entryInfo= btn:HasValidData() and btn.entryInfo
        if not entryInfo then
            return
        end
        tooltip:AddLine(' ')
        local textLeft, portrait= WoWTools_TooltipMixin:Set_HouseItem(tooltip, entryInfo)
        if tooltip.textLeft then
            tooltip.textLeft:SetText(textLeft or '')
            tooltip.Portrait:settings(portrait)
        end
        tooltip:Show()
    end)

--列表，数量
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'OnLoad', function(frame)
        frame.numItemLabel= frame:CreateFontString(nil, nil, 'GameFontWhite')
        frame.numItemLabel:SetPoint('LEFT', frame.CategoryText, 'RIGHT', 4, 0)
    end)

    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'SetCatalogElements', function(frame)
        frame.numItemLabel:SetText(frame.ScrollBox:GetDataProviderSize() or '')
    end)
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'ClearCatalogData', function(frame)
        frame.numItemLabel:SetText('')
    end)
end