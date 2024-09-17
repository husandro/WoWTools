local id, e = ...
local addName

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
        ['TextureAtlasViewer']=78,
        ['WoWeuCN_Tooltips']=96,
        [id]=99,
    },
    enableAllButtn= e.Player.husandro,--全部禁用时，不禁用本插件

    load_list=e.Player.husandro,--禁用, 已加载，列表
    load_list_size=22,
    --load_list_top=true,
}
}



local function Save()
    return WoWTools_AddOnsMixin.Save
end
local NewButton--新建按钮
local FastButtons={}--快捷键











local function Get_Memory_Value(indexORname, showText)
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
    tooltip= tooltip or e.tips
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
        local memo, va= Get_Memory_Value(name, false)--内存
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

































































--新建按钮
local function Init_Add_Save_Button()
    NewButton= WoWTools_ButtonMixin:Cbtn(AddonList, {size={26,26}, atlas='communities-chat-icon-plus'})

    NewButton.Text= WoWTools_LabelMixin:CreateLabel(AddonList)--已选中，数量
    NewButton.Text:SetPoint('BOTTOMRIGHT', NewButton, 'LEFT',0, 1)
    NewButton.Text:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    NewButton.Text:SetScript('OnEnter', function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', e.onlyChinese and '已选中', 'Selected')
        e.tips:Show()
        self:SetAlpha(0.3)
    end)
    NewButton:SetAlpha(0.5)
    NewButton:SetPoint('TOPRIGHT', -2, -28)
    NewButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) self.Text:SetAlpha(1) GameTooltip_Hide() end)
    NewButton:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName , addName)
        e.tips:AddLine(e.onlyChinese and '创建一个新配置方案' or CREATE_NEW_COMPACT_UNIT_FRAME_PROFILE)
        e.tips:AddLine(' ')

        WoWTools_AddOnsMixin:Show_Select_Tooltip()--提示，当前，选中

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            '|A:communities-chat-icon-plus:0:0|a'
            ..(e.onlyChinese and '新建' or NEW)
            ..e.Icon.left,

            (e.onlyChinese and '选项' or OPTIONS)
            ..e.Icon.right
        )
        e.tips:Show()
        self:SetAlpha(1)
        self.Text:SetAlpha(0.5)
    end)
    NewButton:SetScript('OnClick',function(_, d)
        if d=='LeftButton' then
            StaticPopupDialogs['WoWTools_AddOns_NEW']= StaticPopupDialogs['WoWTools_AddOns_NEW'] or {
                text =id..' '..addName
                    ..'|n|n'
                    ..(e.onlyChinese and '当前已选择' or ICON_SELECTION_TITLE_CURRENT)
                    ..' |cnGREEN_FONT_COLOR:%s|r '..(e.onlyChinese and '插件' or ADDONS)..'|n|n'
                    ..(e.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET),
                button1 = e.onlyChinese and '新建' or NEW,
                button2 = e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                OnAccept=function(self)
                    local text = self.editBox:GetText()
                    Save().buttons[text]= select(4 ,WoWTools_AddOnsMixin:Get_AddListInfo())
                    e.call(AddonList_Update)
                end,
                OnShow=function(self)
                    self.editBox:SetText(e.onlyChinese and '一般' or RESISTANCE_FAIR)
                end,
                EditBoxOnTextChanged= function(self)
                    local text= self:GetText()
                    local btn=self:GetParent().button1
                    btn:SetText(Save().buttons[text] and format('|cffff00ff%s', e.onlyChinese and '替换' or REPLACE) or format('|cnGREEN_FONT_COLOR:%s', e.onlyChinese and '新建' or NEW))
                    btn:SetEnabled(self:GetText():gsub(' ', '')~='')
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end,
            }

            local _, some, sel= WoWTools_AddOnsMixin:Get_AddListInfo()--检查列表, 选取数量, 总数, 数量/总数
            StaticPopup_Show('WoWTools_AddOns_NEW',
                format('%d%s',
                    sel,
                    some>0 and format(' (%s%d)', e.Icon.player, some) or ''
                )
            )
        elseif d=='RightButton' then
            e.OpenPanelOpting(nil, addName)
        end
    end)

    NewButton.Text2=WoWTools_LabelMixin:CreateLabel(AddonList, {justifyH='RIGHT'})--总内存
    NewButton.Text2:SetPoint('TOPRIGHT', NewButton, 'LEFT', 0, -1)
    NewButton.Text2:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    NewButton.Text2:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')

        local newTab={}
        local need, load, allMomo= 0, 0, 0
        for index=1, C_AddOns.GetNumAddOns() do
            local isLoaded= C_AddOns.IsAddOnLoaded(index)
            local dema= select(2, C_AddOns.IsAddOnLoadable(index))=='DEMAND_LOADED'
            if isLoaded or dema then--已加载, 带加载
                local title = select(2, C_AddOns.GetAddOnInfo(index))
                local iconTexture = C_AddOns.GetAddOnMetadata(index, "IconTexture")
                local iconAtlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
                local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
                local col= dema and '|cffff00ff' or '|cnGREEN_FONT_COLOR:'
                local memo, value= Get_Memory_Value(index, false)
                memo= memo and ' |cnRED_FONT_COLOR:'..memo..'|r' or ''
                table.insert(newTab, {
                    left=icon..col..title..memo,
                    right=dema and col..e.cn(_G['ADDON_DEMAND_LOADED']) or ' ',
                    memo=value or 0
                })
                allMomo= allMomo+ (value or 0)
            end

            if dema then
                need= need+1
            elseif isLoaded then
                load= load+1
            end
        end

        table.sort(newTab, function(a, b) return a.memo<b.memo end)
        for _, tab in pairs(newTab) do
            local left= tab.left
            if tab.memo>0 and allMomo>0 then
                local percent= tab.memo/allMomo*100
                if percent>1 then
                    left= format('%s |cffffffff%i%%|r', left, tab.memo/allMomo*100)
                end
            end
           e.tips:AddDoubleLine(left, tab.right)
        end

        local allMemberText=''--内存
        if allMomo>0 then
            e.tips:AddLine(' ')
            if allMomo<1000 then
                allMemberText= format(' |cnRED_FONT_COLOR:%0.2fKB|r', allMomo)
            else
                allMemberText=format(' |cnRED_FONT_COLOR:%0.2fMB|r', allMomo/1000)
            end
        end

        e.tips:AddDoubleLine(
            load..' |cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已加载' or LOAD_ADDON)..'|r |cnRED_FONT_COLOR:'..allMemberText,
            '|cffff00ff'..need..' '..(e.onlyChinese and '只能按需加载' or ADDON_DEMAND_LOADED)
        )

        e.tips:Show()
        self:SetAlpha(0.5)
    end)

    NewButton.Text3=WoWTools_LabelMixin:CreateLabel(AddonList, {justifyH='RIGHT'})--总已加载，数量
    NewButton.Text3:SetPoint('RIGHT', NewButton.Text2, 'LEFT', -8, 0)
    NewButton.Text3:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    NewButton.Text3:SetScript('OnEnter', function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(format('|cnGREEN_FONT_COLOR:%s', e.onlyChinese and '已加载', LOAD_ADDON), format('|cffff00ff+%s', e.onlyChinese and '只能按需加载' or ADDON_DEMAND_LOADED))
        e.tips:Show()
        self:SetAlpha(0.3)
    end)

    NewButton:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 3) +elapsed
        if self.elapsed>3 or UnitAffectingCombat('player') then
            self.elapsed=0
            WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
            local value, text= 0, ''
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.IsAddOnLoaded(i) then
                    value= value+ (GetAddOnMemoryUsage(i) or 0)
                end
            end
            if value>0 then
                if value<1000 then
                    text= format('%iKB', value)
                else
                    text= format('%0.2fMB', value/1000)
                end
            end
            self.Text2:SetText(text)
        end
    end)

    local label= WoWTools_LabelMixin:CreateLabel(AddonListEnableAllButton)--插件，总数
    label:SetPoint('LEFT',3,0)
    label:SetText(C_AddOns.GetNumAddOns())


    local btn= WoWTools_ButtonMixin:Cbtn(AddonList, {atlas='talents-button-undo', size=18})
    btn:SetAlpha(0.5)
    btn:SetPoint('TOPLEFT', 160, -33)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip_Hide() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(' ', e.onlyChinese and '刷新' or REFRESH)
        e.tips:Show()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnClick', function()
        if AddonList.startStatus then
            for i=1,C_AddOns.GetNumAddOns() do
                if AddonList.startStatus[i] then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
        else
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.IsAddOnLoaded(i) then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
        end
        e.call(AddonList_Update)
    end)
