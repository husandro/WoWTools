local e= select(2, ...)

WoWTools_ToolsButtonMixin={
    AddList={},--所有, 按钮 {name}=true
    Save={disabledADD={}, lineNum=10, isHideBackground=nil},

    LeftButtons={},--按钮 {btn1, btn2,}
    BottomButtons={},
    OnlyLineButtons={},
    leftNewLineButton=nil,
}

function WoWTools_ToolsButtonMixin:SetBackground(frame, texture, isClear)
    if not texture then
        texture=frame:CreateTexture(nil, 'BACKGROUND')
        texture:SetAlpha(0.5)
    end
    if isClear then
        texture:SetTexture(0)
    else
        texture:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
    end
    return texture
end

function WoWTools_ToolsButtonMixin:Init(save)
    if save.disabled then
        return
    end

    self:SetSaveData(save)

    self.Button= e.Cbtn(nil, {name='WoWTools_ToolsButton', icon='hide', size={30, save.height or 10}})

    self.Button.Frame= CreateFrame('Frame', nil, self.Button)
    self.Button.Frame:SetAllPoints(self.Button)
    self.Button.Frame:SetShown(save.show)

    self.Button.texture=self.Button:CreateTexture(nil, 'BORDER')
    self.Button.texture:SetPoint('CENTER')
    self.Button.texture:SetSize(10,10)
    self.Button.texture:SetShown(save.showIcon)
    self.Button.texture:SetAtlas(e.Icon.icon)

    --需要，设置高 宽， TOP LEFT
    self.Button.LeftBG=self:SetBackground(self.Button.Frame, nil, self.Save.isHideBackground)
    self.Button.LeftBG:SetPoint('BOTTOMRIGHT', self.Button, 'TOPRIGHT', 0, 30)
    self.Button.LeftBG:SetPoint('TOPRIGHT', self.Button, 0, 60)
    self.Button.LeftBG:SetPoint('LEFT', self.Button, -30, 0)

    
    --需要，设置高 TOP
    self.Button.OnlyBG=self:SetBackground(self.Button, nil, self.Save.isHideBackground)
    self.Button.OnlyBG:SetPoint('BOTTOMRIGHT', self.Button.BG2, 'BOTTOMLEFT')
    self.Button.OnlyBG:SetWidth(30)

    --需要，设置宽 LEFT
    self.Button.BottomBG=self:SetBackground(self.Button, nil, self.Save.isHideBackground)
    self.Button.BottomBG:SetPoint('BOTTOMRIGHT', self.Button, 'TOPRIGHT')
    self.Button.BottomBG:SetHeight(30)




    self.last= self.Button
    return self.Button
end

--function WoWTools_ToolsButtonMixin:SetPoint_BG1(btn)



function WoWTools_ToolsButtonMixin:GetName()
    return '|A:Professions-Crafting-Orders-Icon:0:0|aTools'
end

