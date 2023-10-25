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

--local IsInSearch


local function Get_Food_Text(slotPet)
    return BuildListString(GetStablePetFoodTypes(slotPet))
end

--local func_PetStable_Update= PetStable_Update

local function set_PetStable_Update()--查询
    --[[if IsInSearch then
        return
    end]]
    local input = ISF_SearchInput:GetText()
    local all= maxSlots + NUM_PET_ACTIVE_SLOTS
    local num=0
    local btn
    local isSearch= input and input:trim()~= ""

    for i = 1, all do
        local icon, name, _, family, talent = GetStablePetInfo(i);
        if i<=NUM_PET_ACTIVE_SLOTS then
            btn= _G['PetStableActivePet'..i]
        else
            btn= _G["PetStableStabledPet"..i- NUM_PET_ACTIVE_SLOTS]
        end
        local show= isSearch
        if icon then

            if isSearch then
                local food = BuildListString(GetStablePetFoodTypes(i)) or ''
                local matched, expected = 0, 0
                for str in input:gmatch("([^%s]+)") do
                    expected = expected + 1
                    str = str:trim():lower()
                    if name:lower():find(str) or family:lower():find(str) or talent:lower():find(str) or food:lower():find(str) then
                        matched = matched + 1
                    end
                end
                if matched == expected then
                   show= false
                    num= num +1
                end
            else
                num= num +1
            end
        end
        btn.dimOverlay:SetShown(show)
    end
    ISF_SearchInput.text:SetFormattedText(isSearch and '|A:common-search-magnifyingglass:0:0|a |cnGREEN_FONT_COLOR:%d|r /%d' or (e.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN), num, all)
end


local function Set_Food_Lable()--食物
    PetStablePetInfo.foodLable:SetText(Get_Food_Text(PetStableFrame.selectedPet) or '')
end


local function set_PetStable_UpdateSlot(btn, petSlot)--宠物，类型，已激MODEL
    if btn.talentText then--宠物，类型
        local talent =petSlot and select(5, GetStablePetInfo(petSlot))
        talent = talent and e.WA_Utf8Sub(talent, 2, 5, true) or ''
        btn.talentText:SetText(talent)
    end

    if btn.model then--已激活宠物，提示
        local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(petSlot);
        if creatureDisplayID and creatureDisplayID>0 then
            if creatureDisplayID~=btn.creatureDisplayID then
                btn.model:SetDisplayInfo(creatureDisplayID)
            end
        else
            btn.model:ClearModel()
        end
        btn.creatureDisplayID= creatureDisplayID--提示用，
    end
end


local function Create_Text(btn, index, showSlotNum)--创建，提示内容
    if showSlotNum then
        btn.solotText= e.Cstr(btn, {layer='BACKGROUND', color={r=1,g=1,b=1,a=0.2}})--栏位
        btn.solotText:SetPoint('CENTER')
        btn.solotText:SetText(index)
    end

    btn.dimOverlay = btn:CreateTexture(nil, "OVERLAY");--查询提示用
    btn.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
    btn.dimOverlay:SetAllPoints();
    btn.dimOverlay:Hide();

    btn.talentText= e.Cstr(btn, {layer='ARTWORK', color=true})--天赋
    btn.talentText:SetAlpha(1)
    btn.talentText:SetPoint('BOTTOM')

    btn:RegisterForDrag('LeftButton', "RightButton")
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
end