end























local function Create_Fast_Button(indexAdd)
    local btn= WoWTools_ButtonMixin:Cbtn(AddonList, {size={18,18}})
    btn.Text= WoWTools_LabelMixin:CreateLabel(btn)
    btn.Text:SetPoint('RIGHT', btn, 'LEFT')
    btn.checkTexture= btn:CreateTexture()
    btn.checkTexture:SetAtlas('checkmark-minimal')
    btn.checkTexture:SetSize(16,16)
    btn.checkTexture:SetPoint('RIGHT', btn.Text, 'LEFT',0,-2)
    function btn:get_add_info()
        local atlas = C_AddOns.GetAddOnMetadata(self.name, "IconAtlas")
        local texture = C_AddOns.GetAddOnMetadata(self.name, "IconTexture")
        local name, title = C_AddOns.GetAddOnInfo(self.name)
        name= title or name or self.name or ''
        return name, atlas, texture
    end
    function btn:settings()
        local name, atlas, texture= self:get_add_info()
        if texture then
            self:SetNormalTexture(texture)
        elseif atlas then
            self:SetNormalAtlas(atlas)
        else
            self:SetNormalTexture(0)
        end
        self.Text:SetText(name or self.name)
        if C_AddOns.GetAddOnEnableState(self.name)~=0 then
            self.Text:SetTextColor(0,1,0)
            self.checkTexture:SetShown(true)
        else
            self.Text:SetTextColor(1, 0.82,0)
            self.checkTexture:SetShown(false)
        end
    end
    btn:SetScript('OnLeave', function(self)
        if self.findFrame then
            if self.findFrame.check then
                self.findFrame.check:set_leave_alpha()
            end
            self.findFrame=nil
        end
        GameTooltip_Hide()
        self.Text:SetAlpha(1)
    end)
    function btn:set_tooltips()
        AddonTooltip:SetOwner(self.checkTexture, "ANCHOR_LEFT")
        AddonTooltip_Update(self)
        AddonTooltip:AddLine(' ')
        AddonTooltip:AddDoubleLine(e.GetEnabeleDisable(C_AddOns.GetAddOnEnableState(self:GetID())~=0), e.Icon.left)
        AddonTooltip:Show()
    end
    btn:SetScript('OnEnter', function(self)
        local index= self:GetID()
        if C_AddOns.GetAddOnInfo(index)==self.name then
            self:set_tooltips()
        else
           local findIndex
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.GetAddOnInfo(i)== self.name then
                    findIndex= i
                    self:SetID(i)
                    Save().fast[self.name]= i
                    self:set_tooltips()
                    break
                end
            end
            if not findIndex then
                local name, atlas, texture= self:get_add_info()
                local icon= atlas and format('|A:%s:26:26|a', atlas) or (texture and format('|T%d:26|t', texture)) or ''
                e.tips:SetOwner(self.Text, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(' ', icon..name)
                e.tips:Show()
            else
                index=findIndex
            end
        end
        if index then
            AddonList.ScrollBox:ScrollToElementDataIndex(index)
            for _, frame in pairs( AddonList.ScrollBox:GetFrames() or {}) do
                if frame:GetID()==index then
                    if frame.check then
                        frame.check:set_enter_alpha()
                        self.findFrame=frame
                    end
                    break
                end
            end
        end
        self.Text:SetAlpha(0.3)
    end)
    btn:SetScript('OnClick', function(self)
        if C_AddOns.GetAddOnEnableState(self.name)~=0 then
            C_AddOns.DisableAddOn(self.name)
        else
            C_AddOns.EnableAddOn(self.name)
        end
        e.call(AddonList_Update)
        self:set_tooltips()
    end)
    if indexAdd==1 then
        btn:SetPoint('TOPRIGHT', AddonList, 'TOPLEFT', 8,0)
    else
        btn:SetPoint('TOPRIGHT', FastButtons[indexAdd-1], 'BOTTOMRIGHT')
    end
    FastButtons[indexAdd]= btn
    return btn
end











--插件，快捷，选中
local function Set_Fast_Button()
    local newTab={}
    for name, index in pairs(Save().fast) do
        if C_AddOns.DoesAddOnExist(name) then
            table.insert(newTab, {name=name, index=index or 0})
        else
            Save().fast[name]= nil
        end
    end
    table.sort(newTab, function(a, b) return a.index< b.index end)

    for i, info in pairs(newTab) do
        local btn= FastButtons[i] or Create_Fast_Button(i)
        btn.name= info.name
        btn:SetID(info.index)
        btn:settings()
        btn:SetShown(true)
    end
    for i= #newTab +1, #FastButtons do
        local btn= FastButtons[i]
        if btn then
            btn:SetShown(false)
            btn.name=nil
        end
    end
end




























































--依赖，移过，提示
local function Find_AddOn_Dependencies(find, check)--依赖，提示
    local addonIndex= check:GetID()
    local tab={}
    for _, depName in pairs({C_AddOns.GetAddOnDependencies(addonIndex)}) do
        tab[depName]=true
    end
    for _, frame in pairs(AddonList.ScrollBox:GetFrames() or {}) do
        if frame.check then
            local show=false
            if find then
                local index= frame:GetID()
                if index== addonIndex or tab[C_AddOns.GetAddOnInfo(index)] then
                    show=true
                end
            end
            frame.check.select:SetShown(show)
        end
    end
end




local function Create_Check(frame)
    if frame.check then
        return
    end
    frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")

    frame.check:SetSize(20,20)--Fast，选项

    frame.check:SetPoint('RIGHT', frame)
    frame.check:SetScript('OnClick', function(self)
        Save().fast[self.name]= not Save().fast[self.name] and self:GetID() or nil
        Set_Fast_Button()
    end)

    frame.check.dep= frame:CreateLine()--依赖，提示
    frame.check.dep:Hide()
    frame.check.dep:SetColorTexture(1, 0.82, 0)
    frame.check.dep:SetStartPoint('BOTTOMLEFT', 55,2)
    frame.check.dep:SetEndPoint('BOTTOMRIGHT', -20,2)
    frame.check.dep:SetThickness(0.5)
    frame.check.dep:SetAlpha(0.2)

    frame.check.select= frame:CreateTexture(nil, 'OVERLAY')--光标，移过提示
    frame.check.select:SetAtlas('CreditsScreen-Selected')
    frame.check.select:SetAllPoints(frame)
    frame.check.select:Hide()

    frame.check.Text:SetParent(frame)--索引
    frame.check.Text:ClearAllPoints()
    frame.check.Text:SetPoint('RIGHT', frame.check, 'LEFT')

    frame.check.memoFrame= CreateFrame("Frame", nil, frame.check)
    frame.check.memoFrame.Text= WoWTools_LabelMixin:CreateLabel(frame, {justifyH='RIGHT'})
    frame.check.memoFrame.Text:SetPoint('RIGHT', frame.Status, 'LEFT')
    frame.check.memoFrame.Text:SetAlpha(0.5)
    frame.check.memoFrame:Hide()
    frame.check.memoFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 3) + elapsed
        if self.elapsed > 3 then
            self.elapsed = 0
            self.Text:SetText(Get_Memory_Value(self:GetID(), false) or '')
        end
    end)
    frame.check.memoFrame:SetScript('OnHide', function(self)
        self.Text:SetText('')
        self.elapsed=nil
    end)


    function frame.check:set_leave_alpha()
        local addonIndex= self:GetID()
        self:SetAlpha(Save().fast[self.name] and 1 or 0)
        self.Text:SetAlpha(C_AddOns.GetAddOnDependencies(addonIndex) and 0.3 or 1)
        local check= self:GetParent().Enabled
        check:SetAlpha(check:GetChecked() and 1 or 0)
        Find_AddOn_Dependencies(false, self)--依赖，移过，提示
    end
    function frame.check:set_enter_alpha()
        self:SetAlpha(1)
        self.Text:SetAlpha(1)
        self:GetParent().Enabled:SetAlpha(1)
        Find_AddOn_Dependencies(true, self)--依赖，移过，提示
    end


    frame.check:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:set_leave_alpha()
    end)
    frame.check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        local addonIndex= self:GetID()
        local icon= select(3, WoWTools_TextureMixin:IsAtlas( C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture") or C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas"))) or ''--Atlas or Texture
        e.tips:AddDoubleLine(
            format('%s%s |cnGREEN_FONT_COLOR:%d|r', icon, self.name or '', addonIndex),
            format('%s%s', e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, e.Icon.left)
        )
        e.tips:Show()
        self:set_enter_alpha()
    end)
    frame.Enabled:HookScript('OnLeave', function(self)
        self:GetParent().check:set_leave_alpha()
    end)
    frame.Enabled:HookScript('OnEnter', function(self)
        self:GetParent().check:set_enter_alpha()
    end)
    frame:HookScript('OnLeave', function(self)
        self.check:set_leave_alpha()
    end)
    frame:HookScript('OnEnter', function(self)
        self.check:set_enter_alpha()
    end)
