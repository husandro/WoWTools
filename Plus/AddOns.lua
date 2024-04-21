local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, CHAT_MODERATE)
local Save={
        buttons={
            [BASE_SETTINGS_TAB]={
                ['WeakAuras']=true,
                ['WeakAurasOptions']=true,
                ['WeakAurasArchive']=true,
                ['BugSack']=true,
                ['!BugGrabber']=true,
                ['TextureAtlasViewer']=true,-- true, i or guid
                [id]=true,
            },
        },
        fast={
            [id]= 1,
        },
        enableAllButtn= e.Player.husandro,--全部禁用时，不禁用本插件

        load_list=e.Player.husandro,--禁用, 已加载，列表
        load_list_size=22,
        --load_list_top=true,
    }

local NewButton--新建按钮
local LoadFrame--已加载，插件列表
local Initializer
local Buttons={}--方案
local FastButtons={}--快捷键







local function Is_Load(nameORindex)
    return C_AddOns.IsAddOnLoaded(nameORindex) or select(2, C_AddOns.IsAddOnLoadable(nameORindex))=='DEMAND_LOADED'
end

local function Get_AddList_Info()
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

local function Update_Usage()--更新，使用情况
    if not UnitAffectingCombat('player') then
        UpdateAddOnMemoryUsage()
        UpdateAddOnCPUUsage()
    end
end

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
                va= format('%iMB', value/1000)
            end
        end
    end
    return va, value
end













