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
    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        nil,
        {SetValue=function()
            Save().favorites={}
            WoWTools_DataMixin:Call(EncounterJournal_ListInstances)
        end})
        return MenuResponse.Open
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_EncounterMixin.addName})
end




--[[
name, id, timeLimit, texture, backgroundTexture, mapID = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
journalInstanceID = C_EncounterJournal.GetInstanceForGameMap(mapID)
]]



--挑战，数据
local function Set_Button_ChallengData(instanceID)
    if not C_MythicPlus.GetCurrentSeason() then
        return
    end

    local challengeText, challengeText2
    local CurMaphallengeModeID

    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do--挑战地图 mapChallengeModeID

        WoWTools_DataMixin:Load({type='mapChallengeModeID', mapChallengeModeID })

        local mapID= select(6, C_ChallengeMode.GetMapUIInfo(mapChallengeModeID))
        local journalInstanceID = mapID and C_EncounterJournal.GetInstanceForGameMap(mapID)

        if journalInstanceID==instanceID then
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
                        local level= tab.overTime and '|cnWARNING_FONT_COLOR:'..tab.level..'|r' or tab.level
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
            --if all>0 then
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
            --end
        end
    end
    return challengeText, challengeText2, CurMaphallengeModeID
end

















--[[
EncounterInstanceButtonTemplate
QuestTitleFontBlackShadow
]]

local function Init_Button(btn)
    WoWTools_TextureMixin:SetFrame(btn, {index=5, alpha=1})

    btn:HookScript('OnEnter', function(self)
        if Save().hideEncounterJournal or not self.instanceID then
            return
        end

        local name, _, _, _, loreImage, _, dungeonAreaMapID, _, _, mapID = EJ_GetInstanceInfo(self.instanceID)--journalInstanceID

        if not name then
            return
        end

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        local cnName=WoWTools_TextMixin:CN(name)

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2..cnName,
            cnName and cnName~=name and name..' '
        )

        GameTooltip:AddDoubleLine(
            'journalInstanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.instanceID,
            loreImage and '|T'..loreImage..':0|t|cffffffff'..loreImage
        )

        GameTooltip:AddDoubleLine(
            mapID and 'instanceID|cffffffff'..WoWTools_DataMixin.Icon.icon2..mapID or ' ',
            dungeonAreaMapID and dungeonAreaMapID>0 and 'uiMapID|cffffffff'..WoWTools_DataMixin.Icon.icon2..dungeonAreaMapID
        )

        if self.mapChallengeModeID then
            GameTooltip:AddLine( 'mapChallengeModeID:|cffffffff'..WoWTools_DataMixin.Icon.icon2..self.mapChallengeModeID)
        end

        WoWTools_EncounterMixin:GetInstanceData(self, true)--界面,击杀,数据

        GameTooltip:Show()
        self.Favorites2:set_alpha()
    end)
    btn:HookScript('OnLeave', function(self)
        self.Favorites2:set_alpha()
        GameTooltip:Hide()
    end)

--界面,击杀,数据
    btn.tipsText= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')
    --WoWTools_LabelMixin:Create(btn, {size=WoWTools_DataMixin.onlyChinese and 12 or 10, copyFont= not WoWTools_DataMixin.onlyChinese and btn.name or nil})
    btn.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
    btn.tipsText:SetJustifyH('RIGHT')

--挑战，数据
    btn.challengeText= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')--WoWTools_LabelMixin:Create(btn, {size=WoWTools_DataMixin.onlyChinese and 12 or 10})
    btn.challengeText:SetPoint('BOTTOMLEFT',4,4)
    btn.challengeText2= btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')-- WoWTools_LabelMixin:Create(btn, {size=WoWTools_DataMixin.onlyChinese and 12 or 10})
    btn.challengeText2:SetPoint('BOTTOMLEFT', btn.challengeText, 'BOTTOMRIGHT')