end











--列表，内容
local function Init_Set_List(frame, addonIndex)
    Create_Check(frame)

    local name, title= C_AddOns.GetAddOnInfo(addonIndex)
    local isChecked= Save().fast[name] and true or false
    if isChecked then
        Save().fast[name]= addonIndex
    end

    local iconTexture = C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture")
    local iconAtlas = C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas")

    if not iconTexture and not iconAtlas then--去掉，没有图标，提示
       frame.Title:SetText('       '..(title or name))
    end

    frame.check:SetID(addonIndex)
    frame.check:SetCheckedTexture(iconTexture or e.Icon.icon)
    frame.check.name= name
    frame.check.isDependencies= C_AddOns.GetAddOnDependencies(addonIndex) and true or nil
    frame.check:SetChecked(isChecked)--fast
    frame.check:SetAlpha(isChecked and 1 or 0.1)

    frame.check.Text:SetText(addonIndex or '')--索引
    frame.check.memoFrame:SetID(addonIndex)
    frame.check.memoFrame:SetShown(C_AddOns.IsAddOnLoaded(addonIndex))


    if frame.check.isDependencies then--依赖
        frame.check.select:SetVertexColor(0,1,0)
        frame.check.Text:SetTextColor(0.5,0.5,0.5)
        frame.check.Text:SetAlpha(0.3)
        frame.check.dep:SetShown(false)
    else
        frame.check.select:SetVertexColor(1,1,1)
        frame.check.Text:SetTextColor(1, 0.82, 0)
        frame.check.Text:SetAlpha(1)
        frame.check.dep:SetShown(true)
    end
    frame.Status:SetAlpha(0.5)
    frame.Enabled:SetAlpha(frame.Enabled:GetChecked() and 1 or 0)
