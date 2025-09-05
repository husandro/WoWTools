local function Save()
    return  WoWToolsSave['Minimap_Plus']
end

local Button
local libDBIcon
local Objects={}

local function Set_Lib()
    if not libDBIcon then
        libDBIcon = LibStub("LibDBIcon-1.0", true)
    end
end



local function Get_Button(name)
    return Objects[name] or libDBIcon:GetMinimapButton(name)
end

local function Get_All_Objects()
    local objects={}
    for name, btn in pairs(libDBIcon.objects) do
        objects[name]= btn
    end
    for name, btn in pairs(Objects) do
        objects[name]= btn
    end
    return objects
end

















--锁定按钮
local function Lock_Button(btn, name)--lib:Lock(name)
    btn= btn or Get_Button(name)
    if not btn or btn.WoWToolsIsLocked then
        return
    end
    btn.WoWToolsIsLocked=true

--清除，lib 按钮
    Objects[name]= btn
    libDBIcon.objects[name]=nil

--启用 FrameStrata
    btn:SetFixedFrameStrata(false)
    btn:SetParent(Button.frame)

--清除，事件
    if btn:GetScript('OnDragStart') then
        btn:SetScript("OnDragStart", nil)
        btn:SetScript("OnDragStop", nil)
    end
end



--还原按钮
local function Unlock_Button(btn, name)
    btn= btn or Get_Button(name)
    if not btn or not btn.WoWToolsIsLocked then
        return
    end
    btn.WoWToolsIsLocked=nil
    local db= btn.db

--还原，数据
    btn:ClearAllPoints()
    btn:SetFrameStrata('MEDIUM')
    btn:SetFixedFrameStrata(true)
    btn:SetParent(Minimap)

--还原按钮
    libDBIcon.objects[name]= btn
    Objects[name]=nil

--设置 OnDragStart
    if not db or not db.lock then
        libDBIcon:Unlock(name)
    end

--更新位置
    btn:ClearAllPoints()
    libDBIcon:SetButtonToPosition(btn, db and db.minimapPos or nil)

--还原，显示/隐藏
    if not db or not db.hide then
        libDBIcon:Show(name)
    else
        libDBIcon:Hide(name)
    end
end


local function Set_User_Button(btn)
    if not btn then
        return
    elseif btn and btn.WoWToolsIsLocked then
        return true
    end
    if
        not btn.GetFrameStrata
        or WoWTools_FrameMixin:IsLocked(btn)
    then
        return
    end
    btn.WoWToolsIsLocked={
        parent= btn:GetParent(),
        strata= btn:GetFrameStrata(),
        hasFixed= btn:HasFixedFrameStrata(),
        point= {btn:GetPoint(1)},
        onDragStart= btn:GetScript('OnDragStart'),
        onDragStop= btn:GetScript('OnDragStop'),
        size={btn:GetSize()},
    }
    btn:SetParent(Button.frame)
    btn:SetFixedFrameStrata(false)
    btn:SetScript('OnDragStart', nil)
    btn:SetScript('OnDragStop', nil)
    btn:SetSize(31, 31)
    return true
end

local function Rest_Ueser_Button(btn)
    local data= (btn and not  WoWTools_FrameMixin:IsLocked(btn)) and btn.WoWToolsIsLocked

    if not data then
        return
    end

    btn:ClearAllPoints()
    btn:SetParent(data.parent)

    local s= data.strata
    if s then
        btn:SetFrameStrata(s)
    end
    if data.hasFixed then
        btn:SetFixedFrameStrata(true)
    end

    s= data.size

    if s and s[1] and s[2] then
        btn:SetSize(s[1], s[2])
    end

    local p= data.point
    if p and p[1] then
        btn:SetPoint(p[1], p[2], p[3], p[4], p[5])
    end

    btn:SetScript('OnDragStart', data.onDragStart)
    btn:SetScript('OnDragStop', data.onDragStop)
    btn.WoWToolsIsLocked=nil