local function Create_Button(indexAdd)
    local btn=e.Cbtn(AddonList, {icon='hide', size={88,22}})
    btn:SetHighlightAtlas('auctionhouse-nav-button-secondary-select')
    btn.Text= e.Cstr(btn)
    btn.Text:SetPoint('LEFT', 2, 0)

    function btn:set_settings()
        local load, all= 0, 0
        for name in pairs(Save.buttons[self.name] or {}) do
            if C_AddOns.DoesAddOnExist(name) then
                if Is_Load(name) then
                    load= load +1
                end
                all= all+1
            else
                Save.buttons[self.name][name]=nil
            end
        end
        self.Text:SetFormattedText(
            '%s %s%d|r/%s%d|r',
            self.name,
            load==0 and '|cff606060' or '|cnGREEN_FONT_COLOR:',
            load,
            load==all and '|cnGREEN_FONT_COLOR:' or '',
            all
        )
        self.isLoadAll= self.numAllLoad==all and load==all
        self:SetWidth(btn.Text:GetWidth()+4)
        self:SetButtonState(self.isLoadAll and 'PUSHED' or 'NORMAL')
    end

    btn:SetScript('OnClick',function(self, d)
        if d=='LeftButton' then--加载
            local tab= Save.buttons[self.name]
            for i=1, C_AddOns.GetNumAddOns() do
                local name= C_AddOns.GetAddOnInfo(i)
                local value=tab[name]
                local vType= type(value)
                if vType=='boolean' or vType=='number' or value==e.Player.guid then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
            e.Reload()

        elseif d=='RightButton' then--移除
            if not self.Menu then
                self.Menu= CreateFrame("Frame", nil, AddonList, "UIDropDownMenuTemplate")--菜单框架
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)--主菜单
                    local some, sel= select(2, Get_AddList_Info())
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= format('%s #%d', e.onlyChinese and '保存' or SAVE, some+sel),
                        icon= 'ShipMission_ShipFollower-Lock-Rare',
                        notCheckable=true,
                        disabled= (some+sel)==0,
                        arg1= self.name,
                        func= function(_, arg1)
                            Save.buttons[arg1]= select(4, Get_AddList_Info())
                            e.call('AddonList_Update')
                        end
                    }, level)


                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '名称' or NAME,
                        icon= 'QuestLegendaryTurnin',
                        notCheckable=true,
                        arg1= self.name,
                        func= function(_, arg1)
                            StaticPopup_Show('WoWTools_AddOns_NAME', arg1, nil, arg1)
                        end
                    }, level)
                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '删除' or DELETE,
                        icon= 'XMarksTheSpot',
                        colorCode='|cnRED_FONT_COLOR:',
                        notCheckable= true,
                        arg1= self.name,
                        func= function(_, arg1)
                            Save.buttons[arg1]=nil
                            e.call('AddonList_Update')
                        end
                    }, level)
                    e.LibDD:UIDropDownMenu_AddButton({text=self.name, notCheckable=true, isTitle=true}, level)
                    --[[e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '选项' or OPTIONS,
                        icon= 'mechagon-projects',
                        notCheckable= true,
                        func= function()
                            e.OpenPanelOpting(Initializer)
                        end
                    }, level)]]
                end, 'MENU')

            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)

    btn:SetScript('OnEnter', function(self)
        if not Save.buttons[self.name] then return end
        Update_Usage()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(format('|cffffd100%s|r', self.name), Initializer:GetName())
        e.tips:AddLine(' ')
        local index=1
        for name, value in pairs(Save.buttons[self.name]) do
            local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
            local isLoaded= C_AddOns.IsAddOnLoaded(name)
            local vType= type(value)
            local text= vType=='string' and e.GetPlayerInfo({guid=value, reName=true, reRealm=true})
            local reason= select(2, C_AddOns.IsAddOnLoadable(name))
            local col= reason=='DEMAND_LOADED' and '|cffff00ff'
            if not text and not isLoaded and reason then
                text= (col or '|cff606060')..e.cn(_G['ADDON_'..reason] or reason)..' ('..index
            end
            local title= C_AddOns.GetAddOnInfo(name) or name
            local memo= Get_Memory_Value(name, false)--内存
            e.tips:AddDoubleLine(
                format('%s|cffffd100%d)|r%s%s%s|r |cffffffff%s|r',
                    index<10 and ' ' or '',
                    index,
                    icon,
                    isLoaded and '|cnGREEN_FONT_COLOR:' or col or '|cff606060',
                    title,
                    memo or ''
                ), text or ' ')
            index= index+1
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '加载插件' or LOAD_ADDON)..e.Icon.left, (e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..e.Icon.right)
        e.tips:Show()
        NewButton:SetAlpha(1)
    end)
    btn:SetScript('OnLeave', function(self)
        self:set_settings()
        e.tips:Hide()
        NewButton:SetAlpha(0.5)
    end)

    if indexAdd==1 then
        btn:SetPoint('TOPLEFT', AddonList, 'TOPRIGHT', 0, -22)
    else
        btn:SetPoint('TOPLEFT', Buttons[indexAdd-1], 'BOTTOMLEFT')
    end
    Buttons[indexAdd]= btn

    return btn
end








--####
--按钮
--####
local function Set_Buttons()--设置按钮, 和位置
    local load, need, sel, some= 0, 0, 0, 0
    for i=1, C_AddOns.GetNumAddOns() do
        if C_AddOns.IsAddOnLoaded(i) then--已加载
            load= load+1

        elseif select(2, C_AddOns.IsAddOnLoadable(i))=='DEMAND_LOADED' then--需要时加载
            need= need+1
        end
        local stat= C_AddOns.GetAddOnEnableState(i)
        if stat and stat>0 then
            if stat==1 then--角色专用
                some= some +1
            elseif stat==2 then--开启
                sel= sel+1
            end
        end
    end
    local index=1
    for name in pairs(Save.buttons) do
        local btn=Buttons[index] or  Create_Button(index)
        btn.name= name
        btn.numAllLoad= load+ need
        btn:set_settings()
        btn:SetShown(true)
        index= index+1
    end

    --NewButton:SetShown(all>0)
    NewButton.Text:SetFormattedText('%d%s', sel, some>0 and format('%s%d', e.Icon.player, some) or '')
    NewButton.Text2:SetFormattedText('%s%d', need>0 and format('|cffff00ff%d|r|cffffd100+|r', need) or '', load)--总已加载，数量

    for i= index, #Buttons do
        local btn= Buttons[i]
        if btn then
            btn:SetShown(false)
            btn.name= nil
            btn.numAllLoad= nil
        end
    end
