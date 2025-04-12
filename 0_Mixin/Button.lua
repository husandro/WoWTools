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


local TemplateSizeTab={
    ['DropdownButton']= 23,
    ['ItemButton']=36,
}


local function get_size(value, template)
    local w, h
    local t= type(value)
    if t=='table' then
        w, h=value[1], value[2]
    elseif t=='number' then
        w, h= value, value
    end
    w=w or TemplateSizeTab[template] or 30
    h=h or TemplateSizeTab[template] or 30
    return w, h
end



--[[ItemButton ItemButtonTemplate.xml
CircularItemButtonTemplate 圆
CircularGiantItemButtonTemplate 大圆 <Size x="54" y="54"/>
GiantItemButtonTemplate <Size x="54" y="54"/>
LargeItemButtonTemplate <Size x="147" y="41" /> 
SmallItemButtonTemplate <Size x="134" y="30"/>
<CheckButton name="SimplePopupButtonTemplate Size x="36" y="36"/>


ItemButtonTemplate.xml
]]
--遮罩
function WoWTools_ButtonMixin:Mask(btn)

    btn.mask= btn.mask or btn:CreateMaskTexture()
    btn.mask:SetAtlas(CooldownViewerEssentialItemMixin and 'UI-HUD-CoolDownManager-Mask' or 'UI-HUD-ActionBar-IconFrame-Background')
    btn.mask:SetPoint('TOPLEFT', btn, 0.5, -0.5)
    btn.mask:SetPoint('BOTTOMRIGHT', btn, -0.5, 0.5)
    local icon= btn:GetNormalTexture()
    if icon then
        icon:AddMaskTexture(btn.mask)
    end
end


function WoWTools_ButtonMixin:Cbtn(frame, tab)
    tab= tab or {}
    local text= tab.text
    local alpha= tab.alpha
    local setWheel= not tab.notWheel
    local atlas, texture= tab.atlas, tab.texture

    local isMenu= tab.isMenu or tab.frameType=='DropdownButton'
    local isItem= tab.isItem
    local isSecure= tab.isSecure
    local isType2= tab.isType2
    local isMask= tab.isMask

    local name= tab.name or ('WoWToolsMenuButton'..get_index())
    local frameType= tab.frameType
                    or (isMenu and 'DropdownButton')
                    or (isItem and 'ItemButton')
                    or 'Button'
    local template= tab.template
                    or (isSecure and 'SecureActionButtonTemplate')
                    or (tab.isUI and 'UIPanelButtonTemplate')
                    --or (isType2 and isItem and 'CircularItemButtonTemplate')
    local width, height= get_size(tab.size, frameType)
    local setID= tab.setID
    

--提示，已存在
    if _G[name] and WoWTools_DataMixin.Player.husandro then
        print('Cbtn', '已存在', name)
    end

--建立
    local btn= CreateFrame(frameType, name, frame or UIParent, template, setID)

--圆形按钮
    
    if isType2 then
        btn.mask= btn:CreateMaskTexture()
        btn.mask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml

        btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
        btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
 

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
        else
            self:Mask(btn)
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
    elseif atlas then
        btn:SetNormalAtlas(atlas)
    elseif texture then
        btn:SetNormalTexture(texture)       
    end

--设置大小
    btn:SetSize(width, height)

--RegisterForMouse , RegisterForClicks
    if isMenu then
        btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    else
        btn:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
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

--遮罩
    if isMask or ((atlas or texture) and not pushedAtlas and not isType2) then
        self:Mask(btn)
    end
    return btn
end







--菜单按钮 DropdownButtonMixin
function WoWTools_ButtonMixin:Menu(frame, tab)
    tab= tab or {}
    tab.isMenu=true

    if tab.icon~='hide' then
        tab.atlas= tab.atlas or 'ui-questtrackerbutton-filter'
    end

    local btn= self:Cbtn(frame, tab)

    if tab.atlas== 'ui-questtrackerbutton-filter' then
        WoWTools_ColorMixin:Setup(btn, {alpha=1, type='Button'})
    end

    btn:SetFrameLevel(frame:GetFrameLevel()+7)

    function btn:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and d=='RightButton'
    end

    return btn
end
--[[
    function btn:HandlesGlobalMouseEvent(buttonName, event)
        print(buttonName == self.ShowMenuButton)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName=='RightButton'
    end
]]