end

















local function Init_Buttons()
    local isSortUp= Save().Icons.isSortUp
    local noAdd= Save().Icons.noAdd
    local hideAdd= Save().Icons.hideAdd
    local x= Save().Icons.pointX or 0
    local numLine= Save().Icons.numLine or 1

    local tab={}

    for name, btn in pairs(libDBIcon.objects) do
        if not noAdd[name] then
            Lock_Button(btn, name)
        end
    end



    for name, btn in pairs(Objects) do
        if noAdd[name] then
            Unlock_Button(btn, name)

        elseif hideAdd[name] then
            Lock_Button(btn, name)
            btn:SetShown(false)

        elseif btn:IsShown() then
            table.insert(tab, {
                btn=btn,
                name=name
            })
        end
    end

    for name, value in pairs(Save().Icons.userAdd) do
        local btn= value and _G[name]
        if Set_User_Button(btn) then
            table.insert(tab, {
                btn= btn,
                name= btn.GetName and btn:GetName() or name
            })
        end
    end

--排序
    table.sort(tab, function(a, b)
        if isSortUp then
            return a.name>b.name
        else
            return a.name<b.name
        end
    end)

--设置，位置
    local btn
    local num= #tab

    for index, data in pairs(tab) do
        btn= data.btn

        btn:ClearAllPoints()
        btn:SetPoint('BOTTOMLEFT', index==1 and Button or tab[index-1].btn, 'TOPLEFT', 0, x)
    end

    for i= numLine, num, numLine do
        tab[i].btn:ClearAllPoints()
        tab[i].btn:SetPoint('BOTTOMRIGHT', tab[i-numLine] and tab[i-numLine].btn or Button, 'BOTTOMLEFT', -x, 0)
    end

    Button.Background:SetPoint('TOP',
        tab[numLine-1] and tab[numLine-1].btn
        or (tab[num] and tab[num].btn)
        or Button
    )
    Button.Background:SetPoint('LEFT',
        (tab[num] and tab[num].btn)
        or Button
    )
end























--设置，按钮，材质
local function Set_Button_Texture(btn, name)
    btn= btn or Get_Button(name)

    if not btn then
        return
    end

    local bgAlpha, borderAlpha
    local icon= btn.icon

    if not Save().Icons.disabled then
        if libDBIcon.objects[name] then
            borderAlpha= Save().Icons.borderAlpha2--Minimap上
            bgAlpha= Save().Icons.bgAlpha2
        else
            borderAlpha= Save().Icons.borderAlpha--收集图标
            bgAlpha= Save().Icons.bgAlpha
        end
    elseif not Save().disabled then
        borderAlpha= Save().Icons.borderAlpha2
        bgAlpha= Save().Icons.bgAlpha2
    end
    bgAlpha, borderAlpha= bgAlpha or 0.5, borderAlpha or 0

    for _, region in pairs ({btn:GetRegions()}) do
        if region:GetObjectType()=='Texture' and region~=icon then
            local text= region:GetTexture()
            if text==136430 then--OVERLAY 
                region:SetAlpha(borderAlpha)
                WoWTools_TextureMixin:SetAlphaColor(region, nil, nil, borderAlpha or 0)

            elseif text==136467 then--BACKGROUND
                region:SetAlpha(bgAlpha)
            end
        end
    end
end


local function Init_Lib_Register()
    WoWTools_DataMixin:Hook(libDBIcon, 'Register', function(_, name)
        if Button and not Save().Icons.disabled then
            Init_Buttons()
        end

        Set_Button_Texture(nil, name)
    end)
    Init_Register=function()end
end

local function Init_AllButton_Texture()
    Set_Lib()

    Init_Lib_Register()

    for _, name in pairs(libDBIcon:GetButtonList()) do
        Set_Button_Texture(nil, name)
    end

    for name, btn in pairs(Objects) do
        Set_Button_Texture(btn, name)
    end

    if Button then
        Set_Button_Texture(Button, nil)
    end