local function HookEnter_Button(btn)--GameTooltip 提示用 tooltips.lua
    if e.tips.playerModel and btn.petSlot then
        local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(btn.petSlot);
        if creatureDisplayID and creatureDisplayID>0 then
            e.tips.playerModel:SetDisplayInfo(creatureDisplayID)
            e.tips.playerModel:SetShown(true)
            local food= Get_Food_Text(btn.petSlot)
            if food then
                e.tips:AddLine(format(e.onlyChinese and '|cffffd200食物：|r%s' or PET_DIET_TEMPLATE, food, 1, 1, 1, true))
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

    PetStableNextPageButton:Hide()--隐藏
    PetStablePrevPageButton:Hide()
    PetStableBottomInset:Hide()

    PetStableStabledPet1:ClearAllPoints()--设置，200个按钮，第一个位置
    PetStableStabledPet1:SetPoint("TOPLEFT", PetStableFrame, 97, -37)

    for i = 1, maxSlots do
        local btn= _G["PetStableStabledPet"..i] or CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
        btn.petSlot= btn.petSlot or (NUM_PET_ACTIVE_SLOTS+i)

        btn:SetFrameLevel(layer)

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

    --查询
    ISF_SearchInput = _G['ISF_SearchInput'] or CreateFrame("EditBox", nil, PetStableStabledPet1, "SearchBoxTemplate")
    ISF_SearchInput.Middle:SetAlpha(0.5)
    ISF_SearchInput.Right:SetAlpha(0.5)
    ISF_SearchInput.Left:SetAlpha(0.5)
    ISF_SearchInput:SetSize(270,20)
    if  _G['ISF_SearchInput'] then ISF_SearchInput:ClearAllPoints() end--处理插件，Improved Stable Frame
    ISF_SearchInput:SetPoint('BOTTOMRIGHT',PetStableFrame, -6, 10)
    ISF_SearchInput:SetScale(1.2)
    ISF_SearchInput.Instructions:SetText(e.onlyChinese and '名称，类型，天赋，食物' or (NAME .. ", " .. TYPE .. ", " .. TALENT..', '..POWER_TYPE_FOOD))
    ISF_SearchInput:HookScript("OnTextChanged", set_PetStable_Update)
    hooksecurefunc("PetStable_Update", set_PetStable_Update)

    ISF_SearchInput.text= e.Cstr(ISF_SearchInput, {color=true})
    ISF_SearchInput.text:SetPoint('BOTTOMLEFT', ISF_SearchInput, 'TOPLEFT')

    --已激活宠物
    local CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245}--召唤，宠物，法术
    local modelH= (PetStableLeftInset:GetHeight()-28)/NUM_PET_ACTIVE_SLOTS
    for i= 1, NUM_PET_ACTIVE_SLOTS do
        local btn= _G['PetStableActivePet'..i]
        if btn then
            Create_Text(btn, i)--创建，提示内容

            --已激活宠物，提示
            btn.model= CreateFrame("PlayerModel", nil, PetStableFrame)
            btn.model:SetSize(modelH, modelH)
            btn.model:SetFacing(0.3)
            if i==1 then
                btn.model:SetPoint('TOPRIGHT', PetStableLeftInset, 'TOPLEFT', -16,-28)
            else
                btn.model:SetPoint('TOP', _G['PetStableActivePet'..i-1].model, 'BOTTOM')
            end

            local bg=btn.model:CreateTexture('BACKGROUND')
            bg:SetPoint('LEFT')
            bg:SetSize(modelH+14, modelH)
            bg:SetAtlas('ShipMission_RewardsBG-Desaturate')
            bg:SetAlpha(0.3)
            bg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

            btn:HookScript('OnEnter', HookEnter_Button)--GameTooltip 提示用 tooltips.lua
            btn:ClearAllPoints()
            btn:SetPoint('LEFT', btn.model, 'RIGHT', 43,0)

            local spellTexture= btn:CreateTexture()
            spellTexture:SetSize(25,25)
            spellTexture:SetPoint('RIGHT', btn, 'LEFT', -2,0)
            spellTexture:SetAtlas('services-number-'..i)
            spellTexture:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
            spellTexture:SetAlpha(0.3)
            if CALL_PET_SPELL_IDS[i] then--召唤，宠物，法术
                spellTexture.spellID= CALL_PET_SPELL_IDS[i]
                spellTexture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
                spellTexture:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetSpellByID(self.spellID)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                    self:SetAlpha(1)
                end)
            end
            local label= _G['PetStableActivePet'..i..'PetName']
            if label then
                label:ClearAllPoints()
                label:SetPoint('BOTTOM', _G['PetStableActivePet'..i..'Border'] or btn,0,-10)
                label:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
                label:SetShadowOffset(1, -1)
                label:SetJustifyH('LEFT')
                label:SetScale(0.85)
            end
        end
    end

    hooksecurefunc('PetStable_UpdateSlot', set_PetStable_UpdateSlot)--宠物，类型，已激MODEL


    PetStableFrameTitleText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)--标题

    PetStableActiveBg:ClearAllPoints()--已激活宠物，背景，大小
    PetStableActiveBg:SetAllPoints(PetStableLeftInset)
    PetStableActiveBg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    PetStableActivePetsLabel:SetTextColor(e.Player.r, e.Player.g, e.Player.b)


    PetStableFrameInset.NineSlice:ClearAllPoints()--标示，背景
    PetStableFrameInset.NineSlice:SetPoint('TOPLEFT')
    PetStableFrameInset.NineSlice:SetPoint('BOTTOMRIGHT', PetStableFrame, -4, 4)



    PetStableModelScene:ClearAllPoints()--设置，3D，位置
    PetStableModelScene:SetPoint('BOTTOMLEFT', PetStableFrame, 'BOTTOMRIGHT',0,4)
    PetStableModelScene:SetSize(h-24, h-24)

    PetStableFrameModelBg:ClearAllPoints()--3D，背景
    PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
    PetStableFrameModelBg:SetAlpha(0.3)
    PetStableFrameInset.Bg:Hide()
    PetStableFrameModelBg:SetAtlas('ShipMission_RewardsBG-Desaturate')
    PetStableFrameModelBg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    PetStablePetInfo:ClearAllPoints()--宠物，信息
    PetStablePetInfo:SetPoint('BOTTOMLEFT', PetStableModelScene, 0, 4)

    PetStableDiet:ClearAllPoints()--食物，提示
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

    PetStableTypeText:ClearAllPoints()--选定，宠物，类型
    PetStableTypeText:SetPoint('TOPLEFT', PetStableSelectedPetIcon, 'RIGHT',0, -2)
    PetStableTypeText:SetJustifyH('LEFT')
    PetStableTypeText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    PetStableTypeText:SetShadowOffset(1, -1)


    e.call('PetStable_Update')
    --[[if e.Player.husandro then
        local sortButton= e.Cbtn(ISF_SearchInput, {atlas='bags-button-autosort-up', size={22,22}})
        sortButton:SetPoint('BOTTOMRIGHT', ISF_SearchInput, 'TOPRIGHT')
        sortButton:SetScript('OnClick', function()
            IsInSearch=true
            PetStable_Update= function() end
            local type={
                ['狂野']=1,
                
                ['坚韧']=3,
            }
            local tab= {}
            for i=NUM_PET_ACTIVE_SLOTS+1, maxSlots+NUM_PET_ACTIVE_SLOTS do
                local icon, name, _, family, talent = GetStablePetInfo(i)
            
                table.insert(tab, {icon=icon or 0, name=name, family= family, talen=type[talent] or 0, index=i})
            end
            table.sort(tab, function(a, b)
                if a.talen< b.talent then
                    SetPetSlot(a.index, b.index)
                    return true
                end
                return false
            end)
            PetStable_Update= func_PetStable_Update
            IsInSearch=nil
            e.call('PetStable_Update')
            print('完成')
        end)
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
btn.model:ClearScene()
]]
