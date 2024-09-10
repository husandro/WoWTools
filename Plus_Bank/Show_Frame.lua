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


    local btn= WoWTools_ButtonMixin:Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    btn.name= name
    btn.tabIndex= tabIndex
    frame.name= name
    frame.tabIndex= tabIndex

    btn:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function btn:set_atlas()
        self:SetNormalAtlas(Save()['hide'..self.name] and 'editmode-up-arrow' or 'editmode-down-arrow')
    end

    function btn:set_scale()
        if BankFrame.activeTabIndex==self.tabIndex then
            _G[self.name]:SetScale(1)
        else
            _G[self.name]:SetScale(Save()['scale'..self.name] or 1)
        end
    end

    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))..': '..(self.name or ''), e.Icon.left)
        e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        e.tips:Show()
    end

    function btn:set_shown()
        Save()['hide'..self.name]= not Save()['hide'..self.name] and true or nil
        self:show_hide(Save()['hide'..self.name])
        self:set_atlas()
        self:set_tooltips()
    end

    btn:SetScript('OnClick', function(f, d)

        if d=='LeftButton' then
            f:set_shown()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(f, Init_Menu)
        end
    end)


    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:set_scale()
    btn:set_atlas()


    --移动
    frame:SetClampedToScreen(false)
    frame:SetMovable(true)
    frame:HookScript("OnDragStart", frame.StartMoving)
    frame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save()['point'..self.name]= {self:GetPoint(1)}
        Save()['point'..self.name]= nil
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

    --设置，显示材料银行
    function btn:show_hide(hide)
        --local unlocked= IsReagentBankUnlocked()
        if (not Save()['hide'..self.name] or hide) and BankFrame.activeTabIndex then
            local f= _G[self.name]
            if BankFrame.activeTabIndex==1 and not hide then
                f:ClearAllPoints()
                local point= Save()['point'..self.name]
                if point then
                    f:SetPoint(point[1], UIParent, point[3], point[4],  point[5])
                else
                    f:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save()['x'..self.name] or -15, Save()['y'..self.name] or 10)
                end
                f:SetShown(true)
            elseif BankFrame.activeTabIndex==self.tabIndex or hide then
                f:ClearAllPoints()

                    f:SetPoint('TOPLEFT')

                if hide then
                    f:SetShown(false)
                end
            end
            print(f:IsShown())
        end
        btn:SetShown(BankFrame.activeTabIndex==1)--选项
        btn:set_scale()--缩放

        if ReagentBankFrame.autoSortButton then
            ReagentBankFrame.autoSortButton:SetShown(not Save().hideReagentBankFrame and BankFrame.activeTabIndex==1)--整理材料银行
        end

    end
    hooksecurefunc('BankFrame_ShowPanel', function()
        ShowButton:show_hide()
    end)

    ShowButton= btn
end




function WoWTools_ButtonMixin:CreateButton(name, tabIndex)
    return CreateButton(name, tabIndex)
end