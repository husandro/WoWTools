local id, e = ...
WoWTools_BankFrameMixin={
Save={
    --disabled=true,--禁用
    --hideReagentBankFrame=true,--银行,隐藏，材料包
    --scaleReagentBankFrame=0.75,--银行，缩放
    --xReagentBankFrame=-15,--坐标x
    --yReagentBankFrame=10,--坐标y
    --pointReagentBank=｛｝--保存位置
    line=2,
    num=14,
    --notSearchItem=true,--OnEnter时，搜索物品
    --showIndex=true,--显示，索引
    showBackground= true,--设置，背景

    --allBank=e.Player.husandro,--转化为联合的大包
    show_AllBank_Type=true,--大包时，显示，存取，分类，按钮
    openBagInBank=e.Player.husandro,
    left_List= true,

    --show_AllBank_Type_Scale=1,
},
addName=nil,

Init_All_Bank=function()end,
Init_Left_List=function()end,
Init_Desposit_TakeOut=function()end,
--Init_Bank_Plus=function()end,
--CreateButton=function()end,

}


local function Save()
    return WoWTools_BankFrameMixin.Save
end

function WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    if _G['WoWTools_SetAllBankButton'] then
        _G['WoWTools_SetAllBankButton']:settings()
    end
end


function WoWTools_BankFrameMixin:Set_Background_Texture(texture)
    if texture then
        if self.Save.showBackground then
            texture:SetAtlas('bank-frame-background')
        else
            texture:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
        end
    end
end














--#######
--设置菜单
--#######
local function Init_Menu(self, root)
    local sub
    --[[local sub= root:CreateCheckbox(e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED, function()
        return Save().allBank
    end, function()
        Save().allBank= not Save().allBank and true or nil
        self:set_atlas()
    end)

--需要重新加载
    root:CreateDivider()
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)]]
    

--左边列表
    root:CreateCheckbox(e.onlyChinese and '左边列表' or 'Left List', function()
        return Save().left_List
    end, function()
        Save().left_List= not Save().left_List and true or nil
        WoWTools_BankFrameMixin:Init_Left_List()--分类，存取,
    end)

--自动打开背包栏位
    sub=root:CreateCheckbox(
        e.onlyChinese and '自动打开背包栏位' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOTTEXT)),
    function()
        return Save().openBagInBank
    end, function()
        Save().openBagInBank= not Save().openBagInBank and true or nil
        self:set_event()
    end)
    if _G['NDui_BackpackBank'] then
        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip, 'Bub: NDui')
        end)
        sub:SetEnabled(false)
    end


--整合
    if _G['WoWTools_SetAllBankButton'] then
--索引

    root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    end)

--显示背景
    root:CreateCheckbox(
        e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND,
    function()
        return Save().showBackground
    end, function()
        Save().showBackground= not Save().showBackground and true or nil
        WoWTools_BankFrameMixin:Set_Background_Texture(BankFrame.Background)
        WoWTools_BankFrameMixin:Set_Background_Texture(AccountBankPanel.Background)
    end)

    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().num
        end, setValue=function(value)
            Save().num=value
            WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
        end,
        name=e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=4,
        maxValue=32,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()
    root:CreateSpacer()
    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().line
        end, setValue=function(value)
            Save().line=value
            WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
        end,
        name=e.onlyChinese and '间隔' or 'Interval',
        minValue=0,
        maxValue=32,
        step=1,
        bit=nil,
    })
    root:CreateSpacer()
end

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankFrameMixin.addName})
    WoWTools_MenuMixin:Reload(sub, false)
end
















local function Init_Texture()


    e.Set_NineSlice_Color_Alpha(BankFrame, true)
    e.Set_NineSlice_Color_Alpha(AccountBankPanel, true)
    e.Set_NineSlice_Color_Alpha(BankSlotsFrame, nil, true)
    e.Set_Alpha_Frame_Texture(BankFrameTab1, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {notAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {notAlpha=true})
    BankFrameBg:SetTexture(0)

    e.Set_Alpha_Frame_Texture(ReagentBankFrame.EdgeShadows, {})



    ReagentBankFrame.EdgeShadows:Hide()
    BankSlotsFrame.EdgeShadows:Hide()
    --AccountBankPanel.Header.Text:ClearAllPoints()
    --AccountBankPanel.Header.Text:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -12, 0)
    e.Set_Alpha_Frame_Texture(BankFrameTab1, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {isMinAlpha=true})


    BankFrame:EnableDrawLayer('BACKGROUND')
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)    
    WoWTools_BankFrameMixin:Set_Background_Texture(BankFrame.Background)
    --BankFrame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
