local function Save()
    return WoWToolsSave['WoWTools_ToolsButton']
end



WoWTools_ToolsMixin={
    AddList={},--所有, 按钮 {name}=true
    --Save={disabledADD={}, lineNum=10, isHideBackground=nil},

    LeftButtons={},--按钮 {btn1, btn2,}
    LeftButtons2={},
    RightButtons={},
    BottomButtons={},

    leftNewLineButton=nil,
    setID=0,
    addName='|A:Professions-Crafting-Orders-Icon:0:0|aTools',
}

local AllButtons={}



function WoWTools_ToolsMixin:CreateButton(tab)
    tab= tab or {}

    if not tab.disabledOptions then
        table.insert(self.AddList, tab)
    end
    if not self.Button or Save().disabledADD[tab.name] then
        return
    end

    self.setID= self.setID+1

    local btn= WoWTools_ButtonMixin:Cbtn(self:GetParent(tab), {
        name='WoWTools_Tools_'..(tab.name or self.setID)..'_Button',
        setID= self.setID,
        isType2=true,
        isSecure=true,
        size=30,
        --isMenu=tab.isMenu
    })

    btn.IconMask:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
    btn.IconMask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 5)

    function btn:set_border_alpha()
        self.border:SetAlpha(Save().borderAlpha or 0.3)
    end

    function btn:GetData()
        return self.ToolsData
    end
    function btn:SetData(data)
        self.ToolsData=data
    end
    btn:SetData(tab)

    WoWTools_ToolsMixin:SetPoint(btn, tab)

    table.insert(AllButtons, btn)
    return btn
end










function WoWTools_ToolsMixin:Set_Shown_Background(frame)
    if frame and frame.Background then
        --frame.Background:SetShown(Save().isShowBackground)
        frame.Background:SetAlpha(Save().bgAlpha or 0.5)
    end
end




function WoWTools_ToolsMixin:Set_Left_Point(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button.Frame, 'TOPRIGHT', 0, 30)
end
function WoWTools_ToolsMixin:Set_Left2_Point(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button.LeftFrame, 'BOTTOMLEFT')
end
function WoWTools_ToolsMixin:Set_Right_Point(frame)
    frame:SetPoint('BOTTOMLEFT', self.Button, 'TOPRIGHT')
end
function WoWTools_ToolsMixin:Set_Bottom_Point(frame)
    frame:SetPoint('BOTTOMRIGHT', self.Button, 'TOPRIGHT')
end


function WoWTools_ToolsMixin:GetParent(tab)--取得 Parent
    if tab.parentFrame then--指定
        return tab.parentFrame

    elseif Save().BottomPoint[tab.name]--选项，自定义，
        or tab.isMoveButton
    then
        return self.Button
    else
        return self.Button.Frame

    end
end



function WoWTools_ToolsMixin:Init()
    if Save().disabled then
        return
    end

    self.Button= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsMainToolsButton',
        size={30, Save().height or 10}
    })

    self.Button.Frame= CreateFrame('Frame', nil, self.Button)
    self.Button.Frame:SetAllPoints()
    self.Button.Frame:SetShown(Save().show)
--为显示Frame用
    self.Button.IsShownFrameEnterButton=true

    self.Button.texture=self.Button:CreateTexture(nil, 'BORDER')
    self.Button.texture:SetPoint('CENTER')
    self.Button.texture:SetSize(10,10)
    self.Button.texture:SetShown(Save().showIcon)
    self.Button.texture:SetAtlas(WoWTools_DataMixin.Icon.icon)

    --底部,需要，设置高 宽
    self.Button.LeftFrame= self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_LeftFrame')
    self.Button.LeftFrame2= self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_LeftFrame2')
    self.Button.RightFrame=self:CreateBackgroundFrame(self.Button.Frame, 'WoWTools_RightFrame')
    --需要，设置 LEFT
    self.Button.BottomFrame= self:CreateBackgroundFrame(self.Button, 'WoWTools_ButtomFrame')

    self:Set_Left_Point(self.Button.LeftFrame)
    self:Set_Left2_Point(self.Button.LeftFrame2)
    self:Set_Right_Point(self.Button.RightFrame)
    self:Set_Bottom_Point(self.Button.BottomFrame)

    self.last= self.Button
    return self.Button
end










function WoWTools_ToolsMixin:SetPoint(btn, tab)
    btn.IsShownFrameEnterButton=nil--为显示/隐藏Frame用

--最左(右)边，一行，给法师传送门用
    if tab.isLeftOnlyLine then