end





























--新建按钮
local function Init_Add_Save_Button()
    NewButton= e.Cbtn(AddonList, {size={26,26}, atlas='communities-chat-icon-plus'})
        
    NewButton.Text= e.Cstr(AddonList)--已选中，数量
    NewButton.Text:SetPoint('RIGHT', NewButton, 'LEFT')
    NewButton.Text2=e.Cstr(AddonList, {color={r=0,g=1,b=0}, mouse=true, justifyH='RIGHT'})--总已加载，数量
    NewButton.Text2:SetPoint('RIGHT', AddonListForceLoad, 'LEFT',2,6)
    NewButton.Text3=e.Cstr(AddonList, {mouse=true, justifyH='RIGHT'})--总内存
    NewButton.Text3:SetPoint('RIGHT', AddonListForceLoad, 'LEFT',2,-6)

    NewButton:SetAlpha(0.5)
    NewButton:SetPoint('TOPRIGHT', -2, -28)
    NewButton:SetScript('OnLeave', function(self) self:SetAlpha(0.5) self.Text:SetAlpha(1) GameTooltip_Hide() end)
    NewButton:SetScript('OnEnter', function(self)
        Update_Usage()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id , Initializer:GetName())
        e.tips:AddLine(' ')
        local index, newTab, allMemo= 0, {}, 0
        local tab= select(4, Get_AddList_Info())

        for name, value in pairs(tab) do
            local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
            local isLoaded= C_AddOns.IsAddOnLoaded(name)
            local vType= type(value)
            local text= vType=='string' and e.GetPlayerInfo({guid=value})
            if not text and not isLoaded then
                local reason= select(2, C_AddOns.IsAddOnLoadable(name))
                if reason then
                    text= '|cff606060'..e.cn(_G['ADDON_'..reason] or reason)..' ('..index
                end
            end
            local title= C_AddOns.GetAddOnInfo(name) or name
            local col= C_AddOns.GetAddOnDependencies(name) and '|cffff00ff' or (isLoaded and '|cnGREEN_FONT_COLOR:') or '|cff606060'
            local memo, value= Get_Memory_Value(name, false)--内存
            memo= memo and (' |cnRED_FONT_COLOR:'..memo..'|r') or ''
            table.insert(newTab, {
                left=col..icon..title..'|r'..memo,
                right= text or ' ',
                memo= value or 0
            })
            allMemo= allMemo+ (value or 0)
            index= index+1
        end

        table.sort(newTab, function(a,b) return a.memo<b.memo end)
        for _, info in pairs(newTab) do
            local left=info.left
            if info.memo>0 and allMemo>0 then
                local percent= info.memo/allMemo*100
                if percent>1 then
                    left= format('%s |cffffffff%i%%|r', left, percent)
                end
            end
            e.tips:AddDoubleLine(left, info.right)
        end


        e.tips:AddLine(' ')
        local percentText=''
        if allMemo>0 then
            if allMemo<1000 then
                percentText= format('%iKB',allMemo)
            else
                percentText= format('%0.2fMB',allMemo/1000)
            end
        end
        e.tips:AddDoubleLine(
            format('%d|A:communities-chat-icon-plus:0:0|a|cffff00ff%s|r |cnRED_FONT_COLOR:%s|rs%s',
                index,
                e.onlyChinese and '新建' or NEW,
                percentText,
                e.Icon.left),
            format('%s%s', e.onlyChinese and '选项' or OPTIONS, e.Icon.right)
        )
        e.tips:Show()
        self:SetAlpha(1)
        self.Text:SetAlpha(0.5)
    end)
    NewButton:SetScript('OnClick',function(_, d)
        if d=='LeftButton' then
            StaticPopupDialogs['WoWTools_AddOns_NEW']= StaticPopupDialogs['WoWTools_AddOns_NEW'] or {
                text =id..' '..Initializer:GetName()
                    ..'|n|n'
                    ..(e.onlyChinese and '当前已选择' or ICON_SELECTION_TITLE_CURRENT)
                    ..' %s|n|n'
                    ..(e.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET),
                button1 = e.onlyChinese and '新建' or NEW,
                button2 = e.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                OnAccept=function(self)
                    local text = self.editBox:GetText()
                    Save.buttons[text]= select(4 ,Get_AddList_Info())
                    e.call('AddonList_Update')
                end,
                OnShow=function(self)
                    self.editBox:SetText(e.onlyChinese and '一般' or RESISTANCE_FAIR)
                end,
                EditBoxOnTextChanged= function(self)
                    local text= self:GetText()
                    local btn=self:GetParent().button1
                    btn:SetText(Save.buttons[text] and format('|cffff00ff%s', e.onlyChinese and '替换' or REPLACE) or format('|cnGREEN_FONT_COLOR:%s', e.onlyChinese and '新建' or NEW))
                    btn:SetEnabled(self:GetText():gsub(' ', '')~='')
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end,
            }

            local _, some, sel= Get_AddList_Info()--检查列表, 选取数量, 总数, 数量/总数
            StaticPopup_Show('WoWTools_AddOns_NEW',
                format('%d%s',
                    sel,
                    some>0 and format(' (%s%d)', e.Icon.player, some) or ''
                )
            )
        elseif d=='RightButton' then
            e.OpenPanelOpting(Initializer)
        end
    end)

    function NewButton:set_memoria_tooltips(frame)
        Update_Usage()
        e.tips:SetOwner(frame, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
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
            if isLoaded then
                load= load+1
            elseif dema then
                need= need+1
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
    end
    NewButton.Text2:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip_Hide() end)
    NewButton.Text2:SetScript('OnEnter', function(self) NewButton:set_memoria_tooltips(self) self:SetAlpha(0.3) end)

    NewButton:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 2) +elapsed
        if self.elapsed>2 then
            self.elapsed=0
            if UnitAffectingCombat('player') then return end--战斗中，不刷新
            Update_Usage()
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
            self.Text3:SetText(text)
        end
    end)
    NewButton.Text3:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
    NewButton.Text3:SetScript('OnEnter', function(self) NewButton:set_memoria_tooltips(self) self:SetAlpha(0.5) end)

    local label= e.Cstr(AddonListEnableAllButton)--插件，总数
    label:SetPoint('LEFT',3,0)
    label:SetText(C_AddOns.GetNumAddOns())


    local btn= e.Cbtn(AddonList, {atlas='talents-button-undo', size=18})
    btn:SetAlpha(0.5)
    btn:SetPoint('TOPLEFT', 150, -33)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip_Hide() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
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
        e.call('AddonList_Update')
    end)
