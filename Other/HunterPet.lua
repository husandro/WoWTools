local id, e= ...
if e.Player.class~='HUNTER' then --or C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
    return
end

--PetStableFrame, C_AddOns.IsAddOnLoaded("ImprovedStableFrame")
--PetStable.lua

local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  UnitClass('player'), DUNGEON_FLOOR_ORGRIMMARRAID8) --猎人兽栏
local Save={
    --hideIndex=true,--隐藏索引
    --hideTalent=true,--隐藏天赋
    modelScale=0.65,
    sortIndex=4,--1, 2,3,4,5 icon, name, level, family, talent排序
    --line=15,
}
local ISF_SearchInput--查询
local maxSlots
local NUM_PER_ROW= 15--行数
local IsInSearch--排序用
local function Get_Food_Text(slotPet)
    return BuildListString(GetStablePetFoodTypes(slotPet))
end
local function Set_Food_Lable()--食物
    PetStablePetInfo.foodLable:SetText(Get_Food_Text(PetStableFrame.selectedPet) or '')
end
local function set_PetStable_Update()--查询
    if IsInSearch then
        return
    end
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
        if btn and btn.dimOverlay then
            local show= isSearch
            if icon then
                if isSearch then
                    local food = BuildListString(GetStablePetFoodTypes(i)) or ''
                    local matched, expected = 0, 0
                    for str in input:gmatch("([^%s]+)") do
                        expected = expected + 1
                        str = str:trim():lower()
                        if name:lower():find(str)
                            or family:lower():find(str)
                            or talent:lower():find(str)
                            or food:lower():find(str)
                           -- or level:lower():find(str)
                        then
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
    end
    ISF_SearchInput.text:SetFormattedText(isSearch and (e.onlyChinese and '搜索' or SEARCH)..' |cnGREEN_FONT_COLOR:%d|r /%d' or (e.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN), num, all)
end

























local function Set_Slot_Info(btn, index, isActiveSlot)--创建，提示内容
    if not isActiveSlot then
        function btn:set_slot_index()
            if not Save.hideIndex and not self.slotIndexText then
                self.slotIndexText= e.Cstr(self, {layer='BACKGROUND', color={r=1,g=1,b=1,a=0.2}})--栏位
                self.slotIndexText:SetPoint('CENTER')
            end
            if self.slotIndexText then
                self.slotIndexText:SetText(not Save.hideIndex and index or '')
            end
        end
        btn:set_slot_index()
    else
        local CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245}--召唤，宠物，法术
        btn.spellTexture= btn:CreateTexture()
        btn.spellTexture:SetSize(28,28)
        btn.spellTexture:SetPoint('RIGHT', btn, 'LEFT', -2,0)
        btn.spellTexture:SetAtlas('services-number-'..index)
        e.Set_Label_Texture_Color(btn.spellTexture, {type='Texture', alpha=0.3})
        if CALL_PET_SPELL_IDS[index] then--召唤，宠物，法术
            btn.spellTexture.spellID= CALL_PET_SPELL_IDS[index]
            btn.spellTexture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
            btn.spellTexture:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self.spellID)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
                self:SetAlpha(1)
            end)
        end
        btn.spellTexture:SetShown(not Save.hideIndex)
        function btn:set_slot_index()
            self.spellTexture:SetShown(not Save.hideIndex)
        end

         --已激活宠物，提示
         local modelH= (PetStableLeftInset:GetHeight()-28)/NUM_PET_ACTIVE_SLOTS
         btn.model= CreateFrame("PlayerModel", nil, PetStableFrame)
         btn.model:SetSize(modelH, modelH)
         btn.model:SetFacing(0.3)
         if index==1 then
             btn.model:SetPoint('TOPRIGHT', PetStableLeftInset, 'TOPLEFT', -16,-28)
         else
             btn.model:SetPoint('TOP', _G['PetStableActivePet'..index-1].model, 'BOTTOM')
         end

         local bg=btn.model:CreateTexture('BACKGROUND')
         bg:SetPoint('LEFT')
         bg:SetSize(modelH+14, modelH)
         bg:SetAtlas('ShipMission_RewardsBG-Desaturate')
         e.Set_Label_Texture_Color(bg, {type='Texture', alpha=0.3})
         function btn:set_model_info(petSlot)
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

         btn:ClearAllPoints()
         btn:SetPoint('LEFT', btn.model, 'RIGHT', 43,0)

         if btn.PetName then
            btn.PetName:ClearAllPoints()
            btn.PetName:SetPoint('BOTTOM', btn.Border, 0,-10)
            e.Set_Label_Texture_Color(btn.PetName, {type='FontString'})
            btn.PetName:SetShadowOffset(1, -1)
            btn.PetName:SetJustifyH('LEFT')
            btn.PetName:SetScale(0.85)
         end
    end

    btn:HookScript('OnEnter', function(self)--GameTooltip 提示用 tooltips.lua
        local petIcon, _, petLevel= GetStablePetInfo(self.petSlot)
        if petIcon then
            local food= Get_Food_Text(self.petSlot)
            if food then
                e.tips:AddLine(format(e.onlyChinese and '|cffffd200食物：|r%s' or PET_DIET_TEMPLATE, food, 1, 1, 1, true))
            end
            if petLevel then
                e.tips:AddDoubleLine((e.onlyChinese and '等级' or LEVEL)..': '..petLevel, petIcon and '|T'..petIcon..':0|t'..petIcon)
            end
            e.tips:AddDoubleLine('petSlot:', self.petSlot)
            local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(self.petSlot);
            if creatureDisplayID and creatureDisplayID>0 and e.tips.playerModel then
                e.tips.playerModel:SetDisplayInfo(creatureDisplayID)
                e.tips.playerModel:SetShown(true)
            end
            e.tips:AddDoubleLine('creatureDisplayID:', creatureDisplayID)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, e.cn(addName))
            e.tips:Show()
        end
    end)

    function btn:set_settings()
        if not Save.hideTalent then
            if not self.talentText then
                self.talentText= e.Cstr(btn, {layer='ARTWORK', color=true})--天赋
                self.talentText:SetPoint('BOTTOM')
            end
            local talent= self.petSlot and select(5, GetStablePetInfo(self.petSlot))
            self.talentText:SetText(talent and e.WA_Utf8Sub(talent, 2, 5, true) or '')
        elseif self.talentText then
            self.talentText:SetText('')
        end
        if self.model then--已激活宠物，提示
            local creatureDisplayID = C_PlayerInfo.GetPetStableCreatureDisplayInfoID(self.petSlot);
            if creatureDisplayID and creatureDisplayID>0 then
                if creatureDisplayID~=self.creatureDisplayID then
                    self.model:SetDisplayInfo(creatureDisplayID)
                end
            else
                self.model:ClearModel()
            end
            self.creatureDisplayID= creatureDisplayID--提示用，
        end
    end

    btn.dimOverlay = btn.dimOverlay or btn:CreateTexture(nil, "OVERLAY");--查询提示用
    btn.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
    btn.dimOverlay:SetAllPoints();
    btn.dimOverlay:Hide();


    if btn.Checked then
        local w,h= btn:GetSize()
        btn.Checked:ClearAllPoints()
        btn.Checked:SetPoint('CENTER')
        btn.Checked:SetSize(w+10, h+10)
        btn.Checked:SetVertexColor(0,1,0)
    end

    btn:RegisterForDrag('LeftButton', "RightButton")
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
end

