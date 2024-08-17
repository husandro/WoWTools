local e= select(2, ...)

WoWTools_ToolsButtonMixin={
    AddList={},--所有, 按钮 {name}=true
    Save={DisabledAdd={}},
    Buttons={},--存放所有, 按钮 {btn1, btn2,}
    last=nil,--最后, 按钮 btn

    index=0,
    line=1,

    leftIndex=0
}

function WoWTools_ToolsButtonMixin:Init(save)
    if save.disabled then
        return
    end

    self:SetSaveData(save)

    self.Button= e.Cbtn(nil, {name='WoWTools_ToolsButton', icon='hide', size={30, save.height or 10}})
    self.Button.texture=self.Button:CreateTexture(nil, 'BORDER')
    self.Button.texture:SetPoint('CENTER')
    self.Button.texture:SetSize(10,10)
    self.Button.texture:SetShown(save.showIcon)

    self.Button.texture:SetAtlas(e.Icon.icon)

    self.Button.Frame= CreateFrame('Frame', nil, self.Button)
    self.Button.Frame:SetAllPoints(self.Button)
    self.Button.Frame:Hide()

    

    self.last= self.Button
    return self.Button
end











function WoWTools_ToolsButtonMixin:CreateButton(name, tooltip, setParent, isLeftButton, line, unoLine)
    table.insert(self.AddList, {name=name, tooltip=tooltip})

    if not self.Button or self.Save.DisabledAdd[name] then
        return
    end

    local btn= CreateFrame("Button", name, setParent and self.Button.Frame or UIParent, "SecureActionButtonTemplate")
    btn:SetSize(30, 30)
    btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    btn:EnableMouseWheel(true)

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

    e.Set_Label_Texture_Color(btn.border, {type='Texture', 0.5})

    if not isLeftButton then
        WoWTools_ToolsButtonMixin:SetPoint(btn, line, unoLine)
    else
        btn.leftIndex= self.leftIndex
        do
            WoWTools_ToolsButtonMixin:SetLeftPoint(btn)
        end
        self.leftIndex= self.leftIndex+1
    end

    return btn
end









function WoWTools_ToolsButtonMixin:SetPoint(btn, line, unoLine)
    if (not unoLine and self.index>0 and select(2, math.modf(self.index / 10))==0) or line then
        local x= - (self.line * 30)
        btn:SetPoint('BOTTOMRIGHT', self.Button , 'TOPRIGHT', x, 0)
        self.line=self.line + 1
        if line then
            self.index=0
        end
    else
        btn:SetPoint('BOTTOMRIGHT', self.last , 'TOPRIGHT')
    end
    self.last=btn
    self.index=self.index+1
end

function WoWTools_ToolsButtonMixin:SetLeftPoint(btn)
    btn:SetPoint('BOTTOMRIGHT', self.Button, 'TOPLEFT', -(btn.leftIndex*30), 0)
end

function WoWTools_ToolsButtonMixin:GetAllAddList()
    return self.AddList
end

function WoWTools_ToolsButtonMixin:GetSaveData()
    return self.Save
end

function WoWTools_ToolsButtonMixin:SetSaveData(save)
    self.Save= save or {}
    self.Save.DisabledAdd= self.Save.DisabledAdd or {}
end

--[[function WoWTools_ChatButtonMixin:SetCategory(category)
    self.Category= category
end

function WoWTools_ChatButtonMixin:GetCategory()
    return self.Category
end]]

function WoWTools_ToolsButtonMixin:EnterShowFrame()
    if self.Button and self.Save.isEnterShow and not self.Button.Frame:IsShown() then
        self.Button:set_shown()
    end
end

function WoWTools_ToolsButtonMixin:GetButton()
    return self.Button
end