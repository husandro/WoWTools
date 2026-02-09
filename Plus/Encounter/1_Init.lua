

local function Save()
    return WoWToolsSave['Adventure_Journal']
end









local function Init_Encounter()--冒险指南界面
    WoWTools_EncounterMixin:Init_Menu()
    WoWTools_EncounterMixin:Init_Plus()
    WoWTools_EncounterMixin:Init_ListInstances()--界面, 副本击杀
    WoWTools_EncounterMixin:Set_RightAllInfo()--冒险指南,右边,显示所数据
    WoWTools_EncounterMixin:Init_JourneysList()--12.0才有
    WoWTools_EncounterMixin:Init_JourneysPlus()


--记录上次选择版本
    C_Timer.After(0.3, function()
        if Save().EncounterJournalTier and not InCombatLockdown() then--记录上次选择TAB
            local max= EJ_GetNumTiers()
            if max then
                local tier= math.min(Save().EncounterJournalTier, max)
                EJ_SelectTier(tier)
            end
        end

        WoWTools_DataMixin:Hook('EJ_SelectTier', function(tier)
            Save().EncounterJournalTier= Save().isSaveTier and tier or nil
        end)
    end)

    Init_Encounter=function()end
end





local function Init()
    WoWTools_EncounterMixin:Init_LootSpec()--BOSS战时, 指定拾取, 专精

--击杀次数，拾取专精，提示,
    WoWTools_DataMixin:Hook(EncounterJournalPinMixin, 'OnMouseEnter', function(frame)
        local encounterID= frame.tooltipTitle and frame.encounterID and select(7, EJ_GetEncounterInfo(frame.encounterID))
        if not encounterID then
            return
        end

        local numKill= encounterID and WoWToolsPlayerDate['BossKilled'][encounterID] or 0
        if numKill>0 then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                WoWTools_DataMixin.Icon.icon2
                ..format(WoWTools_DataMixin.onlyChinese and '%s（|cffffffff%d|r次）' or REAGENT_COST_CONSUME_CHARGES,
                    WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED,
                    numKill)
            )
        end

        local data= not Save().hideLootSpec and WoWToolsPlayerDate['LootSpec'][encounterID]
        local lootSpecID= data and data.class[WoWTools_DataMixin.Player.Class]
        local loot
        if lootSpecID then
            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpecID)
            if name then
                if numKill==0 then
                    GameTooltip:AddLine(' ')
                end
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.icon2
                    ..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
                    ..': |cffffffff'
                    ..'|T'..(icon or 0)..':0|t'
                    ..(WoWTools_DataMixin.Icon[role] or '')
                    ..WoWTools_TextMixin:CN(name)
                )
                loot= true
            end
        end

        if numKill>0 or loot then
            GameTooltip:Show()
        end
    end)

    Init=function()end
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Adventure_Journal']= WoWToolsSave['Adventure_Journal'] or {
                favorites={},--副本收藏 WoWTools_DataMixin.Player.GUID= {}
                LootSpec= {},--拾取专精
                isSaveTier=WoWTools_DataMixin.Player.husandro,--保存改变
                JourneysList= {
                    list=true
                },
            }

            WoWToolsPlayerDate['BossKilled']= WoWToolsPlayerDate['BossKilled'] or {}

            Save().favorites[WoWTools_DataMixin.Player.GUID]= Save().favorites[WoWTools_DataMixin.Player.GUID] or {}
            if not Save().JourneysList then
                Save().JourneysList={
                    disabled= Save().hideJourneysList,
                    name=true,
                    onlyCurVerName=true
                }
            end

            WoWTools_EncounterMixin.addName= '|A:UI-HUD-MicroMenu-AdventureGuide-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '冒险指南' or ADVENTURE_JOURNAL)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_EncounterMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

--为了保存击杀数据，保持这个开启
            EventRegistry:RegisterFrameEventAndCallback("BOSS_KILL", function(_, ncounterID, encounterName)
                if not ncounterID then
                    return
                end
                local num= (WoWToolsPlayerDate['BossKilled'][ncounterID] or 0)+ 1
                WoWToolsPlayerDate['BossKilled'][ncounterID]= num--Boss击杀数量
                if not Save().hideEncounterJournal then
                    print(
                        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnWARNING_FONT_COLOR:'..(WoWTools_TextMixin:CN(encounterName) or ncounterID)..'|r',
                        format(WoWTools_DataMixin.onlyChinese and '%s（|cffffffff%d|r次）' or REAGENT_COST_CONSUME_CHARGES,
                            WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED,
                            num)
                    )
                end
            end)

            if Save().disabled then
                self:UnregisterEvent(event)
                self:SetScript('OnEvent', nil)
            else

                --[[if WoWTools_DataMixin.Player.husandro then
                    EventRegistry:RegisterFrameEventAndCallback("UPDATE_FACTION", function(owner)
                        WoWTools_LoadUIMixin:JournalInstance(nil)
                        --WoWTools_LoadUIMixin:JournalInstance(nil, 1271)
                        EventRegistry:UnregisterCallback('UPDATE_FACTION', owner)
                    end)
                end]]

                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
                    Init_Encounter()--冒险指南界面
                    self:UnregisterEvent(event)
                    self:SetScript('OnEvent', nil)
                end
            end

        elseif arg1=='Blizzard_EncounterJournal' and WoWToolsSave then---冒险指南
            Init_Encounter()--冒险指南界面
            self:UnregisterEvent(event)
            self:SetScript('OnEvent', nil)
        end
    end
end)