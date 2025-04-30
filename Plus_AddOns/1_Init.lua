local P_Save={
    --load_Button_Name=BASE_SETTINGS_TAB,--记录，已加载方案
    buttons={
        [WoWTools_DataMixin.Player.husandro and '一般' or BASE_SETTINGS_TAB]={
            ['WeakAuras']=true,
            ['WeakAurasOptions']=true,
            ['WeakAurasArchive']=true,
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
            ['WeakAuras']=true,
            ['WeakAurasOptions']=true,
            ['Details']=true,
            ['DBM-Core']=true,
            ['DBM-Challenges']=true,
            ['DBM-StatusBarTimers']=true,
            ['WoWTools']=true,
        }
    },
    fast={
        ['TextureAtlasViewer']=1,
        ['WoWeuCN_Tooltips']=1,
        ['WoWTools']=1,
    },
    enableAllButtn= WoWTools_DataMixin.Player.husandro,--全部禁用时，不禁用本插件


    load_list=WoWTools_DataMixin.Player.husandro,--禁用, 已加载，列表
    --load_list_top=true,
    load_list_size=22,

    rightListScale=1,
    --hideRightList=true, 隐藏右边列表

    leftListScale=1,
    --hideLeftList

    --disabledInfoPlus=true,禁用plus
    Bg_Alpha=0.5
    --addonProfilerEnabled= true,--启用，CPU分析功能,默认开启
}



local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end






















--#####
--初始化
--#####
local function Init()
    do
        WoWTools_AddOnsMixin:Init_NewButton_Button()
    end
    
    WoWTools_AddOnsMixin:Init_Menu_Button()
    WoWTools_AddOnsMixin:Init_Load_Button()
    WoWTools_AddOnsMixin:Init_Right_Buttons()
    WoWTools_AddOnsMixin:Init_Left_Buttons()
    WoWTools_AddOnsMixin:Init_Info_Plus()

    WoWTools_MoveMixin:Setup(AddonList, {
        minW=430, minH=120, setSize=true,
    initFunc=function()
        AddonList.ScrollBox:ClearAllPoints()
        AddonList.ScrollBox:SetPoint('LEFT', 7, 0)
        AddonList.ScrollBox:SetPoint('TOP', AddonList.Performance, 'BOTTOM')
        AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)

        for _, text in pairs({AddonList.ForceLoad:GetRegions()}) do
            if text:GetObjectType()=="FontString" then
                text:SetText('')
                text:ClearAllPoints()
                AddonList.ForceLoad:HookScript('OnEnter', function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '加载过期插件' or ADDON_FORCE_LOAD)
                    GameTooltip:Show()
                end)
                AddonList.ForceLoad:HookScript('OnLeave', GameTooltip_Hide)

                AddonList.SearchBox:ClearAllPoints()
                AddonList.SearchBox:SetPoint('LEFT', AddonList.ForceLoad, 'RIGHT', 6,0)
                AddonList.SearchBox:SetPoint('RIGHT', -42, 0)

                break
            end
        end
    end, sizeRestFunc=function(self)
        self.targetFrame:SetSize(500, 480)
    end})

    AddonList.ForceLoad:ClearAllPoints()
    AddonList.ForceLoad:SetPoint('LEFT', AddonList.Dropdown, 'RIGHT', 23,0)

    hooksecurefunc('AddonList_Update', function()
        WoWTools_AddOnsMixin:Set_Left_Buttons()--插件，快捷，选中
        WoWTools_AddOnsMixin:Set_Right_Buttons()
    end)

    Init=function()end
end














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

--panel:RegisterEvent("PLAYER_LOGIN")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_AddOns']= WoWToolsSave['Plus_AddOns'] or P_Save
            WoWTools_AddOnsMixin.addName='|A:Garr_Building-AddFollowerPlus:0:0|a'..(WoWTools_DataMixin.onlyChinese and '插件管理' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE))

            Save().Bg_Alpha = Save().Bg_Alpha or 0.5

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
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_AddOnsMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })


            if Save().disabled then
                self:UnregisterAllEvents()
            else
                AddonList:HookScript('OnShow', function()
                    Init()
                end)
                self:UnregisterEvent(event)
            end
        end

    --[[elseif event=='PLAYER_LOGIN' then
        if not Save().addonProfilerEnabled and C_AddOnProfiler.IsEnabled() then
            WoWTools_AddOnsMixin:Set_AddonProfiler()
        end
        self:UnregisterEvent(event)]]
    end
end)
