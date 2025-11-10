local function Save()
    return WoWToolsSave['ChatButtonWorldChannel']
end







--[[

]]
--玩家，添加，列表
local function Init_Menu(self, root, data)
    if
        not self:IsMouseOver()
        --not Save().myChatFilter
        or not data.chatTarget
        or data.which~='FRIEND'
        or data.chatTarget==WoWTools_DataMixin.Player.Name_Realm
        or WoWTools_UnitMixin:GetIsFriendIcon(nil, nil, data.chatTarget)
        or WoWTools_DataMixin.GroupGuid[data.chatTarget]
    then
        return
    end--data.playerLocation


    local sub=root:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM),
    function(name)
        return Save().userChatFilterTab[name]
    end, function(name)
        if Save().userChatFilterTab[name] then
            Save().userChatFilterTab[name]= nil
        else
            Save().userChatFilterTab[name]={
                num=0,
                guid=nil,
            }
        end
    end, data.chatTarget)

    sub:SetTooltip(function(tooltip, description)
        tooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_WorldMixin.addName)
        tooltip:AddDoubleLine()
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE), WoWTools_TextMixin:GetEnabeleDisable(Save().userChatFilter))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(
            (WoWTools_DataMixin.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM)
            ..' '
            .. (Save().userChatFilterTab[description.name] and Save().userChatFilterTab[description.name].num) or ''),
            WoWTools_DataMixin.onlyChinese and '添加/移除' or ADD..'/'..REMOVE
        )

    end)
    sub:SetEnabled(data.chatTarget~=WoWTools_DataMixin.Player.Name)

    WoWTools_WorldMixin:Init_Filter_Menu(sub)
    --[[sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '自定义屏蔽' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CUSTOM, IGNORE), function()
        return Save().userChatFilter
    end, function()
        Save().userChatFilter= not Save().userChatFilter and true or false
        WoWTools_WorldMixin:Set_Filters()
    end)]]
end






function WoWTools_WorldMixin:MENU_UNIT_FRIEND()
    Menu.ModifyMenu("MENU_UNIT_FRIEND", function(...) Init_Menu(...) end)
end