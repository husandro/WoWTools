local id, e = ...
local addName='DaisyTools'
local Save={

}


local button

local petName, petGUID
local speciesID=2780

local Pets={
    [2780] = {name='黛西', emote='BECKON'},
}

local function setTargetChaged()
    if Save.notGuLai then
        return
    end
    if UnitIsBattlePetCompanion('target') and C_PetJournal.GetSummonedPetGUID()==petGUID then
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
    local find= summonedPetGUID==petGUID
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
        and not UnitAffectingCombat('player')
        then
        C_PetJournal.SummonPetByGUID(petGUID)
    end
    if button.text then--显示名字
        button.text:SetText(find and petName or '')
    end
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

    --[[if not petGUID then--没找到时, 退出
        print(id, e.cn(addName), e.onlyChinese and '没发现宠物, 黛西' or TAXI_PATH_UNREACHABLE)
        panel:UnregisterAllEvents()
        return
    end]]

    e.ToolsSetButtonPoint(button)--设置位置

    button:SetScript('OnClick', function(_, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            C_PetJournal.SummonPetByGUID(petGUID)

        elseif not key then
            C_PetJournal.SummonRandomPet(true)
        end
    end)

    button:SetScript('OnMouseWheel', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)--主菜单
                local info={
                    text= e.onlyChinese and '使用 /招手' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, USE, EMOTE102_CMD1),
                    checked=not Save.notGuLai,
                    keepShownOnClick=true,
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
                    text= e.onlyChinese and '自动召唤' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SUMMONS),
                    checked=Save.autoSummon,
                    keepShownOnClick=true,
                    func=function()
                        Save.autoSummon= not Save.autoSummon and true or nil
                        setSummonedPetGUID()
                        setAutoSummonTips()--设置, 自动召唤
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end, 'MENU')
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
    button:SetScript('OnLeave', GameTooltip_Hide)

    setGuLaiTip()--设置 是否使用 /招手
    setSummonedPetGUID()--召唤信息,自动召唤
    if Save.autoSummon then
        setAutoSummonTips()--设置, 自动召唤
    end
end

















--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            if not e.toolsFrame.disabled then
                button= e.Cbtn2({
                    name=nil,
                    parent= e.toolsFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })


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