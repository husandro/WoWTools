local id, e = ...
local Save={
    --disabled=true,    
    disabledADD={
        ['ChatButton_Emoji']= not e.Player.cn and not e.Player.husandro,
    },
    scale= 1,
    strata='MEDIUM'
    --isVertical=nil,--方向, 竖
    --isShowBackground=nil,--是否显示背景 bool
    --isEnterShowMenu 移过图标，显示菜单
}
local panel= CreateFrame("Frame")
local addName
local ChatButton
local Initializer, Layout



















local function Init_Menu(self, root)
    local sub

    WoWTools_MenuMixin:Scale(root, function()
        return Save.scale
    end, function(value)
        Save.scale= value
        self:set_scale()
    end)


    sub=root:CreateButton('FrameStrata', function() return MenuResponse.Open end)


    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateRadio((strata=='MEDIUM' and '|cnGREEN_FONT_COLOR:' or '')..strata, function(data)
            return self:GetFrameStrata()== data
        end, function(data)
            Save.strata= data
            self:set_strata()
            print(e.addName, addName ,'SetFrameStrata(\"|cnGREEN_FONT_COLOR:'..self:GetFrameStrata()..'|r\")')
            return MenuResponse.Refresh
        end, strata)
    end


    root:CreateCheckbox('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION), function()
        return Save.isVertical
    end, function()
        Save.isVertical= not Save.isVertical and true or nil
        self:save_data()
        WoWTools_ChatButtonMixin:RestHV()--方向, 竖
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(root,
    function()
        return Save.isShowBackground
    end, function()
        Save.isShowBackground= not Save.isShowBackground and true or nil
        self:save_data()
        WoWTools_ChatButtonMixin:ShowBackgroud()
    end)

    --[[sub=root:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save.isEnterShowMenu
    end, function()
        Save.isEnterShowMenu = not Save.isEnterShowMenu and true or nil
        self:save_data()
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '显示菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, HUD_EDIT_MODE_MICRO_MENU_LABEL))
    end)]]



    --重置位置
    WoWTools_MenuMixin:RestPoint(root, Save.point, function()
        Save.Point=nil
        self:set_point()
        return MenuResponse.Open
    end)

--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {category=Initializer, name=addName})
end
















--####
--初始
--####
local function Init()
    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)

    function ChatButton:save_data()
        WoWTools_ChatButtonMixin:SetSaveData(Save)
    end

    function ChatButton:set_strata()
        self:SetFrameStrata(Save.strata or 'MEDIUM')
    end

    function ChatButton:set_scale()
        self:SetScale(Save.scale or 1)
    end
    function ChatButton:set_point()
        self:ClearAllPoints()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('BOTTOMLEFT', SELECTED_CHAT_FRAME, 'TOPLEFT', -5, 30)
        end
    end
    function ChatButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:Show()
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
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)

    ChatButton:SetScript("OnMouseUp", ResetCursor)
    ChatButton:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    ChatButton:SetScript("OnClick", function(self, d)
        if d=='RightButton' and not IsAltKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    ChatButton:SetScript('OnMouseWheel', function(self, d)--缩放
        Save.scale=WoWTools_FrameMixin:ScaleFrame(self, d, Save.scale, nil)
    end)


    ChatButton:SetScript("OnLeave",function()
        ResetCursor()
        e.tips:Hide()
    end)
    ChatButton:SetScript('OnEnter', ChatButton.set_tooltip)

    ChatButton:set_strata()
    ChatButton:set_point()
    ChatButton:set_scale()
end























local function Init_Panel()


    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    for _, data in pairs (WoWTools_ChatButtonMixin:GetAllAddList()) do
        e.AddPanel_Check({
            category= Initializer,
            name= data.tooltip,
            tooltip= data.name,
            Value= not Save.disabledADD[data.name],
            GetValue= function() return not Save.disabledADD[data.name] end,
            SetValue= function()
                Save.disabledADD[data.name]= not Save.disabledADD[data.name] and true or nil
            end
        })
    end
end























--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButton'] or Save

            Save.disabledADD= Save.disabledADD or {}

            addName='|A:voicechat-icon-textchat-silenced:0:0|a'..(e.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS))

            Initializer, Layout= e.AddPanel_Sub_Category({name=addName})

            e.AddPanel_Check_Button({
                checkName= e.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.Point=nil
                    if ChatButton then
                        ChatButton:set_point()
                    end
                    print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= addName,
                layout= Layout,
                category= Initializer,
            })

            if not Save.disabled then
                ChatButton= WoWTools_ChatButtonMixin:Init(Save.disabledADD, Save)

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
            WoWToolsSave['ChatButton']=Save
        end
    end
end)
