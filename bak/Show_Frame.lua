---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field
local e= select(2, ...)

local function Save()
    return WoWTools_BankFrameMixin.Save
end





local function Init_Menu(self, root)
    root:CreateCheckbox(e.onlyChinese and '显示' or SHOW, function()
        return not Save()['hide'..self.name]
    end, function()        
        self:set_shown()
        return MenuResponse.Close
    end)

--隐藏
    if Save()['hide'..self.name] then
        return
    end
    root:CreateDivider()

--移动点

if Save()['point'..self.name] then
    root:CreateButton(e.onlyChinese and '还原位置' or RESET_POSITION, function()
        Save()['point'..self.name]= nil
        self:show_hide()
        self:set_tooltips()
    end)

else
--x
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save()['scale'..self.name] or 1
        end, setValue=function(value)
            Save()['scale'..self.name]=value
            self:show_hide()
        end,
        name=e.onlyChinese and '缩放' or UI_SCALE,
        minValue=0.4,
        maxValue=4,
        step=0.05,
        bit='%0.2f',
    })
    root:CreateSpacer()

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save()['x'..self.name] or -15
        end, setValue=function(value)
            Save()['x'..self.name]=value
            self:show_hide()
        end,
        name='x',
        minValue=-800,
        maxValue=800,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save()['y'..self.name] or 10
        end, setValue=function(value)
            Save()['y'..self.name]=value
            self:show_hide()
        end,
        name='y',
        minValue=-800,
        maxValue=800,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()
end
end









local ShowButton
local function CreateButton(tabIndex)
    local frame, name
    if tabIndex==2 then
        name='ReagentBankFrame'
        frame= ReagentBankFrame
    elseif tabIndex==3 then
        name= 'AccountBankPanel'
        frame= AccountBankPanel
    end
    if not frame then
        return
    end


--移动
    frame:SetClampedToScreen(false)
    frame:SetMovable(true)
    frame:HookScript("OnDragStart", frame.StartMoving)
    frame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save()['point'..ShowButton.name]= {self:GetPoint(1)}
        Save()['point'..ShowButton.name][2]= nil
        ResetCursor()
    end)
    frame:HookScript("OnMouseUp", ResetCursor)--停止移动
    frame:HookScript("OnMouseDown", function(_, d)--设置, 光标
        SetCursor('UI_MOVE_CURSOR')
    end)
    frame:RegisterForDrag("RightButton", "LeftButton")

    if tabIndex==3 then
        frame:ClearAllPoints()
        frame:SetSize(738, 460)
        frame:SetPoint('TOPLEFT')
    end



    ShowButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    ShowButton.name= name
    ShowButton.tabIndex= tabIndex

    ShowButton:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function ShowButton:set_atlas()
        self:SetNormalAtlas(Save()['hide'..self.name] and 'editmode-up-arrow' or 'editmode-down-arrow')
    end

    function ShowButton:set_scale()
        if BankFrame.activeTabIndex==self.tabIndex then
            _G[self.name]:SetScale(1)
        else
            _G[self.name]:SetScale(Save()['scale'..self.name] or 1)
        end
    end

    function ShowButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))..': '..(self.name or ''), e.Icon.left)
        e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        e.tips:Show()
    end

    function ShowButton:set_shown()
        Save()['hide'..self.name]= not Save()['hide'..self.name] and true or nil
        self:show_hide()
        self:set_atlas()
        self:set_tooltips()
    end

    ShowButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            self:set_shown()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


    ShowButton:SetScript('OnLeave', GameTooltip_Hide)
    ShowButton:SetScript('OnEnter', ShowButton.set_tooltips)
    ShowButton:set_scale()
    ShowButton:set_atlas()



    --设置，显示材料银行
    function ShowButton:show_hide()
        --local unlocked= IsReagentBankUnlocked()
        local f= _G[self.name]
        local index= BankFrame.activeTabIndex

        if index==self.tabIndex then                
            if self.tabIndex==2 then
                f:ClearAllPoints()    
                f:SetPoint('TOPLEFT')
            elseif index==3 then
                f:ClearAllPoints()
                f:SetAllPoints()
            end
            f:SetShown(true)
        elseif index==1 then
            local show=not Save()['hide'..self.name]
            if show then
                local point= Save()['point'..self.name]
                if point then
                    f:SetPoint(point[1], UIParent, point[3], point[4],  point[5])
                else
                    f:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save()['x'..self.name] or -15, Save()['y'..self.name] or 10)
                end
                f:SetPoint(true)
            else
                f:SetShown(false)
            end
        else
            f:Hide()
        end
        self:set_scale()--缩放
        if frame.autoSortButton then
           frame.autoSortButton:SetShown(index==1)--整理材料银行
        end
    
    end

    hooksecurefunc('BankFrame_ShowPanel', function()
        ShowButton:show_hide()
    end)
end




function WoWTools_ButtonMixin:CreateButton(name, tabIndex)
    return CreateButton(name, tabIndex)
end