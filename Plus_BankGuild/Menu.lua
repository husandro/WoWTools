local e= select(2, ...)
local function Save()
    return WoWTools_GuildBankMixin.Save
end
local MenuButton





local function Init_Menu(self, root)
    local sub

    local frame= self:GetParent():GetParent()--GuildBankFrame
    local currentIndex= GetCurrentGuildBankTab()--当前 Tab
    local numTab= GetNumGuildBankTabs()--总计Tab
    local isEnabled= frame.mode== "bank" and currentIndex<= numTab











--索引
    root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_GuildBankMixin:Update_Button()
    end)
    root:CreateDivider()

    root:CreateSpacer()
    sub= WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().BgAplha or 1
        end, setValue=function(value)
            Save().BgAplha=value
            GuildBankFrame.BlackBG:SetAlpha(Save().BgAplha)
        end,
        name=e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            tooltip:AddLine(e.onlyChinese and '改变透明度' or CHANGE_OPACITY)
        end
    })
    sub:SetEnabled(isEnabled)
    root:CreateSpacer()








--行数
    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().num
        end, setValue=function(value)
            Save().num=value
            WoWTools_GuildBankMixin:Update_Button()
        end,
        name=e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=1,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub:SetEnabled(isEnabled)
    root:CreateSpacer()








--间隔
    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().line
        end, setValue=function(value)
            Save().line=value
            WoWTools_GuildBankMixin:Update_Button()
        end,
        name=e.onlyChinese and '间隔' or 'Interval',
        minValue=0,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub:SetEnabled(isEnabled)
    root:CreateSpacer()






    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GuildBankMixin.addName})
    WoWTools_MenuMixin:Reload(sub, false)
end







function WoWTools_GuildBankMixin:Init_GuildMenu()
    MenuButton= WoWTools_ButtonMixin:CreateMenu(GuildBankFrame.CloseButton, {
        name='WoWToolsGuildBankMenuButton',
    })
    MenuButton:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT')
    MenuButton:SetupMenu(Init_Menu)
end