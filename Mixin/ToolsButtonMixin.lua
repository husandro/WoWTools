local e= select(2, ...)

WoWTools_ToolsButtonMixin={
    AddList={},--所有, 按钮 {name}=true
    Save={DisabledAdd={}},
    Buttons={},--存放所有, 按钮 {btn1, btn2,}
    last=nil,--最后, 按钮 btn

    index=0,
    line=1,

    leftIndex=0,
    rightIndex=0,

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
    self.Button.Frame:SetShown(save.show)

    self.last= self.Button
    return self.Button
end


function WoWTools_ToolsButtonMixin:GetName()
    return '|A:bag-border:0:0|aTools'
end

function WoWTools_ToolsButtonMixin:CreateButton(tab)
    local name= tab.name
    local tooltip= tab.tooltip
    local setParent= tab.setParent
    local point= tab.point
    local isNewLine= tab.isNewLine
    local isOnlyLine= tab.isOnlyLine
    local option= tab.option
    local disabledOptions= tab.disabledOptions

    if not disabledOptions then
        table.insert(self.AddList, {name=name, tooltip=tooltip, option=option})
    end

    if not self.Button or self.Save.DisabledAdd[name] then
        return
    end

    local btn= CreateFrame("Button", 'WoWTools_Tools_'..name, setParent and self.Button.Frame or self.Button, "SecureActionButtonTemplate")
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

    if point=='LEFT' then
        WoWTools_ToolsButtonMixin:SetLeftPoint(btn, isNewLine, isOnlyLine)

    elseif point=='BOTTOM' then
        btn.leftIndex= self.leftIndex
        do
            WoWTools_ToolsButtonMixin:SetBottomPoint(btn)
        end
        self.leftIndex= self.leftIndex+1

    elseif point=='RIGHT' then
        btn.rightIndex= self.rightIndex
        do
            WoWTools_ToolsButtonMixin:SetRightPoint(btn)
        end
        self.rightIndex= self.rightIndex+1
    end

    return btn
end









function WoWTools_ToolsButtonMixin:SetLeftPoint(btn, isNewLine, isOnlyLine)
    if (not isOnlyLine and (self.index>0 and select(2, math.modf(self.index / 10))==0)) or isNewLine then
        if isNewLine then--换行
            self.index=0
        end
        local x= - (self.line * 30)
        if self.line>0 then
            btn:SetPoint('BOTTOMRIGHT', self.Button , 'TOPRIGHT', x, 30)
        else
            btn:SetPoint('BOTTOMRIGHT', self.Button , 'TOPRIGHT', x, 0)
        end
        self.line=self.line + 1
    else
        btn:SetPoint('BOTTOMRIGHT', self.last , 'TOPRIGHT')
    end
    self.last=btn
    self.index=self.index+1
end

function WoWTools_ToolsButtonMixin:SetBottomPoint(btn)
    btn:SetPoint('BOTTOMRIGHT', self.Button, 'TOPLEFT', -(btn.leftIndex*30), 0)
end

function WoWTools_ToolsButtonMixin:SetRightPoint(btn)
    btn:SetPoint('BOTTOMLEFT', self.Button, 'TOPRIGHT', 0, (btn.rightIndex*30))
end





function WoWTools_ToolsButtonMixin:AddOptions(option)
    table.insert(self.AddList, {isOnlyOptions=true, option=option})
end

function WoWTools_ToolsButtonMixin:GetAllAddList()
    return self.AddList
end

--[[function WoWTools_ToolsButtonMixin:GetSaveData()
    return self.Save
end]]

function WoWTools_ToolsButtonMixin:SetSaveData(save)
    self.Save= save or {}
    self.Save.DisabledAdd= self.Save.DisabledAdd or {}
end

function WoWTools_ToolsButtonMixin:EnterShowFrame()
    if self.Button and self.Save.isEnterShow and not self.Button.Frame:IsShown() then
        self.Button:set_shown()
    end
end

function WoWTools_ToolsButtonMixin:GetButton()
    return self.Button
end


function WoWTools_ToolsButtonMixin:SetCategory(category, layout)
    self.Category= category
    self.Layout= layout
end

function WoWTools_ToolsButtonMixin:GetCategory()
    return self.Category, self.Layout
end

function WoWTools_ToolsButtonMixin:OpenOptions(name)
    if not self.Category then
        e.OpenPanelOpting()
    end
    e.OpenPanelOpting(self.Category, name)
end

function WoWTools_ToolsButtonMixin:OpenMenu(root, name)
    local sub=root:CreateButton('     '..(e.onlyChinese and '选项' or OPTIONS),
        function(data)
            self:OpenOptions(data)
            return MenuResponse.Open
        end, name)

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddLine(description.data or self:GetName())
        tooltip:AddLine(e.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'))
    end)
end

function WoWTools_ToolsButtonMixin:LoadedCollectionsJournal()
    if not CollectionsJournal then
        CollectionsJournal_LoadUI();
    end
end


--[[function WoWTools_ToolsButtonMixin:GetData(btn)
    GET_ITEM_INFO_RECEIVED: itemID, success
    SPELL_DATA_LOAD_RESULT: spellID, success
end]]