local function Init()
    maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS

    local w, h= 720, 620--get_Frame_Size()--720, 630

    NUM_PET_STABLE_SLOTS = maxSlots
    NUM_PET_STABLE_PAGES = 1
    PetStableFrame.page = 1
    PetStableFrame:SetSize(w, h)--设置，大小

    PetStableNextPageButton:Hide()--隐藏
    PetStablePrevPageButton:Hide()
    PetStableBottomInset:Hide()

    PetStableStabledPet1:ClearAllPoints()--设置，200个按钮，第一个位置
    PetStableStabledPet1:SetPoint("TOPLEFT", PetStableFrame, 97, -37)

    local layer= PetStableFrame:GetFrameLevel()+ 1
    for i = 1, maxSlots do
        local btn= _G["PetStableStabledPet"..i] or CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
        btn.petSlot= btn.petSlot or (NUM_PET_ACTIVE_SLOTS+i)
        btn:SetFrameLevel(layer)
        Set_Slot_Info(btn, i, nil)--创建，提示内容

        --处理，按钮，背景 Texture.lua，中有处理过
        e.Set_Label_Texture_Color(btn.Background, {type='Texture', alpha=0.5})--设置颜色

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
    for i= 1, NUM_PET_ACTIVE_SLOTS do
        local btn= _G['PetStableActivePet'..i]
        if btn then
            btn.petSlot= btn.petSlot or i
            Set_Slot_Info(btn, i, true)--创建，提示内容
        end
    end

    --查询
    ISF_SearchInput = _G['ISF_SearchInput'] or CreateFrame("EditBox", nil, PetStableStabledPet1, "SearchBoxTemplate")
    ISF_SearchInput.Middle:SetAlpha(0.5)
    ISF_SearchInput.Right:SetAlpha(0.5)
    ISF_SearchInput.Left:SetAlpha(0.5)
    ISF_SearchInput:SetSize(200,20)
    if  _G['ISF_SearchInput'] then ISF_SearchInput:ClearAllPoints() end--处理插件，Improved Stable Frame
    ISF_SearchInput:SetPoint('BOTTOMRIGHT',PetStableFrame, -6, 10)
    ISF_SearchInput:SetScale(1.2)
    ISF_SearchInput.Instructions:SetText(e.onlyChinese and '名称,类型,天赋,食物' or (NAME .. "," .. TYPE .. "," .. TALENT..','..POWER_TYPE_FOOD))
    ISF_SearchInput:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    ISF_SearchInput:HookScript("OnTextChanged", set_PetStable_Update)
    hooksecurefunc("PetStable_Update", set_PetStable_Update)
    ISF_SearchInput.text= e.Cstr(ISF_SearchInput, {color=true, alpha=0.5})
    ISF_SearchInput.text:SetPoint('BOTTOM', ISF_SearchInput, 'TOP')






    hooksecurefunc('PetStable_UpdateSlot', function(btn, petSlot)--宠物，类型，已激MODEL
        if btn.set_settings then
            btn:set_settings()
        end
    end)


    e.Set_Label_Texture_Color(PetStableFrameTitleText, {type='FontString'})--标题, 颜色

    PetStableActiveBg:ClearAllPoints()--已激活宠物，背景，大小
    PetStableActiveBg:SetAllPoints(PetStableLeftInset)
    e.Set_Label_Texture_Color(PetStableActivePetsLabel, {type='FontString'})


    PetStableFrameInset.NineSlice:ClearAllPoints()--标示，背景
    PetStableFrameInset.NineSlice:SetPoint('TOPLEFT')
    PetStableFrameInset.NineSlice:SetPoint('BOTTOMRIGHT', PetStableFrame, -4, 4)
    PetStableFrameInset.Bg:ClearAllPoints()
    PetStableFrameInset.Bg:SetPoint('TOPLEFT')
    PetStableFrameInset.Bg:SetPoint('BOTTOMRIGHT', PetStableFrame, -4, 4)


    PetStableModelScene:ClearAllPoints()--设置，3D，位置
    PetStableModelScene:SetPoint('LEFT', PetStableFrame, 'RIGHT',0, -12)
    PetStableModelScene:SetSize(h-24, h-24)

    PetStableModelScene.zoomModelButton= e.Cbtn(PetStableFrameCloseButton, {size={22,22}, icon=true})--atlas='UI-HUD-Minimap-Zoom-In'})
    PetStableModelScene.zoomModelButton:SetPoint('RIGHT', PetStableFrameCloseButton, 'LEFT', -2,0)
    PetStableModelScene.zoomModelButton:SetAlpha(0.5)
    function PetStableModelScene.zoomModelButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '天赋' or TALENT)..': '..e.GetShowHide(not Save.hideTalent),  e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '索引' or 'Index')..': '..e.GetShowHide(not Save.hideIndex),  e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '模型缩放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MODEL, UI_SCALE))..' |cnGREEN_FONT_COLOR:'..Save.modelScale, e.Icon.mid)
        e.tips:Show()
    end
    function PetStableModelScene.zoomModelButton:set_Scale()
        PetStableModelScene:SetScale(Save.modelScale or 1)
    end
    function PetStableModelScene.zoomModelButton:set_Value_Scale(add)
        local n= Save.modelScale or 1
        n= add and n+0.05 or (n-0.05)
        n= n<0.1 and 0.1 or n
        n= n>2 and 2 or n
        Save.modelScale=n
        self:set_Scale()
        self:set_Tooltips()
    end
    PetStableModelScene.zoomModelButton:SetScript('OnMouseWheel', function(self, d)
        self:set_Value_Scale(d==-1)
    end)
    PetStableModelScene.zoomModelButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then--显示/隐藏 天赋
            Save.hideTalent= not Save.hideTalent and true or nil
            for i= 1, maxSlots do
                local btn= _G['PetStableStabledPet'..i]
                if btn then
                    btn:set_settings()
                end
            end
            for i=1, NUM_PET_ACTIVE_SLOTS do
                local btn= _G['PetStableActivePet'..i]
                if btn then
                    btn:set_settings()
                end
            end
        elseif d=='RightButton' then--显示/隐藏 索引
            Save.hideIndex= not Save.hideIndex and true or nil
            for i= 1, maxSlots do
                local btn= _G['PetStableStabledPet'..i]
                if btn then
                    btn:set_slot_index()
                end
            end
            for i=1, NUM_PET_ACTIVE_SLOTS do
                local btn= _G['PetStableActivePet'..i]
                if btn then
                    btn:set_slot_index()
                end
            end
        end
        self:set_Tooltips()
    end)
    PetStableModelScene.zoomModelButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) e.tips:Hide() end)
    PetStableModelScene.zoomModelButton:SetScript('OnEnter', function(self)
        self:set_Tooltips()
        self:SetAlpha(1)
    end)
    PetStableModelScene.zoomModelButton:set_Scale()


    PetStableFrameModelBg:ClearAllPoints()--3D，背景
    PetStableFrameModelBg:SetAllPoints(PetStableModelScene)
    PetStableFrameModelBg:SetAtlas('ShipMission_RewardsBG-Desaturate')
    PetStableFrameModelBg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    PetStablePetInfo:ClearAllPoints()--宠物，信息
    PetStablePetInfo:SetPoint('BOTTOMLEFT', PetStableFrame, 'BOTTOMRIGHT',0, 4)

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
    PetStableNameText:SetPoint('TOPLEFT', PetStableSelectedPetIcon, 'RIGHT',0, -2)
    e.Set_Label_Texture_Color(PetStableNameText, {type='FontString'})--选定，宠物，名称

    PetStableTypeText:ClearAllPoints()--选定，宠物，类型
    PetStableTypeText:SetPoint('BOTTOMLEFT', PetStableSelectedPetIcon, 'RIGHT', 0,2)
    PetStableTypeText:SetJustifyH('LEFT')
    e.Set_Label_Texture_Color(PetStableTypeText, {type='FontString'})
    PetStableTypeText:SetShadowOffset(1, -1)




    local sortButton= e.Cbtn(ISF_SearchInput, {atlas='bags-button-autosort-up', size={26,26}})
    sortButton:SetPoint('RIGHT', ISF_SearchInput, 'LEFT', -6, 0)
    sortButton:SetAlpha(0.7)
    sortButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:SetAlpha(0.7)
    end)
    sortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(
            e.onlyChinese and '排序图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY, EMBLEM_SYMBOL),
            e.onlyChinese and '整理！' or POSTMASTER_BEGIN
        )
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            e.Icon.toRight2..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_UP)..e.Icon.left,
            e.Icon.right..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_UP)..e.Icon.toLeft2)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        self:SetAlpha(1)
    end)

    sortButton:SetScript('OnClick', function(self, d)
        self:SetEnabled(false)
        IsInSearch=true
        local func= PetStable_Update--排序用
        PetStable_Update= function() end
do
        local tab= {}
        for i= NUM_PET_ACTIVE_SLOTS+ 1, maxSlots+ NUM_PET_ACTIVE_SLOTS do
            local icon, name, level, family, talent = GetStablePetInfo(i)
            if icon then
                table.insert(tab, {
                    index= i,
                    icon= icon,
                    name= (string.byte(name, 1) or 0)+ (string.byte(name, 2) or 0)+ (string.byte(name, 3) or 0)+ (string.byte(name, 4) or 0),
                    level= level or 0,
                    family= (string.byte(family, 1) or 0)+ (string.byte(family, 2) or 0)+ (string.byte(family, 3) or 0)+ (string.byte(family, 4) or 0),
                    talen= (string.byte(talent, 1) or 0)+ (string.byte(talent, 2) or 0)+ (string.byte(talent, 3) or 0)+ (string.byte(talent, 4) or 0),
                })

            end
        end
        local str= Save.sortIndex==1 and 'icon'
                or Save.sortIndex==2 and 'name'
                or Save.sortIndex==3 and 'level'
                or Save.sortIndex==4 and 'family'
                or Save.sortIndex==5 and 'talen'

            table.sort(tab, function(a, b)
                return a[str] < b[str]
            end)


        if d=='LeftButton' then--点击，从前，向后
            for i, newTab in pairs(tab) do
                do
                    local index= i+ NUM_PET_ACTIVE_SLOTS
                    SetPetSlot(newTab.index, index)
                end
            end
        else
            local all= maxSlots+ NUM_PET_ACTIVE_SLOTS
            for i, newTab in pairs(tab) do
                do
                    local index= all-i+1
                    SetPetSlot(newTab.index, index)
                end
            end
        end
end
        PetStable_Update= func
        self.num= self.num and self.num+1 or 1
        print(id, e.cn(addName), e.onlyChinese and '完成' or DONE, '|cnGREEN_FONT_COLOR:'..self.num)
        IsInSearch=nil
        e.call('PetStable_Update')
        self:SetEnabled(true)
    end)


    local menu= CreateFrame('Frame', 'SortHunterPetDropDownMenu', sortButton, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_SetWidth(menu, 90)
    menu:SetPoint('RIGHT', sortButton, 'LEFT', 15, -2)
    function menu:get_text(index)
        return index==1 and (e.onlyChinese and '图标' or EMBLEM_SYMBOL)--'icon'
                or index==2 and (e.onlyChinese and '名称' or NAME)--'name'
                or index==3 and (e.onlyChinese and '等级' or LEVEL)--'level'
                or index==4 and (e.onlyChinese and '类型' or TYPE)--'family'
                or index==5 and (e.onlyChinese and '天赋' or TALENT)--'talen'
    end
    e.LibDD:UIDropDownMenu_SetText(menu,  menu:get_text(Save.sortIndex))
    e.LibDD:UIDropDownMenu_Initialize(menu, function(self, level)
        for i=1, 5 do
            local info={
                text=self:get_text(i),
                checked= Save.sortIndex==i,
                arg1=i,
                func=function(_, arg1)
                    Save.sortIndex= arg1
                    e.LibDD:UIDropDownMenu_SetText(self,  self:get_text(Save.sortIndex))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)
   menu.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    for _, icon in pairs({menu:GetRegions()}) do
        if icon:GetObjectType()=="Texture" then
            icon:SetAlpha(0.5)
        end
    end
    for _, icon in pairs({menu.Button:GetRegions()}) do
        if icon:GetObjectType()=="Texture" then
            icon:SetAlpha(0.5)
        end
    end

    e.Set_Label_Texture_Color(menu.Text, {type='FontString', alpha=0.5})
    e.call('PetStable_Update')
end















































--取得，宠物，技能，图标
local function get_abilities_icons(pet)
    local icon=''
    for _, spellID in pairs(pet and pet.abilities or {}) do
        e.LoadDate({id=spellID, type='spell'})
        icon= icon..format('|T%d:14|t', GetSpellTexture(spellID) or 0)
    end
    return icon
end

--宠物，信息，提示
local function set_pet_tooltips(frame, pet, y)
    if not pet or not frame then
        return
    end
    e.tips:SetOwner(frame, "ANCHOR_LEFT", y or 0, 0)
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName))
    e.tips:AddLine(' ')
    local i=1
    for indexType, name in pairs(pet) do
        local col= indexType=='slotID' and '|cffff00ff'
                or (indexType=='name' and '|cnGREEN_FONT_COLOR:')
                or (select(2, math.modf(i/2))==0 and '|cffffffff')
                or '|cff00ccff'
        if type(name)=='table' then
            if indexType=='abilities' then
                e.tips:AddDoubleLine(col..indexType, get_abilities_icons(pet))
            end
        else
            name= indexType=='icon' and format('|T%d:14|t%d', name, name)
                or (name==false and 'false')
                or (name==true and 'true')
                or (name==nil and '')
                or name
            e.tips:AddDoubleLine(col..indexType, col..name)
        end
        i=i+1
    end
