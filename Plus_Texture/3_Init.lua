

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    UIButton=WoWTools_DataMixin.Player.husandro,
    alpha= 0.5,

    --disabledChatBubble=true,--禁用，聊天泡泡
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,

    classPowerNum= WoWTools_DataMixin.Player.husandro,--职业，显示数字
    classPowerNumSize= 12,

    --disabledMainMenu= not WoWTools_DataMixin.Player.husandro, --主菜单，颜色，透明度
    --disabledHelpTip=true,--隐藏所有教程

    Bg={
        --[[UseTexture={
            --自定义，图片 Texture or Atlas

        },]]
        All={--统一设置
            texture='Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga',
            alpha=0.75,
            nineSlice=0,
        },
        Add={--分开设置
--[[   
            [name]={
                enabled=true,--分开设置
                alpha=0.5,
                texture=texture or atlas,
                notLayer=true-- self:SetDrawLayerEnabled('BACKGROUND', not Save().Add[name].notLayer)
            }
]]

        },
        Anims={
            --disabled=true,
            alpha=0.75,
            speed=10,
        }
    },
}


local function Save()
    return WoWToolsSave['Plus_Texture']
end











local function Set_Event_Texture(name)
    if WoWTools_TextureMixin.Events[name] then
        do
            WoWTools_TextureMixin.Events[name](WoWTools_TextureMixin)
        end
        WoWTools_TextureMixin.Events[name]= nil
    end
end








local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Texture']= WoWToolsSave['Plus_Texture'] or CopyTable(P_Save)

            Save().Bg= Save().Bg or P_Save.Bg
            Save().Bg.Anims= Save().Bg.Anims or P_Save.Bg.Anims

            P_Save= nil

            WoWToolsPlayerDate['BGTexture']= WoWToolsPlayerDate['BGTexture'] or {}

            WoWTools_TextureMixin.addName= '|A:AnimCreate_Icon_Texture:0:0|a'..(WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

            WoWTools_TextureMixin:Init_Options()

            if Save().disabled then
                WoWTools_TextureMixin.Events={}
                WoWTools_TextureMixin.Frames={}
                self:UnregisterAllEvents()
            else
                if Save().disabledTexture then
                    self:UnregisterEvent(event)
                else
                    self:RegisterEvent('PLAYER_ENTERING_WORLD')
                    for name in pairs(WoWTools_TextureMixin.Events) do
                        if C_AddOns.IsAddOnLoaded(name) then
                             do
                                WoWTools_TextureMixin.Events[name](WoWTools_TextureMixin)
                            end
                            WoWTools_TextureMixin.Events[name]= nil
                        end
                    end
                end
                WoWTools_TextureMixin:Init_Class_Power()--职业
                WoWTools_TextureMixin:Init_Chat_Bubbles()--聊天泡泡
                WoWTools_TextureMixin:Init_HelpTip()--隐藏教程
            end

        elseif WoWToolsSave and WoWTools_TextureMixin.Events[arg1] then
            do
                WoWTools_TextureMixin.Events[arg1](WoWTools_TextureMixin)
            end
            WoWTools_TextureMixin.Events[arg1]= nil
        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then--需要这个事件
        for name in pairs(WoWTools_TextureMixin.Frames) do
            do
                if _G[name] then
                    WoWTools_TextureMixin.Frames[name](WoWTools_TextureMixin)

                elseif WoWTools_DataMixin.Player.husandro then
                    print(WoWTools_TextureMixin.addName, 'Frames[|cnWARNING_FONT_COLOR:'..name..'|r]', '没有发现')
                end
            end
            WoWTools_TextureMixin.Frames[name]= nil
        end
        self:UnregisterEvent(event)
    end
end)