--左边
        if tab.isLeftOnlyLine() then
            local num= #self.LeftButtons2
            if num==0 then
                self:Set_Left2_Point(btn)
                self.Button.LeftFrame2:SetWidth(30)
                self:Set_Shown_Background(self.Button.LeftFrame2)
            else
                btn:SetPoint('BOTTOM', self.LeftButtons2[num], 'TOP')
            end
            self.Button.LeftFrame2:SetPoint('TOP', btn)
            table.insert(self.LeftButtons2, btn)
        else
--右边
            local num= #self.RightButtons
            if num==0 then
                self:Set_Right_Point(btn)
                self.Button.RightFrame:SetWidth(30)
                self:Set_Shown_Background(self.Button.RightFrame)
            else
                btn:SetPoint('BOTTOM', self.RightButtons[num], 'TOP')
            end
            self.Button.RightFrame:SetPoint('TOP', btn)
            table.insert(self.RightButtons, btn)
        end
    else

--BOOTOM
        if Save().BottomPoint[tab.name] or tab.isMoveButton then
            local num=#self.BottomButtons
            if num==0 then
--为显示/隐藏Frame用
                btn.IsShownFrameEnterButton=true
                self:Set_Bottom_Point(btn)
                self.Button.BottomFrame:SetHeight(30)
                self:Set_Shown_Background(self.Button.BottomFrame)
            else
                btn:SetPoint('RIGHT', self.BottomButtons[num], 'LEFT')
            end
            if not tab.isMoveButton then
                self.Button.BottomFrame:SetPoint('LEFT', btn)--需要，设置宽 LEFT
                table.insert(self.BottomButtons, btn)
            end
        else
--上面，合集
            local num=#self.LeftButtons
            if num==0 then
                self.leftNewLineButton=btn
                self:Set_Left_Point(btn)
                self.Button.LeftFrame:SetPoint('TOP', btn)
                self.Button.LeftFrame:SetPoint('LEFT', btn)
                self:Set_Shown_Background(self.Button.LeftFrame)

            else
                local numLine= Save().lineNum or 10
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
button= WoWTools_ToolsMixin:CreateButton({
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

function WoWTools_ToolsMixin:CreateBackgroundFrame(parent, name)
    local frame= CreateFrame('Frame', name, parent or UIParent)
    WoWTools_TextureMixin:CreateBG(frame, {isAllPoint=true})
    --[[frame.texture=frame:CreateTexture(nil, 'BACKGROUND')
    frame.texture:SetAllPoints()
    frame.texture:SetAlpha(0.5)]]
    return frame
end


--显示背景
function WoWTools_ToolsMixin:ShowBackground()
    self:Set_Shown_Background(self.Button.LeftFrame)
    self:Set_Shown_Background(self.Button.LeftFrame2)
    self:Set_Shown_Background(self.Button.RightFrame)
    self:Set_Shown_Background(self.Button.BottomFrame)
end

--重置所有按钮位置
function WoWTools_ToolsMixin:RestAllPoint()
    if not self.Button:CanChangeAttribute() then
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

        --self.Button.LeftFrame:ClearAllPoints()
        --self.Button.LeftFrame2:ClearAllPoints()
        --self.Button.RightFrame:ClearAllPoints()
        --self.Button.BottomFrame:ClearAllPoints()
        self:Set_Left_Point(self.Button.LeftFrame)
        self:Set_Left2_Point(self.Button.LeftFrame2)
        self:Set_Right_Point(self.Button.RightFrame)
        self:Set_Bottom_Point(self.Button.BottomFrame)
    end


    table.sort(buttons, function(a, b) return a:GetID()< b:GetID() end)

    for _, btn in pairs(buttons) do
        btn:SetParent(self:GetParent(btn:GetData()))
        self:SetPoint(btn, btn:GetData())
    end
end


--用户，自定义设置，选项
function WoWTools_ToolsMixin:AddOptions(option)
    table.insert(self.AddList, {isPlayerSetupOptions=true, option=option})
end



--当Enter图标是，显示Tools Frame
function WoWTools_ToolsMixin:EnterShowFrame(btn)
    if btn.IsShownFrameEnterButton and Save().isEnterShow and not self.Button.Frame:IsShown() then
        self.Button:set_shown()
    end
end




--打开选项界面
function WoWTools_ToolsMixin:OpenMenu(root, name, showText)--打开, 选项界面，菜单
    return WoWTools_MenuMixin:OpenOptions(root, {
        name=name or self.addName,
        name2=showText,
        category= self.Category
    })
end



function WoWTools_ToolsMixin:Get_All_Buttons()
    return AllButtons
end