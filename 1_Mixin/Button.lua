--[[
Cbtn(frame, tab)
CreateSecureButton(tab)
CreateMenu(frame, tab)

InterfaceOptionsCheckButtonTemplate
UICheckButtonArtTemplate
]]

WoWTools_ButtonMixin={}


local TemplateSizeTab={
    ['DropdownButton']= 23,
    ['ItemButton']=36,
    ['CheckButton']= 26,
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




--[[遮罩
UI-HUD-UnitFrame-Player-Portrait-Mask
]]
function WoWTools_ButtonMixin:AddMask(btn, isType2, region, atlas)
    if not btn then
        return
    end

    btn.IconMask= btn.IconMask or btn:CreateMaskTexture(nil, 'OVERLAY')

    if not isType2 then--方形，按钮
        btn.IconMask:SetAtlas(atlas or 'UI-HUD-CoolDownManager-Mask')--'spellbook-item-spellicon-mask'
        btn.IconMask:SetPoint('TOPLEFT', region or btn, 0.5, -0.5)
        btn.IconMask:SetPoint('BOTTOMRIGHT', region or btn, -0.5, 0.5)
    else--圆形，按钮
        btn.IconMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
        btn.IconMask:SetPoint("TOPLEFT", region or btn, 2, -2)
        btn.IconMask:SetPoint("BOTTOMRIGHT", region or btn, -2, 2)
    end

    local icon= region or btn.Icon or btn.icon or btn.texture or (btn.GetNormalTexture and btn:GetNormalTexture())
    if icon then
        icon:AddMaskTexture(btn.IconMask)
    end
end















local function On_Leave(self)
    GameTooltip_Hide()
    if self.set_alpha then
        self:set_alpha()
    end
end
local function On_Enter(self)
    if self.tooltip then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        if type(self.tooltip)=='function' then
            self:tooltip(GameTooltip)
        else
            GameTooltip:AddLine(self.tooltip)
        end
        GameTooltip:Show()
    end
    if self.set_alpha then
        self:set_alpha()
    end
end
local function On_Click(self, ...)
    if self.settings then
        self:settings(...)
    end
end




local function Set_CheckButton(btn, isRightText)
    function btn:SetText(...)
        self.Text:SetText(...)
    end
    function btn:GetText(...)
        self.Text:GetText(...)
    end

    btn:SetScript('OnLeave', function(...) On_Leave(...) end)
    btn:SetScript('OnEnter', function(...) On_Enter(...) end)
    btn:SetScript('OnMouseUp', function(...) On_Enter(...) end)
    btn:SetScript('OnClick', function(...) On_Click(...) end)

    if isRightText then
        btn.Text:ClearAllPoints()
        btn.Text:SetPoint('LEFT', btn, 'RIGHT', 2, 0)
        btn.Text:SetJustifyH('LEFT')
    end
end

--[[template
UIPanelCloseButton
]]
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
    local isBorder= not tab.notBorder and not isMenu
    local isLocked= not tab.notLocked
    local isTexture= tab.addTexture or (isType2 and not tab.notTexture)
    local useAtlasSize= tab.useAtlasSize and TextureKitConstants.UseAtlasSize or TextureKitConstants.IgnoreAtlasSize

    local isCheck= tab.isCheck
    local isRightText= tab.isRightText

    local isUI= tab.isUI

    local name= tab.name --or ((frame and frame:GetName() or 'WoWTools')..'Button'..get_index())

    local frameType= tab.frameType
                    or (isMenu and 'DropdownButton')
                    or (isItem and 'ItemButton')
                    or (isCheck and 'CheckButton')
                    or 'Button'
  --template
    local template= tab.template
            or (isSecure and 'SecureActionButtonTemplate')--SecureHandlerClickTemplate SecureHandlerTemplates.xml
            or (isUI and 'UIPanelButtonTemplate')
            or (isCheck and 'UICheckButtonTemplate')--32x32 UICheckButtonArtTemplate

                    --or (isType2 and isItem and 'CircularItemButtonTemplate')
    local width, height= get_size(tab.size, frameType)
    local setID= tab.setID




--提示，已存在
    if _G[name] and WoWTools_DataMixin.Player.husandro then
        print('Cbtn', '已存在', name)
    end

--建立
    local btn= tab.btn or CreateFrame(frameType, name, frame or UIParent, template, setID)

--设置 CheckButton
    if isCheck then
        Set_CheckButton(btn, isRightText)
    end

    if isTexture then
--添加，遮罩
        self:AddMask(btn, isType2)
        btn.texture=btn:CreateTexture(nil, 'BORDER')
--自定义，图标大小
        btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
        btn.texture:AddMaskTexture(btn.IconMask)
    end

--SetPushedAtlas, SetHighlightAtlas  
    local pushedAtlas= 'PetList-ButtonSelect'--'newplayertutorial-drag-cursor'--''--'auctionhouse-nav-button-select'
    local highlightAtlas= 'Forge-ColorSwatchSelection'--'PetList-ButtonHighlight'--'WoWShare-Highlight'-- ''--auctionhouse-nav-button-select'

--圆形，按钮
    if isType2 then
        pushedAtlas, highlightAtlas= 'bag-border-highlight', 'bag-border'
--添加 Border
        if isBorder then
            btn.border=btn:CreateTexture(nil, 'ARTWORK')
            btn.border:SetPoint('TOPLEFT', -1 ,1)
            btn.border:SetPoint('BOTTOMRIGHT', 1, -1)
            btn.border:SetAtlas('bag-reagent-border')
            WoWTools_TextureMixin:SetAlphaColor(btn.border, nil, nil, 0.3)
        end
--方形，按钮
    elseif atlas then
        if atlas:find('Cursor_OpenHand_(%d+)') then--提取(手)按钮
            highlightAtlas= 'Cursor_OpenHandGlow_'..atlas:match('Cursor_OpenHand_(%d+)')

        elseif atlas=='ui-questtrackerbutton-filter' then--菜单按钮
            pushedAtlas='ui-questtrackerbutton-filter-pressed'
            highlightAtlas= 'ui-questtrackerbutton-red-highlight'
        else
            self:AddMask(btn)
        end
    end
    if not isUI and not isCheck then
        btn:SetPushedAtlas(pushedAtlas)
        if isLocked then
            btn:SetHighlightAtlas(highlightAtlas)
        end
    end

--设置 Atlas or Texture    
    if btn.texture then
        if atlas then
            btn.texture:SetAtlas(atlas, useAtlasSize)
        elseif texture then
            btn.texture:SetTexture(texture)
        end
    elseif atlas then
        btn:SetNormalAtlas(atlas, useAtlasSize)
    elseif texture then
        btn:SetNormalTexture(texture)
    end

--遮罩
    if isMask or ((atlas or texture) and not pushedAtlas and not isType2) then
        self:AddMask(btn)
    end

--SetText

    if text and btn.SetText then
        btn:SetText(text)
    end

--alpha
    if alpha then
        btn:SetAlpha(alpha)
    end
--EnableMouseWheel
    if setWheel then
        btn:EnableMouseWheel(true)
    end

--设置大小
    btn:SetSize(width, height)


    if isMenu then
        btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    else
        btn:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    end

    if isCheck then
        WoWTools_TextureMixin:SetCheckBox(btn)
    elseif isUI then
        WoWTools_TextureMixin:SetUIButton(btn)
    end

    return btn
end






--[[
UIPanelIconDropdownButtonMixin
function UIPanelIconDropdownButtonMixin:OnMouseDown()
	self.Icon:AdjustPointsOffset(1, -1);
end
function UIPanelIconDropdownButtonMixin:OnMouseUp(button, upInside)
	self.Icon:AdjustPointsOffset(-1, 1);
end
]]
--菜单按钮 DropdownButtonMixin
function WoWTools_ButtonMixin:Menu(frame, tab)
    tab= tab or {}
    tab.isMenu=true

    if tab.isSetup then
        tab.template= 'UIPanelIconDropdownButtonTemplate'

    elseif tab.icon~='hide' and not tab.texture then
        tab.atlas= tab.atlas or 'ui-questtrackerbutton-filter'
    end

    local btn= self:Cbtn(frame, tab)

    if tab.atlas== 'ui-questtrackerbutton-filter' then
        WoWTools_TextureMixin:SetButton(btn)
    end

    btn:SetFrameLevel(math.min(frame:GetFrameLevel()+7, 10000))

    function btn:HandlesGlobalMouseEvent(_, event)
        return event == "GLOBAL_MOUSE_DOWN"-- and d=='RightButton'
    end

    return btn
end




