

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    alpha= 0.5,

    --disabledChatBubble=true,--禁用，聊天泡泡
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,

    classPowerNum= WoWTools_DataMixin.Player.husandro,--职业，显示数字
    classPowerNumSize= 12,

    --disabledMainMenu= not WoWTools_DataMixin.Player.husandro, --主菜单，颜色，透明度
    --disabledHelpTip=true,--隐藏所有教程

    HideTalentsBG=true,--隐藏，天赋，背景
}


local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end











local function Set_Event_Texture(name)
    if WoWTools_TextureMixin.Events[name] and C_AddOns.IsAddOnLoaded(name) then
        do
            WoWTools_TextureMixin.Events[name](WoWTools_TextureMixin)
        end
        WoWTools_TextureMixin.Events[name]= nil
    end
end






local function Init_Texture()
    if Save().disabledTexture then
        return
    end

    WoWTools_TextureMixin:Init_All_Frame()

    for name in pairs(WoWTools_TextureMixin.Events) do
        Set_Event_Texture(name)
    end

    hooksecurefunc(DropdownTextMixin, 'OnLoad', function(self)
        WoWTools_TextureMixin:SetMenu(self)
    end)
    hooksecurefunc(DropdownButtonMixin, 'SetupMenu', function(self)
        WoWTools_TextureMixin:SetMenu(self)
    end)

    Init_Texture=function()end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("LOADING_SCREEN_DISABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Texture']= WoWToolsSave['Plus_Texture'] or P_Save
            Save().classPowerNumSize= Save().classPowerNumSize or 12

            WoWTools_TextureMixin.addName= '|A:AnimCreate_Icon_Texture:0:0|a'..(WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

            WoWTools_TextureMixin:Init_Options()

            if Save().disabled then
                WoWTools_TextureMixin.Events={}
                self:UnregisterAllEvents()
            else

                WoWTools_TextureMixin:Init_Class_Power()--职业
                WoWTools_TextureMixin:Init_Chat_Bubbles()--聊天泡泡
                WoWTools_TextureMixin:Init_HelpTip()--隐藏教程
                WoWTools_TextureMixin:Init_Action_Button()

                if Save().disabledTexture then
                    self:UnregisterAllEvents()
                end
            end

        elseif WoWToolsSave then
            Set_Event_Texture(arg1)
        end

    elseif event=='LOADING_SCREEN_DISABLED' then--需要这个事件
        Init_Texture()
        self:UnregisterEvent(event)
    end
end)