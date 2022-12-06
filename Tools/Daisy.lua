local pet=2780

local id, e = ...
local Save={}
local addName='DaisyTools'
local panel=e.Cbtn2(nil, e.toolsFrame, true, false)
local petName, petGUID

local function setTargetChaged()
    if Save.notGuLai then
        return
    end
    if UnitIsBattlePetCompanion('target') and C_PetJournal.GetSummonedPetGUID()==petGUID then
    --and UnitIsBattlePetCompanion('target')
    --UnitIsBattlePet('target')
    --and not IsMounted()
        DoEmote('BECKON')--beckon
    end
end

local function setGuLaiTip()--设置 是否使用 /招手
    panel.texture:SetDesaturated(Save.notGuLai)
end
local function setAutoSummonTips()--设置, 自动召唤
    if Save.autoSummon then
        panel.border:SetAtlas('bag-border')
    else
        panel.border:SetAtlas('bag-reagent-border')
    end
end
local function getSummoned()--是否已召唤, 或有BUFF(在背上)
    local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
    local find=summonedPetGUID==petGUID
    local summoned= summonedPetGUID and true or false
    if not find then
        if e.WA_GetUnitBuff('player', 311796, 'PLAYER') then
            find = true
        end
    end
    return find, summoned
end

local function setSummonedPetGUID()--召唤信息
    local find, summoned = getSummoned()
    if find then--显示名字,提示是否召唤
        if not panel.text then
            local size=8
            if e.toolsFrame.size then
                if e.toolsFrame.size>40 then
                    size=12
                elseif e.toolsFrame.size>30 then
                    size=10
                end
            end
            panel.text=e.Cstr(panel, size,nil,nil, true)
            panel.text:SetPoint('CENTER',0 , -5)
        end
    elseif not summoned
        and Save.autoSummon
        and not IsStealthed()
        and not IsMounted()
        and not UnitIsDeadOrGhost('player')
        and not UnitIsBattlePet('player')
        and not UnitInBattleground('player')
        and not C_PvP.IsArena()
        and not UnitCastingInfo('player')
        and not UnitChannelInfo('paleyr')
        then
        C_PetJournal.SummonPetByGUID(petGUID)
    end
    if panel.text then--显示名字
        panel.text:SetText(find and petName or '')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level)--主菜单
    local info={
        text=USE..' '..EMOTE102_CMD1,
        checked=not Save.notGuLai,
        func=function()
            if Save.notGuLai then
                Save.notGuLai=nil
                setTargetChaged()
            else
                Save.notGuLai=true
            end
            setGuLaiTip()--设置 是否使用 /招手
        end,
    }
    UIDropDownMenu_AddButton(info, level)

    info={--自动召唤
        text=AUTO_JOIN:gsub(JOIN,'')..SUMMONS,
        checked=Save.autoSummon,
        func=function()
            if Save.autoSummon then
                Save.autoSummon=nil
            else
                Save.autoSummon=true
                setSummonedPetGUID()
            end
            setAutoSummonTips()--设置, 自动召唤
        end
    }
    UIDropDownMenu_AddButton(info, level)
end

--####
--初始
--####
local function Init()
    local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(pet)
    if speciesName and speciesIcon then
        local speciesId, petGUID2 = C_PetJournal.FindPetIDByName(speciesName)
        if speciesId==pet and petGUID2 then
            petGUID=petGUID2
            petName=speciesName
            panel.texture:SetTexture(speciesIcon)
        end
    end
    if not petGUID then--没找到时, 退出
        print(id, addName, SPELL_FAILED_ERROR)
        panel:UnregisterAllEvents()
        return
    end

    e.ToolsSetButtonPoint(panel)--设置位置
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            C_PetJournal.SummonPetByGUID(petGUID)

        elseif not key then
            C_PetJournal.SummonRandomPet(true)
        end
    end)

    panel:SetScript('OnMouseWheel', function(self, d)
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
   end)

   panel:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetCompanionPet(petGUID)
        --e.tips:AddLine(' ')
        e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU,e.Icon.mid)
        e.tips:Show()
    end)
    panel:SetScript('OnLeave', function() e.tips:Hide() end)

    setGuLaiTip()--设置 是否使用 /招手
    setSummonedPetGUID()--召唤信息,自动召唤
    if Save.autoSummon then
        setAutoSummonTips()--设置, 自动召唤
    end
end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:RegisterEvent("PLAYER_REGEN_ENABLED")
panel:RegisterUnitEvent('UNIT_AURA','player')
panel:RegisterEvent('PLAYER_STOPPED_MOVING')

panel:RegisterEvent('PLAYER_TARGET_CHANGED')
panel:RegisterEvent('PLAYER_REGEN_DISABLED')

panel:RegisterEvent('COMPANION_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.71, function()
                local num = C_PetJournal.GetNumCollectedInfo(pet)--没宠物,不加载
                if not num or num==0 then
                    panel:UnregisterAllEvents()
                    return
                end
                if UnitAffectingCombat('player')  then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        setSummonedPetGUID()--召唤信息,自动召唤
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
        panel:RegisterEvent('PLAYER_STOPPED_MOVING')
        panel:RegisterUnitEvent('UNIT_AURA','player')
        if panel.combat then
            Init()
            panel.combat=nil
        end
    elseif event=='PLAYER_REGEN_DISABLED' then
        panel:UnregisterEvent('PLAYER_TARGET_CHANGED')
        panel:UnregisterEvent('UNIT_AURA')
        panel:UnregisterEvent('PLAYER_STOPPED_MOVING')

    elseif event=='UNIT_AURA' or event=='PLAYER_STOPPED_MOVING' or (event=='COMPANION_UPDATE' and arg1=='CRITTER') then
        setSummonedPetGUID()--召唤信息

    elseif event=='PLAYER_TARGET_CHANGED' then
        setTargetChaged()
    end
end)