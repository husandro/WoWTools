--local e= select(2, ...)

local AddList={}--插件表，所有，选项用 {name=name, tooltip=tooltip})
local Buttons={}--存放所有, 按钮 {btn1, btn2,}
local ChatButton

local function Save()
    return WoWTools_ChatMixin.Save
end







function WoWTools_ChatMixin:Init()
    if not self.Save.disabled then
        ChatButton= WoWTools_ButtonMixin:Cbtn(nil, {
            name='WoWToolsChatButtonMainButton',
            icon='hide',
            frameType='DropdownButton',
        })

        ChatButton.Background= ChatButton:CreateTexture(nil, 'BACKGROUND')
        ChatButton.Background:SetPoint('BOTTOMLEFT', Buttons[1])
        ChatButton.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
        --ChatButton.Background:SetAlpha(0.7)

        function ChatButton:set_backgroud()
            self.Background:SetPoint('BOTTOMLEFT', Buttons[1])
            self.Background:SetPoint('TOPRIGHT', Buttons[#Buttons])
            self.Background:SetShown(Save().isShowBackground)
        end

        self.ChatButton= ChatButton


        return ChatButton
    end
end












local function Set_Button(btn)
    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')

    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4)

    --[[btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(0.5)
    WoWTools_ColorMixin:Setup(btn.background, {type='Texture', alpha= 0.3})
    btn.background:AddMaskTexture(btn.mask)]]

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)
    btn.border:SetAtlas('bag-reagent-border')
    --btn.border:AddMaskTexture(btn.mask)
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
            self:SetPoint('BOTTOM', Buttons[index-1] or ChatButton, 'TOP', 0, size)
        else
            self:SetPoint('LEFT', Buttons[index-1] or ChatButton, 'RIGHT', size, 0)
        end
    end

    btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    function btn:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton";
    end

    function btn:set_state()
        self:SetButtonState(self:IsMenuOpen() and 'PUSHED' or 'NORMAL')
    end

    hooksecurefunc(btn, 'OnMenuOpened', function(self)
        self:SetButtonState('PUSHED')
    end)

    hooksecurefunc(btn, 'OnMenuClosed', function(self)
        self:SetButtonState('NORMAL')
    end)

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:GetParent():SetButtonState('NORMAL')
        if self.set_OnLeave then
            self:set_OnLeave()
        end
        self:set_state()
    end)

    btn:SetScript('OnEnter', function(self)
        self:GetParent():SetButtonState('PUSHED')
        if self.set_tooltip then
            self:set_tooltip()
        end
        if self.set_OnEnter then
            self:set_OnEnter()
        end
        if Save().isEnterShowMenu and not ChatButton:IsMenuOpen() and not self:IsMenuOpen() then
            self:OpenMenu()
        end
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' and self.set_OnMouseDown then
            if not self:set_OnMouseDown() then
                self:CloseMenu()
            end
            if self.set_tooltip then
                self:set_tooltip()
            end
        end
    end)

    btn:set_border_alpha()
    btn:set_point()
end













function WoWTools_ChatMixin:CreateButton(name, addName)
    table.insert(AddList, {name=name, tooltip=addName})--选项用

    if not ChatButton or self.Save.disabledADD[name] then
        return
    end

    local btn= CreateFrame("DropdownButton", 'WoWToolsChatButton_'..name, ChatButton, nil, #Buttons+1)

    Set_Button(btn)

    table.insert(Buttons, btn)

    ChatButton:set_backgroud()

    return btn
end
















function WoWTools_ChatMixin:GetAllAddList()
    return AddList
end

function WoWTools_ChatMixin:Get_All_Buttons()
    return Buttons
end

function WoWTools_ChatMixin:Open_SettingsPanel(root, name)
    WoWTools_MenuMixin:OpenOptions(root, {category=self.Category, name=name or self.addName})
end