local e= select(2, ...)
--[[
Cbtn(frame, tab)
CreateSecureButton(tab)
CreateMenu(frame, tab)
]]

WoWTools_ButtonMixin={}

local buttonIndex= 1
local function get_index()
    buttonIndex= buttonIndex+1
    return buttonIndex
end

local function get_size(value, isMenu)
    local w, h
    local t= type(value)
    if t=='table' then
        w, h=value[1], value[2]
    elseif t=='number' then
        w, h= value, value
    end
    w=w or (isMenu and 23) or 30
    h=h or (isMenu and 23) or 30
    return w, h
end

function WoWTools_ButtonMixin:Cbtn(frame, tab)
    local text= tab.text
    local alpha= tab.alpha
    local setWheel= not tab.notWheel
    local atlas, texture= tab.atlas, tab.texture
    local isMenu= tab.isMenu or tab.frameType=='DropdownButton'
    local width, height= get_size(tab.size, isMenu)
    local isSecure= tab.isSecure

    local name= tab.name or ('WoWToolsMenuButton'..get_index())
    local frameType= tab.frameType
                    or (isMenu and 'DropdownButton')
                    or 'Button'
    local template= tab.template
                    or (isSecure and 'SecureActionButtonTemplate')
                    or (tab.isUI and 'UIPanelButtonTemplate')

    local setID= tab.setID
    local isType2= tab.isType2

--提示，已存在
    if _G[name] and e.Player.husandro then
        print('Cbtn', '已存在', name)
    end

--建立
    local btn= CreateFrame(frameType, name, frame or UIParent, template, setID)

--圆形按钮
    if isType2 then
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
        btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0,0)
        btn.texture:AddMaskTexture(btn.mask)

        btn.border=btn:CreateTexture(nil, 'ARTWORK')
        btn.border:SetAllPoints(btn)

        btn.border:SetAtlas('bag-reagent-border')
        WoWTools_ColorMixin:Setup(btn.border, {type='Texture', alpha=0.3})
    end

--SetPushedAtlas, SetHighlightAtlas  
    local pushedAtlas= 'auctionhouse-nav-button-select'
    local highlightAtlas= 'auctionhouse-nav-button-select'

    if isType2 then
        pushedAtlas, highlightAtlas= 'bag-border-highlight', 'bag-border'
        
    elseif atlas then
        if atlas:find('Cursor_OpenHand_(%d+)') then--提取(手)按钮
            highlightAtlas= 'Cursor_OpenHandGlow_'..atlas:match('Cursor_OpenHand_(%d+)')

        elseif atlas=='ui-questtrackerbutton-filter' then--菜单按钮
            pushedAtlas='ui-questtrackerbutton-filter-pressed'
            highlightAtlas= 'ui-questtrackerbutton-red-highlight'
        end
    end
    btn:SetPushedAtlas(pushedAtlas)
    btn:SetHighlightAtlas(highlightAtlas)



--设置 Atlas or Texture    
    if isType2 then
        if atlas then
            btn.texture:SetAtlas(atlas)
        elseif texture then
            btn.texture:SetTexture(texture)
        end
    else
        if atlas then
            btn:SetNormalAtlas(atlas)
        elseif texture then
            btn:SetNormalTexture(texture)
        end
    end

--设置大小
    btn:SetSize(width, height)

--RegisterForMouse , RegisterForClicks
    if isMenu then
        btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    else
        btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    end

--EnableMouseWheel
    if setWheel then
        btn:EnableMouseWheel(true)
    end

--SetText
    if text and btn.SetText then
        btn:SetText(text)
    end

--alpha
    if alpha then
        btn:SetAlpha(alpha)
    end
    return btn
end







--菜单按钮 DropdownButtonMixin
function WoWTools_ButtonMixin:CreateMenu(frame, tab)
    tab= tab or {}
    tab.isMenu=true
    
    local hideIcon= tab.icon=='hide'

    if tab.icon~='hide' then
        tab.atlas= tab.atlas or 'ui-questtrackerbutton-filter'
    end


    local btn= self:Cbtn(frame, tab)

    if tab.atlas== 'ui-questtrackerbutton-filter' then
        WoWTools_ColorMixin:Setup(btn, {alpha=1, type='Button'})
    end
    --btn:SetFrameLevel(frame:GetFrameLevel()+7)
    
    function btn:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and buttonName == "RightButton";
    end

    return btn
end

--[[
local btn=WoWTools_ButtonMixin:CreateMenu(OptionButton, {
    name='',
    isType2=true
})
]]