end


local function set_model(self)--StableActivePetButtonTemplateMixin
    local data= self.petData or {}--宠物，类型，图标
    if data.displayID and data.displayID>0 then
        if data.displayID~=self.displayID then
            self.model:SetDisplayInfo(data.displayID)
        end
    else
        self.model:ClearModel()
    end
    self.displayID= data.displayID--提示用，
end


--已激活宠物，Model 提示
local function created_model(btn)
    local w= btn:GetWidth()+40
    btn.model= CreateFrame("PlayerModel", nil, btn)
    btn.model:SetSize(w, w)
    btn.model:SetFacing(0.3)
    --[[
    local bg=btn.model:CreateTexture('BACKGROUND')
    bg:SetAllPoints(btn.model)
    bg:SetAtlas('ShipMission_RewardsBG-Desaturate')
    e.Set_Label_Texture_Color(bg, {type='Texture', alpha=0.3})
    ]]
end

--召唤，法术，提示
local CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245, }

e.LoadDate({id=267116, type='spell'})--动物伙伴









--猎人，兽栏 Plus 10.2.7 Blizzard_StableUI.lua
local function Init_StableFrame_Plus()

     --开关
     StableFrame.WoWToolsButton= e.Cbtn(StableFrame.TitleContainer, {size={20,20}, icon= not Save.disabled})
     StableFrame.WoWToolsButton:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)
     StableFrame.WoWToolsButton:SetAlpha(0.5)
     StableFrame.WoWToolsButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip_Hide() end)
     function StableFrame.WoWToolsButton:set_tooltips()
         e.tips:SetOwner(self, "ANCHOR_LEFT")
         e.tips:ClearLines()
         e.tips:AddDoubleLine(id, '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName))
         e.tips:AddLine(' ')
         e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabled_Hunter_Plus), e.Icon.left)
         e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
         e.tips:Show()
         self:SetAlpha(1)
     end
     StableFrame.WoWToolsButton:SetScript('OnEnter', StableFrame.WoWToolsButton.set_tooltips)
     StableFrame.WoWToolsButton:SetScript('OnClick', function(self, d)
         if d=='LeftButton' then
             Save.disabled= not Save.disabled and true or nil
             print(id, '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
             self:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
             self:set_tooltips()
         else
             e.OpenPanelOpting('|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName))
         end
     end)



    --宠物，列表，提示
    hooksecurefunc(StableStabledPetButtonTemplateMixin, 'SetPet', function(btn)
        if not btn.set_settings then
            btn:HookScript('OnEnter', function(self)--信息，提示
                set_pet_tooltips(self, self.petData, -10)
                e.tips:Show()
            end)
            btn.Portrait2= btn:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
            btn.Portrait2:SetSize(20, 20)
            btn.Portrait2:SetPoint('RIGHT', btn.Portrait,'LEFT')
            btn.Portrait2:SetAlpha(0.5)
            btn.abilitiesText= e.Cstr(btn)--宠物，技能，提示
            btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.Background, -9, 8)
            btn.indexText= e.Cstr(btn)--, {color={r=1,g=0,b=1}})--SlotID
            btn.indexText:SetPoint('TOPRIGHT', -9,-6)
            btn.indexText:SetAlpha(0.5)
            function btn:set_settings()
                self.abilitiesText:SetText(get_abilities_icons(self.petData))--宠物，技能，提示
                local data= self.petData or {}--宠物，类型，图标
                self.Portrait2:SetTexture(data.icon or 0)
                self.indexText:SetText(data.slotID or '')

            end
        end
        btn:set_settings()
    end)













    --已激，宠物栏，提示
    for i, btn in ipairs(StableFrame.ActivePetList.PetButtons) do
        btn.index=btn:GetID()

        btn.callSpellButton= e.Cbtn(btn, {size={18,18},icon='hide'})--召唤，法术，提示
        btn.callSpellButton.Texture=btn.callSpellButton:CreateTexture(nil, 'OVERLAY')
        btn.callSpellButton.Texture:SetAllPoints(btn.callSpellButton)
        SetPortraitToTexture(btn.callSpellButton.Texture, 132161)
        btn.callSpellButton:SetPoint('BOTTOMLEFT', -8, -16)
        btn.callSpellButton.spellID=CALL_PET_SPELL_IDS[btn.index]
        btn.callSpellButton:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
        btn.callSpellButton:SetScript('OnEnter', function(self)
            if not self.spellID then return end
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.spellID, true, true);
            GameTooltip:Show();
            self:SetAlpha(1)
        end)
        btn.callSpellButton:SetAlpha(0.5)

        btn:HookScript('OnEnter', function(self)--信息，提示
            set_pet_tooltips(self, self.petData, -10)
            if not self.petData then return end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.Icon.right)
            e.tips:Show()
        end)

        btn.Portrait2= btn.callSpellButton:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
        btn.Portrait2:SetSize(18, 18)

        btn.Portrait2:SetPoint('LEFT', btn.callSpellButton, 'RIGHT')
        btn.abilitiesText= e.Cstr(btn, {SetJustifyH='RIGHT'})--宠物，技能，提示
        btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.callSpellButton, 'BOTTOMLEFT', 2, -4)

        btn.indexText=e.Cstr(btn.callSpellButton)--索引
        btn.indexText:SetPoint('LEFT', btn.Portrait2, 'RIGHT', 4,0)
        btn.indexText:SetText(i)


        created_model(btn)--已激活宠物，Model 提示
        btn.model:SetPoint('TOP', btn, 'BOTTOM', 0, -14)

        hooksecurefunc(btn, 'SetPet', function(self)--StableActivePetButtonTemplateMixin
            local icon= get_abilities_icons(self.petData)
            icon= icon:gsub('|T.-|t', function(a) return a..'|n' end)

            self.abilitiesText:SetText(icon)--宠物，技能，提示

            local data= self.petData or {}--宠物，类型，图标
            self.Portrait2:SetTexture(data.icon or 0)

            set_model(self)
        end)
    end




    local btn= StableFrame.ActivePetList.BeastMasterSecondaryPetButton
    created_model(btn)--已激活宠物，Model 提示
    hooksecurefunc(btn, 'SetPet', set_model)
    btn.model:SetFacing(-0.3)
    btn.model:SetPoint('RIGHT', btn, 'LEFT')



    --第二个，宠物，提示
    btn:HookScript('OnEnter', function(self)
        if not self.petData or not self:IsEnabled() then
            return
        end
        set_pet_tooltips(self, self.petData, 0)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            format('|A:UI-HUD-MicroMenu-SpecTalents-Mouseover:0:0|a|cffaad372%s|r', e.onlyChinese and '天赋' or TALENT),
            format('|T461112:0|t|cffaad372%s|r', e.onlyChinese and '动物伙伴' or GetSpellLink(267116) or GetSpellInfo(267116) or 'Animal Companion')
        )
        e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.Icon.right)
        e.tips:Show()
    end)

    local frame= CreateFrame('Frame', nil, btn, 'StablePetAbilityTemplate')--StablePetAbilityMixin
    frame:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT', 10,-6)
    frame:Initialize(267116)--动物伙伴
    frame.Icon:ClearAllPoints()
    frame.Icon:SetPoint('RIGHT')
    frame.Name:ClearAllPoints()
    frame.Name:SetPoint('RIGHT', frame.Icon, 'LEFT')


















    --移动，缩放
    e.Set_Move_Frame(StableFrame, {needSize=true, needMove=true, setSize=true, minW=860, minH=440, initFunc=function()
            StableFrame.PetModelScene:ClearAllPoints()
            StableFrame.PetModelScene:SetPoint('TOPLEFT', StableFrame.Topper, 'BOTTOMLEFT', 330, 0)
            StableFrame.PetModelScene:SetPoint('BOTTOMRIGHT', -2, 92)
            StableFrame.ActivePetList:ClearAllPoints()
            StableFrame.ActivePetList:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -45)
            StableFrame.ActivePetList:SetPoint('TOPRIGHT', StableFrame.PetModelScene, 'BOTTOMRIGHT', 0, -45)
            e.Set_Move_Frame(StableFrame.StabledPetList.ScrollBox, {frame=StableFrame})
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(1040, 638)
    end})

    StableFrame.ReleasePetButton:ClearAllPoints()
    StableFrame.ReleasePetButton:SetPoint('BOTTOMLEFT', StableFrame.PetModelScene, 'TOPLEFT', 0,20)
    StableFrame.ReleasePetButton:SetAlpha(0.5)
    StableFrame.ReleasePetButton:HookScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    StableFrame.ReleasePetButton:HookScript('OnEnter', function(self) self:SetAlpha(1) end)

    StableFrame.StableTogglePetButton:ClearAllPoints()
    StableFrame.StableTogglePetButton:SetPoint('BOTTOMRIGHT', StableFrame.PetModelScene)

    StableFrame.PetModelScene.AbilitiesList:ClearAllPoints()
    StableFrame.PetModelScene.AbilitiesList:SetPoint('LEFT', 8, -40)


    StableFrame.PetModelScene.PetInfo.Specialization:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Specialization:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Type, 'BOTTOMRIGHT', 0, -2)

    StableFrame.PetModelScene.PetInfo.Exotic:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Exotic:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Specialization, 'BOTTOMRIGHT', 0, -2)

    StableFrame.ActivePetList.ActivePetListBG:ClearAllPoints()
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -2)
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('BOTTOMRIGHT', StableFrame)
    StableFrame.PetModelScene.ControlFrame:ClearAllPoints()
    StableFrame.PetModelScene.ControlFrame:SetPoint('TOP')

    StableFrame.PetModelScene.PetShadow:ClearAllPoints()
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMLEFT')
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMRIGHT')

    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:ClearAllPoints()
    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:SetPoint('RIGHT',  StableFrame.PetModelScene, -16 ,0)
    StableFrame.ActivePetList.Divider:ClearAllPoints()
    StableFrame.ActivePetList.Divider:Hide()

    local x= 40
    StableFrame.ActivePetList.PetButton3:ClearAllPoints()
    StableFrame.ActivePetList.PetButton3:SetPoint('CENTER')

    StableFrame.ActivePetList.PetButton2:ClearAllPoints()
    StableFrame.ActivePetList.PetButton2:SetPoint('RIGHT', StableFrame.ActivePetList.PetButton3, 'LEFT', -x, 0)

    StableFrame.ActivePetList.PetButton1:ClearAllPoints()
    StableFrame.ActivePetList.PetButton1:SetPoint('RIGHT', StableFrame.ActivePetList.PetButton2, 'LEFT', -x, 0)

    StableFrame.ActivePetList.PetButton4:ClearAllPoints()
    StableFrame.ActivePetList.PetButton4:SetPoint('LEFT', StableFrame.ActivePetList.PetButton3, 'RIGHT', x, 0)

    StableFrame.ActivePetList.PetButton5:ClearAllPoints()
    StableFrame.ActivePetList.PetButton5:SetPoint('LEFT', StableFrame.ActivePetList.PetButton4, 'RIGHT', x, 0)

    StableFrame.ActivePetList.ListName:ClearAllPoints()
    StableFrame.ActivePetList.ListName:SetPoint('BOTTOMLEFT', StableFrame.ActivePetList.ActivePetListBG, 'TOPLEFT',0,-6)