end
































--过滤，列表
local function Init_noAdd_Menu(self, root)
    local sub

--过滤
    sub= root:CreateButton(WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL, function() return MenuResponse.Open end)

--勾选所有    
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        for name, btn in pairs(Get_All_Objects()) do
            Save().Icons.noAdd[name]=true
            Save().Icons.hideAdd[name]=nil
            Unlock_Button(btn, name)
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)
--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        for name, btn in pairs(Get_All_Objects()) do
            Save().Icons.noAdd[name]=nil
            Unlock_Button(btn, name)
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)
    sub:CreateSpacer()


--过滤 Border 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.borderAlpha2 or 0
        end, setValue=function(value)
            Save().Icons.borderAlpha2=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '外框透明度' or 'Border alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--过滤 Bg Alpha
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.bgAlpha2 or 0.5
        end, setValue=function(value)
            Save().Icons.bgAlpha2=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '背景透明度' or 'Background alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()


--过滤列表
    root:CreateDivider()
    local index=0
    for name, btn in pairs(Get_All_Objects()) do
        index= index+1
        root:CreateCheckbox(
            index..') '
            ..'|T'..(btn.dataObject.icon or 0)..':0|t'
            ..(Save().Icons.hideAdd[name] and '|cff626262' or '')
            ..name,
        function(data)
            return Save().Icons.noAdd[data.name]
        end, function(data)
            Save().Icons.noAdd[data.name]= not Save().Icons.noAdd[data.name] and true or nil
            Save().Icons.hideAdd[data.name]=nil
            Unlock_Button(btn, data.name)
            self:settings()
        end, {name=name})
    end
    WoWTools_MenuMixin:SetScrollMode(root)

end























--隐藏，列表
local function Init_hideAdd_Menu(self, root)
    local sub
    local index= 0

    sub= root:CreateButton(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE, function() return MenuResponse.Open end)

--勾选所有    
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        for name, btn in pairs(Get_All_Objects()) do
            Save().Icons.noAdd[name]=nil
            Save().Icons.hideAdd[name]=true
            Unlock_Button(btn, name)
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)

--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        for name, btn in pairs(Get_All_Objects()) do
            Save().Icons.hideAdd[name]=nil
            Unlock_Button(btn, name)
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)

--隐藏列表
    root:CreateDivider()
    for name, btn in pairs(Get_All_Objects()) do
        index= index+1
        root:CreateCheckbox(
            index..') '
            ..'|T'..(btn.dataObject.icon or 0)..':0|t'
            ..(Save().Icons.noAdd[name] and '|cnRED_FONT_COLOR:' or '')
            ..name,
        function(data)
            return Save().Icons.hideAdd[data.name]
        end, function(data)
            Save().Icons.hideAdd[data.name]= not Save().Icons.hideAdd[data.name] and true or nil
            Save().Icons.noAdd[data.name]=nil
            Unlock_Button(btn, data.name)
            self:settings()
        end, {name=name})
    end

    WoWTools_MenuMixin:SetScrollMode(root)
end




















--自定义，添加，列表
local function Init_UserAdd_Menu(_, root)
    local sub, sub2
    local num= 0

    sub= root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_DataMixin.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'))
        ..'\n_G['..(WoWTools_DataMixin.onlyChinese and '名称' or NAME)..']'
        ..'\n\n'..(WoWTools_DataMixin.onlyChinese and '名称' or NAME)..': ',
        nil,
        {

            SetValue= function(s)
                local edit= s.editBox or s:GetEditBox()
                local t= edit:GetText() or ''
                if t:gsub(' ', '')~='' then
                    Save().Icons.userAdd[t]=true
                    Init_Buttons()
                end
            end,
            OnAlt=function(s)
                local edit= s.editBox or s:GetEditBox()
                local t= edit:GetText()
                Save().Icons.userAdd[t]= nil
                Rest_Ueser_Button(_G[t])
                Init_Buttons()
            end,
            EditBoxOnTextChanged=function(s, _, text)
                local p= s:GetParent()
                local b1= p.button1 or p:GetButton1()
                local b3= p.button3 or p:GetButton3()
                if _G[text] and _G[text].GetFrameStrata then
                    b1:SetText(
                        '|cnGREEN_FONT_COLOR:'
                        ..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                    )
                else
                    b1:SetText(
                        '|cff626262'
                        ..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                    )
                end
                b3:SetEnabled(text~='' and Save().Icons.userAdd[text] and true or false)
            end,
        })
        return MenuResponse.Open
    end)

