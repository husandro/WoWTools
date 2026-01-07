

local P_Save={
    --disabled=true,
    --disabledTexture=true,
    --useColor=true,自定义，颜色
    UIButton=WoWTools_DataMixin.Player.husandro,
    CheckBox= WoWTools_DataMixin.Player.husandro,
    alpha= 0.5,

    --disabledChatBubble=true,--禁用，聊天泡泡
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,

    classPowerNum= WoWTools_DataMixin.Player.husandro,--职业，显示数字
    classPowerNumSize= 23,

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
    no={},--禁用
}


local function Save()
    return WoWToolsSave['Plus_Texture']
end
local function SaveLog()
    return WoWToolsPlayerDate['TextureClassColor']
end


--自定义，颜色
local function Set_Color()
    local color= Save().useColor and SaveLog()[WoWTools_DataMixin.Player.Class]
    if color and color.r and color.g and color.b then
        WoWTools_TextureMixin.Color= CreateColor(color.r, color.g, color.b, 1)
    else
        WoWTools_TextureMixin.Color= PlayerUtil.GetClassColor()
    end
end









local function Init_Panel()
    local sub
    local tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)

    WoWTools_PanelMixin:Header(WoWTools_TextureMixin.Layout, WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)



WoWTools_PanelMixin:CheckMenu({
    category=WoWTools_TextureMixin.Category,
    layout= WoWTools_TextureMixin.Layout,
    name= WoWTools_DataMixin.onlyChinese and '自定义颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_FILTER_DROPDOWN_CUSTOM, CLASS_COLORS),
    tooltip=tooltip,
    GetValue=function()
        return Save().useColor
    end,
    SetValue=function()
        Save().useColor= not Save().useColor and true or nil
        Set_Color()
    end,
    DropDownGetValue=function()
        return 0
    end,
    DropDownSetValue=function(classID)
        if ColorPickerFrame:IsShown() then
            ColorPickerFrame.Footer.CancelButton:Click()
        end

--全部重置
        if classID==(GetNumClasses()+1) then
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '职业颜色|n|n全部重置' or (CLASS_COLORS..'|n|n'..RESET_ALL_BUTTON_TEXT) ,
            nil,
            {SetValue=function()
                WoWToolsPlayerDate['TextureClassColor']={}
            end})
            return
        end

--设置，职业，颜色
        local classFile= select(2, GetClassInfo(classID))
        local info = {
            hasOpacity= false,
            extraInfo= RAID_CLASS_COLORS[classFile],
        }
        local overrideInfo = SaveLog()[classFile]
        if overrideInfo then
            info.r, info.g, info.b = overrideInfo.r, overrideInfo.g, overrideInfo.b
        else
            info.r, info.g, info.b= GetClassColor(classFile)
        end
        info.swatchFunc = function ()
            local r,g,b = ColorPickerFrame:GetColorRGB()

            SaveLog()[classFile]= {r=r, g=g, b=b}
        end
        info.cancelFunc = function ()
            --local r,g,b = ColorPickerFrame:GetPreviousValues()
            SaveLog()[classFile]= overrideInfo
        end

        ColorPickerFrame:SetupColorPickerAndShow(info)

    end,
    GetOptions=function()
        local container = Settings.CreateControlTextContainer()
        local maxClass= GetNumClasses()
        for classID = 1, maxClass do
            if (classID == 10) and (GetClassicExpansionLevel() <= LE_EXPANSION_CATACLYSM) then-- We have an annoying gap between warlock and druid
                classID = 11
            end

            local className, classFile= GetClassInfo(classID)

            if classFile then
                local color
                local col= SaveLog()[classFile]
                if col then
                    color= CreateColor(col.r, col.g, col.b)
                else
                    local r,g,b= GetClassColor(classFile)
                    color= CreateColor(r,g,b)
                end

                className= WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.ClassName_CN[classID] or className

                container:Add(classID,
                    WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile)
                    ..color:WrapTextInColorCode(className)
                    ..(classFile==WoWTools_DataMixin.Player.Class and '|A:recipetoast-icon-star:0:0|a' or ' ')..classID
                )
            end
        end

        container:Add(maxClass+1, '|A:talents-button-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET))

        return container:GetData()
    end})


    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:_128-RedButton-Center:0:0|aUIButton',
        tooltip= tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return Save().UIButton end,
        SetValue= function()
            Save().UIButton= not Save().UIButton and true or nil
        end
    }, sub)

    WoWTools_PanelMixin:OnlyCheck({
        name= '|A:checkbox-minimal:0:0|aCheckBox',
        tooltip= tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return Save().CheckBox end,
        SetValue= function()
            Save().CheckBox= not Save().CheckBox and true or nil
        end
    }, sub)

    WoWTools_PanelMixin:Header(WoWTools_TextureMixin.Layout, WoWTools_DataMixin.onlyChinese and '其它' or OTHER)


    sub= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '聊天泡泡' or CHAT_BUBBLES_TEXT,
        tooltip= (WoWTools_DataMixin.onlyChinese and '在副本无效' or (INSTANCE..' ('..DISABLE..')'))
                ..'|n|n'..((WoWTools_DataMixin.onlyChinese and '说' or SAY)..' CVar: chatBubbles '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubbles")))
                ..'|n'..((WoWTools_DataMixin.onlyChinese and '小队' or SAY)..' CVar: chatBubblesParty '.. WoWTools_TextMixin:GetShowHide(C_CVar.GetCVarBool("chatBubblesParty")))
                ..'\n\n'..tooltip,
        category= WoWTools_TextureMixin.Category,
        GetValue= function() return not Save().disabledChatBubble end,
        SetValue= function()
            Save().disabledChatBubble= not Save().disabledChatBubble and true or nil
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    })



    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE,
        GetValue= function() return Save().chatBubbleSacal or 0.85 end,
        minValue= 0.3,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TextureMixin.addName,
        category= WoWTools_TextureMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().chatBubbleSacal= WoWTools_DataMixin:GetFormatter1to10(value2, 0.3, 1)
            WoWTools_TextureMixin:Init_Chat_Bubbles()
        end
    }, sub)






    WoWTools_PanelMixin:Check_Slider({
        checkName= (WoWTools_DataMixin.onlyChinese and '职业能量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CLASS, ENERGY))..' 1 2 3',
        checkGetValue= function() return Save().classPowerNum end,
        tooltip= tooltip,
        checkSetValue= function()
            Save().classPowerNum= not Save().classPowerNum and true or false
            WoWTools_TextureMixin:Init_Class_Power()--职业
        end,
        sliderGetValue= function()
            local s= Save().classPowerNumSize or 23
            if type(s)~='number' then
                s= 23
                Save().classPowerNumSize=23
            end
            return s
        end,
        minValue= 6,
        maxValue= 64,
        step= 1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                local value3= WoWTools_DataMixin:GetFormatter1to10(value2, 6, 64)
                Save().classPowerNumSize= value3
                WoWTools_TextureMixin:Init_Class_Power()--职业
            end
        end,
        layout= WoWTools_TextureMixin.Layout,
        category= WoWTools_TextureMixin.Category,
    })


    local index=0


    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(index..') ')..name:gsub('Blizzard_', ''),
            tooltip= tooltip,
            category= WoWTools_TextureMixin.Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(WoWTools_TextureMixin.Layout, 'Event')
    for name in pairs(WoWTools_TextureMixin.Events) do
        index= index+1
        Add_Options(name)
    end

    index=0
    WoWTools_PanelMixin:Header(WoWTools_TextureMixin.Layout, 'Frame')
    for name in pairs(WoWTools_TextureMixin.Frames) do
        index= index+1
        Add_Options(name)
    end


    Init_Panel=function()end
end












local function Init()
    for name, func in pairs(WoWTools_TextureMixin.Frames) do
        if _G[name] then
            if not Save().no[name] then
                func(WoWTools_TextureMixin)
            end
        elseif WoWTools_DataMixin.Player.husandro then
            print(WoWTools_TextureMixin.addName, 'Frames[|cnWARNING_FONT_COLOR:'..name..'|r]', '没有发现')
        end
        WoWTools_TextureMixin.Frames[name]= nil
    end

    for name, func in pairs(WoWTools_TextureMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            if not Save().no[name] then
                func(WoWTools_TextureMixin)
            end
            WoWTools_TextureMixin.Events[name]= nil
        end
    end

    Init=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

local function Clear_Frame()
    WoWTools_TextureMixin.Events={}
    WoWTools_TextureMixin.Frames={}
    panel:UnregisterEvent('ADDON_LOADED')
    panel:SetScript('OnEvent', nil)
    Clear_Frame=function()end
end

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Texture']= WoWToolsSave['Plus_Texture'] or P_Save
            WoWToolsPlayerDate['TextureClassColor']= WoWToolsPlayerDate['TextureClassColor'] or {}

            Save().Bg= Save().Bg or P_Save.Bg
            Save().Bg.Anims= Save().Bg.Anims or P_Save.Bg.Anims
            Save().no= Save().no or {}

            Set_Color()--自定义，颜色

            P_Save= nil

            WoWToolsPlayerDate['BGTexture']= WoWToolsPlayerDate['BGTexture'] or {}

            WoWTools_TextureMixin.addName= '|A:AnimCreate_Icon_Texture:0:0|a'..(WoWTools_DataMixin.onlyChinese and '材质' or TEXTURES_SUBHEADER)

            WoWTools_TextureMixin.Category, WoWTools_TextureMixin.Layout = WoWTools_PanelMixin:AddSubCategory({
                name= WoWTools_TextureMixin.addName,
                disabled= Save().disabled,
            })

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init_Panel()
                end,
                buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
                buttonFunc= function()
                    StaticPopup_Show('WoWTools_RestData',
                        WoWTools_TextureMixin.addName
                        ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                        nil,
                    function()
                        WoWToolsSave['Plus_Texture']= nil
                        WoWTools_DataMixin:Reload()
                    end)
                end,
                tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                layout= WoWTools_TextureMixin.Layout,
                category= WoWTools_TextureMixin.Category,
            })

            if Save().disabled then
                Clear_Frame()
            else
                Init_Panel()

                WoWTools_TextureMixin:Init_Class_Power()--职业
                WoWTools_TextureMixin:Init_Chat_Bubbles()--聊天泡泡

                if Save().disabledTexture then
                    self:UnregisterEvent(event)
                else
                    Init()
                end
            end

        elseif WoWToolsSave then
            if WoWTools_TextureMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_TextureMixin.Events[arg1](WoWTools_TextureMixin)
                end
                WoWTools_TextureMixin.Events[arg1]= nil
            end
        end
    end
end)