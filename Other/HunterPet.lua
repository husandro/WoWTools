local id, e= ...
if e.Player.class~='HUNTER' then --or C_AddOns.IsAddOnLoaded("ImprovedStableFrame") then
    return
end

local addName --猎人兽栏
local Save={
    --hideIndex=true,--隐藏索引
    --hideTalent=true,--隐藏天赋
   -- modelScale=0.65,

    --line=15,

    --10.2.7
    --show_All_List=true,显示，所有宠物，图标列表
    --sortDown= true,--排序, 降序
    --all_List_Size==28--图标表表，图标大小
    --showTexture=true,--显示，材质
    sortType='specialization',
    all_List_Size=28
}


local AllListFrame

local MAX_SUMMONABLE_HUNTER_PETS = Constants.PetConsts_PostCata.MAX_SUMMONABLE_HUNTER_PETS or 5

local EXTRA_PET_STABLE_SLOT_LUA_INDEX = (Constants.PetConsts_PostCata.EXTRA_PET_STABLE_SLOT or 5) + 1;

local NUM_PET_SLOTS_HUNTER = Constants.PetConsts_PostCata.NUM_PET_SLOTS_HUNTER or 205


--召唤，法术，提示
local CALL_PET_SPELL_IDS = {
    0883,
	83242,
	83243,
	83244,
	83245,
}
e.LoadData({id=267116, type='spell'})--动物伙伴



local function GetAbilitieIconForTab(tab, line)
    local text=''
    for _, spellID in pairs(tab or {}) do
        e.LoadData({id=spellID, type='spell'})
        local texture= C_Spell.GetSpellTexture(spellID)
        if texture and texture>0 then
            text= format('%s%s|T%d:14|t', text, line and text~='' and '|n' or '', texture)
        end
    end
    return text
end



local function get_abilities_icons(pet, line)--取得，宠物，技能，图标
    if not pet then
        return ''
    end

    local text= GetAbilitieIconForTab(pet.specAbilities, line)
    if text~='' then
        text= text..(not line and '  ' or '   |n')
    end
    return text..GetAbilitieIconForTab(pet.petAbilities or pet.abilities, line)
end



--宠物，信息，提示
local function set_pet_tooltips(frame, pet)
    e.tips:SetOwner(frame, "ANCHOR_LEFT", -12, 0)
    e.tips:ClearLines()
    e.tips:AddDoubleLine(e.addName, addName)
    e.tips:AddLine(' ')
    local i=1
    for indexType, name in pairs(pet) do
        local col= indexType=='slotID' and '|cffff00ff'
                or (indexType=='name' and '|cnGREEN_FONT_COLOR:')
                or (select(2, math.modf(i/2))==0 and '|cffffffff')
                or '|cff00ccff'
        if type(name)=='table' then
            if indexType=='abilities' or indexType=='petAbilities' or indexType=='specAbilities' then--11.1
                e.tips:AddDoubleLine(col..indexType, GetAbilitieIconForTab(name, false))
                --e.tips:AddDoubleLine(col..indexType, get_abilities_icons(pet, false))
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
    local dietString = table.concat(C_StableInfo.GetStablePetFoodTypes(pet.slotID), LIST_DELIMITER)
    e.tips:AddDoubleLine(format('|cff00ccff%s', e.onlyChinese and '食物' or PET_DIET_TEMPLATE), dietString)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.onlyChinese and '拖曳' or DRAG_MODEL, e.Icon.left)

    if e.tips.playerModel and pet.displayID and pet.displayID>0 then
        e.tips.playerModel:SetDisplayInfo(pet.displayID)
        e.tips.playerModel:SetShown(true)
    end
end



