end
















local function Init_OpenAllBag_Button()
    local parent= BankSlotsFrame['Bag'..NUM_BANKBAGSLOTS]
    if not parent then
        return
    end

    local up=  WoWTools_ButtonMixin:CreateUpButton(parent, nil, nil)
    up:SetPoint('BOTTOMLEFT', parent, 'RIGHT', 4, -3)
    up:SetScript('OnLeave', GameTooltip_Hide)
    up:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOT))
        e.tips:Show()
    end)
    up:SetScript('OnClick', function()
        do
            WoWTools_BankMixin:OpenBag()
        end
        WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    end)

    local down=  WoWTools_ButtonMixin:CreateDownButton(parent, nil, nil)
    down:SetPoint('TOPLEFT', parent, 'RIGHT', 4, -3)
    down:SetScript('OnLeave', GameTooltip_Hide)
    down:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '关闭背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLOSE, BAGSLOT))
        e.tips:Show()
    end)
    down:SetScript('OnClick', function()
        do
            WoWTools_BankMixin:CloseBag()
        end
        WoWTools_BankFrameMixin:Settings_All_Bank()--设置，整合银行
    end)
end














--银行
--BankFrame.lua
local function Init()
    --local OptionButton= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size={22,22}, atlas='hide'})
    local OptionButton= WoWTools_ButtonMixin:CreateOptionButton(BankSlotsFrame, 'WoWTools_BankFrameOptionButton', nil)
    OptionButton:SetPoint('LEFT',BankFrame.TitleContainer)
    OptionButton:SetFrameStrata(BankFrame.TitleContainer:GetFrameStrata())
    OptionButton:SetFrameLevel(BankFrame.TitleContainer:GetFrameLevel()+1)
 

    OptionButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    OptionButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_BankFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ',(e.onlyChinese and '菜单' or MAINMENU)..e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end)

    OptionButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)
    OptionButton:SetAlpha(0.5)

    function OptionButton:set_event()
        if Save().openBagInBank then
            self:RegisterEvent('BANKFRAME_OPENED')
        else
            self:UnregisterEvent('BANKFRAME_OPENED')
        end
    end
    OptionButton:SetScript('OnEvent', function()
        if not _G['NDui_BackpackBank'] then
            WoWTools_BankMixin:OpenBag()
        end
    end)
    OptionButton:set_event()











    

    --整理材料银行
    ReagentBankFrame.autoSortButton= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    ReagentBankFrame.autoSortButton:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 25, 0)--整理材料银行
    ReagentBankFrame.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)

    --整理材料银行
    AccountBankPanel.autoSortButton= CreateFrame("Button", nil, AccountBankPanel.ItemDepositFrame.DepositButton, 'BankAutoSortButtonTemplate')
    AccountBankPanel.autoSortButton:SetPoint('RIGHT', AccountBankPanel.ItemDepositFrame.DepositButton, 'LEFT', -5, 0)--整理材料银行
    AccountBankPanel.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '清理战团银行' or BAG_CLEANUP_ACCOUNT_BANK)
        e.tips:Show()
    end)
    AccountBankPanel.autoSortButton:SetScript('OnClick', function()
        if GetCVarBool("bankConfirmTabCleanUp") then
        	StaticPopupSpecial_Show(BankCleanUpConfirmationPopup);
        else
            C_Container.SortAccountBankBags();
        end
    end)







    Init_Texture()
    Init_OpenAllBag_Button()





    
    WoWTools_BankFrameMixin:Init_All_Bank()--整合，一起


    WoWTools_BankFrameMixin:Init_Desposit_TakeOut()--存放，取出，所有

    C_Timer.After(4, function()--分类，存取, 2秒为翻译加载时间
        WoWTools_BankFrameMixin:Init_Left_List()
    end)
end

















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_BankFrameMixin.addName= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)
--旧数据
            WoWToolsSave[BANK]=nil
            WoWToolsSave['Bank_Lua']=nil

            WoWTools_BankFrameMixin.Save= WoWToolsSave['Plus_Bank'] or WoWTools_BankFrameMixin.Save

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_BankFrameMixin.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_BankFrameMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if not Save().disabled then
                Init()--银行
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Bank']= WoWTools_BankFrameMixin.Save
        end
    end
end)
