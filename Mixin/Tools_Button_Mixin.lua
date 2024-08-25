local e= select(2, ...)

WoWTools_ToolsButtonMixin={
    AddList={},--所有, 按钮 {name}=true
    Save={disabledADD={}, lineNum=10, isHideBackground=nil},

    LeftButtons={},--按钮 {btn1, btn2,}
    LeftButtons2={},
    RightButtons={},
    BottomButtons={},

    leftNewLineButton=nil,
    setID=1
}


function WoWTools_ToolsButtonMixin:GetName()
    return '|A:Professions-Crafting-Orders-Icon:0:0|aTools'
end

function WoWTools_ToolsButtonMixin:SetLeftPoint(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button.Frame, 'TOPRIGHT', 0, 30)
end
function WoWTools_ToolsButtonMixin:SetLeft2Point(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button.LeftFrame, 'BOTTOMLEFT')
end
function WoWTools_ToolsButtonMixin:SetRightPoint(frame)
    frame:SetPoint('BOTTOMLEFT', self.Button, 'TOPRIGHT')
end
function WoWTools_ToolsButtonMixin:SetBottomPoint(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button, 'TOPRIGHT')
end


function WoWTools_ToolsButtonMixin:GetParent(tab)--取得 Parent
    if tab.parent then--指定
        return tab.parent

    elseif self.Save.BottomPoint[tab.name]--选项，自定义，
        or self.Save.isMoveButton
    then
        return self.Button
    else
        return self.Button.Frame
        
    end
end



function WoWTools_ToolsButtonMixin:Init(save)
    if save.disabled then
        return
    end

    self:SetSaveData(save)

    self.Button= e.Cbtn(nil, {name='WoWTools_ToolsButton', icon='hide', size={30, save.height or 10}})

    self.Button.Frame= CreateFrame('Frame', nil, self.Button)
    self.Button.Frame:SetAllPoints()
    self.Button.Frame:SetShown(save.show)
--为显示Frame用
    self.Button.IsShownFrameEnterButton=true

    self.Button.texture=self.Button:CreateTexture(nil, 'BORDER')
    self.Button.texture:SetPoint('CENTER')
    self.Button.texture:SetSize(10,10)
    self.Button.texture:SetShown(save.showIcon)
    self.Button.texture:SetAtlas(e.Icon.icon)

    --底部,需要，设置高 宽
    self.Button.LeftFrame= self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_LeftFrame')
    self.Button.LeftFrame2= self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_LeftFrame2')
    self.Button.RightFrame=self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_RightFrame')
    --需要，设置 LEFT
    self.Button.BottomFrame= self:CreateBackgroundFrame(self.Button, 'WoWTools_ButtomFrame')
    
    self:SetLeftPoint(self.Button.LeftFrame)
    self:SetLeft2Point(self.Button.LeftFrame2)
    self:SetRightPoint(self.Button.RightFrame)
    self:SetBottomPoint(self.Button.BottomFrame)

    self.last= self.Button
    return self.Button
