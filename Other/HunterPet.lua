local id, e= ...
if e.Player.class~='HUNTER' or IsAddOnLoaded("ImprovedStableFrame") then
    return
end
--PetStableFrame, IsAddOnLoaded("ImprovedStableFrame")

local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  UnitClass('player'), DUNGEON_FLOOR_ORGRIMMARRAID8) --猎人兽栏
local Save={}

local ISF_SearchInput
local maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS
local NUM_PER_ROW=15

local function ImprovedStableFrame_Update()
    local input = ISF_SearchInput:GetText()
    if not input or input:trim() == "" then
        for i = 1, maxSlots do
            local button = _G["PetStableStabledPet"..i];
            button.dimOverlay:Hide();
        end
        return
    end

    for i = 1, maxSlots do
        local icon, name, level, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i);
        local button = _G["PetStableStabledPet"..i];
        
        button.dimOverlay:Show();
        if icon then
            local matched, expected = 0, 0
            for str in input:gmatch("([^%s]+)") do
                expected = expected + 1
                str = str:trim():lower()

                if name:lower():find(str)
                or family:lower():find(str)
                or talent:lower():find(str)
                then
                    matched = matched + 1
                end
            end
            if matched == expected then
                button.dimOverlay:Hide();
            end
        end
    end
end

local function Init()
    for i = 1, maxSlots do--+NUM_PET_STABLE_SLOTS
        local btn= _G["PetStableStabledPet"..i]
        if not btn then
            btn= CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
        end

        btn.solotText= e.Cstr(btn, {layer='BACKGROUND'})
        btn.solotText:SetAlpha(0.5)
        btn.solotText:SetPoint('CENTER')
        btn.solotText:SetText(i)

        local textrue=_G['PetStableStabledPet'..i..'Background']
        if textrue then
            if e.Player.useColor then
                textrue:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
            else
                textrue:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
            end
            textrue:SetAlpha(0.5)
        end


    end

    for i = 1, maxSlots do
        local frame = _G["PetStableStabledPet"..i]
        if i > 1 then
            frame:ClearAllPoints()
            frame:SetPoint("LEFT", _G["PetStableStabledPet"..i-1], "RIGHT", 4, 0)
        end
        frame:SetFrameLevel(PetStableFrame:GetFrameLevel() + 1)
        --frame:SetScale(7/NUM_PER_ROW)
        frame.dimOverlay = frame:CreateTexture(nil, "OVERLAY");
        frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
        frame.dimOverlay:SetAllPoints();
        frame.dimOverlay:Hide();
    end

    for i = NUM_PER_ROW+1, maxSlots, NUM_PER_ROW do
        _G["PetStableStabledPet"..i]:ClearAllPoints()
        _G["PetStableStabledPet"..i]:SetPoint("TOPLEFT", _G["PetStableStabledPet"..i-NUM_PER_ROW], "BOTTOMLEFT", 0, -5)
    end



    PetStableFrame:SetSize(720, 630)

    PetStableFrameInset.NineSlice:Hide()

    PetStableModelScene:ClearAllPoints()
    PetStableModelScene:SetPoint('RIGHT', PetStableFrame, 'LEFT')
    PetStableModelScene:SetSize( PetStableFrame:GetHeight(),  PetStableFrame:GetHeight())

    if PetStableFrameModelBg:IsShown() then
        PetStableFrameModelBg:ClearAllPoints()
        PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
        PetStableFrameModelBg:SetAlpha(0.3)
        PetStableFrameInset.Bg:Hide()
    end

    PetStablePetInfo:ClearAllPoints()
    --PetStablePetInfo:SetPoint('BOTTOMLEFT', PetStableModelScene,'BOTTOMLEFT')
    PetStableSelectedPetIcon:ClearAllPoints()
    PetStableSelectedPetIcon:SetPoint('RIGHT', PetStableFrame, 'LEFT')
    
    PetStableNameText:ClearAllPoints()
    PetStableNameText:SetPoint('BOTTOMRIGHT', PetStableSelectedPetIcon, 'TOPRIGHT')
    PetStableNameText:SetJustifyH('RIGHT')

    PetStableDiet:ClearAllPoints()
    PetStableDiet:SetPoint('TOPRIGHT', PetStableSelectedPetIcon, 'BOTTOMRIGHT')
    PetStableDiet:SetSize(PetStableSelectedPetIcon:GetSize())

    PetStableTypeText:ClearAllPoints()
    PetStableTypeText:SetPoint('TOPRIGHT', PetStableDiet, 'BOTTOMRIGHT')

    PetStableNextPageButton:Hide()
    PetStablePrevPageButton:Hide()
    PetStableBottomInset:Hide()

    local frame = CreateFrame("Frame", nil, PetStableFrame)-- "ImprovedStableFrameSlots", PetStableFrame, "InsetFrameTemplate")
    frame:ClearAllPoints()
    frame:SetSize(640, 550)

    frame:SetPoint(PetStableFrame.Inset:GetPoint(1))
    PetStableFrame.Inset:SetPoint("TOPLEFT", frame, "TOPRIGHT")

    
    --PetStableFrameModelBg
    --PetStableFrameModelBg:SetHeight(281 + heightDelta)

    --[[local p, r, rp, x, y = PetStableModelScene:GetPoint(1)
    PetStableModelScene:SetPoint(p, r, rp, x, y - 32)]]

    PetStableStabledPet1:ClearAllPoints()
    PetStableStabledPet1:SetPoint("TOPLEFT", frame, 8, -8)


    ISF_SearchInput = CreateFrame("EditBox", nil, PetStableFrame, "SearchBoxTemplate")
    if ISF_SearchInput.Middle then
        ISF_SearchInput.Middle:SetAlpha(0.5)
        ISF_SearchInput.Right:SetAlpha(0.5)
        ISF_SearchInput.Left:SetAlpha(0.5)
    end
    --ISF_SearchInput:SetPoint("TOPLEFT", 9, 0)
    --ISF_SearchInput:SetPoint("RIGHT", -3, 0)
    ISF_SearchInput:SetSize(360,20)
    ISF_SearchInput:SetPoint('BOTTOMRIGHT',-8, 8)
    
    ISF_SearchInput:HookScript("OnTextChanged", ImprovedStableFrame_Update)
    ISF_SearchInput.Instructions:SetText(e.onlyChinese and '名称，类型，天赋' or (NAME .. ", " .. TYPE .. ", " .. TALENT))



    NUM_PET_STABLE_SLOTS = maxSlots
    NUM_PET_STABLE_PAGES = 1
    PetStableFrame.page = 1
    


    hooksecurefunc("PetStable_Update", ImprovedStableFrame_Update)
end

local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PET_STABLE_SHOW')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            print(IsAddOnLoaded("ImprovedStableFrame"))
            --添加控制面板
            e.AddPanel_Check({
                name= '|T656681:0|t'..(e.onlyChinese and '猎人兽栏' or addName),
                tooltip= nil,
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled or IsAddOnLoaded("ImprovedStableFrame") then
               panel:UnregisterAllEvents()
            else
                Init()
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