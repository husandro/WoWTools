
local e= select(2, ...)
local function Save()
    return WoWTools_AddOnsMixin.Save
end
local Buttons={}--方案



local function Is_Load(nameORindex)
    return C_AddOns.IsAddOnLoaded(nameORindex) or select(2, C_AddOns.IsAddOnLoadable(nameORindex))=='DEMAND_LOADED'
end






local function Init_Button_Menu(self, root)
    local some, sel, tab= select(2, WoWTools_AddOnsMixin:Get_AddListInfo())
    local sub

--替换
    sub=root:CreateButton(
        '|A:ShipMission_ShipFollower-Lock-Rare:0:0|a'
        ..(e.onlyChinese and '替换' or REPLACE)
        ..' '..(some+sel),
    function(data)
        Save().buttons[data.name]= data.tab--select(4, WoWTools_AddOnsMixin:Get_AddListInfo())
        e.call(AddonList_Update)
    end, {name=self.name, tab=tab})
    sub:SetTooltip(function(tooltip, description)
        WoWTools_AddOnsMixin:Show_Select_Tooltip(tooltip, description.data.tab)
    end)

--修改名称/图标
    root:CreateButton(
        '|A:QuestLegendaryTurnin:0:0|a'
        ..(e.onlyChinese and '修改名称/图标' or EQUIPMENT_SET_EDIT),
    function(data)
        local name= data.name:match('|t(.+)') or data.name
        local texture= data.name:match('|T(%d+):0|t')
        if texture then
            texture= tonumber(texture)
        end
        WoWTools_TextureMixin:Edit_Text_Icon(self, {
            text= name,
            texture= texture,
            SetValue=function(newIcon, newText)
                local new=Save().buttons[data.name]
                if new then
                    for n in pairs(Save().buttons) do
                        if data.name==n then
                            Save().buttons[n]= nil
                            Save().buttons['|T'..(newIcon or 0)..':0|t'..newText]= new
                            e.call(AddonList_Update)
                            return
                        end
                    end
                end
            end
        })
    end, {name=self.name})

--删除
    root:CreateButton(
        '|A:XMarksTheSpot:0:0|a'..(e.onlyChinese and '删除' or DELETE),
    function(data)
        Save().buttons[data.name]=nil
        e.call(AddonList_Update)
    end, {name=self.name})

    root:CreateDivider()
    root:CreateTitle(self.name)
end





















local function Create_Button(indexAdd)
    local btn=WoWTools_ButtonMixin:Cbtn(AddonList, {icon='hide', size=22})
    btn:SetHighlightAtlas('auctionhouse-nav-button-secondary-select')
    btn.Text= WoWTools_LabelMixin:CreateLabel(btn, {size=14})
    btn.Text:SetPoint('LEFT', 2, 0)

    btn.loadTexture= btn:CreateTexture()
    btn.loadTexture:SetPoint('LEFT', btn, 'RIGHT')
    btn.loadTexture:SetSize(8,8)
    btn.loadTexture:SetAtlas('AnimaChannel-Bar-Necrolord-Gem')

    function btn:set_settings()
        local load, all= 0, 0
        for name in pairs(Save().buttons[self.name] or {}) do
            if C_AddOns.DoesAddOnExist(name) then
                if Is_Load(name) then
                    load= load +1
                end
                all= all+1
            else
                Save().buttons[self.name][name]=nil
            end
        end
        self.Text:SetFormattedText(
            '%s %s%d|r/%s%d|r',
            self.name,
            load==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:',
            load,
            load==all and '|cnGREEN_FONT_COLOR:' or '',
            all
        )
        self.isLoadAll= self.numAllLoad==all and load==all
        self:SetWidth(btn.Text:GetWidth()+4)
        self:SetHeight(btn.Text:GetHeight()+4)
        self:SetButtonState(self.isLoadAll and 'PUSHED' or 'NORMAL')
        self.loadTexture:SetShown(Save().load_Button_Name==self.name)
    end

    btn:SetScript('OnClick',function(self, d)
        if d=='LeftButton' then--加载
            local tab= Save().buttons[self.name]
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
            WoWTools_Mixin:Reload()
            Save().load_Button_Name= self.name

        elseif d=='RightButton' then--移除
            MenuUtil.CreateContextMenu(self, Init_Button_Menu)
        end
    end)


    btn:SetScript('OnEnter', function(self)
        if not Save().buttons[self.name] then return end
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(format('|cffffd100%s|r', self.name), addName)
        e.tips:AddLine(' ')
        local index=1
        for name, value in pairs(Save().buttons[self.name]) do
            local iconTexture = C_AddOns.GetAddOnMetadata(name, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(name, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
            local isLoaded= C_AddOns.IsAddOnLoaded(name)
            local vType= type(value)
            local text= vType=='string' and WoWTools_UnitMixin:GetPlayerInfo({guid=value, reName=true, reRealm=true})
            local reason= select(2, C_AddOns.IsAddOnLoadable(name))
            local col= reason=='DEMAND_LOADED' and '|cffff00ff'
            if not text and not isLoaded and reason then
                text= (col or '|cff9e9e9e')..e.cn(_G['ADDON_'..reason] or reason)..' ('..index
            end
            local title= C_AddOns.GetAddOnInfo(name) or name
            local memo= Get_Memory_Value(name, false)--内存
            e.tips:AddDoubleLine(
                format('%s|cffffd100%d)|r%s%s%s|r |cffffffff%s|r',
                    index<10 and ' ' or '',
                    index,
                    icon,
                    isLoaded and '|cnGREEN_FONT_COLOR:' or col or '|cff9e9e9e',
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
        if select(2, C_AddOns.IsAddOnLoadable(i))=='DEMAND_LOADED' then--需要时加载
            need= need+1
        elseif C_AddOns.IsAddOnLoaded(i) then--已加载
            load= load+1
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
    for name in pairs(Save().buttons) do
        local btn= Buttons[index] or  Create_Button(index)
        btn.name= name
        btn.numAllLoad= load+ need
        btn:set_settings()
        btn:SetShown(true)
        index= index+1
    end


    NewButton.Text:SetFormattedText('%d%s', sel, some>0 and format('%s%d', e.Icon.player, some) or '')
    NewButton.Text3:SetFormattedText('|cnGREEN_FONT_COLOR:%d|r%s', load, need>0 and format('|cffff00ff+%d|r', need) or '')--总已加载，数量

    for i= index, #Buttons do
        local btn= Buttons[i]
        if btn then
            btn:SetShown(false)
            btn.name= nil
            btn.numAllLoad= nil
        end
    end
end