--已激活宠物，Model 提示
local function created_model(btn, setBg)
    btn.model= CreateFrame("PlayerModel", nil, btn)
    local w= btn:GetWidth()

    if btn:GetID()==EXTRA_PET_STABLE_SLOT_LUA_INDEX then--11版本
        btn.model:SetFacing(-0.3)
        w=w+80
        btn.model:SetPoint('RIGHT', btn, 'LEFT')
    else
        btn.model:SetFacing(0.3)
        w= w+40
        btn.model:SetPoint('TOP', btn, 'BOTTOM', 0, -14)
    end
    btn.model:SetSize(w, w)

    if setBg then
        btn.model.bg= btn:CreateTexture(nil, 'BACKGROUND')
        btn.model.bg:SetAllPoints(btn.model)

        btn.model.shadow= btn.model:CreateTexture(nil, 'ARTWORK')
        btn.model.shadow:SetAtlas('perks-char-shadow')
        btn.model.shadow:SetPoint('BOTTOMLEFT',btn.model, 0,-3)
        btn.model.shadow:SetSize(w-18, 18)
        btn.model.shadow:SetAlpha(0.4)

        local slotID= btn:GetID()
        btn.callSpellButton= WoWTools_ButtonMixin:Cbtn(btn, {size={18,18},icon='hide'})--召唤，法术，提示
        btn.callSpellButton.Texture=btn.callSpellButton:CreateTexture(nil, 'OVERLAY')
        btn.callSpellButton.Texture:SetAllPoints()
        SetPortraitToTexture(btn.callSpellButton.Texture, 132161)
        btn.callSpellButton:SetPoint('BOTTOMLEFT', -8, -16)
        btn.callSpellButton.spellID=CALL_PET_SPELL_IDS[slotID]
        btn.callSpellButton:SetScript('OnLeave', function(self) self:SetAlpha(0.3) GameTooltip_Hide() end)
        btn.callSpellButton:SetScript('OnEnter', function(self)
            if self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self.spellID, true, true);
                GameTooltip:Show();
            end
            self:SetAlpha(1)
        end)
        btn.callSpellButton:SetAlpha(0.5)
        btn.Portrait2= btn.callSpellButton:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
        btn.Portrait2:SetSize(18, 18)

        btn.Portrait2:SetPoint('LEFT', btn.callSpellButton, 'RIGHT')
        btn.abilitiesText= WoWTools_LabelMixin:Create(btn, {SetJustifyH='RIGHT'})--宠物，技能，提示
        btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.callSpellButton, 'BOTTOMLEFT', 2, -2)

        btn.indexText=WoWTools_LabelMixin:Create(btn.callSpellButton)--索引
        btn.indexText:SetPoint('LEFT', btn.Portrait2, 'RIGHT', 4,0)
        btn.indexText:SetText(slotID)
    end
    btn.specText= WoWTools_LabelMixin:Create(btn, {color=true})--专精
    btn.specText:SetPoint('TOP', 0, 12)

    function btn:set_pet()
        local pet= self:IsVisible() and self.petData or {}--宠物，类型，图标
        local displayID= pet.displayID or 0
        if displayID==0 then
            self.model:ClearModel()
        elseif displayID~=self.displayID then
            self.model:SetDisplayInfo(displayID)
        end
        self.displayID= displayID--提示用，
        if self.model.bg then
            local atlas
            if displayID>0 then
                local backgroundForPetSpec = {
                    [STABLE_PET_SPEC_CUNNING] = "hunter-stable-bg-art_cunning",
                    [STABLE_PET_SPEC_FEROCITY] = "hunter-stable-bg-art_ferocity",
                    [STABLE_PET_SPEC_TENACITY] = "hunter-stable-bg-art_tenacity",
                }
                atlas = backgroundForPetSpec[pet.specialization]
            end
            if atlas then
                self.model.bg:SetAtlas(atlas)-- or 'footer-bg')
            else
                self.model.bg:SetTexture(0)
            end
            self.model.shadow:SetShown(displayID>0)
            self.abilitiesText:SetText(get_abilities_icons(pet, true))--宠物，技能，提示
            self.Portrait2:SetTexture(pet.icon or 0)
        else
            self.Icon:SetTexCoord(0, 1, 0, 1)
        end

        self.specText:SetText(e.cn(pet.specialization) or '')
    end

    hooksecurefunc(btn, 'SetPet', btn.set_pet)--StableActivePetButtonTemplateMixin
    btn:HookScript('OnHide', btn.set_pet)
    btn:HookScript('OnEnter', function(self)--信息，提示
        if self.petData and not self.locked and self:IsEnabled() then
            set_pet_tooltips(self, self.petData)
            e.tips:AddDoubleLine(e.onlyChinese and '放入兽栏' or STABLE_PET_BUTTON_LABEL, e.Icon.right)
            if self:GetID()==EXTRA_PET_STABLE_SLOT_LUA_INDEX then
                e.tips:AddDoubleLine(
                    format('|cffaad372%s|r', e.onlyChinese and '天赋' or TALENT),
                    format('|T461112:0|t|cffaad372%s|r', e.onlyChinese and '动物伙伴' or C_Spell.GetSpellLink(267116) or C_Spell.GetSpellName(267116) or 'Animal Companion')
                )
            end
            e.tips:Show()
        end
    end)

    btn:set_pet()
