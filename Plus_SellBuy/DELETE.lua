local DELETE_ITEM_CONFIRM_STRING= DELETE_ITEM_CONFIRM_STRING
local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING




local function Save()
    return WoWTools_SellBuyMixin.Save
end





local function Init()
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
        if not Save().notDELETE then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end
    end)
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow",function(self)
        if not Save().notDELETE and self.editBox then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end
    end)
    hooksecurefunc(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
        if not Save().notDELETE and self.editBox then
            self.editBox:SetText(COMMUNITIES_DELETE_CONFIRM_STRING)
        end
    end)
end









function WoWTools_SellBuyMixin:Init_Delete()
    Init()
end