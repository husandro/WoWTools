WoWTools_HearthstoneMixin={}


--[[local ModifiedTab={
    [6948]='shift',--炉石
    [110560]='ctrl',--要塞炉石
    [140192]='alt',--达拉然炉石
}]]






local P_Save={
    items={},
    showBindNameShort=true,
    showBindName=true,
    lockedToy=nil,
}

local ToyButton
local addName














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGIN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            if not WoWToolsSave['Tools_Hearthstone'] then
                WoWToolsSave['Tools_Hearthstone']= P_Save
                WoWToolsSave['Tools_Hearthstone'].items= WoWTools_HearthstoneMixin:Get_P_Items()
            end

            addName='|A:delves-bountiful:0:0|a'..(WoWTools_DataMixin.onlyChinese and '炉石' or TUTORIAL_TITLE31)

            ToyButton= WoWTools_ToolsMixin:CreateButton({
                name='Hearthstone',
                tooltip=addName,
                --isMenu=true,
            })

            WoWTools_HearthstoneMixin.ToyButton= ToyButton

            if not ToyButton then
                self:UnregisterAllEvents()
            else
                WoWTools_HearthstoneMixin.addName= addName

                for itemID, _ in pairs(WoWToolsSave['Tools_Hearthstone'].items) do
                    WoWTools_Mixin:Load({id=itemID, type='item'})
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    WoWTools_HearthstoneMixin:Blizzard_Collections()
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            WoWTools_HearthstoneMixin:Blizzard_Collections()
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        WoWTools_HearthstoneMixin:Init_Button()
        self:UnregisterEvent(event)
    end
end)