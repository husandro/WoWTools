local e= select(2, ...)
--[[
Cbtn(frame, tab)
Ctype2(frame, tab)--圆形按钮

CreateSecureButton(tab)
CreateMenu(frame, tab)
CreateOptionButton(frame, name, setID)

Settings(btn)
]]

WoWTools_ButtonMixin={}

local buttonIndex= 1
local function get_index()
    buttonIndex= buttonIndex+1
    return buttonIndex
end

local function get_size(value)
    local w, h
    local t= type(value)
    if t=='table' then
        w, h=value[1], value[2]
    elseif t=='number' then
        w, h= value, value
    end
    return w or 30, h or 30
end


local function SetType2Texture(btn)
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
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 3, -3)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 5)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)

    btn.border:SetAtlas('bag-reagent-border')

    WoWTools_ColorMixin:SetLabelTexture(btn.border, {type='Texture', alpha=0.3})
end



function WoWTools_ButtonMixin:SetPushedTexture(btn, isType2)
    if isType2 then
        btn:SetPushedAtlas('bag-border-highlight')
        btn:SetHighlightAtlas('bag-border')
    else
        btn:SetHighlightAtlas('auctionhouse-nav-button-select')--Forge-ColorSwatchSelection')
        btn:SetPushedAtlas('auctionhouse-nav-button-select')--UI-HUD-MicroMenu-Highlightalert')
    end
end


function WoWTools_ButtonMixin:Settings(btn, isType2)
    self:SetPushedTexture(btn, isType2)
    if isType2 then--圆形按钮
        SetType2Texture(btn)
    end
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
end


















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

    local btn= CreateFrame(frameType, name or ('WoWToolsToolsButton'..get_index()), frame or UIParent, template, setID)
    btn:SetSize(get_size(size))

    if template=='UIPanelButtonTemplate' then
        if text then btn:SetText(text) end
    else
        self:SetPushedTexture(btn, isType2)
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

--圆形按钮
function WoWTools_ButtonMixin:Ctype2(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size
    local template= tab.template--UIPanelButtonTemplate

    local btn= CreateFrame('Button', name or ('WoWToolsToolsButton'..get_index()), frame or UIParent, template, setID)
    btn:SetSize(get_size(size))
    self:Settings(btn, true)
    return btn
end

--安全按钮
function WoWTools_ButtonMixin:CreateSecureButton(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size

    local btn= CreateFrame("Button", name or ('WoWToolsSecureButton'..get_index()), frame or UIParent, "SecureActionButtonTemplate", setID)
    btn:SetSize(get_size(size))
    self:Settings(btn, true)
    return btn
end

--菜单按钮
function WoWTools_ButtonMixin:CreateMenu(frame, tab)
    tab= tab or {}

    local name= tab.name
    local setID= tab.setID
    local size= tab.size or 23
    local template= tab.template--UIPanelButtonTemplate
    local hideIcon= tab.hideIcon
    local isType2= tab.isType2--圆形按钮

    local btn= CreateFrame('DropdownButton', name or ('WoWToolsMenuButton'..get_index()), frame or UIParent, template, setID)
    btn:SetFrameStrata(frame:GetFrameStrata())
    btn:SetFrameLevel(frame:GetFrameLevel())
    btn:SetSize(get_size(size))
    self:Settings(btn, isType2)

    if not hideIcon then
        btn:SetNormalAtlas('ui-questtrackerbutton-filter')
        btn:SetPushedAtlas('ui-questtrackerbutton-filter-pressed')
        btn:SetHighlightAtlas('ui-questtrackerbutton-red-highlight')
    end
    return btn
end
--local btn=WoWTools_ButtonMixin:CreateMenu(OptionButton, {name=''})


--[[打开菜单按钮
function WoWTools_ButtonMixin:CreateOptionButton(frame, name, setID)
    local btn= CreateFrame("Button", name or ('WoWToolsOptionButton'..get_index()), frame or UIParent, nil, setID)--ObjectiveTrackerContainerFilterButtonTemplate
    btn:SetSize(23,23)
    btn:SetNormalAtlas('ui-questtrackerbutton-filter')
    btn:SetPushedAtlas('ui-questtrackerbutton-filter-pressed')
    btn:SetHighlightAtlas('ui-questtrackerbutton-red-highlight')
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
    return btn
end]]



--向上
function WoWTools_ButtonMixin:CreateUpButton(frame, name, setID)
    local btn= CreateFrame("Button", name or ('WoWToolsUpButton'..get_index()), frame or UIParent, nil, setID)--ObjectiveTrackerContainerFilterButtonTemplate
    btn:SetSize(23,23)
    btn:SetNormalAtlas('128-RedButton-ArrowUpGlow')
    btn:SetPushedAtlas('128-RedButton-ArrowUpGlow-Pressed')
    btn:SetHighlightAtlas('Callings-BackHighlight')
    btn:SetDisabledAtlas('128-RedButton-ArrowUpGlow-Disabled')
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
    return btn
end

--向下
function WoWTools_ButtonMixin:CreateDownButton(frame, name, setID)
    local btn= CreateFrame("Button", name or ('WoWToolsDownButton'..get_index()), frame or UIParent, nil, setID)--ObjectiveTrackerContainerFilterButtonTemplate
    btn:SetSize(23,23)
    btn:SetNormalAtlas('128-RedButton-ArrowDown')
    btn:SetPushedAtlas('128-RedButton-ArrowDown-Pressed')
    btn:SetHighlightAtlas('128-RedButton-ArrowDown-Highlight')
    btn:SetDisabledAtlas('128-RedButton-ArrowDown-Disabled')
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
    return btn
end


--[[拿取
function WoWTools_ButtonMixin:CreatePrendButton(frame, name, setID)
    local btn= CreateFrame("Button", name or ('WoWToolsPrendButton'..get_index()), frame or UIParent, nil, setID)--ObjectiveTrackerContainerFilterButtonTemplate
    btn:SetSize(23,23)
    btn:SetNormalAtlas('Cursor_OpenHandGlow_64')
    btn:SetPushedAtlas('Cursor_cast_64')
    btn:SetHighlightAtlas('auctionhouse-nav-button-select')
    btn:SetDisabledAtlas('Cursor_unableOpenHandGlow_64')
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)
    return btn
end]]








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

ObjectiveTrackerContainerFilterButtonTemplate
]]