end









--猎人，兽栏 Plus 10.2.7 Blizzard_StableUI.lua
local function Init_StableFrame_Plus()
    hooksecurefunc(StableStabledPetButtonTemplateMixin, 'SetPet', function(btn)--宠物，列表，提示
        if not btn.set_list_button_settings then
            btn.Portrait2= btn:CreateTexture(nil, 'OVERLAY')--宠物，类型，图标
            btn.Portrait2:SetSize(20, 20)
            btn.Portrait2:SetPoint('RIGHT', btn.Portrait,'LEFT')
            btn.Portrait2:SetAlpha(0.5)
            btn.abilitiesText= WoWTools_LabelMixin:Create(btn)--宠物，技能，提示
            btn.abilitiesText:SetPoint('BOTTOMRIGHT', btn.Background, -9, 8)
            btn.indexText= WoWTools_LabelMixin:Create(btn)--, {color={r=1,g=0,b=1}})--SlotID
            btn.indexText:SetPoint('TOPRIGHT', -9,-6)
            btn.indexText:SetAlpha(0.5)
            function btn:set_list_button_settings()
                self.abilitiesText:SetText(get_abilities_icons(self.petData, false))--宠物，技能，提示
                local data= self.petData or {}--宠物，类型，图标
                self.Portrait2:SetTexture(data.icon or nil)
                self.indexText:SetText(data.slotID or '')
            end
            btn:HookScript('OnEnter', function(self)--信息，提示
                if self.petData then
                    set_pet_tooltips(self, self.petData)
                    e.tips:Show()
                end
            end)
        end
        btn:set_list_button_settings()
    end)


    for _, btn in ipairs(StableFrame.ActivePetList.PetButtons) do--已激，宠物栏，提示
        created_model(btn, true)--已激活宠物，Model 提示
    end
    created_model(StableFrame.ActivePetList.BeastMasterSecondaryPetButton, false)--第二个，宠物，提示

    hooksecurefunc(StableFrame.PetModelScene, 'SetPet', function(self)--选定时，隐藏model
        local frame= self:GetParent()
        local selecIndex= frame.selectedPet and frame.selectedPet.slotID
        for _, btn2 in ipairs(frame.ActivePetList.PetButtons) do--已激，宠物栏，提示
            btn2.model:SetShown(btn2.petData and not btn2.locked and selecIndex~=btn2:GetID())
        end
        local btn2= frame.ActivePetList.BeastMasterSecondaryPetButton
        btn2.model:SetShown(btn2.petData and btn2:IsEnabled() and selecIndex~=btn2:GetID())
    end)


    local btnSecond= StableFrame.ActivePetList.BeastMasterSecondaryPetButton
    btnSecond.SpellFrame= CreateFrame('Frame', nil, btnSecond, 'StablePetAbilityTemplate')--StablePetAbilityMixin
    btnSecond.SpellFrame:SetPoint('TOPRIGHT', btnSecond, 'BOTTOMRIGHT', 10,-6)
    btnSecond.SpellFrame:Initialize(267116)--动物伙伴
    btnSecond.SpellFrame.Icon:ClearAllPoints()
    btnSecond.SpellFrame.Icon:SetPoint('RIGHT')
    btnSecond.SpellFrame.Name:ClearAllPoints()
    btnSecond.SpellFrame.Name:SetPoint('RIGHT', btnSecond.SpellFrame.Icon, 'LEFT')
    if e.onlyChinese and not LOCALE_zhCN then
        btnSecond.SpellFrame.Name:SetText('动物伙伴')
    end
    hooksecurefunc(btnSecond, 'Refresh', function(self)
        if AllListFrame then
            AllListFrame.btn6:settings()
        end
        if self:IsEnabled() then
            self.SpellFrame.Name:SetTextColor(1,1,1)
        else
            self.SpellFrame.Name:SetTextColor(0.5,0.5,0.5)
        end
    end)


    --食物
    StableFrame.PetModelScene.PetInfo.Food=WoWTools_LabelMixin:Create(StableFrame.PetModelScene.PetInfo, {copyFont=not e.onlyChinese and StableFrame.PetModelScene.PetInfo.Specialization, color={r=1,g=1,b=1}, size=16})--copyFont=StableFrame.PetModelScene.PetInfo.Specialization, 
    StableFrame.PetModelScene.PetInfo.Food:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Exotic, 'BOTTOMRIGHT')
    --特殊，加图标
    StableFrame.PetModelScene.PetInfo.ExoticTexture= StableFrame.PetModelScene.PetInfo:CreateTexture()
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetSize(18,18)
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetPoint('RIGHT', StableFrame.PetModelScene.PetInfo.Exotic, 'LEFT')
    StableFrame.PetModelScene.PetInfo.ExoticTexture:SetTexture(461112)

    hooksecurefunc(StableFrame.PetModelScene.PetInfo, 'SetPet', function(self, petData)
        petData= petData or {}
        self.ExoticTexture:SetShown(petData.isExotic)
        local text
        if petData.slotID then
            local dietString = table.concat(C_StableInfo.GetStablePetFoodTypes(petData.slotID), LIST_DELIMITER)
            text= format(e.onlyChinese and '食物：%s' or PET_DIET_TEMPLATE, dietString)
        end
        self.Food:SetText(text or '')
    end)
