
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end

local function Save()
    return WoWToolsSave['Plus_StableFrame'] or {}
end

function WoWTools_MoveMixin.Events:Blizzard_StableUI()
    if Save().disabled then
        self:Setup(StableFrame)
        self:Setup(StableFrame.StabledPetList.ScrollBox, {frame=StableFrame})
    end
end


 --移动，缩放
local function Init_MoveUI()
    StableFrame.PetModelScene:ClearAllPoints()
    StableFrame.PetModelScene:SetPoint('TOPLEFT', StableFrame, 330, -86)
    StableFrame.PetModelScene:SetPoint('BOTTOMRIGHT', -2, 92)
    StableFrame.ActivePetList:ClearAllPoints()
    StableFrame.ActivePetList:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -45)
    StableFrame.ActivePetList:SetPoint('TOPRIGHT', StableFrame.PetModelScene, 'BOTTOMRIGHT', 0, -45)

    StableFrame.ReleasePetButton:ClearAllPoints()
    StableFrame.ReleasePetButton:SetPoint('BOTTOM', StableFrame.PetModelScene, 'TOP', 0, 12)
    --StableFrame.ReleasePetButton:SetAlpha(0.5)
    --StableFrame.ReleasePetButton:HookScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    --StableFrame.ReleasePetButton:HookScript('OnEnter', function(self) self:SetAlpha(1) end)

    StableFrame.StableTogglePetButton:ClearAllPoints()
    StableFrame.StableTogglePetButton:SetPoint('BOTTOMRIGHT', StableFrame.PetModelScene)

    StableFrame.PetModelScene.AbilitiesList:ClearAllPoints()
    StableFrame.PetModelScene.AbilitiesList:SetPoint('LEFT', 8, -40)

    StableFrame.PetModelScene.PetInfo.Specialization:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Specialization:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Type, 'BOTTOMRIGHT', 0, -2)

    StableFrame.PetModelScene.PetInfo.Exotic:ClearAllPoints()
    StableFrame.PetModelScene.PetInfo.Exotic:SetPoint('TOPRIGHT', StableFrame.PetModelScene.PetInfo.Specialization, 'BOTTOMRIGHT', 0, -2)
    StableFrame.PetModelScene.PetInfo.Exotic:SetTextColor(0,1,0)

    StableFrame.ActivePetList.ActivePetListBG:ClearAllPoints()
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -2)
    StableFrame.ActivePetList.ActivePetListBG:SetPoint('BOTTOMRIGHT', StableFrame)
    StableFrame.ActivePetList.ActivePetListBG:SetAtlas('wood-topper')
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

    --激活栏，添加材质
    StableFrame.ActivePetList.ActivePetListBG:SetAtlas('wood-topper')

    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:SetHighlightAtlas('AlliedRace-UnlockingFrame-BottomButtonsSelectionGlow')--修该，名称
    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:HookScript('OnLeave', GameTooltip_Hide)
    StableFrame.PetModelScene.PetInfo.NameBox.EditButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '修改宠物名字' or PET_RENAME_LABEL:gsub(HEADER_COLON, ''))
        GameTooltip:Show()
    end)
    StableFrame.PetModelScene.PetInfo.FavoriteButton:HookScript('OnLeave', GameTooltip_Hide)
    StableFrame.PetModelScene.PetInfo.FavoriteButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '收藏' or FAVORITES)
        GameTooltip:Show()
    end)


    WoWTools_MoveMixin:Setup(StableFrame, {
        minW=860, minH=440,
    sizeRestFunc=function(f)
        f:SetSize(1040, 638)
    end})

    WoWTools_MoveMixin:Setup(StableFrame.StabledPetList.ScrollBox, {frame=StableFrame})

    Init_MoveUI= function()end
end