end























local function Create_Fast_Button(indexAdd)
    local btn= e.Cbtn(AddonList, {size={18,18}})
    btn.Text= e.Cstr(btn)
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
        self.Text:SetText(title or name or self.name)
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
    end)
    function btn:set_tooltips()
        AddonTooltip:SetOwner(self.checkTexture, "ANCHOR_LEFT")
        AddonTooltip_Update(self)
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
                    Save.fast[self.name]= i
                    self:set_tooltips()
                    break
                end
            end
            if not findIndex then
                local name, atlas, texture= self:get_add_info()
                local icon= atlas and format('|A:%s:26:26|a', atlas) or (texture and format('|T%d:26|t', texture)) or ''
                e.tips:SetOwner(self.Text, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, Initializer:GetName())
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
    end)
    btn:SetScript('OnClick', function(self)
        if C_AddOns.GetAddOnEnableState(self.name)~=0 then
            C_AddOns.DisableAddOn(self.name)
        else
            C_AddOns.EnableAddOn(self.name)
        end
        e.call('AddonList_Update')
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
    for name, index in pairs(Save.fast) do
        if C_AddOns.DoesAddOnExist(name) then
            table.insert(newTab, {name=name, index=index or 0})
        else
            Save.fast[name]= nil
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
























--已加载，插件列表
local function Set_Load_Button()--LoadButtons
    LoadFrame:SetShown(Save.load_list)
    if not Save.load_list then
        return
    end

    local newTab={}
    for i=1, C_AddOns.GetNumAddOns() do
        if not C_AddOns.GetAddOnDependencies(i) then
            local texture = C_AddOns.GetAddOnMetadata(i, "IconTexture")
            local atlas = C_AddOns.GetAddOnMetadata(i, "IconAtlas")
            if texture or atlas then
                if C_AddOns.IsAddOnLoaded(i) then
                    table.insert(newTab, {index=i, load=true, atlas=atlas, texture=texture})
                elseif select(2, C_AddOns.IsAddOnLoadable(i))=='DEMAND_LOADED' then
                    table.insert(newTab, {index=i, load=false, atlas=atlas, texture=texture})
                end
            end
        end
    end

    for i, info in pairs(newTab) do
       local btn= LoadFrame.buttons[i]
       if not btn then
            btn= e.Cbtn(LoadFrame, {icon='hide'})--, size=22})
            btn.texture= btn:CreateTexture()
            btn.texture:SetAllPoints(btn)
            function btn:set_alpha()
                self:SetAlpha(self.load and 1 or 0.3)
            end

            btn.Text= e.Cstr(btn)
            btn.Text:SetPoint('CENTER')

            btn:SetScript('OnLeave', function(self)
                if self.findFrame then
                    if self.findFrame.check then
                        self.findFrame.check:set_leave_alpha()
                    end
                    self.findFrame=nil
                end
                GameTooltip_Hide()
                self:set_alpha()
                LoadFrame.btn:SetAlpha(0.5)
            end)
            btn:SetScript('OnEnter', function(self)
                local findIndex= self:GetID()
                AddonTooltip:SetOwner(self:GetParent().buttons[1], "ANCHOR_RIGHT")
                AddonTooltip_Update(self)
                AddonList.ScrollBox:ScrollToElementDataIndex(findIndex)
                for _, frame in pairs(AddonList.ScrollBox:GetFrames() or {}) do
                    if frame:GetID()==findIndex then
                        if frame.check then
                            frame.check:set_enter_alpha()
                            self.findFrame=frame
                        end
                        break
                    end
                end
                self:SetAlpha(1)
                LoadFrame.btn:SetAlpha(1)
            end)
            LoadFrame.buttons[i]= btn
       end

       btn:SetAlpha(info.loaded and 1 or 0.3)

       if info.texture then
            btn.texture:SetTexture(info.texture)
            btn.Text:SetText('')
       elseif info.atlas then
            btn.texture:SetAtlas(info.atlas)
            btn.Text:SetText('')
       else
            local name, title=C_AddOns.GetAddOnInfo(info.index)
            name= name or title or ''
            name= name:gsub('!', '')
            name= e.WA_Utf8Sub(name, 2, 3)
            btn.Text:SetText(name)
            btn:SetTexture(0)
       end

       btn:SetID(info.index)
       btn.load= info.load
       btn:set_alpha()
       btn:SetShown(true)
    end

    for i=#newTab +1,  #LoadFrame.buttons do
        local btn= LoadFrame.buttons[i]
        if btn then
            btn:SetShown(false)
        end
    end

    LoadFrame:set_button_point()
