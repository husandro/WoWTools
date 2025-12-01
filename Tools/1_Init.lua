

local P_Save={
    --disabled=true,

    disabledADD={},
    BottomPoint={
        Mount=true,
        Hearthstone=true,
        OpenItems=true,
        MapToy=true,
    },
    scale=1,
    strata='MEDIUM',

    height=10,
    lineNum=10,

    isEnterShow=true,
    isCombatHide=true,
    isMovingHide=true,
    isMainMenuHide=true,
    showIcon=true,
    --loadCollectionUI=nil,
    --show=false,
    --point
    isShowBackground=WoWTools_DataMixin.Player.husandro,

    bgAlpha= 0.5,
    borderAlpha=0,
}



local Button, Category, Layout
local addName= WoWTools_ToolsMixin.addName

local function Save()
    return WoWToolsSave['WoWTools_ToolsButton']
end




local function Init_Panel()



    local initializer=WoWTools_PanelMixin:Check_Button({
        checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save().point=nil
            if Button then
                Button:set_point()
            end
            print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= addName,
        layout= Layout,
        category= Category,
    })

    --[[WoWTools_PanelMixin:OnlyCheck({
        category= Category,
        name= WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS,
        tooltip= '|nCollectionsJournal_LoadUI()|n|n'
                ..(WoWTools_DataMixin.onlyChinese and '登入游戏时|n建议：开启' or
                (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOG_IN, GAME)..'|n'..HELPFRAME_SUGGESTION_BUTTON_TEXT..': '..ENABLE)
        ),
        GetValue= function() return Save().loadCollectionUI end,
        SetValue= function()
            Save().loadCollectionUI= not Save().loadCollectionUI and true or nil
            Button:load_wow_ui()
        end
    }, initializer)]]



    WoWTools_PanelMixin:OnlyButton({
        category= Category,
        layout=Layout,
        title= WoWTools_ToolsMixin.addName,
        buttonText= '|A:QuestArtifact:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        addSearchTags= WoWTools_DataMixin.onlyChinese and '重置' or RESET,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_ToolsMixin.addName
                ..'|n|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    WoWToolsSave['WoWTools_ToolsButton']=nil
                    WoWTools_DataMixin:Reload()
                end
            )
        end,
        tooltip=WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项: 需要重新加载' or (OPTIONS..': '..REQUIRES_RELOAD))

do
    for _, data in pairs(WoWTools_ToolsMixin:Get_AddList()) do
        initializer=nil
        if not data.isPlayerSetupOptions then--用户，自定义设置，选项，法师

            if data.isMoveButton then--食物
                initializer= WoWTools_PanelMixin:OnlyCheck({
                    category= Category,
                    name= data.tooltip,
                    tooltip= data.name,
                    GetValue= function() return not Save().disabledADD[data.name] end,
                    SetValue= function()
                        Save().disabledADD[data.name]= not Save().disabledADD[data.name] and true or nil
                    end
                })

            else

                initializer= WoWTools_PanelMixin:CheckMenu({
                    category=Category,
                    layout=Layout,
                    name=data.tooltip,
                    tooltip=data.name,
                    GetValue= function() return not Save().disabledADD[data.name] end,
                    SetValue= function()
                        Save().disabledADD[data.name]= not Save().disabledADD[data.name] and true or nil
                    end,

                    DropDownGetValue=function(...)
                        return Save().BottomPoint[data.name] and 2 or 1
                    end,
                    DropDownSetValue=function(value)
                        Save().BottomPoint[data.name]= value==2 and true or nil
                        WoWTools_ToolsMixin:RestAllPoint()--重置所有按钮位置
                    end,
                    GetOptions=function()
                        local container = Settings.CreateControlTextContainer()
                        container:Add(1, '|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE))
                        container:Add(2, '|A:Bags-padlock-authenticator:0:0|a'..(WoWTools_DataMixin.onlyChinese and '位于下方' or QUESTLINE_LOCATED_BELOW))
                        return container:GetData()
                    end
                })
            end
        end
        if data.option then
            data.option(Category, Layout, initializer)
        end
    end
end

    WoWTools_ToolsMixin:Clear_AddList()
    Init_Panel= function()end
end















local function Init_Menu(self, root)

    if not self:CanChangeAttribute() then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local sub, sub2
    sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '显示' or SHOW, function()
        return self.Frame:IsShown()
    end, function()
        self:set_shown()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((UnitAffectingCombat('player') and '|cnWARNING_FONT_COLOR:' or '')..(WoWTools_DataMixin.onlyChinese and '脱离战斗' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT))
    end)

--显示
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '显示' or SHOW)
    sub:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save().isEnterShow
    end, function()
        Save().isEnterShow = not Save().isEnterShow and true or false
    end)

--隐藏
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
    sub:CreateCheckbox('|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(WoWTools_DataMixin.onlyChinese and '进入战斗' or ENTERING_COMBAT), function()
        return Save().isCombatHide
    end, function()
        Save().isCombatHide = not Save().isCombatHide and true or false
        self:set_event()
    end)

    sub:CreateCheckbox('|A:transmog-nav-slot-feet:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE), function()
        return Save().isMovingHide
    end, function()
        Save().isMovingHide = not Save().isMovingHide and true or false
        self:set_event()
    end)

    sub:CreateCheckbox(
        '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '显示主菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, MAINMENU_BUTTON)),
    function()
        return Save().isMainMenuHide
    end, function()
        Save().isMainMenuHide= not Save().isMainMenuHide and true or false
    end)


