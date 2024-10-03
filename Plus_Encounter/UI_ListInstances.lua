--界面, 副本击杀
--Blizzard_EncounterJournal.lua
local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end











local function Init()
    local frame= EncounterJournal.instanceSelect.ScrollBox
    if not frame:GetView() then
        return
    end
    if Save().hideEncounterJournal then
        for _, button in pairs(frame:GetFrames() or {}) do
            if button then
                if button.tipsText then
                    button.tipsText:SetText('')
                end
                if button.challengeText then
                    button.challengeText:SetText('')
                    button.challengeText2:SetText('')
                end
                if button.KeyTexture then
                    button.KeyTexture:SetShown(false)
                    button.KeyTexture.label:SetText('')
                end
            end
        end
        return
    end

    for _, button in pairs(frame:GetFrames() or {}) do--ScrollBox.lua
        if button and button.instanceID then --and button.tooltipTitle--button.bgImage:GetTexture() button.name:GetText()
            local textKill= WoWTools_EncounterMixin:GetInstanceData(button)--界面,击杀,数据
            if not button.tipsText and textKill then
                button.tipsText=WoWTools_LabelMixin:Create(button, {size=e.onlyChinese and 12 or 10, copyFont= not e.onlyChinese and button.name or nil})--10, button.name)
                button.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
                button.tipsText:SetJustifyH('RIGHT')
            end
            if button.tipsText then
                button.tipsText:SetText(textKill or '')
            end


            local instanceName= button.tooltipTitle or button.name:GetText()
            button.mapChallengeModeID=nil
            local challengeText, challengeText2

            for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do--挑战地图 mapChallengeModeID
                e.LoadData({type='mapChallengeModeID',mapChallengeModeID })
                local name= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
                if name==instanceName or name:find(instanceName) then
                    button.mapChallengeModeID= mapChallengeModeID--挑战,地图ID
                    local nu, all, leavel, runScore= 0, 0, 0, 0
                    for _,v in pairs(C_MythicPlus.GetRunHistory(true, true) or {}) do--挑战,全部, 次数
                        if v.mapChallengeModeID==mapChallengeModeID then
                            if v.completed then
                                nu=nu+1
                            end
                            all=all+1
                        end
                    end

                    local affix
                    local affixScores, overAllScore= C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(mapChallengeModeID)--最佳, 词缀
                    if(affixScores and #affixScores > 0) then
                        local nameA, _, filedataidA = C_ChallengeMode.GetAffixInfo(10)
                        local nameB, _, filedataidB = C_ChallengeMode.GetAffixInfo(9)
                        for _, tab in ipairs(affixScores) do
                            if tab.level and tab.level>0 and (tab.name == nameA or tab.name==nameB) then
                                local level= tab.overTime and '|cnRED_FONT_COLOR:'..tab.level..'|r' or tab.level
                                local icon='|T'..(tab.name == nameA and filedataidA or filedataidB)..':0|t'
                                affix= (affix and affix..'|n' or '').. icon..level
                            end
                        end
                    end

                    runScore= overAllScore or 0--最佳, 分数
                    local intimeInfo= C_MythicPlus.GetSeasonBestForMap(mapChallengeModeID)--最佳, 等级
                    if intimeInfo then
                        leavel= intimeInfo.level
                    end
                    if all>0 then
                        local text= '|cff00ff00'..nu..'|r/'..all
                        ..'|n'..'|T4352494:0|t'..leavel
                        ..'|n'..'|A:AdventureMapIcon-MissionCombat:0:0|a'..runScore
                        ..(affix and '|n'..affix or '')

                        local color= C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(runScore)
                        if color then
                            text= color:WrapTextInColorCode(text)
                        end
                        if not challengeText then
                            challengeText= text
                        else
                            challengeText2= text
                        end
                    end
                end
            end

            if not button.challengeText then
                button.challengeText= WoWTools_LabelMixin:Create(button, {size=e.onlyChinese and 12 or 10})
                button.challengeText:SetPoint('BOTTOMLEFT',4,4)
                button.challengeText2= WoWTools_LabelMixin:Create(button, {size=e.onlyChinese and 12 or 10})
                button.challengeText2:SetPoint('BOTTOMLEFT', button.challengeText, 'BOTTOMRIGHT')

                button:HookScript('OnEnter', function(self)
                    if Save().hideEncounterJournal or not self.instanceID then
                        return
                    end
                    local name, _, _, _, loreImage, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.instanceID)
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    if name then
                        local cnName=e.cn(name, true)
                        e.tips:AddDoubleLine(cnName or name, cnName and name..' ')
                    end

                    e.tips:AddDoubleLine('journalInstanceID: |cnGREEN_FONT_COLOR:'..self.instanceID, loreImage and '|T'..loreImage..':0|t'..loreImage)
                    e.tips:AddDoubleLine(
                        dungeonAreaMapID and dungeonAreaMapID>0 and 'dungeonAreaMapID |cnGREEN_FONT_COLOR:'..dungeonAreaMapID or ' ',
                        mapID and 'mapID |cnGREEN_FONT_COLOR:'..mapID
                    )
                    if self.mapChallengeModeID then
                        e.tips:AddLine( 'mapChallengeModeID: |cnGREEN_FONT_COLOR:'.. self.mapChallengeModeID)
                    end
                    e.tips:AddLine(' ')
                    if WoWTools_EncounterMixin:GetInstanceData(self, true) then--界面,击杀,数据
                        e.tips:AddLine(' ')
                    end
                    e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                    e.tips:Show()
                end)
                button:SetScript('OnLeave', GameTooltip_Hide)
            end

            button.challengeText:SetText(challengeText or '')
            button.challengeText2:SetText(challengeText2 or '')

            --当前, KEY地图,ID
            local currentChallengeMapID= C_MythicPlus.GetOwnedKeystoneChallengeMapID()
            local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()--当前KEY，等级
            if currentChallengeMapID and button.mapChallengeModeID==currentChallengeMapID then
                if not button.KeyTexture then
                    button.KeyTexture= button:CreateTexture(nil, 'OVERLAY')
                    button.KeyTexture:SetPoint('TOPLEFT', -4, 0)
                    button.KeyTexture:SetSize(26,26)
                    button.KeyTexture:SetAtlas('common-icon-checkmark')
                    button.KeyTexture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) self.label:SetAlpha(1) end)
                    button.KeyTexture:SetScript('OnEnter', function(self)
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        local link= e.WoWDate[e.Player.guid].Keystone.link
                        if link then
                            e.tips:SetHyperlink(link)
                        else
                            e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                            e.tips:AddLine(e.onlyChinese and '挑战' or PLAYER_DIFFICULTY5)
                        end
                        e.tips:Show()
                        self:SetAlpha(0.3)
                        self.label:SetAlpha(0.3)
                    end)
                    button.KeyTexture.label=WoWTools_LabelMixin:Create(button, {r=1, g=1, b=1})
                    button.KeyTexture.label:SetPoint('TOP', button.KeyTexture, -2, -8)
                end
                button.KeyTexture:SetShown(true)
                button.KeyTexture.label:SetText(keyStoneLevel or '')
            elseif button.KeyTexture then
                button.KeyTexture:SetShown(false)
                button.KeyTexture.label:SetText('')
            end




            if not button.Favorites2 then--收藏
                button.Favorites2=WoWTools_ButtonMixin:Cbtn(button, {atlas='PetJournal-FavoritesIcon', size=25, isType2=true})
                button.Favorites2:SetPoint('TOPLEFT', -8, 8)
                button.Favorites2:EnableMouse(true)
                button.Favorites2:SetScript('OnLeave', function(self)
                    self:settings(false)
                    e.tips:Hide()
                end)
                button.Favorites2:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine('|A:PetJournal-FavoritesIcon:0:0|a'..(e.onlyChinese and '收藏' or FAVORITES), e.Icon.left)
                    e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
                    e.tips:Show()
                    self:settings(true)
                end)
                button.Favorites2:SetScript('OnClick', function(self, d)
                    if d=='RightButton' then
                        MenuUtil.CreateContextMenu(self, function(f, root)
                            local sub=root:CreateCheckbox(e.onlyChinese and '收藏' or FAVORITES, function()
                                return f:get_save()
                            end, function()
                                self:setup()
                            end)
                            sub:SetTooltip(function(tooltip)
                                tooltip:AddLine(e.addName)
                                tooltip:AddLine(WoWTools_EncounterMixin.addName)
                            end)
                            root:CreateDivider()
                            root:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
                                Save().favorites={}
                                e.call(EncounterJournal_ListInstances)
                            end)
                            root:CreateTitle(WoWTools_EncounterMixin.addName)
                        end)
                    elseif d=='LeftButton' then
                        self:setup()
                    end
                end)

                function button.Favorites2:setup()
                    local isSaved= self:get_save()
                    local insID= self:GetParent().instanceID
                    if insID then
                        Save().favorites[e.Player.guid][insID]= not isSaved and true or nil
                        self:settings()
                    end
                end
                function button.Favorites2:settings(isEnter)
                    local isSaved= self:get_save()
                    self:SetAlpha((isEnter or isSaved) and 1 or 0)
                end
                function button.Favorites2:get_save()
                    Save().favorites[e.Player.guid]= Save().favorites[e.Player.guid] or {}
                    return Save().favorites[e.Player.guid][self:GetParent().instanceID]
                end
            end
        end
        if button.Favorites2 then
            button.Favorites2:settings()
            button.Favorites2:SetShown(button.instanceID)
        end
    end
end













function WoWTools_EncounterMixin:Init_UI_ListInstances()
    hooksecurefunc('EncounterJournal_ListInstances', Init)
end