end







local function Init_Load_Button()
    LoadFrame= CreateFrame('Frame', nil, AddonList)

    LoadFrame:SetSize(1,1)
    function LoadFrame:set_frame_point()
        LoadFrame:ClearAllPoints()
        if Save.load_list_top then
            LoadFrame:SetPoint('BOTTOMRIGHT', AddonList, 'TOPRIGHT', 1, 2)
        else
            LoadFrame:SetPoint('TOPRIGHT', AddonList, 'BOTTOMRIGHT', 1, -2)
        end
    end
    LoadFrame.buttons={}
    function LoadFrame:set_button_point()
        local last= self
        for _, btn in pairs(self.buttons) do
            btn:SetSize(Save.load_list_size, Save.load_list_size)
            btn:ClearAllPoints()
            if Save.load_list_top then
                btn:SetPoint('BOTTOMRIGHT', last, 'BOTTOMLEFT')
            else
                btn:SetPoint('TOPRIGHT', last, 'TOPLEFT')
            end
            last=btn
        end
        local num= math.modf((AddonList:GetWidth()+12)/Save.load_list_size)
        num= num<4 and 4 or num
        for i=num+1, #self.buttons, num do
            local btn= self.buttons[i]
            btn:ClearAllPoints()
            if Save.load_list_top then
                btn:SetPoint('BOTTOMRIGHT', self.buttons[i- num], 'TOPRIGHT')
            else
                btn:SetPoint('TOPRIGHT', self.buttons[i- num], 'BOTTOMRIGHT')
            end
        end
    end
    AddonList:HookScript('OnSizeChanged', function()
        LoadFrame:set_button_point()
    end)
    AddonList:HookScript('OnShow', function()
        Update_Usage()
        Set_Load_Button()
    end)
    LoadFrame:set_frame_point()


    local btn= e.Cbtn(AddonList.TitleContainer, {size=22, icon='hide'})
    btn:SetPoint('RIGHT', AddonListCloseButton, 'LEFT', -2, 0)
    btn:SetAlpha(0.5)
    function btn:set_tooltips()
        if Save.load_list_top  then
            e.tips:SetOwner(AddonList, "ANCHOR_RIGHT")
        else
            e.tips:SetOwner(self, "ANCHOR_LEFT")
        end
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '仅限有图标' or format(LFG_LIST_CROSS_FACTION, EMBLEM_SYMBOL))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(format('%s %s', e.onlyChinese and '已经打开' or SPELL_FAILED_ALREADY_OPEN, e.GetShowHide(Save.load_list)), e.Icon.left)
        e.tips:AddDoubleLine(
            format('%s |cnGREEN_FONT_COLOR:%s|r',
                e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
                Save.load_list_top and (e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP) or (e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
            ), e.Icon.right)
        e.tips:AddDoubleLine(format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE, Save.load_list_size or 22), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(format('List Bg%s |cnGREEN_FONT_COLOR:%.1f|r (1)', e.onlyChinese and '透明度' or ' alpha',  AddonListInset.Bg:GetAlpha()), 'Alt+'..e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
    end
    function btn:set_icon()
        self:SetNormalAtlas(Save.load_list and (Save.load_list_top and 'MiniMap-QuestArrow' or 'auctionhouse-ui-dropdown-arrow-up') or 'dressingroom-button-appearancelist-up')
    end

    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip_Hide() end)
    btn:SetScript('OnEnter', btn.set_tooltips)

    btn:SetScript('OnClick', function(self, d)
        if IsAltKeyDown() and d=='RightButton' then--Bg 透明度
            Save.Bg_Alpha1= not Save.Bg_Alpha1 and true or nil
            AddonListInset.Bg:SetAlpha(Save.Bg_Alpha1 and 1 or 0.5)

        elseif not IsModifierKeyDown() then
            if d=='LeftButton' then--已加载，图标列表
                Save.load_list= not Save.load_list and true or nil
                Set_Load_Button()
            elseif d=='RightButton' then--方向
                Save.load_list_top= not Save.load_list_top and true or nil
                LoadFrame:set_frame_point()
                LoadFrame:set_button_point()
            end
        end
        self:set_icon()
        self:set_tooltips()
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        local n= Save.load_list_size or 22
        n= d==1 and n-2 or n
        n= d==-1 and n+2 or n
        n= n>72 and 72 or n
        n= n<8 and 8 or n
        Save.load_list_size= n
        LoadFrame:set_button_point()
        self:set_tooltips()
    end)

    btn:set_icon()
    LoadFrame.btn= btn

    C_Timer.After(2, function()--Bg 透明度
        if AddonListInset.Bg:GetAlpha()~=1 and Save.Bg_Alpha1 then
            AddonListInset.Bg:SetAlpha(1)
        end
    end)
end






























local function Create_Check(frame)
    if frame.check then
        return
    end
    frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")

    frame.check:SetSize(20,20)--Fast，选项

    frame.check:SetPoint('RIGHT', frame)
    frame.check:SetScript('OnClick', function(self)
        Save.fast[self.name]= not Save.fast[self.name] and self.index or nil
        Set_Fast_Button()
    end)

    frame.check.dep= frame:CreateLine()--依赖，提示
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

    frame.check.memoText= e.Cstr(frame, {justifyH='RIGHT'})
    frame.check.memoText:SetPoint('RIGHT', frame.Status, 'LEFT')
    frame.check.memoText:SetAlpha(0.5)

    function frame.check:set_leave_alpha()
        self:SetAlpha(Save.fast[self.name] and 1 or 0)
        self.Text:SetAlpha(C_AddOns.GetAddOnDependencies(self.index) and 0.3 or 1)
        self.select:SetShown(false)
        local check= self:GetParent().Enabled
        check:SetAlpha(check:GetChecked() and 1 or 0)
    end
    function frame.check:set_enter_alpha()
        self:SetAlpha(1)
        self.Text:SetAlpha(1)
        self.select:SetShown(true)
        self:GetParent().Enabled:SetAlpha(1)
    end
    function frame.check:set_usage()
        self.memoText:SetText(Get_Memory_Value(self.index, false) or '')
    end

    frame.check:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:set_leave_alpha()
    end)
    frame.check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((self.icon or '')..self.name, self.index)
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
        self.check:set_usage()
        self.check:set_enter_alpha()
    end)
