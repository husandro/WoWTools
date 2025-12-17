local P_Save={
    --disabled=true,    
    disabledADD={
        ['ChatButton_Emoji']= not WoWTools_DataMixin.Player.IsCN and not WoWTools_DataMixin.Player.husandro,
    },
    scale= 1,
    strata='MEDIUM',
    --isVertical=nil,--方向, 竖
    --isShowBackground=nil,--是否显示背景 bool
    isEnterShowMenu= WoWTools_DataMixin.Player.husandro,-- 移过图标，显示菜单

    borderAlpha=0,--外框，透明度
    bgAlpha=0,

    pointX=0,
    anchorMenuIndex=1,--菜单位置 下，上，左，右
    setChatFrameLeft=nil,--放到聊天框左边

    disabledTooltiip=nil,--禁用提示

}



local function Save()
    return WoWToolsSave['ChatButton'] or {}
end










local function Set_All_Buttons(self)
    local Buttons= WoWTools_ChatMixin:GetButtons()
    local Name= WoWTools_ChatMixin:GetNameText()
    for _, name in pairs(Buttons) do
        _G[Name..name]:SetAllSettings()
    end
    self:set_backgroud()
    self:set_menu_anchor()
end











local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local sub, sub2
--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scale
    end, function(value)
        Save().scale= value
        self:settings()
    end)

--显示背景
    sub=WoWTools_MenuMixin:BgAplha(root, function()
        return Save().bgAlpha or 0
    end, function(value)
        Save().bgAlpha=value
        self:set_backgroud()
    end, function()
        Save().bgAlpha= nil
        Save().bgUseClassColor= nil
        self:set_backgroud()
    end)

--职业颜色
    sub:CreateSpacer()
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '职业颜色' or CLASS_COLORS,
    function()
        return Save().bgUseClassColor
    end, function()
        Save().bgUseClassColor= not Save().bgUseClassColor and true or nil
        self:set_backgroud()
    end)


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:settings()
        return MenuResponse.Refresh
    end)

--外框，透明度
    sub=root:CreateButton(
        '|A:bag-reagent-border:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镶边' or EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end, {rightText=Save().borderAlpha or 0.3})
    WoWTools_MenuMixin:SetRightText(sub)

--Border 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().borderAlpha or 0.3
        end, setValue=function(value)
            Save().borderAlpha=value
            Set_All_Buttons(self)
        end,
        name=WoWTools_DataMixin.onlyChinese and '改变透明度' or HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })

    sub:CreateSpacer()
    sub:CreateSpacer()

    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().pointX or 0
        end, setValue=function(value)
            Save().pointX=value
            Set_All_Buttons(self)
        end,
        name='X',
        minValue=-15,
        maxValue=15,
        step=1,
    })

    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '重置' or RESET,
    function()
        Save().pointX=0
        Save().borderAlpha=0.3
        Set_All_Buttons(self)
        return MenuResponse.Open
    end)


--方向, 竖
    sub=root:CreateCheckbox(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION),
    function()
        return Save().isVertical
    end, function()
        Save().isVertical= not Save().isVertical and true or nil
        self:settings()
        Set_All_Buttons(self)
    end)



--菜单位置
    local textTab={
      '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN),
      WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
      WoWTools_DataMixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
      WoWTools_DataMixin.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    }
    for index, tab in pairs(WoWTools_ChatMixin.AnchorMenuTab) do
        sub2=sub:CreateCheckbox(
            textTab[index],
        function(data)
            return (Save().anchorMenuIndex or 1)==data.index

        end, function(data)
            Save().anchorMenuIndex= data.index
            Set_All_Buttons(self)

        end, {index=index, p=tab[1], p2=tab[2]})

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '菜单位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_MICRO_MENU_LABEL,CHOOSE_LOCATION))
            tooltip:AddDoubleLine(desc.data.p, desc.data.p2)
        end)
    end

--HUD提示信息

    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and 'HUD提示信息' or HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
    function()
        return not Save().disabledTooltiip
    end, function()
        Save().disabledTooltiip= not Save().disabledTooltiip and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('GameTooltip')
    end)

--UIParent
    sub= root:CreateCheckbox(
        'UIParent',
    function()
        return not Save().setParent
    end, function()
        Save().setParent= not Save().setParent and true or nil
        self:settings()
        MenuUtil.ShowTooltip(self, function(tooltip)
            tooltip:AddLine('SetParent '..'|cnGREEN_FONT_COLOR:'..self:GetParent():GetName())
        end)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('SetParent '..'|cnGREEN_FONT_COLOR:'..self:GetParent():GetName())
    end)
--WoWTools_DataMixin.onlyChinese and '聊天框底部' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_CHAT_FRAME_LABEL, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_DOWN),
--放到聊天框左边

    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '聊天框' or HUD_EDIT_MODE_CHAT_FRAME_LABEL,
    function()
        return Save().setChatFrameLeft
    end, function()
        Save().setChatFrameLeft= not Save().setChatFrameLeft and true or nil
        if Save().setChatFrameLeft then
            Save().Point= nil
        end
        self:settings()
    end)


--移过图标
    sub=root:CreateCheckbox(
        '|A:newplayertutorial-drag-cursor:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)),
    function()
        return Save().isEnterShowMenu
    end, function()
        Save().isEnterShowMenu = not Save().isEnterShowMenu and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, HUD_EDIT_MODE_MICRO_MENU_LABEL))
    end)



--打开选项界面
    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, nil)

    --重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().Point, function()
        Save().Point=nil
        self:settings()
        return MenuResponse.Open
    end)