local function Set_BG(self, texture, alpha)
    alpha= texture and 0 or alpha or 1

    StableFrame.Topper:SetAlpha(alpha)
    StableFrame.TopTileStreaks:SetAlpha(alpha)
    StableFrameBg:SetAlpha(alpha)

    self:SetFrame(StableFrame.StabledPetList.ListCounter, {alpha=alpha, notColor=true})--frame
    self:SetFrame(StableFrame.ActivePetList, {alpha=alpha, notColor=true})--frame
    StableFrame.StabledPetList.Backgroud:SetAlpha(alpha)
    StableFrame.StabledPetList.Inset.Bg:SetAlpha(alpha)
    StableFrame.PetModelScene.Inset.Bg:SetAlpha(alpha)

    local bgAlpha= texture and 1 or alpha or 1
    for _, btn in ipairs(StableFrame.ActivePetList.PetButtons) do--已激，宠物栏，提示
        if btn.model and btn.model.bg then
            btn.model.bg:SetAlpha(bgAlpha)
        end
    end
end





local function Init_Texture(self)
    self:SetUIButton(StableFrame.ReleasePetButton)
    self:SetUIButton(StableFrame.StableTogglePetButton)
    self:SetModelZoom(StableFrame.PetModelScene.ControlFrame)
    self:SetAlphaColor(StableFrame.PetModelScene.PetInfo.NameBox.EditButton.Icon, true)

    self:SetEditBox(StableFrame.StabledPetList.FilterBar.SearchBox)
    self:SetMenu(StableFrame.StabledPetList.FilterBar.FilterDropdown)

    self:SetScrollBar(StableFrame.StabledPetList)
    self:SetMenu(StableFrame.PetModelScene.PetInfo.Specialization)
    self:SetMenu(StableFrame.StabledPetList.FilterBar)

    --self:SetNineSlice(StableFrame)
    self:SetNineSlice(StableFrame.StabledPetList.Inset)
    self:SetNineSlice(StableFrame.PetModelScene.Inset)
    self:SetButton(StableFrameCloseButton)
    self:SetButton(StableFrame.MainHelpButton)

    WoWTools_DataMixin:Hook(StableStabledPetButtonTemplateMixin, 'SetPet', function(btn)
        btn.Selected:SetVertexColor(0,1,0)
        self:SetAlphaColor(btn.Background, nil, true, 0.75)
    end)
    WoWTools_DataMixin:Hook(StabledPetListCategoryMixin, 'SetCollapseState', function(btn)
        self:SetAlphaColor(btn.LeftPiece, nil, nil, 0.5)
        self:SetAlphaColor(btn.CenterPiece, nil, nil, 0.5)
        self:SetAlphaColor(btn.RightPiece, nil, nil, 0.5)
    end)

    for i=1, 5 do
        if StableFrame.ActivePetList['PetButton'..i] then
            self:HideTexture(StableFrame.ActivePetList['PetButton'..i].Background)
            self:SetAlphaColor(StableFrame.ActivePetList['PetButton'..i].Border)
        end
    end
    self:SetAlphaColor(StableFrame.ActivePetList.BeastMasterSecondaryPetButton.Border)

    self:HideTexture(StableFrame.ActivePetList.BeastMasterSecondaryPetButton.Background)

    self:HideFrame(StableFrame.StabledPetList.ListCounter)

    StableFrame.MainHelpButton:SetFrameStrata(StableFrame.TitleContainer:GetFrameStrata())
    StableFrame.MainHelpButton:SetFrameLevel(StableFrame.TitleContainer:GetFrameLevel()+1)

    self:Init_BGMenu_Frame(StableFrame, {
        settings=function(_, texture, alpha)
            Set_BG(self, texture, alpha)
        end
    })

    Init_Texture=function()end
end






function WoWTools_TextureMixin.Events:Blizzard_StableUI()
    Init_Texture(self)
end


function WoWTools_HunterMixin:Init_UI()
    Init_MoveUI()
    Init_Texture(WoWTools_TextureMixin)
end