--fstack
    sub2=sub:CreateButton('|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK', function ()
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
            C_AddOns.LoadAddOn("Blizzard_DebugTools")
        end
        FrameStackTooltip_ToggleDefaults()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Alt|r '..(WoWTools_DataMixin.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r '..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Shift|r '..(WoWTools_DataMixin.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(WoWTools_DataMixin.onlyChinese and '类型' or TYPE))
    end)

    sub:CreateDivider()
--勾选所有    
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        for name in pairs(Save().Icons.userAdd) do
            Save().Icons.userAdd[name]=true
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)
--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        for name in pairs(Save().Icons.userAdd) do
            Rest_Ueser_Button(_G[name])
            Save().Icons.userAdd[name]=false
        end
        Init_Buttons()
        return MenuResponse.Refresh
    end)

--全部清除
    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
    function()
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        nil,
        {SetValue=function()
            for name in pairs(Save().Icons.userAdd) do
                Rest_Ueser_Button(_G[name])
                Save().Icons.userAdd[name]=nil
            end
            Init_Buttons()
        end})
        return MenuResponse.Open
    end)


--列表
    root:CreateDivider()
    num=1
    for name, value in pairs(Save().Icons.userAdd) do
        sub=root:CreateCheckbox(
            num..')'
            ..(_G[name] and _G[name].GetFrameStrata and '' or '|cff626262')
            ..name,
        function(data)
            return Save().Icons.userAdd[data]
        end, function(data)
            Save().Icons.userAdd[data]= not Save().Icons.userAdd[data] and true or false
            if Save().Icons.userAdd[data]==false then
                Rest_Ueser_Button(_G[data])
            end
            Init_Buttons()
        end, name)
        sub:SetTooltip(function(tooltip, desc)
            if not _G[desc.data] or not _G[desc.data].GetFrameStrata then
                tooltip:AddLine(desc.data)
                tooltip:AddLine(
                    '|cff626262'
                    ..(WoWTools_DataMixin.onlyChinese and '无效按钮' or CHAR_NAME_FAILURE)
                )
            end
        end)

        sub:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        function(data)
            return Save().Icons.userAdd[data.name]~=nil
        end, function(data)
            if Save().Icons.userAdd[data.name]==nil then
                Save().Icons.userAdd[data.name]= data.value
            else
                Save().Icons.userAdd[data.name]=nil
                Rest_Ueser_Button(_G[data.name])
            end
            Init_Buttons()
            return MenuResponse.Refresh
        end, {name=name, value=value})
        num= num+1
    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end





















local function Init_Menu(self, root)
    local sub, sub2, num

--显示/隐藏
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return self.frame:IsShown()
    end, function()
        Save().Icons.hideFrame= not Save().Icons.hideFrame and true or nil
        self:set_frame()
    end)
    sub:SetEnabled(not WoWTools_FrameMixin:IsLocked(self))



    --sub:CreateDivider()
--显示
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '显示' or SHOW)
    sub:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(WoWTools_DataMixin.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save().isEnterShow
    end, function()
        Save().isEnterShow = not Save().isEnterShow and true or nil
    end)

--隐藏
    sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
