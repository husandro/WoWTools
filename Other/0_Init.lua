local id, e= ...

WoWTools_OtherMixin={
    Save={

    }
}

local function Init()

end

local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if WoWToolsSave['Other'] then
                WoWTools_OtherMixin.Save= WoWToolsSave['Other']
            end

            WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(e.onlyChinese and '其它' or OTHER)

            WoWTools_OtherMixin:Init_Category()

            if WoWTools_OtherMixin.Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                Init()
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_OtherMixin:Blizzard_Settings()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other']= WoWTools_OtherMixin.Save
        end
    end
end)