end






































function Init_UI()
    --移动，缩放
    StableFrame.PetModelScene:ClearAllPoints()
    StableFrame.PetModelScene:SetPoint('TOPLEFT', StableFrame, 330, -86)
    StableFrame.PetModelScene:SetPoint('BOTTOMRIGHT', -2, 92)
    StableFrame.ActivePetList:ClearAllPoints()
    StableFrame.ActivePetList:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -45)
    StableFrame.ActivePetList:SetPoint('TOPRIGHT', StableFrame.PetModelScene, 'BOTTOMRIGHT', 0, -45)
    WoWTools_MoveMixin:Setup(StableFrame.StabledPetList.ScrollBox, {frame=StableFrame})
    WoWTools_MoveMixin:Setup(StableFrame, {needSize=true, needMove=true, setSize=true, minW=860, minH=440, sizeRestFunc=function(btn)
        btn.target:SetSize(1040, 638)
    end})

    StableFrame.ReleasePetButton:ClearAllPoints()
    --StableFrame.ReleasePetButton:SetPoint('BOTTOMLEFT', StableFrame.PetModelScene, 'TOPLEFT', 0,20)
    StableFrame.ReleasePetButton:SetPoint('BOTTOM', StableFrame.PetModelScene, 'TOP', 0, 12)
    StableFrame.ReleasePetButton:SetAlpha(0.5)
    StableFrame.ReleasePetButton:HookScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    StableFrame.ReleasePetButton:HookScript('OnEnter', function(self) self:SetAlpha(1) end)

    StableFrame.StableTogglePetButton:ClearAllPoints()
    StableFrame.StableTogglePetButton:SetPoint('BOTTOMRIGHT', StableFrame.PetModelScene)
    --StableFrame.StableTogglePetButton:SetWidth(StableFrame.StableTogglePetButton:GetFontString():GetWidth()+24)

    StableFrame.PetModelScene.AbilitiesList:ClearAllPoints()
    StableFrame.PetModelScene.AbilitiesList:SetPoint('LEFT', 8, -40)


    --StableFrame.PetModelScene.PetInfo.Type:SetJustifyH('RIGHT')
    StableFrame.PetModelScene.PetInfo.Specialization:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Specialization:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Type, 'BOTTOMRIGHT', 0, -2)

    StableFrame.PetModelScene.PetInfo.Exotic:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Exotic:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Specialization, 'BOTTOMRIGHT', 0, -2)
    StableFrame.PetModelScene.PetInfo.Exotic:SetTextColor(0,1,0)

    StableFrame.ActivePetList.ActivePetListBG:ClearAllPoints()
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -2)
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('BOTTOMRIGHT', StableFrame)
    StableFrame.PetModelScene.ControlFrame:ClearAllPoints()
    StableFrame.PetModelScene.ControlFrame:SetPoint('TOP')

    StableFrame.PetModelScene.PetShadow:ClearAllPoints()
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMLEFT')
    StableFrame.PetModelScene.PetShadow:SetPoint('BOTTOMRIGHT')

    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:ClearAllPoints()
    StableFrame.ActivePetList.BeastMasterSecondaryPetButton:SetPoint('BOTTOMRIGHT',  StableFrame.PetModelScene, -20 , 80)
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

    if StableFrame.Topper:IsShown() then--激活栏，添加材质
        local texture= StableFrame:CreateTexture()
        texture:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT')
        texture:SetPoint('BOTTOMRIGHT')
        texture:SetAtlas('wood-topper')
    end

    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:SetHighlightAtlas('AlliedRace-UnlockingFrame-BottomButtonsSelectionGlow')--修该，名称
    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:HookScript('OnLeave', GameTooltip_Hide)
    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '修改宠物名字' or PET_RENAME_LABEL:gsub(HEADER_COLON, ''))
        e.tips:Show()
    end)
    StableFrame.PetModelScene.PetInfo.FavoriteButton:HookScript('OnLeave', GameTooltip_Hide)
    StableFrame.PetModelScene.PetInfo.FavoriteButton:HookScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '收藏' or FAVORITES)
        e.tips:Show()
    end)