--选项
    root:CreateDivider()
    sub=WoWTools_ToolsMixin:OpenMenu(root)

    sub2=sub:CreateCheckbox('30x30', function()
        return Save().height==30
    end, function()
        Save().height= Save().height==10 and 30 or 10
        self:set_size()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '图标' or EMBLEM_SYMBOL,
    function()
        return Save().showIcon
    end, function()
        Save().showIcon= not Save().showIcon and true or false
        self:set_icon()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_TextMixin:GetShowHide(nil, true))
    end)

--显示背景
    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return Save().bgAlpha
    end, function(value)
        Save().bgAlpha= value
        WoWTools_ToolsMixin:ShowBackground()--显示背景
    end)

--缩放
   WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale
    end, function(data)
        if self:CanChangeAttribute() then
            Save().scale=data
            self:set_scale()
        else
            print(WoWTools_DataMixin.addName, WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)



--外框，透明度
    sub2=sub:CreateButton(
        '|A:bag-reagent-border:0:0|a'..(WoWTools_DataMixin.onlyChinese and '镶边' or EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end)

--Border 透明度
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().borderAlpha or 0
        end, setValue=function(value)
            Save().borderAlpha=value
            local list, Name= WoWTools_ToolsMixin:Get_All_Buttons()
            for _, name in pairs(list) do
                _G[Name..name]:set_border_alpha()
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '改变透明度' or CHANGE_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })

--Border 透明度
    --[[sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().borderAlpha or 0.3
        end, setValue=function(value)
            Save().borderAlpha=value
            local list, Name= WoWTools_ToolsMixin:Get_All_Buttons()
            for _, name in pairs(list) do
                _G[Name..name]:set_border_alpha()
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '镶边' or EMBLEM_BORDER,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '改变透明度' or CHANGE_OPACITY)
        end,
    })
    sub:CreateSpacer()]]



    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:set_point()
    end)

--重新加载UI
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub, false)
end
















local function Init()
    --[[function Button:load_wow_ui()
        if Save().loadCollectionUI then
            WoWTools_LoadUIMixin:Journal()
        end
    end]]

    function Button:set_size()
        self:SetHeight(Save().height)
    end

    Button.texture:SetAlpha(0.5)

    function Button:set_icon()
        self.texture:SetShown(Save().showIcon)
    end


    function Button:set_point()
        if self:IsProtected() and InCombatLockdown() then
           print(WoWTools_DataMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        else
            self:ClearAllPoints()
            local p=Save().point
            if p and p[1] then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            elseif WoWTools_DataMixin.Player.husandro then
                self:SetPoint('BOTTOMRIGHT', -420, 10)
            else
                self:SetPoint('CENTER', 300, 100)
            end
        end
    end

    function Button:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save().scale or 1)
        else
            print(WoWTools_DataMixin.addName, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        end
    end

    function Button:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    function Button:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine((self:CanChangeAttribute() and '' or '|cff626262')..WoWTools_TextMixin:GetShowHide(nil, true), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scale or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE or SLASH_TEXTTOSPEECH_MENU, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end

    Button:RegisterForDrag("RightButton")
    Button:SetMovable(true)
    Button:SetClampedToScreen(true)

    Button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    Button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        end
    end)

    Button:SetScript("OnLeave",function()
        GameTooltip:Hide()
        ResetCursor()
    end)

    Button:SetScript('OnEnter', function(self)
        WoWTools_ToolsMixin:EnterShowFrame(self)
        self:set_tooltip()
    end)

    Button:SetScript("OnMouseUp", ResetCursor)
    Button:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    Button:SetScript('OnMouseWheel', function(self, d)
        Save().scale=WoWTools_FrameMixin:ScaleFrame(self, d, Save().scale, nil)
    end)

    Button:SetScript("OnClick", function(self, d)
        if IsModifierKeyDown() then
            return
        end
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)

        elseif d=='LeftButton' then
            self:set_shown()
        end
    end)

    --Button:load_wow_ui()
    Button:set_scale()
    Button:set_point()
    Button:set_strata()


    function Button:set_shown()
        if self.Frame:CanChangeAttribute() then
            self.Frame:SetShown(not self.Frame:IsShown())
        end
    end

    function Button:set_event()
        self.Frame:UnregisterAllEvents()
        if Save().isCombatHide then
            self.Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
        if Save().isMovingHide then
            self.Frame:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    Button.Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            if self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        elseif event=='PLAYER_STARTED_MOVING' then
            if self:CanChangeAttribute() and self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        end
    end)
    Button:set_event()

    GameMenuFrame:HookScript('OnShow', function()
        if Button.Frame:IsShown() and Save().isMainMenuHide then
            Button:set_shown()
        end
    end)



    Init=function()end
end















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['WoWTools_ToolsButton']= WoWToolsSave['WoWTools_ToolsButton'] or P_Save
            P_Save= nil

            Save().borderAlpha= Save().borderAlpha or 0.3

            if type(Save().bgAlpha)~='number' then
                Save().bgAlpha= 0
            end

            Save().BottomPoint= Save().BottomPoint or {
                Mount=true,
                Hearthstone=true,
                OpenItems=true,
                MapToy=true,
            }

            Button= WoWTools_ToolsMixin:Init()

            Category, Layout= WoWTools_PanelMixin:AddSubCategory({
                name=addName,
                disabled= not Button,
            })

            WoWTools_ToolsMixin.Category= Category
            WoWTools_ToolsMixin.Layout= Layout

            if Button then
                Init()
                self:RegisterEvent("PLAYER_LOGOUT")
            end

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                Init_Panel()
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            Save().show= Button and Button.Frame:IsShown()
        end
    end
end)