end






function Init_StableFrame_List()
    local frame= CreateFrame('Frame', nil, StableFrame)
    frame:SetPoint('TOPLEFT', StableFrame, 'TOPRIGHT')
    frame.Buttons={}
    local last
    for i=Constants.PetConsts.STABLED_PETS_FIRST_SLOT_INDEX+ 1, Constants.PetConsts.NUM_PET_SLOTS do
        local btn= CreateFrame('Button', nil, frame, 'StableActivePetButtonTemplate', i)
        btn:SetSize(30,30)
        if not last then
            btn:SetPoint('TOPLEFT')
        else
            btn:SetPoint('TOP', last, 'BOTTOM')
        end
        last= btn
    end
end


























local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.sortIndex= Save.sortIndex or 4

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or addName),
                tooltip= nil,
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save.disabled  then-- or C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
                panel:UnregisterAllEvents()
            else

                if StableFrame then--10.2.7
                    Init_StableFrame_Plus()
                    Init_StableFrame_List()
                else
                    panel:RegisterEvent('PET_STABLE_SHOW')
                    if C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
                        print(id, e.cn(addName),
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


















--[[猎人，兽栏 Plus 10.2.7 Blizzard_StableUI.lua
local function Init_StableFrame_Plus()
    if e.Player.class~='HUNTER' or not StableFrame then--10.2.7
        return
    else
        --开关
        StableFrame.WoWToolsButton= e.Cbtn(StableFrame.TitleContainer, {size={20,20}, icon= not Save.disabled_Hunter_Plus})
        StableFrame.WoWToolsButton:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)
        StableFrame.WoWToolsButton:SetAlpha(0.3)
        StableFrame.WoWToolsButton:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
        function StableFrame.WoWToolsButton:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Category:GetName())
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.disabled_Hunter_Plus), e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        StableFrame.WoWToolsButton:SetScript('OnEnter', StableFrame.WoWToolsButton.set_tooltips)
        StableFrame.WoWToolsButton:SetScript('OnClick', function(self, d)
            if d=='LeftButton' then
                Save.disabled_Hunter_Plus= not Save.disabled_Hunter_Plus and true or nil
                print(id, Category:GetName(), e.GetEnabeleDisable(not Save.disabled_Hunter_Plus), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                self:SetNormalAtlas(Save.disabled_Hunter_Plus and e.Icon.disabled or e.Icon.icon)
                self:set_tooltips()
            else
                e.OpenPanelOpting(nil, Category)
            end
        end)
        if Save.disabled_Hunter_Plus then
            return
        end
    end

   

    --取得，宠物，技能，图标
    function StableFrame.WoWToolsButton:get_abilities_icons(pet)
        local icon=''
        for _, spellID in pairs(pet and pet.abilities or {}) do
            e.LoadDate({id=spellID, type='spell'})
            icon= icon..format('|T%d:14|t', GetSpellTexture(spellID) or 0)
        end
        return icon
    end

    --宠物，信息，提示
    function StableFrame.WoWToolsButton:set_pet_tooltips(frame, pet, y)
        if not pet or not frame then
            return
        end
        e.tips:SetOwner(frame, "ANCHOR_LEFT", y or 0, 0)
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Category:GetName())
        e.tips:AddLine(' ')
        local i=1
        for indexType, name in pairs(pet) do
            local col= indexType=='slotID' and '|cffff00ff'
                    or (indexType=='name' and '|cnGREEN_FONT_COLOR:')
                    or (select(2, math.modf(i/2))==0 and '|cffffffff')
                    or '|cff00ccff'
            if type(name)=='table' then
                if indexType=='abilities' then
                    e.tips:AddDoubleLine(col..indexType, StableFrame.WoWToolsButton:get_abilities_icons(pet))
                end
            else
                name= indexType=='icon' and format('|T%d:14|t%d', name, name)
                    or (name==false and 'false')
                    or (name==true and 'true')
                    or (name==nil and '')
                    or name
                e.tips:AddDoubleLine(col..indexType, col..name)
            end
            i=i+1
        end

    end


    --宠物，列表，提示
    hooksecurefunc(StableStabledPetButtonTemplateMixin, 'SetPet', function(btn)
        if not btn.set_settings then
            btn:HookScript('OnEnter', function(self)--信息，提示
                StableFrame.WoWToolsButton:set_pet_tooltips(self, self.petData, -10)
                e.tips:Show()
            end)
            btn.Portrait2= btn:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
            btn.Portrait2:SetSize(20, 20)
            btn.Portrait2:SetPoint('RIGHT', btn.Portrait,'LEFT')
            btn.Portrait2:SetAlpha(0.5)
            btn.abilitiesText= e.Cstr(btn)--宠物，技能，提示
            btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.Background, -9, 8)
            btn.indexText= e.Cstr(btn)--, {color={r=1,g=0,b=1}})--SlotID
            btn.indexText:SetPoint('TOPRIGHT', -9,-6)
            btn.indexText:SetAlpha(0.5)
            function btn:set_shown()
                self.abilitiesText:SetShown(not self.isSelected)
                self.Portrait2:SetShown(not self.isSelected)
            end
            function btn:set_settings()
                self.abilitiesText:SetText(StableFrame.WoWToolsButton:get_abilities_icons(self.petData))--宠物，技能，提示
                local data= self.petData or {}--宠物，类型，图标
                self.Portrait2:SetTexture(data.icon or 0)
                self.indexText:SetText(data.slotID or '')
                self:set_shown()
            end
        end
        btn:set_settings()
    end)
    hooksecurefunc(StableStabledPetButtonTemplateMixin, 'OnPetSelected', function(self)--选中时，不显示，技能
        if self.set_shown then
            self:set_shown()
        end
    end)

    --已激，宠物栏，提示
    StableFrame.WoWToolsButton.CALL_PET_SPELL_IDS = {0883, 83242, 83243, 83244, 83245, }
    for i, btn in ipairs(StableFrame.ActivePetList.PetButtons) do
        btn.index=i
        btn.callSpellButton= e.Cbtn(btn, {size={18,18},icon='hide'})--召唤，法术，提示
        btn.callSpellButton.Texture=btn.callSpellButton:CreateTexture(nil, 'OVERLAY')
        btn.callSpellButton.Texture:SetAllPoints(btn.callSpellButton)
        SetPortraitToTexture(btn.callSpellButton.Texture, 132161)
        btn.callSpellButton:SetPoint('BOTTOMLEFT', -8, -16)
        btn.callSpellButton.spellID=StableFrame.WoWToolsButton.CALL_PET_SPELL_IDS[btn.petData and btn.petData.slotID or btn.index]
        btn.callSpellButton:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
        btn.callSpellButton:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.spellID, true, true);
            GameTooltip:Show();
            self:SetAlpha(1)
        end)
        btn.callSpellButton:SetAlpha(0.5)

        btn:HookScript('OnEnter', function(self)--信息，提示
            StableFrame.WoWToolsButton:set_pet_tooltips(self, self.petData, -10)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.Icon.right)
            e.tips:Show()
        end)
        btn.Portrait2= btn.callSpellButton:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
        btn.Portrait2:SetSize(18, 18)
        btn.Portrait2:SetPoint('LEFT', btn.callSpellButton, 'RIGHT')
        btn.abilitiesText= e.Cstr(btn, {SetJustifyH='RIGHT'})--宠物，技能，提示
        btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.callSpellButton, 'BOTTOMLEFT', 2, -4)
        btn.indexText=e.Cstr(btn.callSpellButton)--索引
        btn.indexText:SetPoint('LEFT', btn.Portrait2, 'RIGHT', 4,0)
        btn.indexText:SetText(i)
        
        function btn:set_settings()
            local icon= StableFrame.WoWToolsButton:get_abilities_icons(self.petData)
            icon= icon:gsub('|T.-|t', function(a) return a..'|n' end)
            self.abilitiesText:SetText(icon)--宠物，技能，提示
            local data= self.petData or {}--宠物，类型，图标
            self.Portrait2:SetTexture(data.icon or 0)
        end
        hooksecurefunc(btn, 'SetPet', function(frame)--StableActivePetButtonTemplateMixin
            if frame.set_settings then
                frame:set_settings()
            end
        end)
    end

    --第二个，宠物，提示
    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:HookScript('OnEnter', function(self)
        if not self.petData or not self:IsEnabled() then
            return
        end
        StableFrame.WoWToolsButton:set_pet_tooltips(self, self.petData, 0)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            format('|A:UI-HUD-MicroMenu-SpecTalents-Mouseover:0:0|a|cffaad372%s|r', e.onlyChinese and '天赋' or TALENT),
            format('|T461112:0|t|cffaad372%s|r', e.onlyChinese and '动物伙伴' or GetSpellLink(267116) or GetSpellInfo(267116) or 'Animal Companion')
        )
        e.tips:AddDoubleLine(e.onlyChinese and '移除' or REMOVE, e.Icon.right)
        e.tips:Show()
    end)

    --移动，缩放
    e.Set_Move_Frame(StableFrame, {setSize=true, minW=860, minH=440, initFunc=function()
            StableFrame.PetModelScene:ClearAllPoints()
            StableFrame.PetModelScene:SetPoint('TOPLEFT', StableFrame.Topper, 'BOTTOMLEFT', 330, 0)
            StableFrame.PetModelScene:SetPoint('BOTTOMRIGHT', -2, 92)
            StableFrame.ActivePetList:ClearAllPoints()
            StableFrame.ActivePetList:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -45)
            StableFrame.ActivePetList:SetPoint('TOPRIGHT', StableFrame.PetModelScene, 'BOTTOMRIGHT', 0, -45)
        end, sizeRestFunc=function(btn)
            btn.target:SetSize(1040, 638)
    end})

    StableFrame.ReleasePetButton:ClearAllPoints()
    StableFrame.ReleasePetButton:SetPoint('BOTTOMRIGHT', StableFrame.PetModelScene, 'TOPRIGHT', 0,20)
    StableFrame.ReleasePetButton:SetAlpha(0.5)
    StableFrame.ReleasePetButton:HookScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    StableFrame.ReleasePetButton:HookScript('OnEnter', function(self) self:SetAlpha(1) end)

    StableFrame.StableTogglePetButton:ClearAllPoints()
    StableFrame.StableTogglePetButton:SetPoint('BOTTOMRIGHT', StableFrame.PetModelScene)

    StableFrame.PetModelScene.AbilitiesList:ClearAllPoints()
    StableFrame.PetModelScene.AbilitiesList:SetPoint('LEFT', 2, -40)

    
    StableFrame.PetModelScene.PetInfo.Specialization:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Specialization:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Type, 'BOTTOMRIGHT', 0, -2)

    StableFrame.PetModelScene.PetInfo.Exotic:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Exotic:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Specialization, 'BOTTOMRIGHT', 0, -2)

    StableFrame.ActivePetList.ActivePetListBG:ClearAllPoints()
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -2)
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('BOTTOMRIGHT', StableFrame)
    StableFrame.PetModelScene.ControlFrame:ClearAllPoints()
    StableFrame.PetModelScene.ControlFrame:SetPoint('TOP')

    StableFrame.PetModelScene.PetShadow:ClearAllPoints()
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMLEFT')
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMRIGHT')

    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:ClearAllPoints()
    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:SetPoint('RIGHT',  StableFrame.PetModelScene, -16 ,0)
    StableFrame.ActivePetList.Divider:ClearAllPoints()
    StableFrame.ActivePetList.Divider:Hide()

    local x= 40
    StableFrame.ActivePetList.PetButton3:ClearAllPoints()
    StableFrame.ActivePetList.PetButton3:SetPoint('CENTER')

    StableFrame.ActivePetList.PetButton2:ClearAllPoints()
    StableFrame.ActivePetList.PetButton2:SetPoint('RIGHT', StableFrame.ActivePetList.PetButton3, 'LEFT', -x, 0)

    StableFrame.ActivePetList.PetButton1:ClearAllPoints()
    StableFrame.ActivePetList.PetButton1:SetPoint('RIGHT', StableFrame.ActivePetList.PetButton2, 'LEFT', -x, 0)

    StableFrame.ActivePetList.PetButton4:ClearAllPoints()
    StableFrame.ActivePetList.PetButton4:SetPoint('LEFT', StableFrame.ActivePetList.PetButton3, 'RIGHT', x, 0)
    
    StableFrame.ActivePetList.PetButton5:ClearAllPoints()
    StableFrame.ActivePetList.PetButton5:SetPoint('LEFT', StableFrame.ActivePetList.PetButton4, 'RIGHT', x, 0)

    StableFrame.ActivePetList.ListName:ClearAllPoints()
    StableFrame.ActivePetList.ListName:SetPoint('BOTTOMLEFT', StableFrame.ActivePetList.ActivePetListBG, 'TOPLEFT')
end]]