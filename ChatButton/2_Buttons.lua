local AddList={}--插件表，所有，选项用 {name=name, tooltip=tooltip})
local Buttons={}--存放所有, 按钮 {btn1, btn2,}
--RaidButton.canOpenOnEnter
local Name= 'WoWToolsChatMenuButton_'


local function Save()
    return WoWToolsSave['ChatButton'] or {}
end


WoWTools_ChatMixin.AnchorMenuTab={--菜单位置
        {"TOPLEFT",  "BOTTOMLEFT"},--下
        {"BOTTOMLEFT",  "TOPLEFT"},--上
        {"TOPRIGHT",  "TOPLEFT"},--左
        {"TOPLEFT",  "TOPRIGHT"},--右
    }
local AnchorTooltip={
    'ANCHOR_LEFT',
    'ANCHOR_LEFT',
    'ANCHOR_LEFT',
    'ANCHOR_RIGHT',
}

local function Set_Button_Script(btn)
    function btn:set_state()
        self:SetButtonState(self:IsMouseOver() and 'PUSHED' or 'NORMAL')--self:IsMenuOpen()
    end

    function btn:set_owner()
        GameTooltip:SetOwner(self, AnchorTooltip[Save().anchorMenuIndex or 1])-- "ANCHOR_LEFT")
        GameTooltip:ClearLines()
    end

    function btn:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton"
    end

    WoWTools_DataMixin:Hook(btn, 'OnMenuOpened', function(self)
        self:SetButtonState('PUSHED')
    end)

    WoWTools_DataMixin:Hook(btn, 'OnMenuClosed', function(self)
        self:SetButtonState('NORMAL')
    end)

    btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        ResetCursor()
        if self.border then
            self:GetParent():SetButtonState('NORMAL')
        end
        if self.set_OnLeave then
            self:set_OnLeave()
        end
        self:set_state()
    end)

    btn:SetScript('OnEnter', function(self)
        if self.set_tooltip and not Save().disabledTooltiip then
            self:set_owner()
            self:set_tooltip()
        end

        if self.set_OnEnter then
            self:set_OnEnter()
        end

        if self.border then
            local p= self:GetParent()
            p:SetButtonState('PUSHED')
            if Save().isEnterShowMenu and not p:IsMenuOpen() and not self:IsMenuOpen() then
                self:OpenMenu()
            end
        end
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then--and self.set_OnMouseDown then
            if self.set_OnMouseDown then
                self:set_OnMouseDown()
            end

            if self.set_tooltip and not Save().disabledTooltiip then
                self:set_owner()
                self:set_tooltip()
                GameTooltip:Show()
            end

            self:CloseMenu()
        end
    end)
end
















local function Set_Button(btn)
    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')

    btn.IconMask= btn:CreateMaskTexture()
    btn.IconMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.IconMask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)
    btn.border:SetAtlas('bag-reagent-border')
    WoWTools_TextureMixin:SetAlphaColor(btn.border, nil, nil, 0.3)

    btn:SetSize(30, 30)

    function btn:SetAllSettings()
        local index= btn:GetID()
        local s= index==1 and 0 or Save().pointX or 0

        self:ClearAllPoints()

        local parent=  Buttons[index-1] and _G[Name..Buttons[index-1]] or _G['WoWToolsChatButtonMainButton']
        if Save().isVertical then--方向, 竖
            self:SetPoint('BOTTOM', parent, 'TOP', 0, s)
        else
            self:SetPoint('LEFT', parent, 'RIGHT', s, 0)
        end

        local point= WoWTools_ChatMixin.AnchorMenuTab[Save().anchorMenuIndex or 1]
        self:SetMenuAnchor(AnchorUtil.CreateAnchor(point[1], self, point[2]))

        self.border:SetAlpha(Save().borderAlpha or 0.3)
    end


--菜单，Tooltip, 位置
    Set_Button_Script(btn)
    btn:SetAllSettings()
end













function WoWTools_ChatMixin:CreateButton(name, addName)
    if not _G['WoWToolsChatButtonMainButton'] then
        return
    end

    table.insert(AddList, {name=name, tooltip=addName})--选项用

    if Save().disabledADD[name] then
        return
    end

    local btn= CreateFrame("DropdownButton", Name..name, _G['WoWToolsChatButtonMainButton'], nil, #Buttons+1)

    table.insert(Buttons, name)

    Set_Button(btn)

    _G['WoWToolsChatButtonMainButton']:set_backgroud()

    return btn
end










function WoWTools_ChatMixin:Set_Button_Script(btn)
    Set_Button_Script(btn)
end

function WoWTools_ChatMixin:GetNameText()
    return Name
end

function WoWTools_ChatMixin:GetButtons()
    return Buttons
end

function WoWTools_ChatMixin:GetAllAddList()
    return AddList
end

function WoWTools_ChatMixin:Open_SettingsPanel(root, name)
    return WoWTools_MenuMixin:OpenOptions(root, {
        category=self.Category,
        name=name or self.addName
    })
end
function WoWTools_ChatMixin:GetButtonForName(name)
    return _G[Name..name]
end