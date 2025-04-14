
local function Save()
    return WoWToolsSave['Plus_Tootips']
end



--专业
--lizzard_Professions.lua
function WoWTools_TooltipMixin.Events.Blizzard_Professions()
    hooksecurefunc(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo)
        if currencyInfo then
            local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID()
            local currencyTypesID = nodeID and Professions.GetCurrencyTypesID(nodeID)
            if currencyTypesID then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                WoWTools_TooltipMixin:Set_Currency(GameTooltip, currencyTypesID)--货币
                GameTooltip:AddDoubleLine('nodeID', '|cffffffff'..nodeID..'|r')
            end
        end
    end)

    --专精，技能，查询
    hooksecurefunc(ProfessionsSpecPathMixin, 'OnEnter', function(f)
        if f.nodeID then--f.nodeInfo.ID
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('nodeID '..f.nodeID, f.entryID and 'entryID '..f.entryID)

            local name= WoWTools_TooltipMixin.WoWHead..'profession-trait/'..(f.nodeID or '')
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {name=name})
            GameTooltip:Show()
        end
    end)
end








--飞行点，加名称
function WoWTools_TooltipMixin.Events.Blizzard_FlightMap()
    hooksecurefunc(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(f)
        local info= f.taxiNodeData
        if info then
            GameTooltip:AddDoubleLine('nodeID '..(info.nodeID or ''), 'slotIndex '..(info.slotIndex or ''))
            GameTooltip:Show()
        end
    end)
end

function WoWTools_TooltipMixin.Events.Blizzard_PlayerChoice()
    hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(f)
        if f.optionInfo and f.optionInfo.spellID then
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(f.optionInfo.spellID)
            GameTooltip:Show()
        end
    end)
end