end
--[[
WoWTools_ToolsButtonMixin:CreateButton({
    name=,
    tooltip=nil,
    point='LEFT',

    isLeftOnlyLine=function()--左（右）边，法师传送门
        return Save.isLeft
    end,

    isMoveButton=true,--可移动，按钮，仅BOTTOM
    SavePoint=Save.point,--保存点

    option=funciton()end,--添加选项
    disabledOptions=false,--自定义，选项
}
]]


function WoWTools_ToolsButtonMixin:CreateButton(tab)
    if not tab.disabledOptions then
        table.insert(self.AddList, tab)
    end
    if not self.Button or self.Save.disabledADD[tab.name] then
        return
    end   

    local btn= self:Create(tab)

    function btn:GetData()
        return self.ToolsData       
    end
    function btn:SetData(data)
        self.ToolsData=data
    end
    btn:SetData(tab)

    WoWTools_ToolsButtonMixin:SetPoint(btn, tab)

    return btn
end




function WoWTools_ToolsButtonMixin:SetPoint(btn, tab)
    btn.IsShownFrameEnterButton=nil--为显示/隐藏Frame用

--最左(右)边，一行，给法师传送门用
    if tab.isLeftOnlyLine then
--左边
        if tab.isLeftOnlyLine() then
            local num= #self.LeftButtons2
            if num==0 then
                self:SetLeft2Point(btn)
                self.Button.LeftFrame2:SetWidth(30)
                self:SetBackground(self.Button.LeftFrame2)
            else
                btn:SetPoint('BOTTOM', self.LeftButtons2[num], 'TOP')
            end            
            self.Button.LeftFrame2:SetPoint('TOP', btn)
            table.insert(self.LeftButtons2, btn)
        else
--右边
            local num= #self.RightButtons
            if num==0 then
                self:SetRightPoint(btn)
                self.Button.RightFrame:SetWidth(30)
                self:SetBackground(self.Button.RightFrame)
            else
                btn:SetPoint('BOTTOM', self.RightButtons[num], 'TOP')
            end
            self.Button.RightFrame:SetPoint('TOP', btn)
            table.insert(self.RightButtons, btn)
        end
    else
        --local point= type(tab.point)=='function' and tab.point() or tab.point
--BOOTOM
        if self.Save.BottomPoint[tab.name] then
            local num=#self.BottomButtons
            if num==0 then
--为显示/隐藏Frame用
                btn.IsShownFrameEnterButton=true
                self:SetBottomPoint(btn)
                self.Button.BottomFrame:SetHeight(30)
                self:SetBackground(self.Button.BottomFrame)
            else
                btn:SetPoint('RIGHT', self.BottomButtons[num], 'LEFT')
            end
            self.Button.BottomFrame:SetPoint('LEFT', btn)--需要，设置宽 LEFT
            table.insert(self.BottomButtons, btn)

        else
--上面，合集
            local num=#self.LeftButtons
            if num==0 then
                self.leftNewLineButton=btn
                self:SetLeftPoint(btn)
                self.Button.LeftFrame:SetPoint('TOP', btn)
                self.Button.LeftFrame:SetPoint('LEFT', btn)
                self:SetBackground(self.Button.LeftFrame)

                
            else
                local numLine= self.Save.lineNum or 10
                if select(2, math.modf(num / numLine))==0 then
                    btn:SetPoint('RIGHT', self.leftNewLineButton, 'LEFT')
                    self.Button.LeftFrame:SetPoint('LEFT', btn)
                    self.leftNewLineButton=btn
                else
                    btn:SetPoint('BOTTOM', self.LeftButtons[num], 'TOP')
                    if num== (numLine-1) then
                        self.Button.LeftFrame:SetPoint('TOP', btn)
                    end
                    
                end
            end
            table.insert(self.LeftButtons, btn)
        end
    end

end
--[[
button= WoWTools_ToolsButtonMixin:CreateButton({
    name='',
    tooltip=',
    point='BOTTOM',
    parent=,
    isMoveButton=true,
    isLeftOnlyLine=function()
        return Save.isLeft
    end,
    disabledOptions=true,
    option=function()
    end,
})
]]

function WoWTools_ToolsButtonMixin:Create(tab)

    local btn= CreateFrame("Button",
--设置 名称
        'WoWTools_Tools_'..tab.name,
--设置 Parent,
        self:GetParent(tab),
        "SecureActionButtonTemplate",
        tab.setID or self.setID
    )

    self.setID= self.setID+1

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

function WoWTools_ToolsButtonMixin:CreateBackgroundFrame(parent, name)
    local frame= CreateFrame('Frame', name, parent or UIParent)
    frame.texture=frame:CreateTexture(nil, 'BACKGROUND')
    frame.texture:SetAllPoints()
    frame.texture:SetAlpha(0.5)
    return frame
end

function WoWTools_ToolsButtonMixin:SetBackground(frame)
    if self.Save.isShowBackground then
        frame.texture:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
    else
        frame.texture:SetTexture(0)
    end
end

--显示背景
function WoWTools_ToolsButtonMixin:ShowBackground()
    self:SetBackground(self.Button.LeftFrame)
    self:SetBackground(self.Button.LeftFrame2)
    self:SetBackground(self.Button.RightFrame)
    self:SetBackground(self.Button.BottomFrame)
end

--重置所有按钮位置
function WoWTools_ToolsButtonMixin:RestAllPoint()
    if UnitAffectingCombat('player') then
        return
    end
    self.leftNewLineButton=nil
    local buttons={}
    do
        for _, btn in pairs(self.LeftButtons) do
            btn:ClearAllPoints()
            table.insert(buttons, btn)
        end
        for _, btn in pairs(self.LeftButtons2) do
            btn:ClearAllPoints()
            table.insert(buttons, btn)
        end
        for _, btn in pairs(self.RightButtons) do
            btn:ClearAllPoints()
            table.insert(buttons, btn)
        end
        for _, btn in pairs(self.BottomButtons) do
            btn:ClearAllPoints()
            table.insert(buttons, btn)
        end

        self.LeftButtons={}--按钮 {btn1, btn2,}
        self.LeftButtons2={}
        self.RightButtons={}
        self.BottomButtons={}

        self.leftNewLineButton=nil

        self.Button.LeftFrame:ClearAllPoints()
        self.Button.LeftFrame2:ClearAllPoints()
        self.Button.RightFrame:ClearAllPoints()
        self.Button.BottomFrame:ClearAllPoints()
        self:SetLeftPoint(self.Button.LeftFrame)
        self:SetLeft2Point(self.Button.LeftFrame2)
        self:SetRightPoint(self.Button.RightFrame)
        self:SetBottomPoint(self.Button.BottomFrame)
    end

    
    table.sort(buttons, function(a, b) return a:GetID()< b:GetID() end)

    for _, btn in pairs(buttons) do
        btn:SetParent(self:GetParent(btn:GetData()))
        self:SetPoint(btn, btn:GetData())        
    end
end


--用户，自定义设置，选项
function WoWTools_ToolsButtonMixin:AddOptions(option)
    table.insert(self.AddList, {isPlayerSetupOptions=true, option=option})
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


--当Enter图标是，显示Tools Frame
function WoWTools_ToolsButtonMixin:EnterShowFrame(btn)
    if btn.IsShownFrameEnterButton and self.Save.isEnterShow and not self.Button.Frame:IsShown() then
        self.Button:set_shown()
    end
end


function WoWTools_ToolsButtonMixin:OpenOptions(name)--打开,Tools选项界面，选项
    if not self.Category then
        e.OpenPanelOpting()
    end
    e.OpenPanelOpting(self.Category, name)
end


function WoWTools_ToolsButtonMixin:OpenMenu(root, name, name2)--打开, 选项界面，菜单
    local sub=root:CreateButton(name2 or name or self:GetName(),
        function(data)
            if SettingsPanel:IsShown() then--ToggleGameMenu()
                SettingsPanel:Close()
            else
                self:OpenOptions(data.name)
            end
            return MenuResponse.Open
        end, {name=name, name2=name2})

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddDoubleLine(self:GetName(), description.name)
        tooltip:AddDoubleLine(
            e.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI'),
            description.data.name2
        )
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