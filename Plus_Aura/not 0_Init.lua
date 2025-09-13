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


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            if not WoWTools_DataMixin.Player.husandro then--测试中
                self:UnregisterAllEvents()
                return
            end

            WoWToolsSave['Plus_Aura']= WoWToolsSave['Plus_Aura'] or {}

            WoWTools_AuraMixin.addName= '|A:Adventures-Target-Indicator:0:0|a'..(WoWTools_DataMixin.onlyChinese and '光环' or AURAS)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_AuraMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_AuraMixin.addName,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                        )
                    else
                        Init()
                    end
                end,
                --layout= WoWTools_OtherMixin.Layout,
                --category= WoWTools_OtherMixin.Category,
            })

            if not Save().disabled then
                Init()
            end

            self:UnregisterEvent(event)
        end
    end
end)