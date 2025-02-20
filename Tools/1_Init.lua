local id, e = ...


local Save={
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

    isEnterShow=true,
    isCombatHide=true,
    isMovingHide=true,
    isMainMenuHide=true,
    --showIcon=false,
    --loadCollectionUI=nil,
    --show=false,
    --point
    isShowBackground=e.Player.husandro,

}


local Button
local addName= WoWTools_ToolsButtonMixin:GetName()





local function Init_Panel()
    local Category, Layout= e.AddPanel_Sub_Category({name=addName})
    WoWTools_ToolsButtonMixin:SetCategory(Category, Layout)


    local initializer=e.AddPanel_Check_Button({
        checkName= e.onlyChinese and '启用' or ENABLE,
        GetValue= function() return not Save.disabled end,
        SetValue= function()
            Save.disabled= not Save.disabled and true or nil
            print(e.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save.point=nil
            if Button then
                Button:set_point()
            end
            print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= addName,
        layout= Layout,
        category= Category,
    })

    e.AddPanel_Check({
        category= Category,
        name= e.onlyChinese and '战团藏品' or COLLECTIONS,
        tooltip= '|nCollectionsJournal_LoadUI()|n|n'
                ..(e.onlyChinese and '登入游戏时|n建议：开启' or
                (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOG_IN, GAME)..'|n'..HELPFRAME_SUGGESTION_BUTTON_TEXT..': '..ENABLE)
        ),
        GetValue= function() return Save.loadCollectionUI end,
        SetValue= function()
            Save.loadCollectionUI= not Save.loadCollectionUI and true or nil
            Button:load_wow_ui()
            Button:save_data()
        end
    }, initializer)

    --[[e.AddPanel_Check({
        category= Category,
        name= e.onlyChinese and '加载专业' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'Load', PROFESSIONS_BUTTON),
        tooltip= '|nProfessionsFrame_LoadUI',
        GetValue= function() return Save.loadProfessionsUI end,
        SetValue= function()
            Save.loadProfessionsUI= not Save.loadProfessionsUI and true or nil
            Button:load_wow_ui()
            Button:save_data()
        end
    }, initializer)]]


    e.AddPanel_Button({
        category= Category,
        layout=Layout,
        title= WoWTools_ToolsButtonMixin:GetName(),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '重置' or RESET),
        addSearchTags= e.onlyChinese and '重置' or RESET,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_ToolsButtonMixin:GetName()
                ..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    Save=nil
                    WoWTools_Mixin:Reload()
                end
            )
        end
    })

    e.AddPanel_Header(Layout, e.onlyChinese and '选项: 需要重新加载' or (OPTIONS..': '..REQUIRES_RELOAD))


    for _, data in pairs (WoWTools_ToolsButtonMixin:GetAllAddList()) do
        initializer=nil
        if not data.isPlayerSetupOptions then--用户，自定义设置，选项，法师

            if data.isMoveButton then--食物
                initializer= e.AddPanel_Check({
                    category= Category,
                    name= data.tooltip,
                    tooltip= data.name,
                    GetValue= function() return not Save.disabledADD[data.name] end,
                    SetValue= function()
                        Save.disabledADD[data.name]= not Save.disabledADD[data.name] and true or nil
                    end
                })

            else

                initializer= e.AddPanel_Check_DropDown({
                    category=Category,
                    layout=Layout,
                    name=data.tooltip,
                    tooltip=data.name,
                    GetValue= function() return not Save.disabledADD[data.name] end,
                    SetValue= function()
                        Save.disabledADD[data.name]= not Save.disabledADD[data.name] and true or nil
                    end,

                    DropDownGetValue=function(...)
                        return Save.BottomPoint[data.name] and 2 or 1
                    end,
                    DropDownSetValue=function(value)
                        Save.BottomPoint[data.name]= value==2 and true or nil
                        WoWTools_ToolsButtonMixin:SetSaveData(Save)
                        WoWTools_ToolsButtonMixin:RestAllPoint()--重置所有按钮位置
                    end,
                    GetOptions=function()
                        local container = Settings.CreateControlTextContainer()
                        container:Add(1, '|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '位于上方' or QUESTLINE_LOCATED_ABOVE))
                        container:Add(2, '|A:Bags-padlock-authenticator:0:0|a'..(e.onlyChinese and '位于下方' or QUESTLINE_LOCATED_BELOW))
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















local function Init_Menu(self, root)
    local sub, sub2
    local isInCombat=UnitAffectingCombat('player')
    sub=root:CreateCheckbox(e.onlyChinese and '显示' or SHOW, function()
        return self.Frame:IsShown()
    end, function()
        self:set_shown()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((UnitAffectingCombat('player') and '|cnRED_FONT_COLOR:' or '')..(e.onlyChinese and '脱离战斗' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT))
    end)

--显示
    sub:CreateTitle(e.onlyChinese and '显示' or SHOW)
    sub:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save.isEnterShow
    end, function()
        Save.isEnterShow = not Save.isEnterShow and true or nil
        self:save_data()
    end)

--隐藏
    sub:CreateTitle(e.onlyChinese and '隐藏' or HIDE)
    sub:CreateCheckbox('|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(e.onlyChinese and '进入战斗' or ENTERING_COMBAT), function()
        return Save.isCombatHide
    end, function()
        Save.isCombatHide = not Save.isCombatHide and true or nil
        self:set_event()
    end)

    sub:CreateCheckbox('|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '移动' or NPE_MOVE), function()
        return Save.isMovingHide
    end, function()
        Save.isMovingHide = not Save.isMovingHide and true or nil
        self:set_event()
    end)

    sub:CreateCheckbox(
        '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'
        ..(e.onlyChinese and '显示主菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, MAINMENU_BUTTON)),
    function()
        return Save.isMainMenuHide
    end, function()
        Save.isMainMenuHide= not Save.isMainMenuHide and true or nil
    end)


--选项
    root:CreateDivider()
    sub=WoWTools_ToolsButtonMixin:OpenMenu(root)

    sub2=sub:CreateCheckbox('30x30', function()
        return Save.height==30
    end, function()
        Save.height= Save.height==10 and 30 or 10
        self:set_size()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE)
    end)

    sub2=sub:CreateCheckbox('|A:'..e.Icon.icon..':0:0|a'..(e.onlyChinese and '图标' or EMBLEM_SYMBOL), function()
        return Save.showIcon
    end, function()
        Save.showIcon= not Save.showIcon and true or nil
        self:set_icon()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.GetShowHide(nil, true))
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(sub,
    function()
        return Save.isShowBackground
    end, function()
        Save.isShowBackground= not Save.isShowBackground and true or nil
        self:save_data()
        WoWTools_ToolsButtonMixin:ShowBackground()--显示背景
    end)


    sub2= WoWTools_MenuMixin:Scale(self, sub, function()
        return Save.scale
    end, function(data)
        if self:CanChangeAttribute() then
            Save.scale=data
            self:set_scale()
        else
            print(e.addName, e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        end
    end)
    sub2:SetEnabled(self:CanChangeAttribute())

   sub2= WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save.strata= data
        self:set_strata()
    end)
    
    

    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save.point, function()
        Save.point=nil
        self:set_point()
    end)

--重新加载UI
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub, false)
end
