--[[
WoWTools_ToolsButtonMixin:CreateButton({
    name=,
    point='LEFT',
    isOnlyLine=false,

    option=funciton()end,
    disabledOptions=false,
    tooltip=nil,

}
]]




function WoWTools_ToolsButtonMixin:Create(tab)
    local btn= CreateFrame("Button", 'WoWTools_Tools_'..tab.name, tab.parent or (tab.point=='LEFT' and self.Button.Frame) or self.Button, "SecureActionButtonTemplate")
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
    return btn
end
--[[
WoWTools_ToolsButtonMixin:Create({
name='',
parent=nil,--Frame or UIPrent
point=nil,--LEFT BOTTOM
})
]]


function WoWTools_ToolsButtonMixin:CreateButton(tab)
    --local name= tab.name
    --local tooltip= tab.tooltip
    --local setParent= tab.setParent
    --local point= tab.point
    --local isNewLine= tab.isNewLine
    --local isOnlyLine= tab.isOnlyLine
    --local option= tab.option
    --local disabledOptions= tab.disabledOptions

    if not tab.disabledOptions then
        table.insert(self.AddList, tab)
    end
    if not self.Button or self.Save.disabledADD[tab.name] then
        return
    end   
    local btn= self:Create(tab)
    WoWTools_ToolsButtonMixin:SetPoint(btn, tab)
    return btn
end
    --[[if point=='LEFT' then
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
    end]]


function WoWTools_ToolsButtonMixin:SetPoint(btn, tab)
    if tab.point=='BOTTOM' then
        local num=#self.BottomButtons
        if num==0 then
            btn:SetPoint('BOTTOM', self.Button, 'TOP')
        else
            btn:SetPoint('RIGHT', self.BottomButtons[num], 'LEFT')
        end
        self.Button.BottomBG:SetPoint('LEFT', btn)--需要，设置宽 LEFT

        

        table.insert(self.BottomButtons, btn)

    else
        if tab.isOnlyLine then
            local num= #self.OnlyLineButtons
            if num==0 then
                btn:SetPoint('BOTTOMRIGHT', self.Button.LeftBG, 'BOTTOMLEFT')
            else
                btn:SetPoint('BOTTOM', self.BottomButtons[num], 'TOP')
            end
            self.Button.OnlyBG:SetPoint('TOP', btn)
            table.insert(self.OnlyLineButtons, btn)

        else
            local num=#self.LeftButtons
            if num==0 then
                btn:SetPoint('BOTTOM', self.Button, 'TOP', 0, 30)
                self.leftNewLineButton=btn
                self.Button.LeftBG:SetPoint('TOP', btn)
                self.Button.LeftBG:SetPoint('LEFT', btn)
            else
                local numLine= self.Save.lineNum or 10
                if select(2, math.modf(num / numLine))==0 then
                    btn:SetPoint('LEFT', self.leftNewLineButton, 'RIGHT')
                    self.Button.LeftBG:SetPoint('LEFT', btn)
                    self.leftNewLineButton=btn
                else
                    btn:SetPoint('BOTTOM', self.LeftButtons[num], 'TOP')
                    self.Button.LeftBG:SetPoint('TOP', btn)
                end
            end
            table.insert(self.LeftButtons, btn)
        end
    end

end



--[[
function WoWTools_ToolsButtonMixin:SetBottomPoint(btn)---按钮，放在下面一行
    btn:SetPoint('BOTTOMRIGHT', self.Button, 'TOPLEFT', -(btn.leftIndex*30), 0)
end

function WoWTools_ToolsButtonMixin:SetRightPoint(btn)--按钮，放在右边
    btn:SetPoint('BOTTOMLEFT', self.Button, 'TOPRIGHT', 0, (btn.rightIndex*30))
end

function WoWTools_ToolsButtonMixin:SetLeftPoint(btn, isNewLine, isOnlyLine)--按钮，放在左边
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
end]]


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



function WoWTools_ToolsButtonMixin:EnterShowFrame()--当Enter图标是，显示Tools Frame
    if self.Button and self.Save.isEnterShow and not self.Button.Frame:IsShown() then
        self.Button:set_shown()
    end
end


function WoWTools_ToolsButtonMixin:OpenOptions(name)--打开,Tools选项界面，选项
    if not self.Category then
        e.OpenPanelOpting()
    end
    e.OpenPanelOpting(self.Category, name)
end


function WoWTools_ToolsButtonMixin:OpenMenu(root, name)--打开, 选项界面，菜单
    local sub=root:CreateButton(name or self:GetName(),
        function(data)
            if SettingsPanel:IsShown() then--ToggleGameMenu()
                SettingsPanel:Close()
            else
                self:OpenOptions(data)
            end
            return MenuResponse.Open
        end, name)

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddLine(description.data or self:GetName())
        tooltip:AddLine(e.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'))
    end)
    return sub
end







--[[
EventRegistry:TriggerEvent("GenericTraitFrame.SetSystemID", systemID, configID);

function DragonflightLandingOverlayMixin.HandleUnlockEvent(event, ...)
end

function DragonflightLandingOverlayMixin.HandleMinimapAnimationEvent(event, ...)
	if event == "QUEST_TURNED_IN" then
		local questID, xpReward, moneyReward = ...;
		if questID == DRAGONRIDING_INTRO_QUEST_ID then
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_DRAGONRIDING_UNLOCKED);
			EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.DragonridingUnlocked);
		end
	elseif event == "MAJOR_FACTION_UNLOCKED" then
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerAlert", DRAGONFLIGHT_LANDING_PAGE_ALERT_MAJOR_FACTION_UNLOCKED);
		EventRegistry:TriggerEvent("ExpansionLandingPage.TriggerPulseLock", minimapPulseLocks.MajorFactionUnlocked);
	end
end



function WoWTools_ToolsButtonMixin:GetData(btn)
    GET_ITEM_INFO_RECEIVED: itemID, success
    SPELL_DATA_LOAD_RESULT: spellID, success
end]]