end











local function Init_UI_Texture()
    local show= Save.showTexture

    WoWTools_PlusTextureMixin:SetAlphaColor(StableFrameBg, nil, nil, show and 1 or 0.5)
    WoWTools_PlusTextureMixin:SetNineSlice(StableFrame, true, nil, nil)

    WoWTools_PlusTextureMixin:SetAlphaColor(StableFrame.Topper, nil, nil, show and 1 or 0)

    for _, object in pairs({StableFrame:GetRegions()}) do
        if object~=StableFrameBg and object:GetObjectType()=='Texture' then
            object:SetAlpha(show and 1 or 0)
        end
    end

    WoWTools_PlusTextureMixin:SetAlphaColor(StableFrame.StabledPetList.Backgroud, nil, nil, show and 1 or 0)
    WoWTools_PlusTextureMixin:SetAlphaColor(StableFrame.StabledPetList.Inset.Bg, nil, nil, show and 1 or 0)

    WoWTools_PlusTextureMixin:SetSearchBox(StableFrame.StabledPetList.FilterBar.SearchBox)
    WoWTools_PlusTextureMixin:SetScrollBar(StableFrame.StabledPetList)
    WoWTools_PlusTextureMixin:SetMenu(StableFrame.PetModelScene.PetInfo.Specialization)
    WoWTools_PlusTextureMixin:SetMenu(StableFrame.StabledPetList.FilterBar)

    WoWTools_PlusTextureMixin:SetFrame(StableFrame.StabledPetList.ListCounter, {alpha=show and 1 or 0.8})
end























local function set_button_size(btn)
    local n= Save.all_List_Size or 28
    AllListFrame.s= n
    btn:SetSize(n, n)
    btn.Icon:SetSize(n, n)
    local s= n*0.5
    btn.BackgroundMask:SetSize(s, s)
    local w= n+ ((85-72)/72)*n--0.287
    local h= n+ ((100-72)/72)*n--0.515
    btn.Highlight:SetSize(w, h)
end



local function created_button(index)
    local btn= CreateFrame('Button', nil, AllListFrame, 'StableActivePetButtonTemplate', index)
    btn:HookScript('OnEnter', function(self)
        if self.petData then
            set_pet_tooltips(self, self.petData)
            e.tips:Show()
        end
    end)
    set_button_size(btn)

    btn.Border:SetTexture(nil)
    btn.Border:ClearAllPoints()
    btn.Border:Hide()
    btn.Text= WoWTools_LabelMixin:Create(btn,{size=10, color={r=1,g=1,b=1,a=0.2}, layer='BACKGROUND'})
    btn.Text:SetPoint('CENTER', btn.Background)
    btn.Text:SetText(index)
    btn.Icon:SetDrawLayer('BORDER')
    hooksecurefunc(btn, 'SetPet', function(self)
        self.Icon:SetTexCoord(0, 1, 0, 1);
    end)
    return btn
end










