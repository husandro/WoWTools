local e= select(2, ...)
if e.Player.class~='HUNTER' then
    return
end





local function Init_UI()
    --移动，缩放
    StableFrame.PetModelScene:ClearAllPoints()
    StableFrame.PetModelScene:SetPoint('TOPLEFT', StableFrame, 330, -86)
    StableFrame.PetModelScene:SetPoint('BOTTOMRIGHT', -2, 92)
    StableFrame.ActivePetList:ClearAllPoints()
    StableFrame.ActivePetList:SetPoint('TOPLEFT', StableFrame.PetModelScene, 'BOTTOMLEFT', 0, -45)
    StableFrame.ActivePetList:SetPoint('TOPRIGHT', StableFrame.PetModelScene, 'BOTTOMRIGHT', 0, -45)
    WoWTools_MoveMixin:Setup(StableFrame.StabledPetList.ScrollBox, {frame=StableFrame})
    WoWTools_MoveMixin:Setup(StableFrame, {
        --needSize=true, needMove=true,
        setSize=true, minW=860, minH=440,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(1040, 638)
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










local function Init_Texture()
    local show= WoWTools_StableFrameMixin.Save.showTexture

    WoWTools_TextureMixin:SetAlphaColor(StableFrameBg, nil, nil, show and 1 or 0.5)
    WoWTools_TextureMixin:SetNineSlice(StableFrame, true, nil, nil)

    WoWTools_TextureMixin:SetAlphaColor(StableFrame.Topper, nil, nil, show and 1 or 0)

    for _, object in pairs({StableFrame:GetRegions()}) do
        if object~=StableFrameBg and object:GetObjectType()=='Texture' then
            object:SetAlpha(show and 1 or 0)
        end
    end

    WoWTools_TextureMixin:SetAlphaColor(StableFrame.StabledPetList.Backgroud, nil, nil, show and 1 or 0)
    WoWTools_TextureMixin:SetAlphaColor(StableFrame.StabledPetList.Inset.Bg, nil, nil, show and 1 or 0)

    WoWTools_TextureMixin:SetSearchBox(StableFrame.StabledPetList.FilterBar.SearchBox)
    WoWTools_TextureMixin:SetScrollBar(StableFrame.StabledPetList)
    WoWTools_TextureMixin:SetMenu(StableFrame.PetModelScene.PetInfo.Specialization)
    WoWTools_TextureMixin:SetMenu(StableFrame.StabledPetList.FilterBar)

    WoWTools_TextureMixin:SetFrame(StableFrame.StabledPetList.ListCounter, {alpha=show and 1 or 0.8})
end









function WoWTools_StableFrameMixin:Init_UI()
    Init_UI()
    Init_Texture()
end

function WoWTools_StableFrameMixin:Set_UI_Texture()
    Init_Texture()
end