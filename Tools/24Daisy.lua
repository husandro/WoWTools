local id, e = ...
local Save={}
local addName='DaisyTools'
local panel= CreateFrame('Frame')
local button
local petName, petGUID
local speciesID=2780

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
    button.texture:SetDesaturated(Save.notGuLai)
end
local function setAutoSummonTips()--设置, 自动召唤
    if Save.autoSummon then
        button.border:SetAtlas('bag-border')
    else
        button.border:SetAtlas('bag-reagent-border')
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
        if not button.text then
            button.text=e.Cstr(button, {size=10, color=true})-- size,nil,nil, true)
            button.text:SetPoint('CENTER',0 , -5)
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
    if button.text then--显示名字
        button.text:SetText(find and petName or '')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level)--主菜单
    local info={
        text= e.onlyChinese and '使用 /招手' or (USE..' '..EMOTE102_CMD1),
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
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={--自动召唤
        text= e.onlyChinese and '自动召唤' or (AUTO_JOIN:gsub(JOIN,'')..SUMMONS),
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
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

--####
--初始
--####
local function Init()
    local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if speciesName and speciesIcon then
        local speciesId2, petGUID2 = C_PetJournal.FindPetIDByName(speciesName)
        if speciesId2==speciesID and petGUID2 then
            petGUID=petGUID2
            petName=speciesName
            button.texture:SetTexture(speciesIcon)
        end
    end
    if not petGUID then--没找到时, 退出
        print(id, addName, e.onlyChinese and '没发现宠物, 黛西' or SPELL_FAILED_ERROR)
        panel:UnregisterAllEvents()
        return
    end

    e.ToolsSetButtonPoint(button)--设置位置

    button:SetScript('OnMouseDown', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            C_PetJournal.SummonPetByGUID(petGUID)

        elseif not key then
            C_PetJournal.SummonRandomPet(true)
        end
    end)

    button:SetScript('OnMouseWheel', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
   end)

   button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetCompanionPet(petGUID)
        e.tips:AddLine(' ')
        local name=C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        e.tips:AddDoubleLine(name and name..e.Icon.left, (e.onlyChinese and '随机偏好宠物' or SLASH_RANDOMFAVORITEPET1)..e.Icon.right, 0,1,0, 0,1,0)
        e.tips:AddLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU).. e.Icon.mid, 0,1,0)
        e.tips:Show()
    end)
    button:SetScript('OnLeave', function() e.tips:Hide() end)

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
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                button=e.Cbtn2(nil, e.toolsFrame, true, false)

                panel:RegisterEvent('PLAYER_LOGOUT')
                panel:RegisterEvent("PLAYER_REGEN_ENABLED")
                panel:RegisterUnitEvent('UNIT_AURA','player')
                panel:RegisterEvent('PLAYER_STOPPED_MOVING')
                panel:RegisterEvent('PLAYER_TARGET_CHANGED')
                panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                panel:RegisterEvent('COMPANION_UPDATE')

                C_Timer.After(2.4, function()
                    local num = C_PetJournal.GetNumCollectedInfo(speciesID)--没宠物,不加载
                    if not num or num==0 then
                        panel:UnregisterAllEvents()
                        return
                    end
                    if UnitAffectingCombat('player')  then
                        button.combat= true
                    else
                        Init()--初始
                    end
                end)
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then

            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        setSummonedPetGUID()--召唤信息,自动召唤
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
        panel:RegisterEvent('PLAYER_STOPPED_MOVING')
        panel:RegisterUnitEvent('UNIT_AURA','player')
        if button.combat then
            Init()
            button.combat=nil
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