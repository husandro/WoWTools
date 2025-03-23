


--[[local ModifiedTab={
    [6948]='shift',--炉石
    [110560]='ctrl',--要塞炉石
    [140192]='alt',--达拉然炉石
}]]



WoWTools_HearthstoneMixin={
    Save={
        items={},
        showBindNameShort=true,
        showBindName=true,
        lockedToy=nil,
    }
}

local ToyButton
local addName














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_LOGIN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_HearthstoneMixin.Save= WoWToolsSave['Tools_Hearthstone'] or WoWTools_HearthstoneMixin.Save
            addName='|A:delves-bountiful:0:0|a'..(WoWTools_Mixin.onlyChinese and '炉石' or TUTORIAL_TITLE31)

            ToyButton= WoWTools_ToolsMixin:CreateButton({
                name='Hearthstone',
                tooltip=addName,
                --isMenu=true,
            })

            if not ToyButton then
                self:UnregisterEvent(event)
                self:UnregisterEvent('PLAYER_LOGIN')
            else
                WoWTools_HearthstoneMixin.addName= addName
                WoWTools_HearthstoneMixin.ToyButton= ToyButton

                for itemID, _ in pairs(WoWTools_HearthstoneMixin.Save.items) do
                    WoWTools_Mixin:Load({id=itemID, type='item'})
                end
            end

        elseif arg1=='Blizzard_Collections' then
            WoWTools_HearthstoneMixin:Init_Blizzard_Collections()
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        WoWTools_HearthstoneMixin:Init_Button()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Tools_Hearthstone']= WoWTools_HearthstoneMixin.Save
        end
    end
end)