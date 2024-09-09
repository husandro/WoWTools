local e= select(2, ...)

local function Save()
    return WoWTools_BankFrame.Save
end









--原生, 增强
local function Init()--增强，原生
    --选项
    ReagentBankFrame.ShowHideButton= WoWTools_ButtonMixin:Cbtn(BankFrame, {size={18,18}, atlas='hide'})
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
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrame.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示材料银行' or REAGENT_BANK, e.GetShowHide(not Save().hideReagentBankFrame)..e.Icon.left)
        e.tips:AddLine(' ')

        local col= not ReagentBankFrame:IsShown() and '|cff9e9e9e'
        e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scaleReagentBankFrame or 1), (col or '')..'Alt+'..e.Icon.mid)

        if Save().pointReagentBank then
            col='|cff9e9e9e'
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((col or '')..'X |cnGREEN_FONT_COLOR:'..Save().xReagentBankFrame, (col or '')..'Ctrl+'..e.Icon.mid)
        e.tips:AddDoubleLine((col or '')..'Y |cnGREEN_FONT_COLOR:'..Save().yReagentBankFrame, (col or '')..'Shift+'..e.Icon.mid)
        col= Save().pointReagentBank and '' or '|cff9e9e9e'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '还原位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save().pointReagentBank= nil
            self:show_hide()
            self:set_tooltips()
            print(e.addName, WoWTools_BankFrame.addName, e.onlyChinese and '还原位置' or RESET_POSITION)
        else
            Save().hideReagentBankFrame= not Save().hideReagentBankFrame and true or nil
            self:show_hide(Save().hideReagentBankFrame)
            self:set_atlas()
            self:set_tooltips()
        end
    end)

    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', GameTooltip_Hide)
    ReagentBankFrame.ShowHideButton:SetScript('OnEnter', ReagentBankFrame.ShowHideButton.set_tooltips)
    ReagentBankFrame.ShowHideButton:SetScript('OnMouseWheel', function(self, d)
        if Save().hideReagentBankFrame then
            return
        end
        local n
        if IsAltKeyDown() then
            n= Save().scaleReagentBankFrame or 1--缩放
            if d==1 then
                n= n+0.05
            elseif d==-1 then
                n= n-0.05
            end
            n= n>4 and 4 or n
            n= n<0.4 and 0.4 or n
            Save().scaleReagentBankFrame= n
            self:set_scale()
        elseif not Save().pointReagentBank then
            if IsControlKeyDown() then
                n= Save().xReagentBankFrame--坐标 X
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save().xReagentBankFrame= n
                self:show_hide()--设置，显示材料银行
            elseif IsShiftKeyDown() then
                n= Save().yReagentBankFrame--坐标 Y
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save().yReagentBankFrame= n
                self:show_hide()--设置，显示材料银行
            end
        end
        self:set_tooltips()
    end)
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





    ReagentBankFrame:SetSize(715, 415)--386, 415
    --添加，背景
    ReagentBankFrame.Bg= ReagentBankFrame:CreateTexture(nil, 'BACKGROUND')
    ReagentBankFrame.Bg:SetSize(715, 350)
    ReagentBankFrame.Bg:SetPoint('BOTTOMLEFT',10, 10)
    ReagentBankFrame.Bg:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    ReagentBankFrame.Bg:SetAlpha(0.5)

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

    ReagentBankFrame:HookScript('OnShow', function(self)

        for _, region in pairs({ReagentBankFrame:GetRegions()}) do--隐藏，材料包，背景
            if region:GetObjectType()=='Texture' then
                region:SetTexture(0)
                region:Hide()
            end
        end
    end)
end








function WoWTools_BankFrame:Init_Bank_Plus()--原生, 增强
    Init()
end