--初始，宠物列表
function Set_StableFrame_List()
    if AllListFrame or not Save.show_All_List then
        if AllListFrame then
            AllListFrame:Settings()

        end
        return
    end

    AllListFrame= CreateFrame('Frame', nil, StableFrame)
    AllListFrame:SetPoint('TOPLEFT', StableFrame, 'TOPRIGHT', StableFrame.Topper:IsShown() and 0 or 12,0)
    AllListFrame:SetSize(1,1)
    AllListFrame:Hide()
    function AllListFrame:Settings()
        self:SetShown(Save.show_All_List)
        self.Bg:SetAtlas(Save.showTexture and 'pet-list-bg' or 'footer-bg')
    end

    AllListFrame.Buttons={}

    AllListFrame.s= Save.all_List_Size or 28

    AllListFrame.Bg= AllListFrame:CreateTexture(nil, "BACKGROUND")


    AllListFrame.Bg:SetTexCoord(1,0,1,0)
    AllListFrame.Bg:SetPoint('TOPLEFT')

    for i=EXTRA_PET_STABLE_SLOT_LUA_INDEX, NUM_PET_SLOTS_HUNTER do
        local btn= created_button(i)
        AllListFrame.Buttons[i]= btn
    end



    function AllListFrame:set_point()
        if not self:IsShown() then return end

        local x, y = 0, 0
        local btnY
        local s= StableFrame:GetHeight()
        for _, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', x, y)
            y= y-self.s
            if -y> s then
                btnY=btn
                y=0
                x=x+ self.s
            end
        end
        AllListFrame.Bg:ClearAllPoints()
        AllListFrame.Bg:SetPoint('TOPLEFT', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX])
        AllListFrame.Bg:SetPoint('BOTTOM', btnY)
        AllListFrame.Bg:SetPoint('RIGHT', AllListFrame.Buttons[NUM_PET_SLOTS_HUNTER])
    end



    function AllListFrame:Refresh()
        local show= self:IsShown()
        for _, btn in pairs(AllListFrame.Buttons) do
            btn:SetPet(show and C_StableInfo.GetStablePetInfo(btn:GetID()) or nil)
        end
        self.btn6:settings()
    end

    hooksecurefunc(StableFrame, 'Refresh', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)
    AllListFrame:SetScript('OnHide', AllListFrame.Refresh)
    AllListFrame:SetScript('OnShow', function(self)
        self:Refresh()
        self:set_point()
    end)

    StableFrame:HookScript('OnSizeChanged', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)

    --第6个，提示，如果，没有专精支持，它会禁用，所有，建立一个
    AllListFrame.btn6= created_button(MAX_SUMMONABLE_HUNTER_PETS)
    AllListFrame.btn6:SetPoint('BOTTOM', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX],'TOP')
    function AllListFrame.btn6:settings()
        local show= self:GetParent():IsShown() and not StableFrame.ActivePetList.BeastMasterSecondaryPetButton:IsEnabled()
        self:SetPet(show and C_StableInfo.GetStablePetInfo(self:GetID()) or nil)
        self:SetShown(show)
    end

    AllListFrame:Settings()


    StableFrame:HookScript('OnSizeChanged', function()
        AllListFrame:set_point()
    end)
end










local function get_text_byte(text)
    local num=0
    if type(text)=='number' then
        num= text
    elseif type(text)=='string' then
         for i=1, #text do
            num= num+ (string.byte(text, i) or 0)
         end
    end
    return num
end











local Is_In_Search
local function sort_pets_list(type)
    if Is_In_Search then
        return
    end
    Is_In_Search= true

    do
        local tab= {}
        for _, btn in pairs(AllListFrame.Buttons) do
            if btn.petData and btn.petData.slotID then
                local info = C_StableInfo.GetStablePetInfo(btn.petData.slotID) or {}
                table.insert(tab, {
                    slotID= get_text_byte(info.slotID),
                    petNumber= get_text_byte(info.petNumber),
                    type= get_text_byte(info.type),
                    creatureID= get_text_byte(info.CreatureID),
                    uiModelSceneID= get_text_byte(info.uiModelSceneID),
                    displayID= get_text_byte(info.displayID),
                    name= get_text_byte(info.name),
                    specialization= get_text_byte(info.specialization),
                    icon= get_text_byte(info.icon),
                    familyName= get_text_byte(info.familyName)
                })

            end
        end
        table.sort(tab, function(a, b)
            return a[type] < b[type]
        end)

        if not Save.sortDown then--点击，从前，向后
            for i, newTab in pairs(tab) do
                do
                    local index= i+  MAX_SUMMONABLE_HUNTER_PETS
                    C_StableInfo.SetPetSlot(newTab.slotID, index)
                end
            end
        else
            local all= #AllListFrame.Buttons
            for i, newTab in pairs(tab) do
                do
                    local newIndex= all-i+1
                    C_StableInfo.SetPetSlot(newTab.slotID, newIndex)
                end
            end
        end
    end
    Is_In_Search=nil
end

















local function Init_Menu(_, root)

