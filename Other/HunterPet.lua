local id, e= ...
if e.Player.class~='HUNTER' then --or IsAddOnLoaded("ImprovedStableFrame") then
    return
end

--PetStableFrame, IsAddOnLoaded("ImprovedStableFrame")
--PetStable.lua

local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  UnitClass('player'), DUNGEON_FLOOR_ORGRIMMARRAID8) --猎人兽栏
local Save={}

local ISF_SearchInput
local maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS
local NUM_PER_ROW=15




local function ImprovedStableFrame_Update()--查询
    local input = ISF_SearchInput:GetText()
    if not input or input:trim() == "" then
        for i = 1, maxSlots do
            _G["PetStableStabledPet"..i].dimOverlay:Hide()
        end
        return
    end

    for i = 1, maxSlots do
        local icon, name, _, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i);
        local btn = _G["PetStableStabledPet"..i];
        local show=true
        if icon then
            local matched, expected = 0, 0
            for str in input:gmatch("([^%s]+)") do
                expected = expected + 1
                str = str:trim():lower()
                if
                    name:lower():find(str)
                    or family:lower():find(str)
                    or talent:lower():find(str)
                then
                    matched = matched + 1
                end
            end
            if matched == expected then
                show=false
            end
        end
        btn.dimOverlay:SetShown(show)
    end
end

local function Set_Food_Lable()--食物
    if GetStablePetFoodTypes(PetStableFrame.selectedPet) then
        PetStablePetInfo.foodLable:SetText(BuildListString(GetStablePetFoodTypes(PetStableFrame.selectedPet)))
    else
        PetStablePetInfo.foodLable:SetText('')
    end
end


local function set_PetStable_UpdateSlot(btn, petSlot)
    if btn.talentText then--宠物，类型
        local talent =petSlot and select(5, GetStablePetInfo(petSlot))
        talent = talent and e.WA_Utf8Sub(talent, 2, 5, true) or ''
        btn.talentText:SetText(talent)
    end

    if btn.model then--已激活宠物，提示

        local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(petSlot);
        if creatureDisplayID and creatureDisplayID>0 then
            if creatureDisplayID~=btn.creatureDisplayID then
                --[[local actor = btn.model:GetActorByTag("pet");
                if actor then
                    actor:SetModelByCreatureDisplayID(creatureDisplayID);
                end]]
                btn.model:SetDisplayInfo(creatureDisplayID)
            end
        else
            btn.model:ClearScene()
        end
        btn.creatureDisplayID= creatureDisplayID--提示用，
        btn:set_Activ_Button_Texture()
    end
end


local function Create_Text(btn, index, searchTips)--创建，提示内容
    btn.solotText= e.Cstr(btn, {layer='BACKGROUND', color={r=1,g=1,b=1,a=0.2}})
    btn.solotText:SetPoint('CENTER')
    btn.solotText:SetText(index)

    btn.talentText= e.Cstr(btn, {layer='ARTWORK', color=true})
    btn.talentText:SetAlpha(1)
    btn.talentText:SetPoint('BOTTOM')

    if searchTips then
        btn.dimOverlay = btn:CreateTexture(nil, "OVERLAY");--查询提示用
        btn.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
        btn.dimOverlay:SetAllPoints();
        btn.dimOverlay:Hide();
    end
end

local function HookEnter_Button(btn)--GameTooltip 提示用 tooltips.lua
    if e.tips.playerModel and btn.petSlot then
        local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(btn.petSlot);
        if creatureDisplayID and creatureDisplayID>0 then
            e.tips.playerModel:SetDisplayInfo(creatureDisplayID)
            e.tips.playerModel:SetShown(true)
            if GetStablePetFoodTypes(btn.petSlot) then
                e.tips:AddLine(format(e.onlyChinese and '|cffffd200食物：|r%s' or PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(PetStableFrame.selectedPet))), 1, 1, 1, true)
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('creatureDisplayID', creatureDisplayID)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end
    end
end

