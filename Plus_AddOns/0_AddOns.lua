local id, e = ...

WoWTools_AddOnsMixin={
Save={
    --load_Button_Name=BASE_SETTINGS_TAB,--记录，已加载方案
    buttons={
        [e.Player.husandro and '一般' or BASE_SETTINGS_TAB]={
            ['WeakAuras']=true,
            ['WeakAurasOptions']=true,
            ['WeakAurasArchive']=true,
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['TextureAtlasViewer']=true,-- true, i or guid
            ['WoWTools_Chinese']=(not LOCALE_zhCN and not LOCALE_zhTW) and true or nil,
            [id]=true,
        }, [e.Player.husandro and '宠物对战' or PET_BATTLE_COMBAT_LOG]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['tdBattlePetScript']=true,
            --['zAutoLoadPetTeam_Rematch']=true,
            ['Rematch']=true,
            [id]=true,
        }, [e.Player.husandro and '副本' or INSTANCE]={
            ['BugSack']=true,
            ['!BugGrabber']=true,
            ['WeakAuras']=true,
            ['WeakAurasOptions']=true,
            ['Details']=true,
            ['DBM-Core']=true,
            ['DBM-Challenges']=true,
            ['DBM-StatusBarTimers']=true,
            [id]=true,
        }
    },
    fast={
        ['TextureAtlasViewer']=1,
        ['WoWeuCN_Tooltips']=1,
        [id]=1,
    },
    enableAllButtn= e.Player.husandro,--全部禁用时，不禁用本插件


    load_list=e.Player.husandro,--禁用, 已加载，列表
    --load_list_top=true,
    load_list_size=22,

    rightListScale=1,
    --hideRightList=true, 隐藏右边列表

    leftListScale=1,
    --hideLeftList

    --disabledInfoPlus=true,禁用plus
},

NewButton=nil,--新建按钮
BottomFrame=nil,--插件，图标，列表
MenuButton=nil,--菜单，按钮
RightFrame=nil,--右边列表
LeftFrame=nil,--左边列表
}

local function Save()
    return WoWTools_AddOnsMixin.Save
end





function WoWTools_AddOnsMixin:Get_MenoryValue(indexORname, showText)
    local va
    local value= GetAddOnMemoryUsage(indexORname)
    if value and value>0 then
        if value<1000 then
            if showText then
                va= format(e.onlyChinese and '插件内存：%.2f KB' or TOTAL_MEM_KB_ABBR, value)
            else
                va= format('%iKB', value)
            end
        else
            if showText then
                va= format(e.onlyChinese and '插件内存：%.2f MB' or TOTAL_MEM_MB_ABBR, value/1000)
            else
                va= format('%.2fMB', value/1000)
            end
        end
    end
    return va, value
end










function WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
    if not UnitAffectingCombat('player') then
        UpdateAddOnMemoryUsage()
        UpdateAddOnCPUUsage()
    end
end









function WoWTools_AddOnsMixin:Get_AddListInfo()
    local load, some, sel= 0, 0, 0
    local tab= {}
    for i=1, C_AddOns.GetNumAddOns() do
        if C_AddOns.IsAddOnLoaded(i) then
            load= load+1
        end
        local stat= C_AddOns.GetAddOnEnableState(i) or 0
        if stat>0 then
            if stat==1 then
                some= some +1
            elseif stat==2 then
                sel= sel+1
            end
            local name=C_AddOns.GetAddOnInfo(i)
            tab[name]= stat==1 and e.Player.guid or i
        end
    end
    return load, some, sel, tab
end







--提示，当前，选中
function WoWTools_AddOnsMixin:Show_Select_Tooltip(tooltip, tab)
    tooltip= tooltip or GameTooltip
    tab= tab or select(4, WoWTools_AddOnsMixin:Get_AddListInfo())

    local index, newTab, allMemo= 0, {}, 0
    for name, value in pairs(tab) do
        local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
        local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
        local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
        local isLoaded, reason= C_AddOns.IsAddOnLoaded(name)
        local vType= type(value)
        local text= vType=='string' and WoWTools_UnitMixin:GetPlayerInfo({guid=value})
        if not text and not isLoaded and reason then
            text= '|cff9e9e9e'..e.cn(_G['ADDON_'..reason] or reason)..' ('..index
        end
        local title= C_AddOns.GetAddOnInfo(name) or name
        local col= C_AddOns.GetAddOnDependencies(name) and '|cffff00ff' or (isLoaded and '|cnGREEN_FONT_COLOR:') or '|cff9e9e9e'
        local memo, va= self:Get_MenoryValue(name, false)--内存
        memo= memo and (' |cnRED_FONT_COLOR:'..memo..'|r') or ''
        table.insert(newTab, {
            left=col..icon..title..'|r'..memo,
            right= text or ' ',
            memo= va or 0
        })
        allMemo= allMemo+ (va or 0)
        index= index+1
    end

    table.sort(newTab, function(a,b) return a.memo<b.memo end)

    local percentText=''
    if allMemo>0 then
        if allMemo<1000 then
            percentText= format('%iKB',allMemo)
        else
            percentText= format('%0.2fMB',allMemo/1000)
        end
    end
    tooltip:AddDoubleLine(' ', index..' '..(e.onlyChinese and '插件' or ADDONS)..' '..percentText)

    for i, info in pairs(newTab) do
        local left=info.left
        if info.memo>0 and allMemo>0 then
            local percent= info.memo/allMemo*100
            if percent>1 then
                left= format('%s |cffffffff%i%%|r', left, percent)
            end
        end
        tooltip:AddDoubleLine((i<10 and ' '..i or i)..') '..left, info.right)
    end
end


















--#####
--初始化
--#####
local function Init()
    do
        WoWTools_AddOnsMixin:Init_Menu_Button()
        WoWTools_AddOnsMixin:Init_Load_Button()
        WoWTools_AddOnsMixin:Init_NewButton_Button()--新建按钮
        WoWTools_AddOnsMixin:Init_Right_Buttons()
        WoWTools_AddOnsMixin:Init_Left_Buttons()
    end

    WoWTools_AddOnsMixin:Init_Info_Plus()

    WoWTools_MoveMixin:Setup(AddonList, {
        --needSize=true, needMove=true,
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
                    GameTooltip:AddLine(e.onlyChinese and '加载过期插件' or ADDON_FORCE_LOAD)
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
end














local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_AddOnsMixin.Save= WoWToolsSave['Plus_AddOns'] or Save()
            local addName='|A:Garr_Building-AddFollowerPlus:0:0|a'..(e.onlyChinese and '插件管理' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE))

            WoWTools_AddOnsMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                Value= not Save().disabled,
                GetValue=function () return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })


            if not Save().disabled then
                Init()
            end
            self:UnregisterEvent(event)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_AddOns']=Save()
        end
    end
end)