--要塞，技能树
function WoWTools_TooltipMixin.Events.Blizzard_OrderHallUI()

    hooksecurefunc(GarrisonTalentButtonMixin, 'OnEnter', function(f)--Blizzard_OrderHallTalents.lua
        local info=f.talent--C_Garrison.GetTalentInfo(f.talent.id)
        if not info or not info.id then
            return
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('talentID '..info.id, info.icon and '|T'..info.icon..':0|t'..info.icon)
        if info.ability and info.ability.id and info.ability.id>0 then
            GameTooltip:AddDoubleLine('ability '..info.ability.id, info.ability.icon and '|T'..info.ability.icon..':0|t'..info.ability.icon)
        end
        GameTooltip:Show()
    end)
    hooksecurefunc(GarrisonTalentButtonMixin, 'SetTalent', function(f)--是否已激活, 和等级
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















function WoWTools_TooltipMixin.Events.Blizzard_GenericTraitUI()
    GenericTraitFrame.Currency:HookScript('OnEnter', function(f)
        local currencyInfo = f:GetParent().treeCurrencyInfo and f:GetParent().treeCurrencyInfo[1] or {}
        if not currencyInfo.traitCurrencyID or currencyInfo.traitCurrencyID<=0 then
            return
        end
        local overrideIcon = select(4, C_Traits.GetTraitCurrencyInfo(currencyInfo.traitCurrencyID))
        GameTooltip:AddDoubleLine(format('traitCurrencyID: %d', currencyInfo.traitCurrencyID), format('|T%d:0|t%d', overrideIcon or 0, overrideIcon or 0))
        GameTooltip:Show()
    end)
end













--宠物手册， 召唤随机，偏好宠物，技能ID 
function WoWTools_TooltipMixin.Events.Blizzard_Collections()
    hooksecurefunc('PetJournalSummonRandomFavoritePetButton_OnEnter', function()--PetJournalSummonRandomFavoritePetButton
        WoWTools_TooltipMixin:Set_Spell(GameTooltip, 243819)
        GameTooltip:Show()
    end)
end


















--天赋 ClassTalentSpecTabMixin
function WoWTools_TooltipMixin.Events.Blizzard_ClassTalentUI()
    hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecFrame', function(btn)
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

                frame.specIDLabel= WoWTools_LabelMixin:Create(frame, {mouse=true, size=18, copyFont=frame.RoleName})
                frame.specIDLabel:SetPoint('LEFT', frame.specIcon, 'RIGHT', 12, 0)
                frame.specIDLabel:SetScript('OnLeave', function(s) s:SetAlpha(1) GameTooltip_Hide() end)
                frame.specIDLabel:SetScript('OnEnter', function(s)
                    GameTooltip:SetOwner(s, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_TooltipMixin.addName)
                    local specIndex= s:GetParent().specIndex
                    if specIndex then
                        local specID, name, _, icon= GetSpecializationInfo(specIndex)
                        if specID then
                            GameTooltip:AddLine(' ')
                            GameTooltip:AddLine(name)
                            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '专精' or SPECIALIZATION)..' ID', specID)
                            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '专精' or SPECIALIZATION)..' Index', specIndex)
                            if icon then
                                GameTooltip:AddDoubleLine(icon and '|T'..icon..':0|t'..icon)
                            end
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
function WoWTools_TooltipMixin.Events.Blizzard_ChallengesUI()
    hooksecurefunc(ChallengesKeystoneFrameAffixMixin, 'OnEnter',function(f)
        if f.affixID then
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
            WoWTools_TooltipMixin:Set_Web_Link(GameTooltip, {type='affix', id=f.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
end













function WoWTools_TooltipMixin.Events:Blizzard_AchievementUI()
    hooksecurefunc(AchievementTemplateMixin, 'Init', function(frame)
        if frame.Shield and frame.id then
            if not frame.AchievementIDLabel  then
                frame.AchievementIDLabel= WoWTools_LabelMixin:Create(frame.Shield)
                frame.AchievementIDLabel:SetPoint('TOP', frame.Shield.Icon)
                frame.Shield:SetScript('OnEnter', function(f)
                    local achievementID= f:GetParent().id
                    if achievementID then
                        GameTooltip:SetOwner(f:GetParent(), "ANCHOR_RIGHT")
                        GameTooltip:ClearLines()
                        GameTooltip:SetAchievementByID(achievementID)
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddDoubleLine('|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY), WoWTools_DataMixin.Icon.left)
                        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_TooltipMixin.addName)
                        GameTooltip:Show()
                    end
                    f:SetAlpha(0.5)
                end)
                frame.Shield:SetScript('OnLeave', function(f) f:SetAlpha(1) GameTooltip_Hide() end)
                frame.Shield:SetScript('OnMouseUp', function(f) f:SetAlpha(0.5) end)
                frame.Shield:SetScript('OnMouseDown', function(f) f:SetAlpha(0.3) end)
                frame.Shield:SetScript('OnClick', function(f)
                    local achievementID= f:GetParent().id
                    local achievementLink = achievementID and GetAchievementLink(achievementID)
                    if achievementLink then
                        WoWTools_ChatMixin:Chat(achievementLink)
                    end
                end)
                frame.Shield:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
            end
        end
        if frame.AchievementIDLabel then
            local text= frame.id
            local flags= frame.id and select(9, GetAchievementInfo(frame.id))
            if flags==0x20000 then
                text= WoWTools_DataMixin.Icon.net2..'|cff00ccff'..frame.id..'|r'
            end
            frame.AchievementIDLabel:SetText(text or '')
        end
    end)
    hooksecurefunc('AchievementFrameComparison_UpdateDataProvider', function()--比较成就, Blizzard_AchievementUI.lua
        local frame= AchievementFrameComparison.AchievementContainer.ScrollBox
        if not frame:GetView() then
            return
        end
        for _, button in pairs(frame:GetFrames() or {}) do
            if not button.OnEnter then
                button:SetScript('OnLeave', GameTooltip_Hide)
                button:SetScript('OnEnter', function(f)
                    if f.id then
                        GameTooltip:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                        GameTooltip:ClearLines()
                        GameTooltip:SetAchievementByID(f.id)
                        GameTooltip:Show()
                    end
                end)
                if button.Player and button.Player.Icon and not button.Player.idText then
                    button.Player.idText= WoWTools_LabelMixin:Create(button.Player)
                    button.Player.idText:SetPoint('LEFT', button.Player.Icon, 'RIGHT', 0, 10)
                end
            end
            if button.Player and button.Player.idText then
                local flags= button.id and select(9, GetAchievementInfo(button.id))
                if flags==0x20000 then
                    button.Player.idText:SetText(WoWTools_DataMixin.Icon.net2..'|cffff00ff'..button.id..'|r')
                else
                    button.Player.idText:SetText(button.id or '')
                end
            end
        end
    end)
    hooksecurefunc('AchievementFrameComparison_SetUnit', function(unit)--比较成就
        local text= WoWTools_UnitMixin:GetPlayerInfo({unit=unit, reName=true, reRealm=true})--玩家信息图标
        if text~='' then
            AchievementFrameComparisonHeaderName:SetText(text)
        end
    end)
    if AchievementFrameComparisonHeaderPortrait then
        AchievementFrameComparisonHeader:EnableMouse(true)
        AchievementFrameComparisonHeader:HookScript('OnLeave', GameTooltip_Hide)
        AchievementFrameComparisonHeader:HookScript('OnEnter', function()
            local unit= AchievementFrameComparisonHeaderPortrait.unit
            if unit then
                GameTooltip:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                GameTooltip:ClearLines()
                GameTooltip:SetUnit(unit)
                GameTooltip:Show()
            end
        end)
    end
    if Save().AchievementFrameFilterDropDown then--保存，过滤
        AchievementFrame_SetFilter(Save().AchievementFrameFilterDropDown)
    end
    hooksecurefunc('AchievementFrame_SetFilter', function(value)
        Save().AchievementFrameFilterDropDown = value
    end)

end