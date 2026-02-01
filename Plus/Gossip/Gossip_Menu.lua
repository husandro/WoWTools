
local function Save()
    return WoWToolsSave['Plus_Gossip']
end

























local function Init_Menu(self, root)
    local sub, sub2, num, num2

--启用
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '启用' or ENABLE)..'|A:SpecDial_LastPip_BorderGlow:0:0|a',
    function()
        return Save().gossip
    end, function()
        Save().gossip= not Save().gossip and true or false
        WoWTools_GossipMixin:Init_Gossip_Data()
        self:set_Texture()--设置，图片
        self:tooltip_Show()
        WoWTools_GossipMixin:Init_StaticPopupDialogs()
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '暂时' or BOOSTED_CHAR_SPELL_TEMPLOCK)
    end)
--唯一对话  
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '唯一对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEM_UNIQUE, ENABLE_DIALOG),
    function()
        return  Save().unique
    end, function ()
        Save().unique= not Save().unique and true or false
        WoWTools_GossipMixin:UpdateGossip()--更新GossipFrame
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '当选项只有一个时，自动对话' or 'When there is only one option, automatic dialogue.', nil, nil,nil, true)
    end)


--自定义,闲话
    root:CreateDivider()
    num= CountTable(Save().gossipOption or {})

    sub=root:CreateButton(
        '|T0:0|t'
        ..(WoWTools_DataMixin.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG)),
    function()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)

--列表，自定义,闲话
    for gossipOptionID, text in pairs(Save().gossipOption) do
        sub2=sub:CreateCheckbox(
            text==true and gossipOptionID or text,
        function(data)
            return Save().gossipOption[data.gossipOptionID]
        end, function(data)
            Save().gossipOption[data.gossipOptionID]= not Save().gossipOption[data.gossipOptionID] and data.text or nil
            WoWTools_GossipMixin:UpdateGossip()--更新GossipFrame
        end, {gossipOptionID=gossipOptionID, text=text})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddDoubleLine('gossipOptionID', description.data.gossipOptionID)
        end)
    end

--全部清除
    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().gossipOption={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)



--对话替换
    --root:CreateDivider()
    num= CountTable(WoWToolsPlayerDate['GossipTextIcon'] or {})
    num2= CountTable(WoWTools_GossipMixin:Get_GossipData() or {})

    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE))
        ..WoWTools_DataMixin.Icon.mid,
        --..((num+num2)==0 and '|cff626262' or '')
        --..(num..'/'..num2),
    function()
        return not Save().not_Gossip_Text_Icon
    end, function()
        Save().not_Gossip_Text_Icon= not Save().not_Gossip_Text_Icon and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_GossipMixin:UpdateGossip()--更新GossipFrame
    end, {rightText=num..'/'..num2, rightColor= (num+num2==0) and DISABLED_FONT_COLOR or nil})
    WoWTools_MenuMixin:SetRightText(sub)

--对话替换, 打开自定义, Frame
    sub:CreateButton(
        '|A:mechagon-projects:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM),
    function ()
        WoWTools_GossipMixin:Init_Options_Frame()
        return MenuResponse.Open
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)

--默认
    num= CountTable(WoWTools_GossipMixin:Get_GossipData() or {})
    
    sub:CreateDivider()
    sub:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return not Save().notGossipPlayerData
    end, function()
        Save().notGossipPlayerData= not Save().notGossipPlayerData and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_GossipMixin:UpdateGossip()--更新GossipFrame
    end, {rightText=num})
    WoWTools_MenuMixin:SetRightText(sub)

--禁用NPC, 闲话,任务, 选项
    num= CountTable(Save().NPC or {})
    
    sub=root:CreateButton(
        '|T0:0|t'..(WoWTools_DataMixin.onlyChinese and '禁用NPC' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, 'NPC')),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end, {rightText=num})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '闲话/任务' or (GOSSIP_OPTIONS..'/'..QUESTS_LABEL))
    end)
    WoWTools_MenuMixin:SetRightText(sub)

--列表，禁用NPC, 闲话,任务, 选项
    for npcID, name in pairs(Save().NPC) do--npcID 是字符
        sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN(nil, {npcID=npcID, isName=true})
            or (name~=true and name)
            or npcID,
        function(data)
            return Save().NPC[data.npc]
        end, function(data)
            Save().NPC[data.npc]= not Save().NPC[data.npc] and data.name or nil
        end, {npc=npcID, name=name})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddDoubleLine('NPC ID', description.data.npc)
        end)
    end

--全部清除
    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().NPC={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)

--PlayerChoiceFrame
    num= CountTable(Save().choice or {})
    
    sub=root:CreateButton(
        '|T0:0|t'..(WoWTools_DataMixin.onlyChinese and '选择' or CHOOSE),--..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end, {rightText=num})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('PlayerChoiceFrame')
        tooltip:AddLine('Blizzard_PlayerChoice')
    end)
    WoWTools_MenuMixin:SetRightText(sub)

--列表，PlayerChoiceFrame
    for spellID, rarity in pairs(Save().choice) do
        sub2=sub:CreateCheckbox(
            WoWTools_SpellMixin:GetName(spellID)
            ..' '
            ..(WoWTools_ItemMixin.QualityText[rarity] or ''),
        function(data)
            return Save().choice[data.spellID]
        end, function(data)
            Save().choice[data.spellID]= not Save().choice[data.spellID] and data.rarity or nil
        end, {spellID=spellID, rarity=rarity})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

--全部清除
    sub:CreateDivider()
    WoWTools_MenuMixin:ClearAll(sub, function()
        Save().choice={}
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)


    root:CreateDivider()
    WoWTools_GossipMixin:Init_MoveListMenu(self, root)


--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GossipMixin.addName})




--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:settings()
    end)


--背景, 透明度
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().bgAlpha or 0.5
    end, function(value)--SetValue
        Save().bgAlpha= value
        self:settings()
    end, function()--RestFunc
        Save().bgAlpha= nil
        self:settings()
    end)--onlyRoot


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:settings()
        return MenuResponse.Refresh
    end)


--重置位置
    sub:CreateDivider()
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:ClearAllPoints()
        self:set_Point()
    end)
end


















function WoWTools_GossipMixin:Init_Menu_Gossip(frame)
    MenuUtil.CreateContextMenu(frame, function(_, root)
        Init_Menu(_G['WoWToolsGossipButton'], root)
    end)
end