--收藏
    btn.Favorites2= CreateFrame('Button', nil, btn)
    WoWTools_ButtonMixin:Cbtn(btn, {btn=btn.Favorites2, atlas='PetJournal-FavoritesIcon', size=25, isType2=true})
    btn.Favorites2.border:SetTexture(0)
    btn.Favorites2:SetPoint('TOPLEFT', -8, 8)
    btn.Favorites2:EnableMouse(true)
    btn.Favorites2:SetScript('OnLeave', function(self)
        self:set_alpha()
        GameTooltip:Hide()
    end)
    btn.Favorites2:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddDoubleLine('|A:PetJournal-FavoritesIcon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '收藏' or FAVORITES), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:set_alpha()
    end)
    btn.Favorites2:SetScript('OnClick', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Fvorite_Menu)

        elseif d=='LeftButton' then
            self:setup()
        end
    end)
    function btn.Favorites2:setup()
        local isSaved= self:get_save()
        local insID= self:GetParent().instanceID
        if insID then
            Save().favorites[WoWTools_DataMixin.Player.GUID][insID]= not isSaved and true or nil
        end
        self:set_alpha()
    end
    function btn.Favorites2:set_alpha()
        local isSaved= self:get_save()
        if isSaved then
            self:GetHighlightTexture():SetVertexColor(0,1,0)
        else
            self:GetHighlightTexture():SetVertexColor(1,1,1)
        end
        self:SetAlpha((isSaved or GameTooltip:IsOwned(self) or GameTooltip:IsOwned(self:GetParent())) and 1 or 0)
    end
    function btn.Favorites2:get_save()
        Save().favorites[WoWTools_DataMixin.Player.GUID]= Save().favorites[WoWTools_DataMixin.Player.GUID] or {}
        return Save().favorites[WoWTools_DataMixin.Player.GUID][self:GetParent().instanceID]
    end

--当前, KEY地图,ID
    btn.KeyTexture= btn:CreateTexture(nil, 'ARTWORK')
    btn.KeyTexture:SetPoint('TOPLEFT', -4, -2)
    btn.KeyTexture:SetSize(26,26)
    btn.KeyTexture:SetAtlas('common-icon-checkmark')
    btn.KeyTexture:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) self.label:SetAlpha(1) end)
    btn.KeyTexture:SetScript('OnEnter', function(self)
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
    btn.KeyTexture.label=btn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')--WoWTools_LabelMixin:Create(btn, {r=1, g=1, b=1})
    btn.KeyTexture.label:SetPoint('TOP', btn.KeyTexture, -2, -10)
    function btn:clear_data()
        self.tipsText:SetText('')
        self.challengeText:SetText('')
        self.challengeText2:SetText('')
        self.KeyTexture:SetShown(false)
        self.KeyTexture.label:SetText('')
        self.Favorites2:Hide()
    end

    function btn:settings()
--界面, 击杀, 数据
        self.tipsText:SetText(WoWTools_EncounterMixin:GetInstanceData(self) or '')

--挑战，数据
        local challengeText, challengeText2, CurMaphallengeModeID= Set_Button_ChallengData(self.instanceID)
        self.challengeText:SetText(challengeText or '')
        self.challengeText2:SetText(challengeText2 or '')

--当前, KEY地图,ID
        local isCurrent=  CurMaphallengeModeID and CurMaphallengeModeID==C_MythicPlus.GetOwnedKeystoneChallengeMapID()
        self.mapChallengeModeID= CurMaphallengeModeID
        self.KeyTexture:SetShown(isCurrent)
        self.KeyTexture.label:SetText(isCurrent and C_MythicPlus.GetOwnedKeystoneLevel() or '')--当前KEY，等级

--收藏
        self.Favorites2:set_alpha()
        self.Favorites2:SetShown(true)
    end

    btn:settings()
end



















local function Init_ListInstances(frame)
    if not frame:HasView() then
        return
    end

    local hide= Save().hideEncounterJournal
    for _, btn in pairs(frame:GetFrames() or {}) do--ScrollBox.lua
        if btn and btn.instanceID then
            if hide then
                if btn.clear_data then
                    btn:clear_data()
                end

            elseif not btn.settings then
                Init_Button(btn)

            else
                btn:settings()
            end
        end
    end
end









--EncounterJournal_DisplayInstance
--EncounterJournal_ListInstances

function WoWTools_EncounterMixin:Init_UI_ListInstances()
    --WoWTools_DataMixin:Hook('EncounterJournal_DisplayInstance', function(...) Init_DisplayInstance(...) end)
    --EncounterInstanceButtonTemplate
    WoWTools_DataMixin:Hook(EncounterJournal.instanceSelect.ScrollBox, 'Update', function(frame)
        Init_ListInstances(frame)
    end)
   EncounterJournal.instanceSelect.ScrollBox:HookScript('OnShow', function(frame)
        C_Timer.After(0.1, function()
            Init_ListInstances(frame)
        end)
    end)
end