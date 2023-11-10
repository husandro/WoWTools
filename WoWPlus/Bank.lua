local id, e = ...
local addName= BANK
local Save={
     --disabled=true,--禁用
    --hideReagentBankFrame=true,--银行,隐藏，材料包
    scaleReagentBankFrame=0.75,--银行，缩放
    xReagentBankFrame=-15,--坐标x
    yReagentBankFrame=10,--坐标y
    --pointReagentBank=｛｝--保存位置
    line=2,
    num=7
}



local panel= CreateFrame("Frame")






--银行
--BankFrame.lua
local function Init_Bank_Frame()
    if not ReagentBankFrame then
        return
    end

    local tab={--隐藏，背景
        'LeftTopCorner-Shadow',
        'LeftBottomCorner-Shadow',
        'RightTopCorner-Shadow',
        'RightBottomCorner-Shadow',
        'Right-Shadow',
        'Left-Shadow',
        'Bottom-Shadow',
        'Top-Shadow',
    }
    for _, textrue in pairs(tab) do
        if ReagentBankFrame[textrue] then
            ReagentBankFrame[textrue]:SetTexture(0)
            ReagentBankFrame[textrue]:Hide()
        end
    end

    --整理材料银行
    ReagentBankFrame.autoSortButton= CreateFrame("Button", nil, BankFrame, 'BankAutoSortButtonTemplate')
    ReagentBankFrame.autoSortButton:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', -2, 0)
    ReagentBankFrame.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)

    --选项
    ReagentBankFrame.ShowHideButton= e.Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    ReagentBankFrame.ShowHideButton:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function ReagentBankFrame.ShowHideButton:set_atlas()
        self:SetNormalAtlas(Save.hideReagentBankFrame and 'editmode-up-arrow' or 'editmode-down-arrow')
    end
    function ReagentBankFrame.ShowHideButton:set_scale()
        if BankFrame.activeTabIndex==2 then
            ReagentBankFrame:SetScale(1)
        else
            ReagentBankFrame:SetScale(Save.scaleReagentBankFrame or 1)
        end
    end
    function ReagentBankFrame.ShowHideButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '显示材料银行' or REAGENT_BANK, e.GetShowHide(not Save.hideReagentBankFrame)..e.Icon.left)
        e.tips:AddLine(' ')

        local col= not ReagentBankFrame:IsShown() and '|cff606060'
        e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleReagentBankFrame or 1), (col or '')..'Alt+'..e.Icon.mid)

        if Save.pointReagentBank then
            col='|cff606060'
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((col or '')..'X |cnGREEN_FONT_COLOR:'..Save.xReagentBankFrame, (col or '')..'Ctrl+'..e.Icon.mid)
        e.tips:AddDoubleLine((col or '')..'Y |cnGREEN_FONT_COLOR:'..Save.yReagentBankFrame, (col or '')..'Shift+'..e.Icon.mid)
        col= Save.pointReagentBank and '' or '|cff606060'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '还原位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self, d)
        if IsControlKeyDown() and d=='RightButton' then
            Save.pointReagentBank= nil
            self:show_hide()
            self:set_tooltips()
            print(id, addName, e.onlyChinese and '还原位置' or RESET_POSITION)
        else
            Save.hideReagentBankFrame= not Save.hideReagentBankFrame and true or nil
            self:show_hide(Save.hideReagentBankFrame)
            self:set_atlas()
            self:set_tooltips()
        end
    end)

    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', function() e.tips:Hide() end)
    ReagentBankFrame.ShowHideButton:SetScript('OnEnter', ReagentBankFrame.ShowHideButton.set_tooltips)
    ReagentBankFrame.ShowHideButton:SetScript('OnMouseWheel', function(self, d)
        if Save.hideReagentBankFrame then
            return
        end
        local n
        if IsAltKeyDown() then
            n= Save.scaleReagentBankFrame or 1--缩放
            if d==1 then
                n= n+0.05
            elseif d==-1 then
                n= n-0.05
            end
            n= n>4 and 4 or n
            n= n<0.4 and 0.4 or n
            Save.scaleReagentBankFrame= n
            self:set_scale()
        elseif not Save.pointReagentBank then
            if IsControlKeyDown() then
                n= Save.xReagentBankFrame--坐标 X
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save.xReagentBankFrame= n
                self:show_hide()--设置，显示材料银行
            elseif IsShiftKeyDown() then
                n= Save.yReagentBankFrame--坐标 Y
                if d==1 then
                    n= n+5
                elseif d==-1 then
                    n= n-5
                end
                Save.yReagentBankFrame= n
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
        Save.pointReagentBank= {self:GetPoint(1)}
        Save.pointReagentBank[2]= nil
        ResetCursor()
    end)
    ReagentBankFrame:HookScript("OnMouseUp", ResetCursor)--停止移动
    ReagentBankFrame:HookScript("OnMouseDown", function(_, d)--设置, 光标
        SetCursor('UI_MOVE_CURSOR')
    end)
    ReagentBankFrame:RegisterForDrag("RightButton", "LeftButton")


    --添加，背景
    ReagentBankFrame.Bg= ReagentBankFrame:CreateTexture(nil, 'BACKGROUND')
    ReagentBankFrame.Bg:SetSize(715, 350)
    ReagentBankFrame.Bg:SetPoint('BOTTOMLEFT',10, 10)
    ReagentBankFrame.Bg:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    ReagentBankFrame.Bg:SetAlpha(0.5)
    ReagentBankFrame.Bg:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)

    --NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES
    --local w, h= 370, 200
    --BankSlotsFrame:ClearAllPoints()
    --BankSlotsFrame:SetPoint('TOPLEFT')
    --BankSlotsFrame:SetSize(w,h)

    --[[
    local last
    for i=1, 28 do
        local btn= _G['BankFrameItem'..i]
        if btn then
            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', 8,-60)
                last=btn
            else
                btn:SetPoint('TOP', _G['BankFrameItem'..i-1], 'BOTTOM', 0, -Save.line)
            end
        end
    end
    for i=8, 28, Save.num do
        local btn= _G['BankFrameItem'..i]
        if btn then
            btn:ClearAllPoints()
            btn:SetPoint('LEFT', last, 'RIGHT', Save.line, 0)
            last= btn
        end
    end

    
    hooksecurefunc('ReagentBankFrameItemButton_OnLoad', function(btn)
        local index= tonumber(btn:GetName():match('%d+'))
        if index then
            if index==1 then
                btn:SetPoint('LEFT', last, 'RIGHT', Save.line, 0)
            else
                btn:SetPoint('TOP',_G['ReagentBankFrameItem'..(index-Save.num)], 'BOTTOM', 0, -Save.line)
            end
        end
    end)

    local last2
    for i=1, 7 do
        local btn= BankSlotsFrame['Bag'..i]
        if btn then
            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', _G['BankFrameItem'..Save.num], 'BOTTOMLEFT', 0,-8)
            else
                btn:SetPoint('LEFT', last2, 'RIGHT', Save.line, 0)
            end
            last2= btn
        end
    end]]

    --BankSlotsFrame.Bag1:ClearAllPoints()
    --BankSlotsFrame.Bag1:SetPoint()
    --ReagentBankFrame:ClearAllPoints()
    ReagentBankFrame:SetSize(715, 415)--386, 415
    --ReagentBankFrame:SetPoint('TOPLEFT')
    

    --设置，显示材料银行
    function ReagentBankFrame.ShowHideButton:show_hide(hide)
        --local unlocked= IsReagentBankUnlocked()
        if (not Save.hideReagentBankFrame or hide) and BankFrame.activeTabIndex then
            if BankFrame.activeTabIndex==1 and not hide then
               -- BankFrame:SetSize(370, 300)--<Size x="386" y="415"/>
                ReagentBankFrame:ClearAllPoints()
                if Save.pointReagentBank then
                    ReagentBankFrame:SetPoint(Save.pointReagentBank[1], UIParent, Save.pointReagentBank[3], Save.pointReagentBank[4],  Save.pointReagentBank[5])
                else
                    ReagentBankFrame:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save.xReagentBankFrame, Save.yReagentBankFrame)
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
        ReagentBankFrame.autoSortButton:SetShown(not Save.hideReagentBankFrame and BankFrame.activeTabIndex==1)--整理材料银行
    end
    hooksecurefunc('BankFrame_ShowPanel', ReagentBankFrame.ShowHideButton.show_hide)
end



--###########
--加载保存数据
--###########


panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= e.Icon.bank2..(e.onlyChinese and '银行' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if not Save.disabled then
                Init_Bank_Frame()--银行
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]= Save
        end
    end
end)