--进入战斗，隐藏
    sub:CreateCheckbox(
        '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '进入战斗' or ENTERING_COMBAT),
    function()
        return Save().Icons.hideInCombat
    end, function()
        Save().Icons.hideInCombat = not Save().Icons.hideInCombat and true or nil
        self:set_event()
    end)

--移动时，隐藏
    sub:CreateCheckbox(
        '|A:transmog-nav-slot-feet:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE),
    function()
        return Save().Icons.hideInMove
    end, function()
        Save().Icons.hideInMove = not Save().Icons.hideInMove and true or nil
        self:set_event()
    end)




--Border 透明度

    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.borderAlpha or 0
        end, setValue=function(value)
            Save().Icons.borderAlpha=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '外框透明度' or 'Border alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--Bg Alpha
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.bgAlpha or 0.5
        end, setValue=function(value)
            Save().Icons.bgAlpha=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '背景透明度' or 'Background alpha',
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%0.2f',
    })
    sub:CreateSpacer()

--按钮，间隔
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.pointX or 0
        end, setValue=function(value)
            Save().Icons.pointX=value
            self:settings()
        end,
        name='X',
        minValue=-15,
        maxValue=15,
        step=1,
    })
    sub:CreateSpacer()

--数量
    sub:CreateSpacer()
    num=0
    for _ in pairs(Get_All_Objects()) do
        num=num+1
    end
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Icons.numLine or 1
        end, setValue=function(value)
            Save().Icons.numLine=value
            self:settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
        minValue=1,
        maxValue=num+1,
        step=1,
    })
    sub:CreateSpacer()

--升序
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
    function()
        return Save().Icons.isSortUp
    end, function()
        Save().Icons.isSortUp= not Save().Icons.isSortUp and true or nil
        self:settings()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '按字母排序' or OPTION_RAID_SORT_BY_ALPHABETICAL)
    end)



--刷新
    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '刷新' or REFRESH,
    function()
        Init_Buttons()
        print(WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '刷新' or REFRESH, WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)
        return MenuResponse.Open
    end)


    root:CreateDivider()
--过滤
    num=0
    for name in pairs(Save().Icons.noAdd) do
        if Get_Button(name) then
            num=num+1
        end
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '过滤' or AUCTION_HOUSE_SEARCH_BAR_FILTERS_LABEL)..' |cnRED_FONT_COLOR:#|r'..num,
    function()
        return MenuResponse.Open
    end)
    Init_noAdd_Menu(self, sub)


--隐藏
    num=0
    for name in pairs(Save().Icons.hideAdd) do
        if Get_Button(name) then
           num=num+1
        end
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)..' |cff626262#|r'..num,
    function()
        return MenuResponse.Open
    end)
    Init_hideAdd_Menu(self, sub)


--自定义，添加，列表
    num= 0
    for name, value in pairs(Save().Icons.userAdd) do
        if value and _G[name] and _G[name].GetFrameStrata then
            num= num+1
        end
    end
    sub= root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)..' |cff00ccff#|r'..num,
    function()
        return MenuResponse.Open
    end)
    Init_UserAdd_Menu(self, sub)




--[[设置，按钮
root:CreateDivider()
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '按钮' or 'Button',
    function()
        return MenuResponse.Open
    end)

    sub=root:CreateButton(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
]]







    root:CreateDivider()
--打开，选项
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_MinimapMixin.addName,
        name2=WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL))
    })


--显示背景
    sub2= WoWTools_MenuMixin:BgAplha(sub,
    function()
        return Save().Icons.alphaBG or 0.5
    end, function(value)
        Save().Icons.alphaBG=value
        self:settings()
    end)



--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().Icons.scale or 1
    end, function(value)
        Save().Icons.scale= value
        self:settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().Icons.strata= data
        self:settings()
    end)

    sub:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().Icons.point, function()
        Save().Icons.point=nil
        self:set_point()
        return MenuResponse.Open
    end)

