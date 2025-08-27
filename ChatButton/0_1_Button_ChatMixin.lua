local AddList={}--插件表，所有，选项用 {name=name, tooltip=tooltip})
local Buttons={}--存放所有, 按钮 {btn1, btn2,}
local ChatButton



local function Save()
    return WoWToolsSave['ChatButton'] or {}
end


local AnchorMenu={--菜单位置
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


    btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    function btn:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton"
    end

    hooksecurefunc(btn, 'OnMenuOpened', function(self)
        self:SetButtonState('PUSHED')
    end)

    hooksecurefunc(btn, 'OnMenuClosed', function(self)
        self:SetButtonState('NORMAL')
    end)


    function btn:set_state()
        self:SetButtonState(self:IsMouseOver() and 'PUSHED' or 'NORMAL')--self:IsMenuOpen()
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        ResetCursor()
        if not self.IsMainButton then
            self:GetParent():SetButtonState('NORMAL')
        end
        if self.set_OnLeave then
            self:set_OnLeave()
        end
        self:set_state()
    end)

    btn:SetScript('OnEnter', function(self)
        if self.set_tooltip then
            self:set_owner()
            self:set_tooltip()
        end

        if self.set_OnEnter then
            self:set_OnEnter()
        end

        if not self.IsMainButton then
            local p= self:GetParent()
            p:SetButtonState('PUSHED')
            if Save().isEnterShowMenu and not p:IsMenuOpen() and not self:IsMenuOpen() then
                self:OpenMenu()
            end
        end
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and self.set_OnMouseDown then
            if not self:set_OnMouseDown() then
                self:CloseMenu()
            end
            if self.set_tooltip then
                self:set_owner()
                self:set_tooltip()
                GameTooltip:Show()
            end
        end
    end)

--菜单，Tooltip, 位置
    function btn:set_anchor()
        local index= Save().anchorMenuIndex or 1
        self.menuAnchor= AnchorUtil.CreateAnchor(AnchorMenu[index][1], self, AnchorMenu[index][2])
    end

    function btn:set_owner()
        GameTooltip:SetOwner(self, AnchorTooltip[Save().anchorMenuIndex or 1])-- "ANCHOR_LEFT")
        GameTooltip:ClearLines()
    end

    btn:set_anchor()
end










function WoWTools_ChatMixin:Init()
    if not Save().disabled then
        ChatButton= WoWTools_ButtonMixin:Cbtn(nil, {
            name='WoWToolsChatButtonMainButton',
            icon='hide',
            frameType='DropdownButton',
        })

        ChatButton.IsMainButton=true
        Save().isShowBackground= nil

        --WoWTools_TextureMixin:CreateBG(ChatButton, {isColor=true})
        ChatButton.Background= ChatButton:CreateTexture(nil, 'BACKGROUND')
        ChatButton.Background:SetColorTexture(0,0,0)

        function ChatButton:set_backgroud()
            local btn1= _G[Buttons[1]]
            if not btn1 then
                return
            end

            local btn2= _G[Buttons[#Buttons]]

            self.Background:ClearAllPoints()

            self.Background:SetPoint('BOTTOMLEFT', btn1, -2, -2)

            local w= 30+4
            if Save().isVertical then
                self.Background:SetPoint('TOP', btn2, 0, 2)
                self.Background:SetWidth(w)
            else
                self.Background:SetPoint('LEFT', btn2, 2, 0)
                self.Background:SetHeight(w)
            end

            self.Background:SetAlpha(Save().bgAlpha or 0.5)
        end

        Set_Button_Script(ChatButton)

        self.ChatButton= ChatButton

        return ChatButton
    end
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
    WoWTools_ColorMixin:Setup(btn.border, {type='Texture', alpha= 0.3})

    btn:SetSize(30, 30)

    function btn:set_border_alpha()
        self.border:SetAlpha(Save().borderAlpha or 1)
    end

    function btn:set_point()
        local index= btn:GetID()

        self:ClearAllPoints()

        local size= index==1 and 0 or Save().pointX or 0

        if Save().isVertical then--方向, 竖
            self:SetPoint('BOTTOM', _G[Buttons[index-1]] or ChatButton, 'TOP', 0, size)
        else
            self:SetPoint('LEFT', _G[Buttons[index-1]] or ChatButton, 'RIGHT', size, 0)
        end
    end


--菜单，Tooltip, 位置
    Set_Button_Script(btn)


    btn:set_border_alpha()
    btn:set_point()
end













function WoWTools_ChatMixin:CreateButton(name, addName)
    if not ChatButton then
        return
    end

    table.insert(AddList, {name=name, tooltip=addName})--选项用

    if Save().disabledADD[name] then
        return
    end

    local btn= CreateFrame("DropdownButton", 'WoWToolsChatButton_'..name, ChatButton, nil, #Buttons+1)

    Set_Button(btn)

    ChatButton:set_backgroud()

    table.insert(Buttons, 'WoWToolsChatButton_'..name)

    return btn
end













function WoWTools_ChatMixin:Get_AnchorMenu()
    return AnchorMenu
end

function WoWTools_ChatMixin:GetAllAddList()
    return AddList
end

function WoWTools_ChatMixin:Set_All_Buttons(isPoint)
    for _, name in pairs(Buttons) do
        if isPoint then
            _G[name]:set_point()
        else
            _G[name]:set_border_alpha()
            _G[name]:set_anchor()
        end
    end
end

function WoWTools_ChatMixin:Open_SettingsPanel(root, name)
    return WoWTools_MenuMixin:OpenOptions(root, {category=self.Category, name=name or self.addName})
end