end
















    --[[WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsChatButtonMainButton',
        icon='hide',
        frameType='DropdownButton',
    })]]

local function Init()
    local btn= CreateFrame('DropdownButton', 'WoWToolsChatButtonMainButton', UIParent)

    WoWTools_ChatMixin:Set_Button_Script(btn)
    btn:SetHighlightAtlas('WoWShare-Highlight')
    btn:SetPushedAtlas('WoWShare-Selection')

    btn.Background= btn:CreateTexture(nil, 'BACKGROUND')

    function btn:set_backgroud()
        local Name= WoWTools_ChatMixin:GetNameText()
        local Buttons= WoWTools_ChatMixin:GetButtons()
        local btn1= Buttons[1] and _G[Name..Buttons[1]]
        if not btn1 then
            self.Background:SetColorTexture(0,0,0,0)
            return
        end

        local btn2= _G[Name..Buttons[#Buttons]]

        self.Background:ClearAllPoints()

        self.Background:SetPoint('BOTTOMLEFT', btn1, -2, -2)

        local w= 30+ 4
        if Save().isVertical then
            self.Background:SetPoint('TOPLEFT', btn2, -2, 2)
            self.Background:SetWidth(w)
        else
            self.Background:SetPoint('BOTTOMRIGHT', btn2, 2, -2)
            self.Background:SetHeight(w+1)
        end

        local r,g,b,a= 0, 0, 0, Save().bgAlpha or 0
        if Save().bgUseClassColor then
            r,g,b= PlayerUtil.GetClassColor():GetRGB()
        end
        self.Background:SetColorTexture(r,g,b,a)
    end

    function btn:set_menu_anchor()
        local point= WoWTools_ChatMixin.AnchorMenuTab[Save().anchorMenuIndex or 1]
        self:SetMenuAnchor(AnchorUtil.CreateAnchor(point[1], self, point[2]))
    end


    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)
    WoWTools_TextureMixin:SetEditBox(SELECTED_DOCK_FRAME.editBox, {alpha=1})

    function btn:settings()
        if Save().isVertical then--方向, 竖
            self:SetSize(30,10)
        else
            self:SetSize(10,30)
        end
        self:set_menu_anchor()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
        self:SetScale(Save().scale or 1)

        self:ClearAllPoints()

        local toChatFrame= Save().setChatFrameLeft and true or false
        if toChatFrame then
            self:SetPoint('TOP', ChatFrameMenuButton, 'BOTTOM')
        elseif Save().Point then
            self:SetPoint(Save().Point[1], UIParent, Save().Point[3], Save().Point[4], Save().Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end

        self:SetParent(Save().setParent and GeneralDockManager or UIParent)

        self:SetMovable(not toChatFrame)
        self:SetClampedToScreen(toChatFrame)
        self:RegisterForDrag(toChatFrame and '' or "RightButton")
    end

    function btn:set_tooltip()
        if not self:IsMovable() then
            return
        end
        GameTooltip:SetText(
            (WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
            ..' Alt+'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
    end


    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().Point={self:GetPoint(1)}
            Save().Point[2]=nil
        end
    end)

    btn:SetScript("OnMouseUp", function()
        ResetCursor()
    end)
    btn:SetScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' and self:IsMovable() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
            self:CloseMenu()
        end
    end)

    btn:settings()
    btn:SetupMenu(Init_Menu)

    Init=function()end
end























local function Init_Panel()
    if Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(WoWTools_ChatMixin.Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    for _, data in pairs (WoWTools_ChatMixin:GetAllAddList()) do
        WoWTools_PanelMixin:OnlyCheck({
            category= WoWTools_ChatMixin.Category,
            name= data.tooltip,
            tooltip= data.name,
            Value= not Save().disabledADD[data.name],
            GetValue= function() return not Save().disabledADD[data.name] end,
            SetValue= function()
                Save().disabledADD[data.name]= not Save().disabledADD[data.name] and true or nil
            end
        })
    end

    Init_Panel=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton']= WoWToolsSave['ChatButton'] or P_Save
            Save().disabledADD= Save().disabledADD or {}
            P_Save=nil

            if not Save().disabled then
                Init()
            end

            WoWTools_ChatMixin.addName='|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_DataMixin.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS))

            WoWTools_ChatMixin.Category, WoWTools_ChatMixin.Layout= WoWTools_PanelMixin:AddSubCategory({
                name=WoWTools_ChatMixin.addName,
                disabled=Save().disabled
            })

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init_Panel()
                end,
                buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
                buttonFunc= function()
                    StaticPopup_Show('WoWTools_RestData',
                        WoWTools_ChatMixin.addName
                        ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                        nil,
                    function()
                        WoWToolsSave['ChatButton']= nil
                        WoWTools_DataMixin:Reload()
                    end)
                end,
                tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                layout= WoWTools_ChatMixin.Layout,
                category= WoWTools_ChatMixin.Category,
            })

            WoWTools_PanelMixin:OnlyButton({
                buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                category= WoWTools_ChatMixin.Category,
                SetValue= function()
                    Save().Point=nil
                    if _G['WoWToolsChatButtonMainButton'] then
                        _G['WoWToolsChatButtonMainButton']:settings()
                    end
                    print(
                        WoWTools_ChatMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
                    )
                end
            })

            WoWTools_PanelMixin:Header(WoWTools_ChatMixin.Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                Init_Panel()
                self:UnregisterEvent(event)
                self:SetScript('OnEvent', nil)
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)