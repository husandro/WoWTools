local id, e = ...
local addName='DaisyTools'
local Save={
    speciesID=2280
}


local button
local Pets={}

local Tabs={
    [2780]= {cn='黛西', emote='BECKON', auraID=311796},
 }
 for _, info in pairs(Tabs) do
    if info.auraID then
        e.LoadDate({id=info.auraID, type='spell'})
    end
 end


local function set_pets_data()
    Pets={}
    for speciesID, tab in pairs(Tabs) do
        local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        Pets[speciesID]= {
            name= speciesName,
            cn= tab.cn,
            guid=select(2, C_PetJournal.FindPetIDByName(speciesName)),
            icon= speciesIcon,
            emote=tab.emote,
            auraID= tab.auraID,
            auraName= tab.auraID and GetSpellInfo(tab.auraID) or nil,
        }
        if Save.speciesID== speciesID then
            button.texture:SetTexture(speciesIcon)
        end
    end
end

local function get_speciesID_data()
    return Pets[Save.speciesID] or {}
end


local function setTargetChaged()
    local info= get_speciesID_data()
    if Save.notGuLai or not info.emote then
        return
    end
    if UnitIsBattlePetCompanion('target') and C_PetJournal.GetSummonedPetGUID()==info.guid then
        DoEmote(info.emote)--beckon
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


local function setSummonedPetGUID()--召唤信息
    local info= get_speciesID_data()
    local guid= info.guid
    if not guid then
        set_pets_data()
        return
    end

    local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
    local find= (info.guid and summonedPetGUID==guid) and true or false
    if not find and info.auraName and AuraUtil.FindAuraByName(info.auraName, 'player', 'HELPFUL') then
        find=true
        --if not summonedPetGUID then
          --  C_PetJournal.SummonRandomPet(true)
        --end
    end
    if not find and Save.autoSummon
        and not IsStealthed()
        and not IsMounted()
        and not UnitIsDeadOrGhost('player')
        and not UnitIsBattlePet('player')
        and not UnitInBattleground('player')
        and not C_PvP.IsArena()
        and not UnitCastingInfo('player')
        and not UnitChannelInfo('paleyr')
        and not UnitAffectingCombat('player')
        and not UnitInVehicle('player')
    then
        C_PetJournal.SummonPetByGUID(guid)
    end
    local name
    if find then
        name= e.onlyChinese and info.cn or e.WA_Utf8Sub(info.name, 2, 5)
    end
    button.Text:SetText(name or '')
end














--####
--初始
--####
local function Init()
    set_pets_data()
    button.Text=e.Cstr(button, {size=10, color=true})-- size,nil,nil, true)
    button.Text:SetPoint('CENTER',0 , -5)

    e.ToolsSetButtonPoint(button)--设置位置

    button:SetScript('OnClick', function(_, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            local guid= get_speciesID_data().guid
            if guid then
                C_PetJournal.SummonPetByGUID(guid)
            end

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
        local info= get_speciesID_data()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if info.guid then
            e.tips:SetCompanionPet(info.guid)
        end
        e.tips:AddLine(' ')
        local name =info.name or info.cn
        if name then
            e.tips:AddDoubleLine(name, e.Icon.left)
        end
        e.tips:AddDoubleLine(e.onlyChinese and '随机偏好宠物' or SLASH_RANDOMFAVORITEPET1:gsub('/', ''), e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), e.Icon.mid)
        e.tips:Show()
    end)
    button:SetScript('OnLeave', GameTooltip_Hide)



    setGuLaiTip()--设置 是否使用 /招手
    setSummonedPetGUID()--召唤信息,自动召唤
    setAutoSummonTips()--设置, 自动召唤
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
            Save.speciesID= Save.speciesID or 2780

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

                if UnitAffectingCombat('player')  then
                    button.combat= true
                else
                    Init()--初始
                end

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