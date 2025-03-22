local id, e = ...
WoWTools_ChatMixin.Save={
    --disabled=true,    
    disabledADD={
        ['ChatButton_Emoji']= not e.Player.cn and not e.Player.husandro,
    },
    scale= 1,
    strata='MEDIUM',
    --isVertical=nil,--方向, 竖
    --isShowBackground=nil,--是否显示背景 bool
    isEnterShowMenu= e.Player.husandro,-- 移过图标，显示菜单

    borderAlpha=0.3,--外框，透明度
    pointX=0,
    anchorMenuIndex=1,--菜单位置 下，上，左，右
}

local addName
local ChatButton
local Category, Layout




local function Save()
    return WoWTools_ChatMixin.Save
end












local function Init_Menu(self, root)
    local sub, sub2

    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scale
    end, function(value)
        Save().scale= value
        self:set_scale()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
        print(e.Icon.icon2.. addName ,'SetFrameStrata(\"|cnGREEN_FONT_COLOR:'..self:GetFrameStrata()..'|r\")')
        return MenuResponse.Refresh
    end)

--外框，透明度
    sub=root:CreateButton(
        '|A:bag-reagent-border:0:0|a'..(WoWTools_Mixin.onlyChinese and '镶边' or EMBLEM_BORDER),
    function()
        return MenuResponse.Open
    end)

--Border 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().borderAlpha or 1
        end, setValue=function(value)
            Save().borderAlpha=value
            for _, btn in pairs(WoWTools_ChatMixin:Get_All_Buttons()) do
                btn:set_border_alpha()
            end
        end,
        name=WoWTools_Mixin.onlyChinese and '改变透明度' or CHANGE_OPACITY,
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
            for _, btn in pairs(WoWTools_ChatMixin:Get_All_Buttons()) do
                btn:set_point()
            end
        end,
        name=WoWTools_Mixin.onlyChinese and 'X' or CHANGE_OPACITY,
        minValue=-15,
        maxValue=15,
        step=1,
    })



--方向, 竖
    sub=root:CreateCheckbox('|A:bags-greenarrow:0:0|a'..(WoWTools_Mixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION), function()
        return Save().isVertical
    end, function()
        Save().isVertical= not Save().isVertical and true or nil
        self:set_size()
        for _, btn in pairs(WoWTools_ChatMixin:Get_All_Buttons()) do
            btn:set_point()
        end
    end)

--菜单位置
    local textTab={
      '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN),
      WoWTools_Mixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP,
      WoWTools_Mixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
      WoWTools_Mixin.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    }
    for index, tab in pairs(WoWTools_ChatMixin:Get_AnchorMenu()) do
        sub2=sub:CreateCheckbox(
            textTab[index],
        function(data)
            return Save().anchorMenuIndex==data.index
        end, function(data)
            self:CloseMenu()
            Save().anchorMenuIndex= data.index
            self:set_anchor()
            for _, btn in pairs(WoWTools_ChatMixin:Get_All_Buttons()) do
                btn:set_anchor()
            end
            self:OpenMenu()
        end, {index=index, p=tab[1], p2=tab[2]})
        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddDoubleLine(desc.data.p, desc.data.p2)
        end)
    end

    sub:CreateDivider()
    sub:CreateTitle(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)


--显示背景
    WoWTools_MenuMixin:ShowBackground(root, function()
        return Save().isShowBackground
    end, function()
        Save().isShowBackground= not Save().isShowBackground and true or nil
        self:set_backgroud()
    end)

    sub=root:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(WoWTools_Mixin.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save().isEnterShowMenu
    end, function()
        Save().isEnterShowMenu = not Save().isEnterShowMenu and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '显示菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, HUD_EDIT_MODE_MICRO_MENU_LABEL))
    end)



    --重置位置
    root:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, root, Save().Point, function()
        Save().Point=nil
        self:set_point()
        return MenuResponse.Open
    end)

--打开选项界面
    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, nil)
end

















--####
--初始
--####
local function Init()
    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)
    WoWTools_TextureMixin:SetSearchBox(SELECTED_DOCK_FRAME.editBox, {alpha=1})

    function ChatButton:set_size()
        if Save().isVertical then--方向, 竖
            self:SetSize(30,10)
        else
            self:SetSize(10,30)
        end
    end

    function ChatButton:set_strata()
        self:SetFrameStrata(Save().strata or 'MEDIUM')
    end

    function ChatButton:set_scale()
        self:SetScale(Save().scale or 1)
    end
    function ChatButton:set_point()
        self:ClearAllPoints()
        if Save().Point then
            self:SetPoint(Save().Point[1], UIParent, Save().Point[3], Save().Point[4], Save().Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end
    end
    function ChatButton:set_tooltip()
       -- GameTooltip:AddDoubleLine(e.Icon.icon2.. addName)
       -- GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        --GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scale or 1), 'Alt+'..e.Icon.mid)
        --GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        GameTooltip:Show()
    end

    ChatButton:RegisterForDrag("RightButton")
    ChatButton:SetMovable(true)
    ChatButton:SetClampedToScreen(true)

    ChatButton:SetScript("OnDragStart", function(self,d )
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)

    ChatButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().Point={self:GetPoint(1)}
        Save().Point[2]=nil
    end)

    ChatButton:SetScript("OnMouseUp", ResetCursor)
    ChatButton:HookScript("OnMouseDown", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
            self:CloseMenu()
        end
    end)



    ChatButton:set_strata()
    ChatButton:set_point()
    ChatButton:set_scale()
    ChatButton:set_size()
    ChatButton:SetupMenu(Init_Menu)
end























local function Init_Panel()


    e.AddPanel_Header(Layout, WoWTools_Mixin.onlyChinese and '选项' or OPTIONS)

    for _, data in pairs (WoWTools_ChatMixin:GetAllAddList()) do
        e.AddPanel_Check({
            category= Category,
            name= data.tooltip,
            tooltip= data.name,
            Value= not Save().disabledADD[data.name],
            GetValue= function() return not Save().disabledADD[data.name] end,
            SetValue= function()
                Save().disabledADD[data.name]= not Save().disabledADD[data.name] and true or nil
            end
        })
    end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWTools_ChatMixin.Save= WoWToolsSave['ChatButton'] or Save()
            Save().disabledADD= Save().disabledADD or {}
            Save().borderAlpha= Save().borderAlpha or 0.3
            Save().anchorMenuIndex= Save().anchorMenuIndex or 1

            ChatButton= WoWTools_ChatMixin:Init()
            

            addName='|A:voicechat-icon-textchat-silenced:0:0|a'..(WoWTools_Mixin.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS))

            Category, Layout= e.AddPanel_Sub_Category({
                name=addName,
                disabled=Save().disabled
            })

            WoWTools_ChatMixin.Category= Category
            WoWTools_ChatMixin.addName= addName


            e.AddPanel_Check_Button({
                checkName= WoWTools_Mixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save().Point=nil
                    if ChatButton then
                        ChatButton:set_point()
                    end
                    print(e.Icon.icon2.. addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= addName,
                layout= Layout,
                category= Category,
            })

            if ChatButton then
                Init()
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton']= Save()
        end
    end
end)