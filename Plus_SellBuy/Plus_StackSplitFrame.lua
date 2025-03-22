
local e= select(2, ...)





--堆叠,数量,框架 StackSplitFrame.lua
local function Init()
    local frame= StackSplitFrame
    frame.restButton=WoWTools_ButtonMixin:Cbtn(frame, {size=22})--重置
    frame.restButton:SetPoint('TOP')
    frame.restButton:SetNormalAtlas('characterundelete-RestoreButton')
    frame.restButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split= f.minSplit
        f.LeftButton:SetEnabled(false)
        f.RightButton:SetEnabled(true)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame.restButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_SellBuyMixin.addName)
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '重置' or RESET)
        GameTooltip:Show()
    end)
    frame.restButton:SetScript('OnLeave', GameTooltip_Hide)

    frame.MaxButton=WoWTools_ButtonMixin:Cbtn(frame, {size={40,20}})
    frame.MaxButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MaxButton:SetPoint('LEFT', frame.restButton, 'RIGHT')
    frame.MaxButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=f.maxStack
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.MetaButton=WoWTools_ButtonMixin:Cbtn(frame, {size={40,20}})
    frame.MetaButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MetaButton:SetPoint('RIGHT', frame.restButton, 'LEFT')
    frame.MetaButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=floor(f.maxStack/2)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.editBox=CreateFrame('EditBox', nil, frame)--输入框
    frame.editBox:SetSize(100, 23)
    frame.editBox:SetPoint('TOPLEFT', 38, -18)
    frame.editBox:SetTextColor(0,1,0)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:ClearFocus()
    frame.editBox:SetFontObject("ChatFontNormal")
    frame.editBox:SetMultiLine(false)
    frame.editBox:SetNumeric(true)
    --frame.editBox:SetScript('OnEditFocusLost', function(self) self:SetText('') end)
    frame.editBox:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnHide', function(self) self:SetText('') self:ClearFocus() end)
    frame.editBox:SetScript('OnTextChanged',function(self, userInput)
        if not userInput then
            return
        end
        local f= self:GetParent()
        local num=self:GetNumber()
        if f.isMultiStack then
            num= floor(num/f.minSplit) * f.minSplit
        end
        num= num<f.minSplit and f.minSplit or num
        num= num>f.maxStack and f.maxStack or num
        f.RightButton:SetEnabled(num<f.maxStack)
        f.LeftButton:SetEnabled(num==f.minSplit)
        f.split=num
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame:HookScript('OnMouseWheel', function(self, d)
        local minSplit= self.minSplit or 1
        local maxStack= self.maxStack or 1
        local num= self.split or 1
        num= d==1 and num+ minSplit or num
        num= d==-1 and num- minSplit or num
        num= num< minSplit and minSplit or num
        num= num> maxStack and maxStack or num
        self.split= num
        self:UpdateStackText()
        self:UpdateStackSplitFrame(self.maxStack)
    end)

    hooksecurefunc(StackSplitFrame, 'OpenStackSplitFrame', function(self)
        self.MaxButton:SetText(self.maxStack)
        self.MetaButton:SetText(floor(self.maxStack/2))
    end)
end




function WoWTools_SellBuyMixin:Init_StackSplitFrame()
    Init()
end