local e= select(2, ...)

local function Save()
    return WoWTools_BankFrameMixin.Save
end

--[[
local function Init_Menu(self, root)
    root:CreateCheckbox(e.onlyChinese and '显示' or SHOW, function()
        return not Save().hideReagentBankFrame
    end, function()
        self:set_shown()
        return MenuResponse.Close
    end)
   
--隐藏
    if Save().hideReagentBankFrame then
        return
    end
    root:CreateDivider()

--移动点
if Save().pointReagentBank then
    root:CreateButton(e.onlyChinese and '还原位置' or RESET_POSITION, function()
        Save().pointReagentBank= nil
        self:show_hide()
        self:set_tooltips()
    end)

else
--x
    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().scaleReagentBankFrame
        end, setValue=function(value)
            Save().scaleReagentBankFrame=value
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
            return Save().yReagentBankFrame
        end, setValue=function(value)
            Save().yReagentBankFrame=value
            self:show_hide()
        end,
        name='y',
        minValue=-800,
        maxValue=800,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()

    root:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().xReagentBankFrame
        end, setValue=function(value)
            Save().xReagentBankFrame=value
            self:show_hide()
        end,
        name='x',
        minValue=-800,
        maxValue=800,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()
end
end]]






--原生, 增强
local function Init()--增强，原生
    --[[ReagentBankFrame.ShowHideButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    ReagentBankFrame.ShowHideButton:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function ReagentBankFrame.ShowHideButton:set_atlas()
        self:SetNormalAtlas(Save().hideReagentBankFrame and 'editmode-up-arrow' or 'editmode-down-arrow')
    end

    function ReagentBankFrame.ShowHideButton:set_scale()
        if BankFrame.activeTabIndex==2 then
            ReagentBankFrame:SetScale(1)
        else
            ReagentBankFrame:SetScale(Save().scaleReagentBankFrame or 1)
        end
    end

    function ReagentBankFrame.ShowHideButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE))..': '..(self.name or ''), e.Icon.left)
        e.tips:AddDoubleLine('|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL), e.Icon.right)
        e.tips:Show()
    end

    function ReagentBankFrame.ShowHideButton:set_shown()
        Save().hideReagentBankFrame= not Save().hideReagentBankFrame and true or nil
        self:show_hide(Save().hideReagentBankFrame)
        self:set_atlas()
        self:set_tooltips()
    end

    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            self:set_shown()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', GameTooltip_Hide)
    ReagentBankFrame.ShowHideButton:SetScript('OnEnter', ReagentBankFrame.ShowHideButton.set_tooltips)
    ReagentBankFrame.ShowHideButton:set_scale()
    ReagentBankFrame.ShowHideButton:set_atlas()


    --移动
    ReagentBankFrame:SetClampedToScreen(false)
    ReagentBankFrame:SetMovable(true)
    ReagentBankFrame:HookScript("OnDragStart", ReagentBankFrame.StartMoving)
    ReagentBankFrame:HookScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().pointReagentBank= {self:GetPoint(1)}
        Save().pointReagentBank[2]= nil
        ResetCursor()
    end)
    ReagentBankFrame:HookScript("OnMouseUp", ResetCursor)--停止移动
    ReagentBankFrame:HookScript("OnMouseDown", function(_, d)--设置, 光标
        SetCursor('UI_MOVE_CURSOR')
    end)
    ReagentBankFrame:RegisterForDrag("RightButton", "LeftButton")


    --设置，显示材料银行
    function ReagentBankFrame.ShowHideButton:show_hide(hide)
        --local unlocked= IsReagentBankUnlocked()
        if (not Save().hideReagentBankFrame or hide) and BankFrame.activeTabIndex then
            if BankFrame.activeTabIndex==1 and not hide then
                ReagentBankFrame:ClearAllPoints()
                if Save().pointReagentBank then
                    ReagentBankFrame:SetPoint(Save().pointReagentBank[1], UIParent, Save().pointReagentBank[3], Save().pointReagentBank[4],  Save().pointReagentBank[5])
                else
                    ReagentBankFrame:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save().xReagentBankFrame, Save().yReagentBankFrame)
                end
                ReagentBankFrame:SetShown(true)
            elseif BankFrame.activeTabIndex==2 or hide then
                ReagentBankFrame:ClearAllPoints()
                ReagentBankFrame:SetPoint('TOPLEFT')
                if hide then
                    ReagentBankFrame:SetShown(false)
                end
            end
        end
        ReagentBankFrame.ShowHideButton:SetShown(BankFrame.activeTabIndex==1)--选项
        ReagentBankFrame.ShowHideButton:set_scale()--缩放
        ReagentBankFrame.autoSortButton:SetShown(not Save().hideReagentBankFrame and BankFrame.activeTabIndex==1)--整理材料银行
    end
    hooksecurefunc('BankFrame_ShowPanel', ReagentBankFrame.ShowHideButton.show_hide)
    ]]















    ReagentBankFrame:SetSize(715, 415)--386, 415
    ReagentBankFrame.NineSlice:Hide()
    ReagentBankFrame.EdgeShadows:Hide()

    ReagentBankFrame.DespositButton:ClearAllPoints()
    ReagentBankFrame.DespositButton:SetPoint('BOTTOM',0 ,18)

    ReagentBankFrame.autoSortButton:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 25, 0)--整理材料银行
    ReagentBankFrame.DespositButton.texture2= ReagentBankFrame.DespositButton:CreateTexture(nil, 'OVERLAY')--增加，提示图标
    ReagentBankFrame.DespositButton.texture2:SetSize(23,23)
    ReagentBankFrame.DespositButton.texture2:SetPoint('RIGHT', -4, 0)
    ReagentBankFrame.DespositButton.texture2:SetAtlas('poi-traveldirections-arrow')
    ReagentBankFrame.DespositButton.texture2:SetTexCoord(0,1,1,0)
end








function WoWTools_BankFrameMixin:Init_Bank_Plus()--原生, 增强
    Init()
    WoWTools_ButtonMixin:CreateButton(2)
end