local id, e = ...
WoWTools_BankFrame={
Save={
    --disabled=true,--禁用
    --hideReagentBankFrame=true,--银行,隐藏，材料包
    --scaleReagentBankFrame=0.75,--银行，缩放
    xReagentBankFrame=-15,--坐标x
    yReagentBankFrame=10,--坐标y
    --pointReagentBank=｛｝--保存位置
    line=2,
    num=14,
    --notSearchItem=true,--OnEnter时，搜索物品
    --showIndex=true,--显示，索引
    --showBackground= true,--设置，背景

    allBank=e.Player.husandro,--转化为联合的大包
    show_AllBank_Type=e.Player.husandro,--大包时，显示，存取，分类，按钮
    
    left_List= true,
    
    --show_AllBank_Type_Scale=1,
},
addName=nil,

Init_All_Bank=function()end,
Init_Left_List=function()end,
Init_Desposit_TakeOut=function()end,
Init_Bank_Plus=function()end,

}


local function Save()
    return WoWTools_BankFrame.Save
end





























































































--#######
--设置菜单
--#######
local function Init_Menu(self, root)
    local sub= root:CreateCheckbox(e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED, function()
        return Save().allBank
    end, function()
        Save().allBank= not Save().allBank and true or nil
        self:set_atlas()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    WoWTools_MenuMixin:Reload(sub, false)

    if Save().allBank then
        root:CreateDivider()
        root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
            return Save().showIndex
        end, function()
            Save().showIndex= not Save().showIndex and true or nil--显示，索引
            local btn= _G['WoWTools_SetAllBankButton']
            if btn then
                btn:set_bank()--设置，银行，按钮
                btn:set_reagent()--设置，材料，按钮
                btn:set_size()--设置，外框，大小
            end
        end)


        --[[root:CreateCheckbox(e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND, function()
            return Save().showBackground or Save().showBackground==nil
        end, function()
            Save().showBackground= not Save().showBackground and true or false
            if _G['WoWTools_SetAllBankButton'] then
                _G['WoWTools_SetAllBankButton']:set_background()--设置，背景
            end
        end)]]
    end

    
    root:CreateCheckbox(e.onlyChinese and '左边列表' or 'Left List', function()
        return Save().left_List
    end, function()
        Save().left_List= not Save().left_List and true or nil
        WoWTools_BankFrame:Init_Left_List()--分类，存取,
    end)
    
    root:CreateCheckbox(
        e.onlyChinese and '自动打开背包栏位' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOTTEXT)),
    function()
        return Save().openBagInBank
    end, function()
        Save().openBagInBank= not Save().openBagInBank and true or nil
        self:set_event()
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankFrame.addName})
end
















local function Set_Texture()
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
            ReagentBankFrame[textrue]:SetAlpha(0)
        end
    end

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
    AccountBankPanel.Header.Text:ClearAllPoints()
    AccountBankPanel.Header.Text:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -12, 0)
    e.Set_Alpha_Frame_Texture(BankFrameTab1, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab2, {isMinAlpha=true})
    e.Set_Alpha_Frame_Texture(BankFrameTab3, {isMinAlpha=true})

    BankFrame:EnableDrawLayer('BACKGROUND')
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetPoint('TOPLEFT', BankFrame)
    BankFrame.Background:SetPoint('BOTTOMRIGHT', BankFrame)
    BankFrame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
end




















--银行
--BankFrame.lua
local function Init()
    local OptionButton= WoWTools_ButtonMixin:Cbtn(BankFrame.TitleContainer, {size={22,22}, atlas='hide'})
    if _G['MoveZoomInButtonPerBankFrame'] then
        OptionButton:SetPoint('LEFT', _G['MoveZoomInButtonPerBankFrame'], 'RIGHT')
    else
        OptionButton:SetPoint('LEFT', 34,0)
    end
    function OptionButton:set_atlas()
        self:SetNormalAtlas(Save().allBank and 'Warfronts-BaseMapIcons-Alliance-Workshop-Minimap' or 'Warfronts-BaseMapIcons-Empty-Workshop-Minimap')
    end
    OptionButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) end)
    OptionButton:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
    OptionButton:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)
    OptionButton:SetAlpha(0.5)
    OptionButton:set_atlas()

    function OptionButton:set_event()
        if Save().openBagInBank then
            self:RegisterEvent('BANKFRAME_OPENED')
        else
            self:UnregisterEvent('BANKFRAME_OPENED')
        end
    end
    OptionButton:SetScript('OnEvent', function()
        WoWTools_BankMixin:OpenBag()
    end)
    OptionButton:set_event()




    --整理材料银行
    ReagentBankFrame.autoSortButton= CreateFrame("Button", nil, ReagentBankFrame, 'BankAutoSortButtonTemplate')
    ReagentBankFrame.autoSortButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '整理材料银行' or BAG_CLEANUP_REAGENT_BANK)
        e.tips:Show()
    end)
    ReagentBankFrame.autoSortButton:SetScript('OnClick', function()
        C_Container.SortReagentBankBags()
    end)


    if Save().allBank then
        WoWTools_BankFrame:Init_All_Bank()--整合，一起
    else
        WoWTools_BankFrame:Init_Bank_Plus()--原生, 增强
    end

    WoWTools_BankFrame:Init_Desposit_TakeOut()--存放，取出，所有

    C_Timer.After(4, function()--分类，存取, 2秒为翻译加载时间
        WoWTools_BankFrame:Init_Left_List()
    end)

    Set_Texture()
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
            WoWTools_BankFrame.addName= '|A:Banker:0:0|a'..(e.onlyChinese and '银行' or BANK)

            WoWTools_BankFrame.Save= WoWToolsSave['Plus_Bank'] or WoWTools_BankFrame.Save

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_BankFrame.addName,
                GetValue=function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_BankFrame.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if not Save().disabled then
                Init()--银行
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Bank']= WoWTools_BankFrame.Save
        end
    end
end)
