local DELETE_ITEM_CONFIRM_STRING= DELETE_ITEM_CONFIRM_STRING
local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING




local function Save()
    return WoWToolsSave['Plus_SellBuy']
end





local function Init()
    StaticPopupDialogs["DELETE_GOOD_ITEM"].acceptDelay=0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
        if not Save().notDELETE then
            local edit= self:GetEditBox()
            edit:SetText(DELETE_ITEM_CONFIRM_STRING)
            edit:ClearFocus()
        end
    end)

    StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"].acceptDelay=0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow",function(self)
        if not Save().notDELETE then
            local edit= self:GetEditBox()
            edit:SetText(DELETE_ITEM_CONFIRM_STRING)
            edit:ClearFocus()
        end
    end)

    StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"].acceptDelay=0.5
    WoWTools_DataMixin:Hook(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
        if not Save().notDELETE then
            local edit= self:GetEditBox()
            edit:SetText(COMMUNITIES_DELETE_CONFIRM_STRING)
            edit:ClearFocus()
        end
    end)
end









function WoWTools_MerchantMixin:Init_Delete()
    Init()
end