end





























--#####
--初始化
--#####
local function Init()
    StaticPopupDialogs['WoWTools_AddOns_NAME']= {
        text =id..' '..addName
            ..'|n|n'
            ..(e.onlyChinese and '为布局%s输入新名称' or HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE)
            ..'|n|n'
            ..(e.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET),
        button1 = e.onlyChinese and '更新' or UPDATE,
        button2 = e.onlyChinese and '取消' or CANCEL,
        whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
        OnAccept=function(self, name)
            local tab=Save().buttons[name]
            if tab then
                local text= self.editBox:GetText()
                for n in pairs(Save().buttons) do
                    if name==n then
                        Save().buttons[n]= nil
                        Save().buttons[text]= tab
                        e.call(AddonList_Update)
                        return
                    end
                end
            end
            print(e.addName, addName, format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), name)
        end,
        OnShow=function(self, name)
            self.editBox:SetText(name)
        end,
        EditBoxOnTextChanged= function(self, name)
            local text= self:GetText()
            self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='' and not Save().buttons[text])
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }


    e.Set_Move_Frame(AddonList, {needSize=true, needMove=true, minW=430, minH=120, setSize=true, initFunc=function()
        AddonList.ScrollBox:ClearAllPoints()
        AddonList.ScrollBox:SetPoint('TOPLEFT', 7, -64)
        AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)
    end, sizeRestFunc=function(self)
        self.target:SetSize("500", "478")
    end})

    AddonListForceLoad:ClearAllPoints()
    AddonListForceLoad:SetPoint('TOP', AddonList, -16, -26)

    
    do
        WoWTools_AddOnsMixin:Init_Menu_Button()
    end
    WoWTools_AddOnsMixin:Init_Load_Button()
    Init_Add_Save_Button()--新建按钮




    hooksecurefunc('AddonList_InitButton', function(frame, addonIndex)
        frame.Title:SetPoint('RIGHT', -220, 0 )
        Init_Set_List(frame, addonIndex)--列表，内容
    end)

    hooksecurefunc('AddonList_Update', function()
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        Set_Fast_Button()--插件，快捷，选中
        Set_Buttons()
        AddonListOkayButton:SetWidth(AddonListOkayButton:GetFontString():GetWidth()+24)
    end)



    --#############
    --不禁用，本插件
    --#############
    local btn= WoWTools_ButtonMixin:Cbtn(AddonList, {size={18,18}, icon= Save().enableAllButtn})
    btn:SetPoint('LEFT', AddonListDisableAllButton, 'RIGHT', 2,0)
    btn:SetAlpha(0.3)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS)
        e.tips:AddDoubleLine(format('%s|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r', e.onlyChinese and '启用' or ENABLE, ''), e.GetYesNo(Save().enableAllButtn))
        e.tips:Show()
        self:SetAlpha(1)
    end
    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:SetAlpha(0.3)
        AddonListDisableAllButton:SetAlpha(1)
        if self.findFrame then
            if self.findFrame.check then
                self.findFrame.check:set_leave_alpha()
            end
            self.findFrame=nil
        end
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        AddonListDisableAllButton:SetAlpha(0.3)
        if not self.index then
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.GetAddOnInfo(i)== id then
                    self.index=i
                    break
                end
            end
        end
        if self.index then
            AddonList.ScrollBox:ScrollToElementDataIndex(self.index)
            for index, frame in pairs( AddonList.ScrollBox:GetFrames() or {}) do
                if frame:GetID()==index then
                    if frame.check then
                        frame.check:set_enter_alpha()
                        self.findFrame=frame
                    end
                    break
                end
            end
        end
    end)
    btn:SetScript('OnClick', function(self)
        Save().enableAllButtn= not Save().enableAllButtn and true or nil
        self:SetNormalAtlas(Save().enableAllButtn and e.Icon.icon or e.Icon.disabled)
        self:set_tooltips()
    end)
    AddonListDisableAllButton:HookScript('OnClick', function()
        if Save().enableAllButtn then
            C_AddOns.EnableAddOn(id)
            e.call(AddonList_Update)
        end
    end)




    hooksecurefunc('AddonTooltip_Update', function(frame)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        local index= frame:GetID()
        local va=Get_Memory_Value(index, true)
        if va then
            local iconTexture = C_AddOns.GetAddOnMetadata(index, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or ''
            AddonTooltip:AddLine(icon..va, 1,0.82,0)
            AddonTooltip:Show()
        end
    end)
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE)] then
                WoWTools_AddOnsMixin.Save= WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE)]
                WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE)]=nil
                Save().fast= Save().fast or {}
                Save().load_list_size= Save().load_list_size or 22
            else
                WoWTools_AddOnsMixin.Save= WoWToolsSave['Plus_AddOns'] or WoWTools_AddOnsMixin.Save
            end

            WoWTools_AddOnsMixin.addName='|A:Garr_Building-AddFollowerPlus:0:0|a'..(e.onlyChinese and '插件管理' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE))
            addName= WoWTools_AddOnsMixin.addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                tooltip= addName,
                Value= not Save().disabled,
                GetValue=function () return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(e.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })


            if not Save().disabled then
                Init()
            end

            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_AddOns']= Save
        end
    end
end)