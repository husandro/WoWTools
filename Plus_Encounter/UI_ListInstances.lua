--界面, 副本击杀
--Blizzard_EncounterJournal.lua

local function Save()
    return WoWToolsSave['Adventure_Journal']
end




--收藏,菜单
local function Init_Fvorite_Menu(self, root)
    local sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '收藏' or FAVORITES, function()
        return self:get_save()
    end, function()
        self:setup()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.addName)
        tooltip:AddLine(WoWTools_EncounterMixin.addName)
    end)
    root:CreateDivider()
    root:CreateButton(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL, function()
        Save().favorites={}
        WoWTools_Mixin:Call(EncounterJournal_ListInstances)
    end)
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_EncounterMixin.addName})
end







--挑战，数据
local function Set_Button_ChallengData(button)
    local challengeText, challengeText2
    local instanceName= button.tooltipTitle or button.name:GetText()
    local CurMaphallengeModeID

    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do--挑战地图 mapChallengeModeID
        WoWTools_Mixin:Load({type='mapChallengeModeID',mapChallengeModeID })
        local name= C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        if name==instanceName or name:find(instanceName) then
            CurMaphallengeModeID= mapChallengeModeID--挑战,地图ID
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
                local text
                text= '|cff00ff00'..nu..'|r/'..all
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
    return challengeText, challengeText2, CurMaphallengeModeID
end


















local function Create(button)
    if button.tipsText then
        return
    end

--界面,击杀,数据
    button.tipsText=WoWTools_LabelMixin:Create(button, {size=WoWTools_DataMixin.onlyChinese and 12 or 10, copyFont= not WoWTools_DataMixin.onlyChinese and button.name or nil})--10, button.name)
    button.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
    button.tipsText:SetJustifyH('RIGHT')

--挑战，数据
    button.challengeText= WoWTools_LabelMixin:Create(button, {size=WoWTools_DataMixin.onlyChinese and 12 or 10})
    button.challengeText:SetPoint('BOTTOMLEFT',4,4)
    button.challengeText2= WoWTools_LabelMixin:Create(button, {size=WoWTools_DataMixin.onlyChinese and 12 or 10})
    button.challengeText2:SetPoint('BOTTOMLEFT', button.challengeText, 'BOTTOMRIGHT')
   


--当前, KEY地图,ID
    button.KeyTexture= button:CreateTexture(nil, 'OVERLAY')
    button.KeyTexture:SetPoint('TOPLEFT', -4, 0)
    button.KeyTexture:SetSize(26,26)
    button.KeyTexture:SetAtlas('common-icon-checkmark')
    button.KeyTexture:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) self.label:SetAlpha(1) end)
    button.KeyTexture:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link
        if link then
            GameTooltip:SetHyperlink(link)
        else
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '挑战' or PLAYER_DIFFICULTY5)
        end
        GameTooltip:Show()
        self:SetAlpha(0.3)
        self.label:SetAlpha(0.3)
    end)

--当前KEY，等级
    button.KeyTexture.label=WoWTools_LabelMixin:Create(button, {r=1, g=1, b=1})
    button.KeyTexture.label:SetPoint('TOP', button.KeyTexture, -2, -8)