local function Init()
    local w, h=720, 630
    local layer= PetStableFrame:GetFrameLevel()+ 1

    NUM_PET_STABLE_SLOTS = maxSlots
    NUM_PET_STABLE_PAGES = 1
    PetStableFrame.page = 1
    PetStableFrame:SetSize(w, h)--设置，大小

    PetStableStabledPet1:ClearAllPoints()--设置，200个按钮，第一个位置
    PetStableStabledPet1:SetPoint("TOPLEFT", PetStableFrame, 97, -37)

    for i = 1, maxSlots do
        local btn= _G["PetStableStabledPet"..i]
        if not btn then
            btn= CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
        end
        btn:SetFrameLevel(layer)
        --btn:SetScale(1)

        Create_Text(btn, i, true)--创建，提示内容

        btn:HookScript('OnEnter', HookEnter_Button)--GameTooltip 提示用 tooltips.lua

        local textrue= _G['PetStableStabledPet'..i..'Background']--处理，按钮，背景 Texture.lua，中有处理过
        if textrue then
            if e.Player.useColor then
                textrue:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
            else
                textrue:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
            end
            textrue:SetAlpha(0.5)
        end

        if i > 1 then--设置位置
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", _G["PetStableStabledPet"..i-1], "RIGHT", 4, 0)
        end
    end

    for i = NUM_PER_ROW+1, maxSlots, NUM_PER_ROW do--换行
        _G["PetStableStabledPet"..i]:ClearAllPoints()
        _G["PetStableStabledPet"..i]:SetPoint("TOPLEFT", _G["PetStableStabledPet"..i-NUM_PER_ROW], "BOTTOMLEFT", 0, -4)
    end


    --已激活宠物
    local CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245}--召唤，宠物，法术
    local modeW= h/NUM_PET_ACTIVE_SLOTS
    for i= 1, NUM_PET_ACTIVE_SLOTS do
        local btn= _G['PetStableActivePet'..i]
        if btn then
            Create_Text(btn, i)--创建，提示内容
            
            
            --已激活宠物，提示
            btn.model= CreateFrame("PlayerModel", nil, PetStableFrame)

            btn.model:SetSize(modeW, modeW)
            btn.model:SetFacing(0.3)
            if i==1 then
                btn.model:SetPoint('TOPRIGHT', PetStableFrame, 'TOPLEFT', -14,0)
            else
                btn.model:SetPoint('TOP', _G['PetStableActivePet'..i-1].model, 'BOTTOM')
            end
            local bg=btn.model:CreateTexture('BACKGROUND')
            bg:SetPoint('LEFT')
            bg:SetSize(modeW+14, modeW)
            bg:SetAtlas('ShipMission_RewardsBG-Desaturate')
            bg:SetAlpha(0.5)
            btn:HookScript('OnEnter', HookEnter_Button)--GameTooltip 提示用 tooltips.lua

            if CALL_PET_SPELL_IDS[i] then--召唤，宠物，法术
                btn.spellActivaButton= e.Cbtn(btn, {size={22,22}, icon='hide'})
                btn.spellActivaButton:SetPoint('LEFT', btn.model, 'RIGHT', -10,0)
                btn.spellActivaButton:SetFrameLevel(layer+2)
                btn.spellID= CALL_PET_SPELL_IDS[i]
                function btn:set_Activ_Button_Texture()
                    local icon= select(3, GetSpellInfo(self.spellID)) or 132161
                    self.spellActivaButton:SetNormalTexture(icon)
                end
                btn:set_Activ_Button_Texture()


                btn.spellActivaButton:SetScript('OnLeave', function(self) e.tips:Hide() end)
                btn.spellActivaButton:SetScript('OnEnter', function(self)
                    local parent= self:GetParent()
                    local spellID= parent.spellID
                    if spellID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(spellID)
                        e.tips:AddLine(' ')
                        local creatureDisplayID=  parent.creatureDisplayID
                        if creatureDisplayID and creatureDisplayID>0 then
                            e.tips:AddDoubleLine('creatureDisplayID', creatureDisplayID)
                        end
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                    end
                end)
            end
            local label= _G['PetStableActivePet'..i..'PetName']
            if label then
                label:ClearAllPoints()
                label:SetPoint('TOP', btn, 'BOTTOM')
                label:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                label:SetShadowOffset(1, -1)
                label:SetJustifyH('LEFT')
                label:SetScale(0.85)
            end
        end
    end




    --查询
    ISF_SearchInput = _G['ISF_SearchInput'] or CreateFrame("EditBox", nil, PetStableStabledPet1, "SearchBoxTemplate")
    if ISF_SearchInput.Middle then
        ISF_SearchInput.Middle:SetAlpha(0.5)
        ISF_SearchInput.Right:SetAlpha(0.5)
        ISF_SearchInput.Left:SetAlpha(0.5)
    end

    ISF_SearchInput:SetSize(270,20)
    if  _G['ISF_SearchInput'] then ISF_SearchInput:ClearAllPoints() end--处理插件，Improved Stable Frame
    ISF_SearchInput:SetPoint('BOTTOMRIGHT',PetStableFrame, -6, 10)
    ISF_SearchInput:SetScale(1.2)
    ISF_SearchInput.Instructions:SetText(e.onlyChinese and '名称，类型，天赋' or (NAME .. ", " .. TYPE .. ", " .. TALENT))

    ISF_SearchInput:HookScript("OnTextChanged", ImprovedStableFrame_Update)
    hooksecurefunc("PetStable_Update", ImprovedStableFrame_Update)


    PetStableModelScene:ClearAllPoints()--设置，3D，位置
    PetStableModelScene:SetPoint('LEFT', PetStableFrame, 'RIGHT')
    PetStableModelScene:SetSize(h, h)

    --3D，背景
    PetStableFrameModelBg:ClearAllPoints()
    PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
    PetStableFrameModelBg:SetAlpha(0.3)
    PetStableFrameInset.Bg:Hide()
    PetStableFrameModelBg:SetAtlas('ShipMission_RewardsBG-Desaturate')
    --PetStableFrameInset.NineSlice:Hide()--预览外框
    PetStableFrameInset.NineSlice:ClearAllPoints()
    PetStableFrameInset.NineSlice:SetPoint('TOPLEFT')
    PetStableFrameInset.NineSlice:SetPoint('BOTTOMRIGHT', PetStableFrame, -4, 4)

    PetStablePetInfo:ClearAllPoints()--隐藏，宠物，信息
    PetStablePetInfo:SetPoint('BOTTOMLEFT',PetStableFrame, 'BOTTOMRIGHT')

    PetStableNextPageButton:Hide()--隐藏
    PetStablePrevPageButton:Hide()
    PetStableBottomInset:Hide()

    hooksecurefunc('PetStable_UpdateSlot', set_PetStable_UpdateSlot)

    PetStableDiet:ClearAllPoints()
    PetStableDiet:SetSize(PetStableSelectedPetIcon:GetSize())
    PetStableDiet:SetPoint('BOTTOMRIGHT', PetStableSelectedPetIcon,'TOPRIGHT', 0,2)
    PetStableDiet:HookScript('OnLeave', function(self) self:SetAlpha(1) end)
    PetStableDiet:HookScript('OnEnter', function(self) self:SetAlpha(0.5) end)

    PetStablePetInfo.foodLable= e.Cstr(PetStablePetInfo, {color=true})--食物
    PetStablePetInfo.foodLable:SetPoint('LEFT', PetStableDiet, 'Right',0,0)
    Set_Food_Lable()--食物
    hooksecurefunc('PetStable_UpdatePetModelScene', Set_Food_Lable)--食物

    PetStableNameText:ClearAllPoints()
    PetStableNameText:SetPoint('BOTTOMLEFT', PetStableSelectedPetIcon, 'RIGHT', 0,2)
    PetStableNameText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)--选定，宠物，名称

    PetStableTypeText:ClearAllPoints()
    PetStableTypeText:SetPoint('TOPLEFT', PetStableSelectedPetIcon, 'RIGHT',0, -2)
    --PetStableTypeText:SetPoint('BOTTOMLEFT', PetStableDiet, 'TOPLEFT',0,2)
    PetStableTypeText:SetJustifyH('LEFT')
    PetStableTypeText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    PetStableTypeText:SetShadowOffset(1, -1)

    PetStableActiveBg:ClearAllPoints()--已激活宠物，背景，大小
    PetStableActiveBg:SetAllPoints(PetStableLeftInset)

    e.call('PetStable_Update')
