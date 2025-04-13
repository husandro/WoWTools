
local P_Save={}

local function Save()
    return WoWToolsSave['Plus_Aura'] or {}
end






local function Init()
    if Save().disabled then
        return
    end
    

    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGIN")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            if not WoWTools_DataMixin.Player.husandro then--测试中
                return
            end

            WoWToolsSave['Plus_Aura']= WoWToolsSave['Plus_Aura'] or P_Save

            WoWTools_AuraMixin.addName= '|A:Adventures-Target-Indicator:0:0|a'..(WoWTools_DataMixin.onlyChinese and '光环' or AURAS)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_AuraMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init()
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_AuraMixin.addName,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                        )
                    end
                end,
                --layout= WoWTools_OtherMixin.Layout,
                --category= WoWTools_OtherMixin.Category,
            })

            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        Init()
        self:UnregisterEvent(event)
    end
end)