end











--列表，内容
local function Init_Set_List(frame, addonIndex)
    Create_Check(frame)

    local name= C_AddOns.GetAddOnInfo(addonIndex)
    local isChecked= Save.fast[name] and true or false
    if isChecked then
        Save.fast[name]= addonIndex
    end

    local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
    local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")

    if not iconTexture and not iconAtlas then--去掉，没有图标，提示
        local title= frame.Title:GetText()
        if title and title:find('|TInterface\\ICONS\\INV_Misc_QuestionMark:%d+:%d+|t') then
            frame.Title:SetText(title:gsub('|TInterface\\ICONS\\INV_Misc_QuestionMark:%d+:%d+|t', '      '))
        end
    end

    frame.check:SetCheckedTexture(iconTexture or e.Icon.icon)
    frame.check.icon= iconTexture and '|T'..iconTexture..':32|t' or (iconAtlas and '|A:'..iconAtlas..':32:32|a') or nil
    frame.check.index= addonIndex
    frame.check.name= name
    frame.check:SetChecked(isChecked)--fast
    frame.check:SetAlpha(isChecked and 1 or 0.1)

    frame.check.Text:SetText(addonIndex or '')--索引
    frame.check:set_usage()


    if C_AddOns.GetAddOnDependencies(addonIndex) then--依赖
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
        text =id..' '..Initializer:GetName()
            ..'|n|n'
            ..(e.onlyChinese and '为布局%s输入新名称' or HUD_EDIT_MODE_RENAME_LAYOUT_DIALOG_TITLE)
            ..'|n|n'
            ..(e.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET),
        button1 = e.onlyChinese and '更新' or UPDATE,
        button2 = e.onlyChinese and '取消' or CANCEL,
        whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
        OnAccept=function(self, name)
            local tab=Save.buttons[name]
            if tab then
                local text= self.editBox:GetText()
                for n in pairs(Save.buttons) do
                    if name==n then
                        Save.buttons[n]= nil
                        Save.buttons[text]= tab
                        e.call('AddonList_Update')
                        return
                    end
                end
            end
            print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), name)
        end,
        OnShow=function(self, name)
            self.editBox:SetText(name)
        end,
        EditBoxOnTextChanged= function(self, name)
            local text= self:GetText()
            self:GetParent().button1:SetEnabled(text:gsub(' ', '')~='' and not Save.buttons[text])
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }


    e.Set_Move_Frame(AddonList, {needSize=true, needMove=true, minW=430, minH=120, setSize=true, initFunc=function()
        AddonList.ScrollBox:ClearAllPoints()
        AddonList.ScrollBox:SetPoint('TOPLEFT', 7, -64)
        AddonList.ScrollBox:SetPoint('BOTTOMRIGHT', -22,32)
        --hooksecurefunc('AddonList_InitButton', function(entry) entry.Title:SetPoint('RIGHT', -220, 0)end)
    end, sizeRestFunc=function(self)
        self.target:SetSize("500", "478")
    end})

    AddonListForceLoad:ClearAllPoints()
    AddonListForceLoad:SetPoint('TOP', AddonList, -16, -26)

    Init_Add_Save_Button()--新建按钮
    Init_Load_Button()

    hooksecurefunc('AddonList_InitButton', function(frame, addonIndex)
        frame.Title:SetPoint('RIGHT', -220, 0 )
        Init_Set_List(frame, addonIndex)--列表，内容
    end)