--/reload
    WoWTools_MenuMixin:Reload(sub, false)
end






































local function Init()
    if Save().Icons.disabled then
        return
    end
    Set_Lib()


    Button= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsMinimapCollectionIcons',
        size=31,
        isType2=true,
        notTexture=true,
        notBorder=true,
    })
    Button:SetHighlightTexture(136477)--"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"

    Button.border = Button:CreateTexture(nil, "OVERLAY")
    Button.border:SetSize(50, 50)
    Button.border:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
    Button.border:SetPoint("TOPLEFT", Button, "TOPLEFT")

    Button.bg = Button:CreateTexture(nil, "BACKGROUND")
    Button.bg:SetSize(24, 24)
    Button.bg:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
    Button.bg:SetPoint("CENTER", Button, "CENTER")

    Button.icon=Button:CreateTexture(nil, 'ARTWORK')
    Button.icon:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
    Button.icon:SetPoint('CENTER')
    Button.icon:SetSize(18, 18)

    Button.frame= CreateFrame('Frame', nil, Button)
    Button.frame:SetAllPoints()

--显示背景 Background
    WoWTools_TextureMixin:CreateBG(Button)--, {frame=Button.frame})
    Button.Background:SetPoint('BOTTOMRIGHT', Button)


    Button:SetMovable(true)
    Button:SetClampedToScreen(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().Icons.point= {self:GetPoint(1)}
            Save().Icons.point[2]=nil
        end
    end)

    Button:SetScript("OnMouseUp", ResetCursor)--停止移动
    Button:SetScript("OnMouseDown", function(self, d)--设置, 光标
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='RightButton' then
            WoWTools_MinimapMixin:Open_Menu(self)
            self:set_tooltip()

        elseif d=='LeftButton' then
            MenuUtil.CreateContextMenu(self, function(...) Init_Menu(...) end)
            self:set_tooltip()
        end
    end)

    Button:EnableMouseWheel(true)
    Button:SetScript('OnMouseWheel', function(self, d)
        if IsAltKeyDown() then
            if not InCombatLockdown() then
                if d==1 then
                    WoWTools_PanelMixin:Open(nil, '|A:talents-button-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置数据' or RESET_ALL_BUTTON_TEXT))
                else
                    WoWTools_PanelMixin:Open(nil, WoWTools_MinimapMixin.addName)
                end
            end
        else
            if not WoWTools_FrameMixin:IsLocked(self) then
                Save().Icons.hideFrame= d==-1
                self:set_frame()
            end
        end
    end)

    Button:SetScript("OnLeave", function()
        ResetCursor()
        GameTooltip:Hide()
    end)
    Button:SetScript('OnEnter', function(self)
        if Save().Icons.isEnterShow then
            Save().Icons.hideFrame=false
            self:set_frame()
        end
        self:set_tooltip()
    end)

    Button:SetScript('OnEvent', function(self)
        Save().Icons.hideFrame=true
        self:set_frame()
    end)

    function Button:set_frame()
        if not WoWTools_FrameMixin:IsLocked(self) then
            local show= not Save().Icons.hideFrame
            self.frame:SetShown(show)
            self.Background:SetShown(show)
            self.Background:SetAlpha(Save().Icons.alphaBG or 0.5)
        end
    end

    function Button:set_event()
        self:UnregisterAllEvents()
--战斗
        if Save().Icons.hideInCombat then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
