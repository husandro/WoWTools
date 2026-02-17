
local function IsLeader()
    return not UnitIsGroupLeader("player") or not IsInGroup()
end
local function EnabledDungeon(id)
    return DifficultyUtil.IsDungeonDifficultyEnabled(id) and IsLeader() and not IsInInstance()
end
local function EnableRaid()
    return not DifficultyUtil.InStoryRaid() and (UnitIsGroupLeader("player") or not IsInGroup())
end
local function EnabledLegacy()
    if IsInInstance()
        or not IsLeader()
        or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
        or GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic then
        return false
    end
    local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
    if isDynamicInstance and CanChangePlayerDifficulty() then
        local toggleDifficultyID = select(7, GetDifficultyInfo(instanceDifficultyID));
        if toggleDifficultyID then
            return false
        end
    end
    return true
end

local function SetDungeon(id)
    SetDungeonDifficultyID(id)
end
local function SetRaid(id)
    SetRaidDifficulties(true, id)
end
local function SetLegacy(id)
    SetRaidDifficulties(false, id)
end

local function CheckDungeon(id)
    return GetDungeonDifficultyID()==id
end
local function CheckRaid(id)
    return DifficultyUtil.DoesCurrentRaidDifficultyMatch(id)
end
local function CheckLegacy(id)
    local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo())
    if isDynamicInstance then
        if NormalizeLegacyDifficultyID(instanceDifficultyID) == id then
            return true
        end
    else
        local raidDifficultyID = GetLegacyRaidDifficultyID();
        if NormalizeLegacyDifficultyID(raidDifficultyID) == id then
            return true;
        end
    end
    return false
end


--UnitPopupSharedButtonMixins.lua
function WoWTools_MenuMixin:DungeonDifficulty(_, root)
    if DifficultyUtil.InStoryRaid() then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '在剧情模式不可用' or DIFFICULTY_LOCKED_REASON_STORY_RAID, WARNING_FONT_COLOR)
        return
    end


    for _, tab in pairs({
            WoWTools_DataMixin.onlyChinese and '地下城难度' or DUNGEON_DIFFICULTY,
            {id= DifficultyUtil.ID.DungeonNormal, enable=EnabledDungeon, set=SetDungeon, check=CheckDungeon},
            {id=DifficultyUtil.ID.DungeonHeroic, enable=EnabledDungeon, set=SetDungeon, check=CheckDungeon},
            {id=DifficultyUtil.ID.DungeonMythic, enable=EnabledDungeon, set=SetDungeon, check=CheckDungeon},
            '-',
            WoWTools_DataMixin.onlyChinese and '团队副本难度' or RAID_DIFFICULTY,
            {id=DifficultyUtil.ID.PrimaryRaidNormal, enable=EnableRaid, set=SetRaid, check=CheckRaid},--14,
	        {id=DifficultyUtil.ID.PrimaryRaidHeroic, enable=EnableRaid, set=SetRaid, check=CheckRaid},--15,
	        {id=DifficultyUtil.ID.PrimaryRaidMythic, enable=EnableRaid, set=SetRaid, check=CheckRaid},--16,
            '-',
            WoWTools_DataMixin.onlyChinese and '旧版团队规模' or UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LEGACY_RAID,
            {id=DifficultyUtil.ID.Raid10Normal, enable=EnabledLegacy, set=SetLegacy, check=CheckLegacy, name=WoWTools_DataMixin.onlyChinese and '10人' or RAID_DIFFICULTY1},--3,
	        {id=DifficultyUtil.ID.Raid25Normal, enable=EnabledLegacy, set=SetLegacy, check=CheckLegacy, name=WoWTools_DataMixin.onlyChinese and '25人' or RAID_DIFFICULTY2},--4,
        })
    do

        --local enabled= DifficultyUtil.IsDungeonDifficultyEnabled(id) and '|A:recipetoast-icon-star:0:0|a' or ''
        if tab=='-' then
            root:CreateDivider()
        elseif type(tab)=='string' then
            root:CreateTitle(tab)
        else
            local sub=root:CreateRadio(
                tab.name or WoWTools_MapMixin:GetDifficultyColor(nil, tab.id),
            function(data)
                return data.check(data.id)

            end, function(data)
                print(data.id)
                data.set(data.id)

                return MenuResponse.Refresh
            end, {
                    rightText=DISABLED_FONT_COLOR:WrapTextInColorCode(tab.id),
                    id=tab.id,
                    set=tab.set,
                    check=tab.check,
                    enable=tab.enable,
                })
            self:SetRightText(sub)
            sub:AddInitializer(function(btn, desc, menu)
                btn:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
                btn:SetScript('OnEvent', function(s)
                    WoWTools_DataMixin:Call(menu.ReinitializeAll, menu)
                    local enable= desc.data.enable(desc.data.id)
                    btn:SetEnabled(enable)
                    s:SetAlpha(enable and 1 or 0.5)
                end)
                btn:SetScript('OnHide', function(s)
                    s:UnregisterEvent('PLAYER_DIFFICULTY_CHANGED')
                    s:SetScript('OnHide', nil)
                    s:SetScript('OnEvent', nil)
                    s:SetAlpha(1)
                end)
                local isEnabled= desc.data.enable(tab.id)
                btn:SetEnabled(isEnabled)
                btn:SetEnabled(isEnabled and 1 or 0.5)
            end)
        end
    end

