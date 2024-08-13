local id, e = ...
local Save={
    --disabled=true,    
    disabledADD={
        ['ChatButton_Emoji']= not e.Player.cn and not e.Player.husandro,
    },
    scale= 1,
    --isVertical=nil,--方向, 竖
    --isShowBackground=nil,--是否显示背景 bool
}

local addName
local ChatButton
local Initializer, Layout




















local function Init_Menu(self, root)


    --缩放
    local sub= root:CreateButton(e.onlyChinese and '缩放' or 'Scale', function()
        return MenuResponse.Open
    end)
    for index=0.4, 4, 0.05 do
        sub:CreateCheckbox(index, function(data)
            return Save.scale==data
        end, function(data)
            Save.scale= data
            self:set_scale()
            return MenuResponse.Refresh
        end, index)
    end
    sub:CreateDivider()
    sub:CreateTitle(Save.scale or 1)
    sub:SetGridMode(MenuConstants.VerticalGridDirection, 5)

    sub=root:CreateButton(self:GetFrameStrata() or Save.strata or 'FrameStrata', function() return MenuResponse.Open end)


    for _, strata in pairs({'BACKGROUND','LOW','MEDIUM','HIGH','DIALOG','FULLSCREEN','FULLSCREEN_DIALOG'}) do
        sub:CreateRadio((strata=='HIGH' and '|cnGREEN_FONT_COLOR:' or '')..strata, function(data)
            return self:GetFrameStrata()== data
        end, function(data)
            Save.strata= data
            self:set_strata()
            print(id, addName ,'SetFrameStrata(\"|cnGREEN_FONT_COLOR:'..self:GetFrameStrata()..'|r\")')
            return MenuResponse.Refresh
        end, strata)
    end
    

    root:CreateCheckbox('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION), function()
        return Save.isVertical
    end, function()
        Save.isVertical= not Save.isVertical and true or nil
        WoWToolsChatButtonMixin:RestHV(Save.isVertical)--方向, 竖
    end)
    root:CreateCheckbox(e.onlyChinese and '背景' or 'Background', function()
        return Save.isShowBackground
    end, function()
        Save.isShowBackground= not Save.isShowBackground and true or nil
        WoWToolsChatButtonMixin.isShowBackground= Save.isShowBackground
        WoWToolsChatButtonMixin:ShowBackgroud()
    end)

    root:CreateDivider()
    root:CreateButton((Save.Point and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.Point=nil
        self:set_point()
    end)

    root:CreateDivider()
    sub=root:CreateButton(addName, function()
        e.OpenPanelOpting(addName)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '打开选项界面' or OPTIONS)
    end)
end


















--####
--初始
--####
local function Init()
    SELECTED_DOCK_FRAME.editBox:SetAltArrowKeyMode(false)

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
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
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
        Save.scale=e.Set_Frame_Scale(self, d, Save.scale, nil)
    end)


    ChatButton:SetScript("OnLeave",function()
        ResetCursor()
        e.tips:Hide()
    end)
    ChatButton:SetScript('OnEnter',ChatButton.set_tooltip)

    ChatButton:set_strata()
    ChatButton:set_point()
    ChatButton:set_scale()
end























local function Init_Panel()
    Initializer, Layout= e.AddPanel_Sub_Category({name=addName})

    e.AddPanel_Check_Button({
        checkName= e.onlyChinese and '启用' or ENABLE,
        checkValue= not Save.disabled,
        checkFunc= function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
        buttonFunc= function()
            Save.Point=nil
            if ChatButton then
                ChatButton:set_point()
            end
            print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end,
        tooltip= addName,
        layout= Layout,
        category= Initializer,
    })

    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    for _, data in pairs (WoWToolsChatButtonMixin:GetAllAddList()) do
        e.AddPanel_Check({
            name= type(data.tooltip)=='function' and data.tooltip() or data.tooltip,
            tooltip= data.name,
            value= not Save.disabledADD[data.name],
            category= Initializer,
            func= function()
                print(data.name)
                Save.disabledADD[data.name]= not Save.disabledADD[data.name] and true or nil
            end
        })
    end
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
            Save= WoWToolsSave['ChatButton'] or Save
            Save.disabledADD= Save.disabledADD or {}
            addName='|A:voicechat-icon-textchat-silenced:0:0|a'..(e.onlyChinese and '聊天工具' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHAT, AUCTION_SUBCATEGORY_PROFESSION_TOOLS))
            
            if not Save.disabled then
                ChatButton= WoWToolsChatButtonMixin:Init(Save.disabledADD, Save)

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
            --[[添加控制面板
            e.AddPanel_Header(nil, 'ChatButton')

            local initializer2= e.AddPanel_Check_Button({
                checkName= addName,
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.Point=nil
                    if ChatButton then
                        ChatButton:set_point()
                    end
                    print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= addName,
                layout= nil,
                category= nil,
            })

            local initializer= e.AddPanel_Check({
                name= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\greet:0|tEmoji',
                tooltip= addName..', Emoji',
                value= Save.emoji,
                func= function()
                    Save.emoji= not Save.emoji and true or nil
                    print(id, addName, 'Emoji', e.GetEnabeleDisable(Save.emoji), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })
            initializer:SetParentInitializer(initializer2, function() if Save.disabled then return false else return true end end)
]]