--所有宠物
    root:CreateCheckbox(
        '|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '所有宠物' or BATTLE_PETS_TOTAL_PETS),
    function()
        return Save.show_All_List
    end, function()
        Save.show_All_List= not Save.show_All_List and true or nil
        Set_StableFrame_List()--初始，宠物列表
        return MenuResponse.Close

    end)


    if Save.show_All_List then
--排序
        root:CreateDivider()
        root:CreateCheckbox(
            e.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
        function()
            return not Save.sortDown
        end, function()
            Save.sortDown= not Save.sortDown and true or nil
        end)

        local tab={
            ['petNumber']=  'petNumber',
            [e.onlyChinese and '类型' or TYPE]= 'type',
            ['creatureID']= 'creatureID',
            ['uiModelSceneID']= 'uiModelSceneID',
            ['displayID']= 'displayID',
            [e.onlyChinese and '名称' or NAME]= 'name',
            [e.onlyChinese and '天赋' or TALENT]= 'specialization',
            [e.onlyChinese and '图标' or EMBLEM_SYMBOL]='icon',
            ['familyName']= 'familyName',
        }
        for text, name in pairs(tab) do
            root:CreateButton(text, function(data)
                sort_pets_list(data.name)
                return MenuResponse.Open
            end, {name=name})
        end

--图标尺寸
        root:CreateDivider()
        root:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(root, {
            getValue=function()
                return Save.all_List_Size or 28
            end, setValue=function(value)
                Save.all_List_Size=value
                if AllListFrame then
                    AllListFrame.s=value
                    for _, btn2 in pairs(AllListFrame.Buttons) do
                        set_button_size(btn2)
                    end
                    if AllListFrame:IsShown() then
                        AllListFrame:set_point()
                    end
                end
            end,
            name=e.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
            minValue=8,
            maxValue=72,
            step=1,
            bit=nil,
        })
        root:CreateSpacer()
    end

--显示，材质
    WoWTools_MenuMixin:ShowTexture(root, function()
        return Save.showTexture
    end, function()
        Save.showTexture= not Save.showTexture and true or nil
        Init_UI_Texture()
        Set_StableFrame_List()
    end)

--选项
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=addName})
end






--宠物列表
function Init_StableFrame_List()
    --local btn= WoWTools_ButtonMixin:Cbtn(StableFrame, {size={20,20}, atlas='dressingroom-button-appearancelist-up'})
    local btn= WoWTools_ButtonMixin:CreateMenu(StableFrameCloseButton)
    btn:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)


    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
    end
    btn:SetupMenu(Init_Menu)




    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)

    StableFrame.AllListButton= btn
    Set_StableFrame_List()--初始，宠物列表

end













local panel=CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['Other_HunterPet'] or Save

            addName= '|A:groupfinder-icon-class-hunter:0:0|a'..(e.onlyChinese and '猎人兽栏' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UnitClass('player'), STABLE_STABLED_PET_LIST_LABEL))

            --添加控制面板
             e.AddPanel_Check({
                name= addName,
                tooltip= nil,
                Value= not Save.disabled,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                Init_StableFrame_List()
                Init_StableFrame_Plus()
                Init_UI()
                Init_UI_Texture()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_HunterPet']= Save
        end
    end

end)

--[[
    Name = "PetConsts_PostCata",
			Type = "Constants",
			Values =
			{
{ Name = "MAX_STABLE_SLOTS", Type = "number", Value = 200 },
{ Name = "MAX_SUMMONABLE_PETS", Type = "number", Value = 25 },
{ Name = "MAX_SUMMONABLE_HUNTER_PETS", Type = "number", Value = 5 },
{ Name = "NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL", Type = "number", Value = 5 },
{ Name = "NUM_PET_SLOTS", Type = "number", Value = Constants.PetConsts.MAX_STABLE_SLOTS + Constants.PetConsts.NUM_PET_SLOTS_THAT_NEED_LEARNED_SPELL },
{ Name = "EXTRA_PET_STABLE_SLOT", Type = "number", Value = 5 },
{ Name = "STABLED_PETS_FIRST_SLOT_INDEX", Type = "number", Value = Constants.PetConsts.EXTRA_PET_STABLE_SLOT + 1 },
			},

local function Is_Selected_Pet(slotID)--是否，选中
    local selectedPet = StableFrame.selectedPet
    return selectedPet and selectedPet.slotID == slotID
end

--PetConstantsDocumentation.lua

]]
