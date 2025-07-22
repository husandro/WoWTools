
local function Save()
    return WoWToolsSave['Plus_GuildBank']
end



--GuildBankFrame:UpdateTabs()
--GuildBankFrame:Update()
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    --索引
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '索引' or 'Index',
    function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_GuildBankMixin:Init_Plus()
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO),
    function()
        return Save().showItemInfo
    end, function()
        Save().showItemInfo= not Save().showItemInfo and true or nil
        GuildBankFrame:Update()
    end)

end



local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame.CloseButton, {
        name='WoWToolsGuildBankMenuButton',
    })
    btn:SetPoint('RIGHT', GuildBankFrame.CloseButton, 'LEFT', -2, 0)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end




function WoWTools_GuildBankMixin:Init_Menu()
   Init()
end