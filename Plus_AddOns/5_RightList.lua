
local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end

local Buttons={}--方案
local RightFrame


local function Is_Load(nameORindex)
    return C_AddOns.IsAddOnLoaded(nameORindex) or select(2, C_AddOns.IsAddOnLoadable(nameORindex))=='DEMAND_LOADED'
end





local function Set_OnEnter_Tooltip(self, tooltip)
    tooltip:AddLine(self.name)
    WoWTools_AddOnsMixin:Show_Select_Tooltip(
        tooltip,
        Save().buttons[self.name] or {}
    )
end













local function Init_Button_Menu(self, root)
    if not self:IsVisible() then
        return
    end

    local sub

    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '加载插件' or LOAD_ADDON),
    function(data)
        return Save().load_Button_Name==data.name
    end, function()
        do
            local tab= Save().buttons[self.name]
            for i=1, C_AddOns.GetNumAddOns() do
                local name= C_AddOns.GetAddOnInfo(i)
                local value=tab[name]
                local vType= type(value)
                if vType=='boolean' or vType=='number' or value==WoWTools_DataMixin.Player.GUID then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
        end
        Save().load_Button_Name= self.name
        WoWTools_Mixin:Reload()
    end, {name=self.name})
    sub:SetTooltip(function(tooltip)
        Set_OnEnter_Tooltip(self, tooltip)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI, '/reload')
    end)

--替换
    root:CreateDivider()
    local some, sel, tab= select(2, WoWTools_AddOnsMixin:Get_AddListInfo())
    sub=root:CreateButton(
        '|A:ShipMission_ShipFollower-Lock-Rare:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '替换' or REPLACE)
        ..' '..(some+sel),
    function(data)

        StaticPopup_Show('WoWTools_OK',
            '|A:ShipMission_ShipFollower-Lock-Rare:0:0|a'..(WoWTools_DataMixin.onlyChinese and '替换' or REPLACE)
            ..'|n'..data.name,
            nil,
            {SetValue=function()
                Save().buttons[data.name]= select(4, WoWTools_AddOnsMixin:Get_AddListInfo())
                WoWTools_Mixin:Call(AddonList_Update)
            end}
        )

       
    end, {name=self.name})
    sub:SetTooltip(function(tooltip, description)
        WoWTools_AddOnsMixin:Show_Select_Tooltip(tooltip, description.data.tab)
    end)

--修改名称/图标
    root:CreateButton(
        '|A:QuestLegendaryTurnin:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '修改名称/图标' or EQUIPMENT_SET_EDIT),
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
                            WoWTools_Mixin:Call(AddonList_Update)
                            return
                        end
                    end
                end
            end
        })
    end, {name=self.name})

--删除
    root:CreateButton(
        '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE),
    function(data)
        StaticPopup_Show('WoWTools_OK',
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)
            ..'|n'..data.name,
            nil,
            {SetValue=function()
                Save().buttons[self.name]=nil
                WoWTools_Mixin:Call(AddonList_Update)
            end}
        )
    end, {name=self.name})

--缩放
    root:CreateDivider()
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().rightListScale or 1
    end, function(value)
        Save().rightListScale= value
        RightFrame:settings()
    end)


    root:CreateTitle(self.name)
end





















local function Create_Button(indexAdd)
    local btn= WoWTools_ButtonMixin:Menu(RightFrame, {icon='hide'})
    btn:SetHighlightAtlas('auctionhouse-nav-button-secondary-select')
    btn.Text= WoWTools_LabelMixin:Create(btn, {size=14})
    btn.Text:SetPoint('LEFT', 2, 1)

    btn.loadTexture= btn:CreateTexture()
    btn.loadTexture:SetPoint('LEFT', btn, 'RIGHT')
    btn.loadTexture:SetSize(12,12)
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
        self:SetHeight(btn.Text:GetHeight()+6)
        self:SetButtonState(self.isLoadAll and 'PUSHED' or 'NORMAL')
        self.loadTexture:SetShown(Save().load_Button_Name==self.name)
    end

    btn:SetupMenu(Init_Button_Menu)

    btn:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        Set_OnEnter_Tooltip(self, GameTooltip)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetScript('OnLeave', function(self)
        self:set_settings()
        GameTooltip:Hide()
    end)

    if indexAdd==1 then
        --btn:SetPoint('TOPLEFT', AddonList, 'TOPRIGHT', 2, -12)
        btn:SetPoint('TOPLEFT', RightFrame)
    else
        btn:SetPoint('TOPLEFT', Buttons[indexAdd-1], 'BOTTOMLEFT')
    end
    Buttons[indexAdd]= btn

    return btn
end







local function Set_Right_Buttons()
    if not RightFrame:IsShown() then
        return
    end
    
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

    if _G['WoWToolsAddonsNewButton'] then
        _G['WoWToolsAddonsNewButton'].Text:SetFormattedText('%d%s', sel, some>0 and format('%s%d', WoWTools_DataMixin.Icon.Player, some) or '')
        _G['WoWToolsAddonsNewButton'].Text3:SetFormattedText('|cnGREEN_FONT_COLOR:%d|r%s', load, need>0 and format('|cffff00ff+%d|r', need) or '')--总已加载，数量
    end

    for i= index, #Buttons do
        local btn= Buttons[i]
        if btn then
            btn:SetShown(false)
            btn.name= nil
            btn.numAllLoad= nil
        end
    end
end




local function Init()
    RightFrame= CreateFrame("Frame", 'WoWToolsAddOnsRightFrame', AddonList)
    RightFrame:SetSize(1,1)
    RightFrame:SetPoint('TOPLEFT', AddonList, 'TOPRIGHT', 2, 0)
    function RightFrame:settings()
        self:SetScale(Save().rightListScale or 1)
        self:SetShown(not Save().hideRightList)
        if _G['WoWToolsAddonsNewButton'] then
            _G['WoWToolsAddonsNewButton']:SetShown(not Save().hideRightList)
        end
    end
    RightFrame:settings()
    Set_Right_Buttons()
end















function WoWTools_AddOnsMixin:Init_Right_Buttons()
    Init()
end

--方案，按钮
function WoWTools_AddOnsMixin:Set_Right_Buttons()
    Set_Right_Buttons()
end