local id, e = ...
local addName= BANK
local Save={
     --disabled=true,--禁用
    --notShowReagentBankFrame=true,--银行,隐藏，材料包
    scaleReagentBankFrame=0.75,--银行，缩放
    --xReagentBankFrame=15,--坐标x
    --yReagentBankFrame=10,--坐标y
}










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
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function(self)
        C_Container.SortReagentBankBags();
    end)

    --选项
    ReagentBankFrame.ShowHideButton= e.Cbtn(BankFrame, {size={18,18}, atlas='hide'})
    ReagentBankFrame.ShowHideButton:SetPoint('BOTTOMRIGHT', _G['BankFrameTab1'], 'BOTTOMLEFT')
    function ReagentBankFrame.ShowHideButton:set_atlas()
        self:SetNormalAtlas(Save.notShowReagentBankFrame and 'editmode-up-arrow' or 'editmode-down-arrow')
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
        local col= ReagentBankFrame:IsShown() and '' or '|cff606060'
        e.tips:AddDoubleLine(e.onlyChinese and '显示材料银行' or REAGENT_BANK, e.GetShowHide(not Save.notShowReagentBankFrame)..e.Icon.left)
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scaleReagentBankFrame or 1), col..'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(col..'X |cnGREEN_FONT_COLOR:'..(Save.xReagentBankFrame or -15), col..'Ctrl+'..e.Icon.mid)
        e.tips:AddDoubleLine(col..'Y |cnGREEN_FONT_COLOR:'..(Save.yReagentBankFrame or 10), col..'Shift+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end
    ReagentBankFrame.ShowHideButton:SetScript('OnClick', function(self)
        Save.notShowReagentBankFrame= not Save.notShowReagentBankFrame and true or nil
        self:show_hide(Save.notShowReagentBankFrame)
        self:set_atlas()
        self:set_tooltips()
    end)
    ReagentBankFrame.ShowHideButton:SetScript('OnLeave', function() e.tips:Hide() end)
    ReagentBankFrame.ShowHideButton:SetScript('OnEnter', ReagentBankFrame.ShowHideButton.set_tooltips)
    ReagentBankFrame.ShowHideButton:SetScript('OnMouseWheel', function(self, d)
        if Save.notShowReagentBankFrame then
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
        elseif IsControlKeyDown() then
            n= Save.xReagentBankFrame or -15--坐标 X
            if d==1 then
                n= n+5
            elseif d==-1 then
                n= n-5
            end
            Save.xReagentBankFrame= n
            self:show_hide()--设置，显示材料银行
        elseif IsShiftKeyDown() then
            n= Save.yReagentBankFrame or 10--坐标 Y
            if d==1 then
                n= n+5
            elseif d==-1 then
                n= n-5
            end
            Save.yReagentBankFrame= n
            self:show_hide()--设置，显示材料银行
        end
        self:set_tooltips()
    end)
    ReagentBankFrame.ShowHideButton:set_scale()
    ReagentBankFrame.ShowHideButton:set_atlas()

    ReagentBankFrame:ClearAllPoints()
    ReagentBankFrame:SetSize(386, 415)
    ReagentBankFrame:SetPoint('TOPLEFT')

    --背景
    ReagentBankFrame.Bg= ReagentBankFrame:CreateTexture(nil, 'BACKGROUND')
    ReagentBankFrame.Bg:SetSize(715, 350)
    ReagentBankFrame.Bg:SetPoint('BOTTOMLEFT',10, 10)
    ReagentBankFrame.Bg:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    ReagentBankFrame.Bg:SetAlpha(0.7)

    --设置，显示材料银行
    function ReagentBankFrame.ShowHideButton:show_hide(hide)
        if (not Save.notShowReagentBankFrame or hide) and BankFrame.activeTabIndex then

            if BankFrame.activeTabIndex==1 and not hide then
                ReagentBankFrame:SetPoint('TOPLEFT', BankFrame, 'BOTTOMLEFT', Save.xReagentBankFrame or -15, Save.yReagentBankFrame or 10)
                ReagentBankFrame:SetShown(true)
            elseif BankFrame.activeTabIndex==2 or hide then
                ReagentBankFrame:SetPoint('TOPLEFT')
                if hide then
                    ReagentBankFrame:SetShown(false)
                end
            end
        end
        ReagentBankFrame.ShowHideButton:SetShown(BankFrame.activeTabIndex==1)--选项
        ReagentBankFrame.ShowHideButton:set_scale()--缩放
        ReagentBankFrame.autoSortButton:SetShown(not Save.notShowReagentBankFrame and BankFrame.activeTabIndex==1)--整理材料银行
    end
    hooksecurefunc('BankFrame_ShowPanel', ReagentBankFrame.ShowHideButton.show_hide)
end



--###########
--加载保存数据
--###########

local panel= CreateFrame("Frame")
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