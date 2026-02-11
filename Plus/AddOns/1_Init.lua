local P_Save={
    --load_Button_Name=BASE_SETTINGS_TAB,--记录，已加载方案
    buttons={
        [WoWTools_DataMixin.Player.husandro and '一般' or BASE_SETTINGS_TAB]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['TextureAtlasViewer']=true,-- true, i or guid
            ['WoWTools_Chinese']=(not LOCALE_zhCN and not LOCALE_zhTW) and true or nil,
            ['WoWTools']=true,
        }, [WoWTools_DataMixin.Player.husandro and '宠物对战' or PET_BATTLE_COMBAT_LOG]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['tdBattlePetScript']=true,
            --['zAutoLoadPetTeam_Rematch']=true,
            ['Rematch']=true,
            ['WoWTools']=true,
        }, [WoWTools_DataMixin.Player.husandro and '副本' or INSTANCE]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            --['WeakAuras']=true,
            --['WeakAurasOptions']=true,
            ['Details']=true,
            ['DBM-Core']=true,
            ['DBM-Challenges']=true,
            ['DBM-StatusBarTimers']=true,
            ['WoWTools']=true,
        }
    },
    fast={
        ['TextureAtlasViewer']=true,
        ['WoWTools']=true,
        --['WeakAuras']=true,
        --['WeakAurasOptions']=true,
    },
    enableAllButtn= WoWTools_DataMixin.Player.husandro,--全部禁用时，不禁用本插件


    load_list=WoWTools_DataMixin.Player.husandro,--禁用, 已加载，列表
    --load_list_top=true,
    load_list_onlyIcon=true,
    load_list_size=22,

    rightListScale=1,
    --hideRightList=true, 隐藏右边列表

    leftListScale=1,
    --hideLeftList

    --disabledInfoPlus=true,禁用plus
    --bgAlpha=0.3
    --addonProfilerEnabled= true,--启用，CPU分析功能,默认开启
}



local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end






















--#####
--初始化
--#####
local function Init()
    WoWTools_AddOnsMixin:Init_Menu_Button()
    WoWTools_AddOnsMixin:Init_Bottom_Buttons()
    WoWTools_AddOnsMixin:Init_Right_Buttons()
    WoWTools_AddOnsMixin:Init_Left_Buttons()
    WoWTools_AddOnsMixin:Init_Info_Plus()
    Init=function()end
end














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Plus_AddOns']= WoWToolsSave['Plus_AddOns'] or P_Save
    P_Save=nil
    Save().Bg_Alpha= nil

    WoWTools_AddOnsMixin.addName='|A:Garr_Building-AddFollowerPlus:0:0|a'..(WoWTools_DataMixin.onlyChinese and '插件管理' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE))

    --添加控制面板
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_AddOnsMixin.addName,
        Value= not Save().disabled,
        GetValue=function () return not Save().disabled end,
        SetValue= function()
            Save().disabled = not Save().disabled and true or nil
            if not Save().disabled then
                if Init() then
                    Init=function()end
                    return
                end
            end
            print(
                WoWTools_AddOnsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                WoWTools_DataMixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD
            )
        end
    })



    if not Save().disabled then
        AddonList:HookScript('OnShow', function()
            Init()
        end)
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)