--移动
        if Save().Icons.hideInMove then
            self:RegisterEvent("PLAYER_STARTED_MOVING")
        end
    end

    function Button:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddLine(
            '|cffffd100'..WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '收集图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WEEKLY_REWARDS_GET_CONCESSION, EMBLEM_SYMBOL))
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL,
            WoWTools_DataMixin.Icon.left..(InCombatLockdown() and '' or WoWTools_DataMixin.Icon.right),
            1,1,1,1,1,1
        )
        GameTooltip:AddDoubleLine(--显示/隐藏
            (WoWTools_FrameMixin:IsLocked(self) and '|cff626262' or '')
            ..WoWTools_TextMixin:GetShowHide(nil, true),
            WoWTools_DataMixin.Icon.mid,
            1,1,1,1,1,1
        )

        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE,
            'Alt+'..WoWTools_DataMixin.Icon.right,
            1,1,1,1,1,1
        )
        GameTooltip:AddDoubleLine(
            (InCombatLockdown() and '|cff626262' or '')
            ..(WoWTools_DataMixin.onlyChinese and '打开选项界面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS), 'UI')),
            'Alt+'..WoWTools_DataMixin.Icon.mid,
            1,1,1,1,1,1
        )
        GameTooltip:Show()
    end



    function Button:settings()
        self.Background:SetAlpha(Save().Icons.alphaBG or 0.5)
        self:SetFrameStrata(Save().Icons.strata or 'HIGH')
        self:SetScale(Save().Icons.scale or 1)
        self:set_event()
        self:set_frame()
        self:SetShown(true)
        Init_Buttons()
        Init_AllButton_Texture()
    end

    function Button:set_point()
        self:ClearAllPoints()
        local p= Save().Icons.point
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        elseif CharacterReagentBag0Slot:IsVisible() then
            self:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT', -2, 0)
        else
            self:SetPoint('BOTTOMLEFT', Minimap, 8, 15)
        end
    end

    function Button:rest()
        self:UnregisterAllEvents()
        for name, btn in pairs(Objects) do
            Unlock_Button(btn, name)
        end
        for name in pairs(Save().Icons.userAdd) do
            Rest_Ueser_Button(_G[name])
        end
        self:SetShown(false)
    end






    WoWTools_DataMixin:Hook(libDBIcon, 'IconCallback', function(_, _, name, key, value)
        local btn= Objects[name]
        if not btn or libDBIcon:GetMinimapButton(name) then
            return
        end

        if key == "icon" then
			btn.icon:SetTexture(value)
            if AddonCompartmentFrame and btn.db and btn.db.showInCompartment then
				local addonList = AddonCompartmentFrame.registeredAddons
				for i =1, #addonList do
					if addonList[i].text == name then
						addonList[i].icon = value
						return
					end
				end
			end
		elseif key == "iconCoords" then
			btn.icon:UpdateCoord()
		elseif key == "iconR" then
			local _, g, b = btn.icon:GetVertexColor()
			btn.icon:SetVertexColor(value, g, b)
		elseif key == "iconG" then
			local r, _, b = btn.icon:GetVertexColor()
			btn.icon:SetVertexColor(r, value, b)
		elseif key == "iconB" then
			local r, g = btn.icon:GetVertexColor()
			btn.icon:SetVertexColor(r, g, value)
		end
    end)





    Button:set_point()
    Button:settings()


    Init=function()
        if Save().Icons.disabled then
            Button:rest()
            WoWTools_MinimapMixin:Init_Icon()
        else
            Button:set_point()
            Button:settings()
        end
    end
end
















--小地图
function WoWTools_TextureMixin.Events:Blizzard_Minimap()
    self:SetAlphaColor(MinimapCompassTexture)
    self:SetButton(GameTimeFrame)

    if MinimapCluster and MinimapCluster.TrackingFrame then
       self:SetButton(MinimapCluster.TrackingFrame.Button, {alpha= 0.3, all=false})
       self:SetFrame(MinimapCluster.BorderTop)
    end

    Init_AllButton_Texture()

--插件，菜单
    self:HideFrame(AddonCompartmentFrame, {alpha= 0.3})
    self:SetAlphaColor(AddonCompartmentFrame.Text, nil, nil, 0.3)
end



function WoWTools_MinimapMixin:Init_Collection_Icon()
    Init()
end

function WoWTools_MinimapMixin:Init_SetMinamp_Texture()
    Init_AllButton_Texture()
end