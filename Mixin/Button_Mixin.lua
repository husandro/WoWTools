local e= select(2, ...)
--[[
CreateSecureButton(tab)
CreateMenuButton(tab)
Settings(btn)
]]

WoWTools_ButtonMixin={}
local buttonIndex= 1

function WoWTools_ButtonMixin:Cbtn(frame, tab)
    tab=tab or {}

    local frameType= tab.button or 'Button'
    local name= tab.name
    local setID= tab.setID
    local size= tab.size or (frameType=='ItemButton' and 34)
    local isType2= tab.isType2--true, 圆形按钮
    local icon= tab.icon--'hide', false, true
    local texture= tab.texture
    local atlas= tab.atlas
    local text= tab.text--仅限 UIPanelButtonTemplate
    local alpha= tab.alpha

    local template
    if tab.type==false then
        template= 'UIPanelButtonTemplate'
    elseif tab.type==true then
        template= 'SecureActionButtonTemplate'
    end
    template= template or tab.type

    local btn= CreateFrame(frameType, name or ('WoWToolsToolsButton'..self:GetIndex()), frame or UIParent, template, setID)
    btn:SetSize(self:GetSize(size))
    if template=='UIPanelButtonTemplate' then
        if text then btn:SetText(text) end
    else
        self:SetTexture(btn, isType2)
        if icon~='hide' then
            if texture then
                btn:SetNormalTexture(texture)
            elseif atlas then
                btn:SetNormalAtlas(atlas)
            elseif icon==true then
                btn:SetNormalAtlas(e.Icon.icon)
            else
                btn:SetNormalAtlas(e.Icon.disabled)
            end
        end
    end

    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)

    if alpha then btn:SetAlpha(alpha) end
    return btn, template
end



function WoWTools_ButtonMixin:Ctype2(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size
    local template= tab.template--UIPanelButtonTemplate

    local btn= CreateFrame('Button', name or ('WoWToolsToolsButton'..self:GetIndex()), frame or UIParent, template, setID)
    btn:SetSize(self:GetSize(size))
    self:Settings(btn, true)
end


function WoWTools_ButtonMixin:CreateSecureButton(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size

    local btn= CreateFrame("Button", name or ('WoWToolsToolsButton'..self:GetIndex()), frame or UIParent, "SecureActionButtonTemplate", setID)
    btn:SetSize(self:GetSize(size))
    self:Settings(btn, true)
    return btn
end


function WoWTools_ButtonMixin:CreateMenuButton(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size
    local template= tab.template--UIPanelButtonTemplate

    local btn= CreateFrame('DropdownButton', name or ('WoWToolsToolsButton'..self:GetIndex()), frame or UIParent, template, setID)
    btn:SetSize(self:GetSize(size))
    self:Settings(btn, true)
    return btn
end























function WoWTools_ButtonMixin:Settings(btn, isType2)
    self:SetTexture(btn, isType2)
    if isType2 then--圆形按钮
        self:SetType2Texture(btn)
    end
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
end

function WoWTools_ButtonMixin:SetTexture(btn, isType2)
    if isType2 then
        btn:SetPushedAtlas('bag-border-highlight')
        btn:SetHighlightAtlas('bag-border')
    else
        btn:SetHighlightAtlas('auctionhouse-nav-button-select')--Forge-ColorSwatchSelection')
        btn:SetPushedAtlas('auctionhouse-nav-button-select')--UI-HUD-MicroMenu-Highlightalert')
    end
end



function WoWTools_ButtonMixin:SetType2Texture(btn)
    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)

    btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(0.3)
    btn.background:AddMaskTexture(btn.mask)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)

    btn.border:SetAtlas('bag-reagent-border')

    e.Set_Label_Texture_Color(btn.border, {type='Texture', alpha=0.3})
end



function WoWTools_ButtonMixin:GetIndex()
    buttonIndex= buttonIndex+1
    return buttonIndex
end


function WoWTools_ButtonMixin:GetSize(value)
    local w, h
    local t= type(value)
    if t=='table' then
        w, h=value[1], value[2]
    elseif t=='number' then
        w, h= value, value
    end
    return w or 30, h or 30
end

--[[SharedUIPanelTemplates.xml
SecureTemplates
SecureActionButtonTemplate	Button	Perform protected actions.
SecureUnitButtonTemplate	Button	Unit frames.
SecureAuraHeaderTemplate	Frame	Managing buffs and debuffs.
SecureGroupHeaderTemplate	Frame	Managing group members.
SecurePartyHeaderTemplate	Frame	Managing party members.
SecureRaidGroupHeaderTemplate	Frame	Managing raid group members.
SecureGroupPetHeaderTemplate	Frame	Managing group pets.
SecurePartyPetHeaderTemplate	Frame	Managing party pets.
SecureRaidPetHeaderTemplate
btn:RegisterForClicks("AnyDown", "AnyUp")
]]

