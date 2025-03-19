--local e= select(2, ...)

WoWTools_ChatButtonMixin= {
    AddList={},--所有, 按钮 {name}=true
    DisabledAdd={},--禁用, 按钮 {name}=true
    Save={},
    Buttons={},--存放所有, 按钮 {btn1, btn2,}
    LastButton=nil,--最后, 按钮 btn
    numButton=0,--总数, 按钮 numberi

}



function WoWTools_ChatButtonMixin:Init(disableTab, save)
    self.ChatButton= WoWTools_ButtonMixin:Cbtn(nil, {name='WoWToolsChatButtonMainButton'})
    self:SetSaveData(save)
    self.DisabledAdd= disableTab or {}--禁用, 按钮 {name}=true
    self.LastButton= self.ChatButton
    self.numButton=0--总数, 按钮 numberi
    self:SetChatButtonSize()

    return self.ChatButton
end

















function WoWTools_ChatButtonMixin:CreateButton(name, tooltip)
    table.insert(self.AddList, {name=name, tooltip=tooltip})

    if not self.ChatButton or self.DisabledAdd[name] then
        return
    end

    local btn= CreateFrame("DropdownButton", 'WoWToolsChatButton_'..name, self.ChatButton, nil, self.numButton+1)

    self:Set_Point(btn)

    btn:SetSize(30, 30)

    btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    function btn:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton";
    end

    function btn:set_state()
        self:SetButtonState(self:IsMenuOpen() and 'PUSHED' or 'NORMAL')
    end

    hooksecurefunc(btn, 'OnMenuOpened', function(frame)
        frame:SetButtonState('PUSHED')
    end)

    hooksecurefunc(btn, 'OnMenuClosed', function(frame)
        frame:SetButtonState('NORMAL')
    end)

    btn:SetScript('OnLeave', function(frame)
        GameTooltip:Hide()
        frame:GetParent():SetButtonState('NORMAL')
        if frame.set_OnLeave then
            frame:set_OnLeave()
        end
        frame:set_state()
    end)

    btn:SetScript('OnEnter', function(frame)
        frame:GetParent():SetButtonState('PUSHED')
        if frame.set_tooltip then
            frame:set_tooltip()
        end
        if frame.set_OnEnter then
            frame:set_OnEnter()
        end
        if self.Save.isEnterShowMenu then
            frame:OpenMenu()
        end
        --frame:set_state()
    end)

    btn:SetScript('OnMouseDown', function(frame, d)
        if d=='LeftButton' and frame.set_OnMouseDown then
            if not frame:set_OnMouseDown() then
                frame:CloseMenu()
            end
            if frame.set_tooltip then
                frame:set_tooltip()
            end
        end
    end)



    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')

    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4)

    btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(0.5)
    WoWTools_ColorMixin:Setup(btn.background, {type='Texture', alpha= 0.3})
    btn.background:AddMaskTexture(btn.mask)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)
    btn.border:SetAtlas('bag-reagent-border')
    --btn.border:AddMaskTexture(btn.mask)
    WoWTools_ColorMixin:Setup(btn.border, {type='Texture', alpha= 0.3})

    table.insert(self.Buttons, btn)
    self.numButton= self.numButton+1
    self.LastButton= btn
    self:ShowBackgroud()
    return btn
end










function WoWTools_ChatButtonMixin:Set_Point(btn)
    local id= btn:GetID()
    if self.Save.isVertical then--方向, 竖
        btn:SetPoint('BOTTOM', id==1 and self.ChatButton or self.Buttons[id-1], 'TOP')
    else
        btn:SetPoint('LEFT', id==1 and self.ChatButton or self.Buttons[id-1], 'RIGHT')
    end
end




function WoWTools_ChatButtonMixin:SetChatButtonSize()
    if self.Save.isVertical then--方向, 竖
        self.ChatButton:SetSize(30,10)
    else
        self.ChatButton:SetSize(10,30)
    end
end


function WoWTools_ChatButtonMixin:RestHV()--Horizontal and vertical
    self:SetChatButtonSize()
    for _, btn in pairs(self.Buttons) do
        btn:ClearAllPoints()
        self:Set_Point(btn)
    end
end

function WoWTools_ChatButtonMixin:GetHV()--方向, 竖
    return self.Save.isVertical
end

function WoWTools_ChatButtonMixin:GetAllAddList()
    return self.AddList
end


function WoWTools_ChatButtonMixin:ShowBackgroud()
    local btn= self.ChatButton
    if not btn then
        return
    end
    if self.Save.isShowBackground then--是否显示背景 bool
        if not btn.Background then
            btn.Background= btn:CreateTexture(nil, 'BACKGROUND')
            btn.Background:SetPoint('BOTTOMLEFT', self.Buttons[1])
            btn.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
            btn.Background:SetAlpha(0.5)
        end
        btn.Background:SetPoint('TOPRIGHT', self.LastButton)
    end
    if btn.Background then
        btn.Background:SetShown(self.Save.isShowBackground)
    end
end



function WoWTools_ChatButtonMixin:GetSaveData()
    return self.Save
end
function WoWTools_ChatButtonMixin:SetSaveData(save)
    self.Save= save or {}
end