end
--[[
self:SetPortraitToAsset("Interface\\Icons\\ability_physical_taunt");
ButtonFrameTemplate_HideButtonBar(self);
self.Inset
self.LeftInset
self.BottomInset
self.page = 1;
self.selectedPet = nil;

local frame = CreateFrame("Frame", nil, "ImprovedStableFrameSlots", PetStableFrame, "InsetFrameTemplate")
frame:ClearAllPoints()
frame:SetSize(640, 550)
frame:SetPoint(PetStableFrame.Inset:GetPoint(1))
PetStableFrame.Inset:SetPoint("TOPLEFT", frame, "TOPRIGHT")

--btn.model= CreateFrame('ModelScene', nil, PetStableFrame, 'PanningModelSceneMixinTemplate', i)
--btn.model:TransitionToModelSceneID(718, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true);
local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(petSlot);
local actor = btn.model:GetActorByTag("pet");
if actor then
    actor:SetModelByCreatureDisplayID(creatureDisplayID);
end
btn.model:SetDisplayInfo(creatureDisplayID)
]]


local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PET_STABLE_SHOW')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if PetStableFrame then

                Save= WoWToolsSave[addName] or Save
                --添加控制面板
                e.AddPanel_Check({
                    name= '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName),
                    tooltip= nil,
                    value= not Save.disabled,
                    func= function()
                        Save.disabled = not Save.disabled and true or nil
                        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                    end
                })

                if Save.disabled  then-- or IsAddOnLoaded("ImprovedStableFrame") then
                    panel:UnregisterAllEvents()
                else
                    if IsAddOnLoaded("ImprovedStableFrame") then
                        print(id, addName,
                            e.GetEnabeleDisable(false), 'Improved Stable Frame',
                            e.onlyChinese and '插件' or ADDONS
                        )
                    end
                end

            end
            self:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PET_STABLE_SHOW' then
        Init()
        panel:UnregisterEvent('PET_STABLE_SHOW')
    end
end)