-- e.call('AddonList_HasAnyChanged')
    hooksecurefunc('AddonList_Update', function()
        Update_Usage()--更新，使用情况
        Set_Fast_Button()--插件，快捷，选中
        Set_Buttons()
    end)



    --#############
    --不禁用，本插件
    --#############
    local btn= e.Cbtn(AddonList, {size={18,18}, icon= Save.enableAllButtn})
    btn:SetPoint('LEFT', AddonListDisableAllButton, 'RIGHT', 2,0)
    btn:SetAlpha(0.3)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS)
        e.tips:AddDoubleLine(format('%s|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r', e.onlyChinese and '启用' or ENABLE, ''), e.GetYesNo(Save.enableAllButtn))
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
    end)
    btn:SetScript('OnClick', function(self)
        Save.enableAllButtn= not Save.enableAllButtn and true or nil
        self:SetNormalAtlas(Save.enableAllButtn and e.Icon.icon or e.Icon.disabled)
        self:set_tooltips()
    end)
    AddonListDisableAllButton:HookScript('OnClick', function()
        if Save.enableAllButtn then
            C_AddOns.EnableAddOn(id)
            e.call('AddonList_Update')
        end
    end)




    hooksecurefunc('AddonTooltip_Update', function(frame)
        Update_Usage()
        local va=Get_Memory_Value(frame:GetID(), true)
        if va then
            AddonTooltip:AddLine(va, 1,0.82,0)
            AddonTooltip:Show()
        end
    end)


    local frame= Create
end


















--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.fast= Save.fast or {}
            Save.load_list_size= Save.load_list_size or 22

            if e.Player.husandro then
                Save.buttons[e.onlyChinese and '宠物对战' or PET_BATTLE_COMBAT_LOG ]={
                    ['BugSack']=true,
                    ['!BugGrabber']=true,
                    ['tdBattlePetScript']=true,
                    --['zAutoLoadPetTeam_Rematch']=true,
                    ['Rematch']=true,
                    [id]=true,
                }
                Save.buttons[e.onlyChinese and '副本' or INSTANCE ]={
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
                Save.fast={
                    ['TextureAtlasViewer']=78,
                    ['WoWeuCN_Tooltips']=96,
                    [id]=1,
                }
            end

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:Garr_Building-AddFollowerPlus:0:0|a'..(e.onlyChinese and '插件管理' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                Init()
            end
          panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)