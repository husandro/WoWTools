if BankFrameTab2 then
    return
end
local function Save()
    return WoWToolsSave['Plus_Bank2']
end


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

--Plus
    sub= root:CreateCheckbox(
        'Plus',
    function()
        return Save().plus
    end, function()
        Save().plus= not Save().plus and true or nil
        WoWTools_BankMixin:Init_BankPlus()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)

--转化为联合的大包
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED,
    function()
        return Save().allBank
    end, function()
        Save().allBank= not Save().allBank and true or nil
        WoWTools_BankMixin:Init_AllBank()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)



--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName,})
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end

















local function Init()
    local OptionButton= WoWTools_ButtonMixin:Menu(BankFrameCloseButton, {name='WoWTools_BankFrameMenuButton'})
    OptionButton:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -2,0)

    function OptionButton:Open_Bag()
        WoWTools_BagMixin:OpenBag(nil, true)
        C_Timer.After(0.3, function() BankFrame:Raise() end)
    end
    OptionButton:SetupMenu(Init_Menu)


    OptionButton:SetScript('OnLeave', GameTooltip_Hide)
    OptionButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        GameTooltip:Show()
    end)

    Init=function()end
end


function WoWTools_BankMixin:Init_BankMenu()
    Init()
end