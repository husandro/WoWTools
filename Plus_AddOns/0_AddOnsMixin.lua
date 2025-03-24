WoWTools_AddOnsMixin={}

--插件内存
function WoWTools_AddOnsMixin:Get_MenoryValue(indexORname, showText)
    local va
    local value= GetAddOnMemoryUsage(indexORname)
    if value and value>0 then
        if value<1000 then
            if showText then
                va= format(WoWTools_Mixin.onlyChinese and '插件内存：%.2f KB' or TOTAL_MEM_KB_ABBR, value)
            else
                va= format('%iKB', value)
            end
        else
            if showText then
                va= format(WoWTools_Mixin.onlyChinese and '插件内存：%.2f MB' or TOTAL_MEM_MB_ABBR, value/1000)
            else
                va= format('%.2fMB', value/1000)
            end
        end
    end
    return va, value
end

--更新，使用情况
local lastMemoryUpdate
function WoWTools_AddOnsMixin:Update_Usage()
    if UnitAffectingCombat('player') or InGlue() then
        return
    end
    local now = GetTime()
    if not lastMemoryUpdate or now > lastMemoryUpdate + 15 then
        lastMemoryUpdate= now
        UpdateAddOnMemoryUsage()
        UpdateAddOnCPUUsage()
    end
end

--列表，信息
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
            tab[name]= stat==1 and WoWTools_DataMixin.Player.GUID or i
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
            text= '|cff9e9e9e'..WoWTools_TextMixin:CN(_G['ADDON_'..reason] or reason)..' ('..index
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
    tooltip:AddDoubleLine(' ', index..' '..(WoWTools_Mixin.onlyChinese and '插件' or ADDONS)..' '..percentText)

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