--收藏
    button.Favorites2=WoWTools_ButtonMixin:Cbtn(button, {atlas='PetJournal-FavoritesIcon', size=25, isType2=true})
    button.Favorites2.border:SetTexture(0)
    button.Favorites2:SetPoint('TOPLEFT', -8, 8)
    button.Favorites2:EnableMouse(true)
    button.Favorites2:SetScript('OnLeave', function(self)
        self:set_alpha()
        GameTooltip:Hide()
    end)
    button.Favorites2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('|A:PetJournal-FavoritesIcon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '收藏' or FAVORITES), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:set_alpha()
    end)
    button.Favorites2:SetScript('OnClick', function(self, d)
        if d=='RightButton' then
--收藏,菜单
            MenuUtil.CreateContextMenu(self, Init_Fvorite_Menu)

        elseif d=='LeftButton' then
            self:setup()
        end
    end)

    function button.Favorites2:setup()
        local isSaved= self:get_save()
        local insID= self:GetParent().instanceID
        if insID then
            Save().favorites[WoWTools_DataMixin.Player.GUID][insID]= not isSaved and true or nil
            self:set_alpha()
        end
    end
    function button.Favorites2:set_alpha()
        local isSaved= self:get_save()
        self:SetAlpha((isSaved or GameTooltip:IsOwned(self) or GameTooltip:IsOwned(self:GetParent())) and 1 or 0)
    end
    function button.Favorites2:get_save()
        Save().favorites[WoWTools_DataMixin.Player.GUID]= Save().favorites[WoWTools_DataMixin.Player.GUID] or {}
        return Save().favorites[WoWTools_DataMixin.Player.GUID][self:GetParent().instanceID]
    end




    button:HookScript('OnEnter', function(self)
        if Save().hideEncounterJournal or not self.instanceID then
            return
        end
        local name, _, _, _, loreImage, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.instanceID)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if name then
            local cnName=WoWTools_TextMixin:CN(name, true)
            GameTooltip:AddDoubleLine(cnName or name, cnName and name..' ')
        end

        GameTooltip:AddDoubleLine('journalInstanceID: |cnGREEN_FONT_COLOR:'..self.instanceID, loreImage and '|T'..loreImage..':0|t'..loreImage)
        GameTooltip:AddDoubleLine(
            dungeonAreaMapID and dungeonAreaMapID>0 and 'dungeonAreaMapID |cnGREEN_FONT_COLOR:'..dungeonAreaMapID or ' ',
            mapID and 'mapID |cnGREEN_FONT_COLOR:'..mapID
        )
        if self.mapChallengeModeID then
            GameTooltip:AddLine( 'mapChallengeModeID: |cnGREEN_FONT_COLOR:'.. self.mapChallengeModeID)
        end
        GameTooltip:AddLine(' ')
        if WoWTools_EncounterMixin:GetInstanceData(self, true) then--界面,击杀,数据
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
        self.Favorites2:set_alpha()
    end)
    button:HookScript('OnLeave', function(self)
        self.Favorites2:set_alpha()
        GameTooltip:Hide()
    end)
end



















local function Init_ListInstances()
    local frame= EncounterJournal.instanceSelect.ScrollBox
    if not frame:GetView() then
        return
    end
    
    if Save().hideEncounterJournal then
        for _, button in pairs(frame:GetFrames() or {}) do
            if button.tipsText then
                button.tipsText:SetText('')
                button.challengeText:SetText('')
                button.challengeText2:SetText('')
                button.KeyTexture:SetShown(false)
                button.KeyTexture.label:SetText('')
            end
        end
        return
    end

    for _, button in pairs(frame:GetFrames() or {}) do--ScrollBox.lua
        if button and button.instanceID then --and button.tooltipTitle--button.bgImage:GetTexture() button.name:GetText()
            Create(button)
--界面,击杀,数据
            button.tipsText:SetText(WoWTools_EncounterMixin:GetInstanceData(button) or '')

--挑战，数据
            local challengeText, challengeText2, CurMaphallengeModeID= Set_Button_ChallengData(button)
            button.challengeText:SetText(challengeText or '')
            button.challengeText2:SetText(challengeText2 or '')

--当前, KEY地图,ID
            local isCurrent=  CurMaphallengeModeID and CurMaphallengeModeID==C_MythicPlus.GetOwnedKeystoneChallengeMapID() 
            button.mapChallengeModeID= CurMaphallengeModeID
            button.KeyTexture:SetShown(isCurrent)
            button.KeyTexture.label:SetText(isCurrent and C_MythicPlus.GetOwnedKeystoneLevel() or '')--当前KEY，等级

--收藏
            button.Favorites2:set_alpha()
            button.Favorites2:SetShown(button.instanceID)
        end
    end
end















function WoWTools_EncounterMixin:Init_UI_ListInstances()
    hooksecurefunc('EncounterJournal_ListInstances', Init_ListInstances)
end