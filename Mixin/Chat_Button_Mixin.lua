local e= select(2, ...)

WoWToolsChatButtonMixin= {
    AddList={},--所有, 按钮 {name}=true
    DisabledAdd={},--禁用, 按钮 {name}=true
    isShowBackground=nil,--是否显示背景 bool

    Buttons={},--存放所有, 按钮 {btn1, btn2,}
    LastButton=nil,--最后, 按钮 btn
    numButton=0,--总数, 按钮 numberi

    isVertical=nil,--方向, 竖
}




function WoWToolsChatButtonMixin:Init(disableTab, save)
    self.ChatButton= e.Cbtn(nil, {name='WoWToolsChatButtonFrame', icon='hide'})
    
    self.isShowBackground= save.isShowBackground--是否显示背景 bool
    self.isVertical= save.isVertical--方向, 竖
    self.DisabledAdd= disableTab or {}--禁用, 按钮 {name}=true
    self.LastButton= self.ChatButton
     
    self.numButton=0--总数, 按钮 numberi
    self:SetChatButtonSize()

    return self.ChatButton
end



function WoWToolsChatButtonMixin:CreateButton(name, tooltip)
    table.insert(self.AddList, {name=name, tooltip=tooltip})

    if not self.ChatButton or self.DisabledAdd[name] then
        return
    end

    local btn= CreateFrame("Button", 'WoWToolsChatButton_'..name, self.ChatButton, nil, self.numButton+1)

    self:SetPoint(btn)

    btn:SetSize(30, 30)
    btn:RegisterForClicks('AnyDown')
    btn:SetPushedAtlas('bag-border-highlight')
    btn:SetHighlightAtlas('bag-border')

    btn.mask= btn:CreateMaskTexture()
    btn.mask:SetTexture('Interface\\CHARACTERFRAME\\TempPortraitAlphaMask')
    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)

    btn.background= btn:CreateTexture(nil, 'BACKGROUND')
    btn.background:SetAllPoints(btn)
    btn.background:SetAtlas('bag-reagent-border-empty')
    btn.background:SetAlpha(0.5)
    btn.background:AddMaskTexture(btn.mask)

    btn.texture=btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
    btn.texture:AddMaskTexture(btn.mask)

    btn.border=btn:CreateTexture(nil, 'ARTWORK')
    btn.border:SetAllPoints(btn)
    btn.border:SetAtlas('bag-reagent-border')

    e.Set_Label_Texture_Color(btn.border, {type='Texture', alpha= 0.3})

    function btn:state_enter(isSelf)
        local frame= isSelf and self or self:GetParent()
        frame:SetButtonState('PUSHED')
    end
    function btn:state_leave(isSelf)
        local frame= isSelf and self or self:GetParent()
        frame:SetButtonState('NORMAL')
    end

    table.insert(self.Buttons, btn)
    self.numButton= self.numButton+1
    self.LastButton= btn

    self:ShowBackgroud()
    return btn
end


function WoWToolsChatButtonMixin:SetPoint(btn)
    local id= btn:GetID()
    if self.H then
        btn:SetPoint('BOTTOM', id==1 and self.ChatButton or self.Buttons[id-1], 'TOP')        
    else
        btn:SetPoint('LEFT', id==1 and self.ChatButton or self.Buttons[id-1], 'RIGHT')
    end
end




function WoWToolsChatButtonMixin:SetChatButtonSize()
    if self.isVertical then
        self.ChatButton:SetSize(30,10)
    else
        self.ChatButton:SetSize(10,30)
    end
end


function WoWToolsChatButtonMixin:RestHV()--Horizontal and vertical
    self:SetChatButtonSize()
    for _, btn in pairt(self.Buttons) do
        btn:ClearAllPoint()
        self:SetPoint(btn)
    end
end


function WoWToolsChatButtonMixin:GetAllAddList()
    return self.AddList
end


function WoWToolsChatButtonMixin:ShowBackgroud()
    local btn= self.ChatButton
    if not btn then
        return
    end
    if self.isShowBackground then
        if not btn.Background then
            btn.Background= btn:CreateTexture(nil, 'BACKGROUND')
            btn.Background:SetPoint('BOTTOMLEFT', self.Buttons[1])
            btn.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
            btn.Background:SetAlpha(0.5)
        end
        btn.Background:SetPoint('TOPRIGHT', self.LastButton)
    end
    if btn.Background then
        btn.Background:SetShown(self.isShowBackground)
    end
end