local function Init()
    function Button:load_wow_ui()
        if Save.loadCollectionUI then
            WoWTools_LoadUIMixin:Journal()
        end
    end

    function Button:set_size()
        self:SetHeight(Save.height)
    end

    Button.texture:SetAlpha(0.5)

    function Button:set_icon()
        self.texture:SetShown(Save.showIcon)
    end

    function Button:save_data()
        WoWTools_ToolsButtonMixin:SetSaveData(Save)
    end

    function Button:set_point()
        if not self:CanChangeAttribute() then
           print(e.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        else
            self:ClearAllPoints()
            if Save.point then
                self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
            elseif e.Player.husandro then
                self:SetPoint('BOTTOMRIGHT', -420, 10)
            else
                self:SetPoint('CENTER', 300, 100)
            end
        end
    end

    function Button:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save.scale or 1)
        else
            print(e.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
        end
    end

    function Button:set_strata()
        self:SetFrameStrata(Save.strata or 'MEDIUM')
    end

    function Button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..e.GetShowHide(nil, true), e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE or SLASH_TEXTTOSPEECH_MENU, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
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
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
    end)

    Button:SetScript("OnLeave",function(self)
        e.tips:Hide()
        ResetCursor()
    end)

    Button:SetScript('OnEnter', function(self)
        WoWTools_ToolsButtonMixin:EnterShowFrame(self)
        self:set_tooltip()
    end)

    Button:SetScript("OnMouseUp", ResetCursor)
    Button:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    Button:SetScript('OnMouseWheel', function(self, d)
        Save.scale=WoWTools_FrameMixin:ScaleFrame(self, d, Save.scale, nil)
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

    Button:load_wow_ui()
    Button:set_scale()
    Button:set_point()
    Button:set_strata()


    function Button:set_shown()
        if not UnitAffectingCombat('player') then
            self.Frame:SetShown(not self.Frame:IsShown())
        end
    end

    function Button:set_event()
        self.Frame:UnregisterAllEvents()
        if Save.isCombatHide then
            self.Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
        if Save.isMovingHide then
            self.Frame:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    Button.Frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            if self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        elseif event=='PLAYER_STARTED_MOVING' then
            if not UnitAffectingCombat('player') and self:IsShown() then
                self:SetShown(false)--设置, TOOLS 框架,隐藏
            end
        end
    end)
    Button:set_event()

    GameMenuFrame:HookScript('OnShow', function()
        if Button.Frame:IsShown() and Save.isMainMenuHide then
            Button:set_shown()
        end
    end)
end















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave['WoWTools_ToolsButton'] or Save
            Save.BottomPoint= Save.BottomPoint or {
                Mount=true,
                Hearthstone=true,
                OpenItems=true,
            }
            Button= WoWTools_ToolsButtonMixin:Init(Save)

            if Button  then
                Init()
            end

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                Init_Panel()
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if Save then
                Save.show= Button and Button.Frame:IsShown()
            end
            WoWToolsSave['WoWTools_ToolsButton']=Save
        end
    end
end)