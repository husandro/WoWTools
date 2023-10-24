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




local function ImprovedStableFrame_Update()
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



local function Create_Text(btn, index)--创建，提示内容
    btn.solotText= e.Cstr(btn, {layer='BACKGROUND', color={r=1,g=1,b=1,a=0.2}})
    btn.solotText:SetPoint('CENTER')
    btn.solotText:SetText(index)

    btn.talentText= e.Cstr(btn, {layer='ARTWORK'})
    btn.talentText:SetAlpha(1)
    btn.talentText:SetPoint('BOTTOM')
end



local function Init()

    PetStableStabledPet1:ClearAllPoints()--设置，200个按钮，第一个位置
    PetStableStabledPet1:SetPoint("TOPLEFT", PetStableFrame, 97, -37)
    for i = 1, maxSlots do
        local btn= _G["PetStableStabledPet"..i]
        if not btn then
            btn= CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
        end
        Create_Text(btn, i)--创建，提示内容

        local textrue= _G['PetStableStabledPet'..i..'Background']--按钮，背景
        if textrue then
            if e.Player.useColor then
                textrue:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
            else
                textrue:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
            end
            textrue:SetAlpha(0.5)
        end
    end
    


    local CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245}--召唤，宠物，法术
    for i= 1, NUM_PET_ACTIVE_SLOTS do
        local btn= _G['PetStableActivePet'..i]
        if btn then
            Create_Text(btn, i)--创建，提示内容
            if CALL_PET_SPELL_IDS[i] then--召唤，宠物，法术
                local texture= btn:CreateTexture()
                texture:SetSize(22,22)
                texture:SetPoint('RIGHT', btn, 'LEFT')
                texture.spellID= CALL_PET_SPELL_IDS[i]
                local icon= select(3, GetSpellInfo(CALL_PET_SPELL_IDS[i])) or 132161
                texture:SetTexture(icon)
                texture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
                texture:SetScript('OnEnter', function(self)
                    if self.spellID then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetSpellByID(self.spellID)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                    end
                    self:SetAlpha(0.5)
                end)
            end
        end
        --local label= _G['PetStableActivePet'..i..'PetName']
    end

    local layer=PetStableFrame:GetFrameLevel()+ 1--查询
    for i = 1, maxSlots do
        local frame = _G["PetStableStabledPet"..i]
        if i > 1 then
            frame:ClearAllPoints()
            frame:SetPoint("LEFT", _G["PetStableStabledPet"..i-1], "RIGHT", 4, 0)
        end
        frame:SetFrameLevel(layer)
        frame.dimOverlay = frame:CreateTexture(nil, "OVERLAY");
        frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
        frame.dimOverlay:SetAllPoints();
        frame.dimOverlay:Hide();
    end

    for i = NUM_PER_ROW+1, maxSlots, NUM_PER_ROW do
        _G["PetStableStabledPet"..i]:ClearAllPoints()
        _G["PetStableStabledPet"..i]:SetPoint("TOPLEFT", _G["PetStableStabledPet"..i-NUM_PER_ROW], "BOTTOMLEFT", 0, -5)
    end

    --local frame = CreateFrame("Frame", nil, "ImprovedStableFrameSlots", PetStableFrame, "InsetFrameTemplate")
    --frame:ClearAllPoints()
    --frame:SetSize(640, 550)

    --frame:SetPoint(PetStableFrame.Inset:GetPoint(1))
    --PetStableFrame.Inset:SetPoint("TOPLEFT", frame, "TOPRIGHT")

    --查询
    ISF_SearchInput = CreateFrame("EditBox", nil, PetStableFrame, "SearchBoxTemplate")
    if ISF_SearchInput.Middle then
        ISF_SearchInput.Middle:SetAlpha(0.5)
        ISF_SearchInput.Right:SetAlpha(0.5)
        ISF_SearchInput.Left:SetAlpha(0.5)
    end

    ISF_SearchInput:SetSize(270,20)
    ISF_SearchInput:SetPoint('BOTTOMRIGHT',-6, 10)
    ISF_SearchInput:SetScale(1.2)

    ISF_SearchInput:HookScript("OnTextChanged", ImprovedStableFrame_Update)
    ISF_SearchInput.Instructions:SetText(e.onlyChinese and '名称，类型，天赋' or (NAME .. ", " .. TYPE .. ", " .. TALENT))
    hooksecurefunc("PetStable_Update", ImprovedStableFrame_Update)

    
    
    

    local w, h=720, 630
    PetStableFrame:SetSize(w, h)--设置，大小
    PetStableFrameInset.NineSlice:Hide()


    PetStableModelScene:ClearAllPoints()--设置，3D，位置
    PetStableModelScene:SetPoint('LEFT', PetStableFrame, 'RIGHT')
    PetStableModelScene:SetSize(h, h)

    if PetStableFrameModelBg:IsShown() then--3D，背景
        PetStableFrameModelBg:ClearAllPoints()
        PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
        PetStableFrameModelBg:SetAlpha(0.3)
        PetStableFrameInset.Bg:Hide()
    end

    PetStablePetInfo:ClearAllPoints()--隐藏，宠物，信息
    PetStablePetInfo:SetPoint('BOTTOMLEFT',PetStableFrame, 'BOTTOMRIGHT')
    

    PetStableNextPageButton:Hide()--隐藏
    PetStablePrevPageButton:Hide()
    PetStableBottomInset:Hide()

    NUM_PET_STABLE_SLOTS = maxSlots
    NUM_PET_STABLE_PAGES = 1
    PetStableFrame.page = 1

    

    hooksecurefunc('PetStable_UpdateSlot', function(button, petSlot)--宠物，类型
        if button.talentText then
            local talent =petSlot and select(5, GetStablePetInfo(petSlot))
            talent = talent and e.WA_Utf8Sub(talent, 2, 5, true) or ''
            button.talentText:SetText(talent)
        end
    end)
    


    
    PetStableDiet:ClearAllPoints()
    PetStableDiet:SetSize(PetStableSelectedPetIcon:GetSize())
    PetStableDiet:SetPoint('BOTTOMRIGHT', PetStableSelectedPetIcon,'TOPRIGHT', 0,2)
    PetStableDiet:HookScript('OnLeave', function(self) self:SetAlpha(1) end)
    PetStableDiet:HookScript('OnEnter', function(self) self:SetAlpha(0.5) end)

    PetStablePetInfo.foodLable= e.Cstr(PetStablePetInfo)--食物
    PetStablePetInfo.foodLable:SetPoint('LEFT', PetStableDiet, 'Right',4,0)
    

    PetStableTypeText:ClearAllPoints()
    PetStableTypeText:SetPoint('BOTTOMLEFT', PetStableDiet, 'TOPLEFT',0,2)
    PetStableTypeText:SetJustifyH('LEFT')
    
    
    

    --PetStablePetInfo.foodLable:SetPoint('LEFT', PetStableTypeText, 'RIGHT', 4,0)
    hooksecurefunc('PetStable_UpdatePetModelScene', function()
        if GetStablePetFoodTypes(PetStableFrame.selectedPet) then
            PetStablePetInfo.foodLable:SetText(format(e.onlyChinese and '|cffffd200食物：|r%s' or PET_DIET_TEMPLATE, BuildListString(GetStablePetFoodTypes(PetStableFrame.selectedPet))))
        else
            PetStablePetInfo.foodLable:SetText('')
        end
    end)

    --[[PetStableSelectedPetIcon:ClearAllPoints()--提示，当前，宠物，图标
    PetStableSelectedPetIcon:SetPoint('RIGHT', PetStableFrame, 'LEFT', -4,0)

    PetStableNameText:ClearAllPoints()--，当前，宠物，名称
    PetStableNameText:SetPoint('BOTTOMRIGHT', PetStableSelectedPetIcon, 'TOPRIGHT')
    PetStableNameText:SetJustifyH('RIGHT')

    PetStableDiet:ClearAllPoints()--食物，提示，图标
    PetStableDiet:SetPoint('TOPRIGHT', PetStableSelectedPetIcon, 'BOTTOMRIGHT')
    PetStableDiet:SetSize(PetStableSelectedPetIcon:GetSize())

    PetStableTypeText:ClearAllPoints()--宠物，类型，文本
    PetStableTypeText:SetPoint('TOPRIGHT', PetStableDiet, 'BOTTOMRIGHT')]]



    --[[PetStableModelScene:ClearAllPoints()--设置，3D，位置
    PetStableModelScene:SetPoint('RIGHT', PetStableFrame, 'LEFT')
    PetStableModelScene:SetSize(h, h)

    if PetStableFrameModelBg:IsShown() then--3D，背景
        PetStableFrameModelBg:ClearAllPoints()
        PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
        PetStableFrameModelBg:SetAlpha(0.3)
        PetStableFrameInset.Bg:Hide()
    end

    PetStablePetInfo:ClearAllPoints()--隐藏，宠物，信息

    PetStableSelectedPetIcon:ClearAllPoints()--提示，当前，宠物，图标
    PetStableSelectedPetIcon:SetPoint('RIGHT', PetStableFrame, 'LEFT', -4,0)

    PetStableNameText:ClearAllPoints()--，当前，宠物，名称
    PetStableNameText:SetPoint('BOTTOMRIGHT', PetStableSelectedPetIcon, 'TOPRIGHT')
    PetStableNameText:SetJustifyH('RIGHT')

    PetStableDiet:ClearAllPoints()--食物，提示，图标
    PetStableDiet:SetPoint('TOPRIGHT', PetStableSelectedPetIcon, 'BOTTOMRIGHT')
    PetStableDiet:SetSize(PetStableSelectedPetIcon:GetSize())

    PetStableTypeText:ClearAllPoints()--宠物，类型，文本
    PetStableTypeText:SetPoint('TOPRIGHT', PetStableDiet, 'BOTTOMRIGHT')]]




    --[[local model= CreateFrame('ModelScene', nil, PetStableFrame,'PanningModelSceneMixinTemplate', 1)
    model:SetSize(400,400)
    model:SetPoint('LEFT', PetStableFrame, 'RIGHT')

    local forceSceneChange = true;
	model:TransitionToModelSceneID(718, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(1);
	if creatureDisplayID then
		local actor = model:GetActorByTag("pet");
		if actor then
			actor:SetModelByCreatureDisplayID(creatureDisplayID);
		end
	end]]

end

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
                    Init()
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
    end
end)