end





























function WoWTools_MenuMixin:Set_Specialization(root)
    local numSpec= GetNumSpecializations(false, false) or 0
    if not C_SpecializationInfo.IsInitialized() or numSpec==0 then
		return
	end

    local sub, specID, name, icon, _
    local isInCombat= InCombatLockdown()
    local curSpecIndex= GetSpecialization() or 0--当前，专精
    local sex= WoWTools_DataMixin.Player.Sex

    for specIndex=1, numSpec, 1 do
        specID, name, _, icon= C_SpecializationInfo.GetSpecializationInfo(specIndex, false, false, nil, sex)

        sub=root:CreateRadio(
            '|T'..(icon or 0)..':0|t'
            ..'|A:'..(GetMicroIconForRoleEnum(GetSpecializationRoleEnum(specIndex, false, false)) or '')..':0:0|a'
            ..(isInCombat and '|cff828282' or (curSpecIndex==specIndex and '|cnGREEN_FONT_COLOR:') or '')
            ..WoWTools_TextMixin:CN(name),
        function(data)
            return data.specID== PlayerUtil.GetCurrentSpecID()
        end, function(data)
            if C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
                C_SpecializationInfo.SetSpecialization(data.specIndex)
            end
            return MenuResponse.Refresh
        end, {
            specIndex=specIndex,
            specID= specID,
            tooltip= function(tooltip, data2)
                local canSpecsBeActivated, failureReason = C_SpecializationInfo.CanPlayerUseTalentSpecUI()
                tooltip:AddLine(' ')
                if GetSpecialization(nil, false, 1)==data2.specIndex then
                    GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '已激活' or COVENANT_SANCTUM_UPGRADE_ACTIVE)

                elseif canSpecsBeActivated then
                    tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '激活' or SPEC_ACTIVE)..WoWTools_DataMixin.Icon.left)

                elseif failureReason and failureReason~='' then
                    GameTooltip_AddErrorLine(tooltip, WoWTools_TextMixin:CN(failureReason), true)
                end
            end}
        )

        sub:AddInitializer(function(btn, desc, menu)
            local rightTexture= btn:AttachTexture()
            rightTexture:SetPoint('RIGHT', -12, 0)
            rightTexture:SetSize(20,20)
            rightTexture:SetAtlas('VignetteLoot')

            function btn:set_loot()
                local lootID= GetLootSpecialization()
                local show
                if lootID==0 then
                    show= GetSpecialization(nil, false, 1)==desc.data.specIndex
                else
                    show= lootID==desc.data.specID
                end
                rightTexture:SetShown(show)
            end
            btn:set_loot()

            btn:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
            btn:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')

            btn:SetScript('OnEvent', function(s, event)
                if event=='ACTIVE_PLAYER_SPECIALIZATION_CHANGED' then
                    WoWTools_DataMixin:Call(menu.ReinitializeAll, menu)
                end
                s:set_loot()
            end)
            btn:SetScript('OnHide', function(s)
                s:UnregisterAllEvents()
                s:SetScript('OnHide', nil)
                s:SetScript('OnEvent', nil)
                s.set_loot= nil
                s.set_loot=nil
            end)
        end)
        WoWTools_SetTooltipMixin:Set_Menu(sub)

        sub:CreateButton(
            '|T'..(icon or 0)..':0|t'
            ..'|A:VignetteLoot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION),
        function(data)
            SetLootSpecialization(data.specID)
            return MenuResponse.Open
        end, {specID= specID})


        sub:CreateDivider()
        sub:CreateButton(
            --'|T'..(PlayerUtil.GetSpecIconBySpecID(C_SpecializationInfo.GetSpecializationInfo(curSpecIndex), sex) or 0)..':0|t'
            WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT,
        function()
            SetLootSpecialization(0)
            return MenuResponse.Open
        end)
    end

    sub= root:CreateCheckbox(
        ((C_PvP.ArePvpTalentsUnlocked() and C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired())) and '' or '|cff828282')
        ..'|A:pvptalents-warmode-swords:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE),
    function()
        return C_PvP.IsWarModeDesired()
    end,function()
        WoWTools_LoadUIMixin:SpellBook(2)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE)
        if not C_PvP.ArePvpTalentsUnlocked() then
			GameTooltip_AddErrorLine(
                GameTooltip,
                format(
                    WoWTools_DataMixin.onlyChinese and '在%d级解锁' or PVP_TALENT_SLOT_LOCKED,
                    C_PvP.GetPvpTalentsUnlockedLevel()
                ),
            true)

        elseif not C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired()) then
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '当前不能操作' or SPELL_FAILED_NOT_HERE, 1,0,0)
		end
    end)

    sub:AddInitializer(function(btn, _, menu)
        btn:RegisterEvent('PLAYER_FLAGS_CHANGED')
        btn:SetScript('OnEvent', function()
            WoWTools_DataMixin:Call(menu.ReinitializeAll, menu)
        end)
        btn:SetScript('OnHide', function(s)
            s:UnregisterEvent('PLAYER_FLAGS_CHANGED')
            s:SetScript('OnHide', nil)
            s:SetScript('OnEvent', nil)
        end)
    end)

    return true
end
