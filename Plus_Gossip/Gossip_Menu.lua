
local function Save()
    return WoWToolsSave['Plus_Gossip']
end










local function Movie_SubMenu(root, movieID, dateTime)
--移除
    if dateTime  then

        root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
        function(data)
            return Save().movie[data.movieID]
        end, function(data)
            Save().movie[data.movieID]= not Save().movie[data.movieID] and data.dateTime or nil
            return MenuResponse.Close
        end, {movieID=movieID, dateTime=dateTime})
        root:CreateDivider()
    end

--下载
    if not IsMovieLocal(movieID) then
        local sub=root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '下载' or 'Download',
        function(data)
            PreloadMovie(data.movieID)
        end, {movieID=movieID})

        --进度        
        sub:SetTooltip(function(tooltip, description)
            local inProgress, downloaded, total = GetMovieDownloadProgress(description.data.movieID)
            if inProgress and downloaded and total and total>0 then
                tooltip:AddDoubleLine(
                    WoWTools_DataMixin.onlyChinese and '进度' or PVP_PROGRESS_REWARDS_HEADER,
                    format('|n%i%%', downloaded/total*100)
                )
            end
        end)
    end
end
















local function Init_Menu(self, root)
    local sub, sub2, num, num2

--启用
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '启用' or ENABLE)..'|A:SpecDial_LastPip_BorderGlow:0:0|a',
    function()
        return Save().gossip
    end, function()
        Save().gossip= not Save().gossip and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        self:set_Texture()--设置，图片
        self:tooltip_Show()
        WoWTools_GossipMixin:Init_Gossip()
        return MenuResponse.Close
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '暂时' or BOOSTED_CHAR_SPELL_TEMPLOCK)
    end)

--唯一对话    
    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '唯一对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEM_UNIQUE, ENABLE_DIALOG),
    function()
        return  Save().unique
    end, function ()
        Save().unique= not Save().unique and true or nil
        WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
    end)

--自定义,闲话
    num=0
    for _ in pairs(Save().gossipOption) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '
        ..(WoWTools_DataMixin.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG))
        ..(num==0 and ' |cff9e9e9e' or ' ')
        ..num,
    function()
        return MenuResponse.Open
    end)

--列表，自定义,闲话
    for gossipOptionID, text in pairs(Save().gossipOption) do
        sub2=sub:CreateCheckbox(
            text==true and gossipOptionID or text,
        function(data)
            return Save().gossipOption[data.gossipOptionID]
        end, function(data)
            Save().gossipOption[data.gossipOptionID]= not Save().gossipOption[data.gossipOptionID] and data.text or nil
            WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        end, {gossipOptionID=gossipOptionID, text=text})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.gossipOptionID)
            tooltip:AddLine('gossipOptionID')
        end)
    end
    if num>1 then
        sub:CreateDivider()
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().gossipOption={}
        end)

        WoWTools_MenuMixin:SetScrollMode(sub)
    end



--对话替换
    root:CreateDivider()
    num, num2= 0, 0
    for _ in pairs(Save().Gossip_Text_Icon_Player) do
        num=num+1
    end
    for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
        num2=num2+1
    end
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE))
        ..WoWTools_DataMixin.Icon.mid
        ..((num+num2)==0 and '|cff9e9e9e' or '')
        ..(num..'/'..num2),
    function()
        return not Save().not_Gossip_Text_Icon
    end, function()
        Save().not_Gossip_Text_Icon= not Save().not_Gossip_Text_Icon and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        return MenuResponse.Close
    end)

--对话替换, 打开自定义, Frame
    sub:CreateButton(
        '|A:mechagon-projects:0:0|a'..(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function ()
        WoWTools_GossipMixin:Init_Options_Frame()
        return MenuResponse.Open
    end)

--默认
    num=0
    for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
        num= num+1
    end
    sub:CreateDivider()
    sub:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return not Save().notGossipPlayerData
    end, function()
        Save().notGossipPlayerData= not Save().notGossipPlayerData and true or nil
        WoWTools_GossipMixin:Init_Gossip_Data()
        WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        return MenuResponse.CloseAll
    end)



--禁用NPC, 闲话,任务, 选项
    num=0
    for _ in pairs(Save().NPC) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(WoWTools_DataMixin.onlyChinese and '禁用NPC' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, 'NPC'))..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '闲话/任务' or (GOSSIP_OPTIONS..'/'..QUESTS_LABEL))
    end)

--列表，禁用NPC, 闲话,任务, 选项
    for npcID, name in pairs(Save().NPC) do--npcID 是字符
        sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN(nil, {npcID=npcID, isName=true}) or name~=true and name or npcID,
        function(data)
            return Save().NPC[data.npc]
        end, function(data)
            Save().NPC[data.npc]= not Save().NPC[data.npc] and data.name or nil
        end, {npc=npcID, name=name})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.npc)
            tooltip:AddLine('NPC ID')
        end)
    end
    if num>1 then
        sub:CreateDivider()
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().NPC={}
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end


--PlayerChoiceFrame
    num=0
    for _ in pairs(Save().choice) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(WoWTools_DataMixin.onlyChinese and '选择' or CHOOSE)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('PlayerChoiceFrame')
        tooltip:AddLine('Blizzard_PlayerChoice')
    end)

--列表，PlayerChoiceFrame
    for spellID, rarity in pairs(Save().choice) do
        local hex= select(4, C_Item.GetItemQualityColor(rarity))
        local quality=(hex and '|c'..hex or '')..(WoWTools_TextMixin:CN(_G['ITEM_QUALITY'..rarity..'_DESC']) or rarity)

        sub2=sub:CreateCheckbox(
            WoWTools_SpellMixin:GetName(spellID)
            ..quality,
        function(data)
            return Save().choice[data.spellID]
        end, function(data)
            Save().choice[data.spellID]= not Save().choice[data.spellID] and data.rarity or nil
        end, {spellID=spellID, rarity=rarity})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    if num>1 then
        sub:CreateDivider()
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().choice={}
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end


--视频
    num=0
    for _ in pairs(Save().movie) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(WoWTools_DataMixin.onlyChinese and '视频' or VIDEOOPTIONS_MENU)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
--列表，电影
    for movieID, dateTime in pairs(Save().movie) do
        sub2=sub:CreateButton(
            movieID,
        function(data)
            return Save().movie[data.movieID]
        end, function(data)
            MovieFrame_PlayMovie(MovieFrame, data.movieID)
        end, {movieID=movieID, dateTime=dateTime})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY)
        end)
        Movie_SubMenu(sub2, movieID, dateTime)
    end
    if num>0 then
        sub:CreateDivider()
    end
    if num>1 then
--全部清除
        WoWTools_MenuMixin:ClearAll(sub, function()
            Save().movie={}
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end

--跳过，视频，
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON,
    function()
        return Save().stopMovie
    end, function()
        Save().stopMovie= not Save().stopMovie and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(
            WoWTools_DataMixin.onlyChinese and '已经播放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ANIMA_DIVERSION_NODE_SELECTED, EVENTTRACE_BUTTON_PLAY)
        )
    end)

--动画字幕
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '动画字幕' or CINEMATIC_SUBTITLES,
    function()
        return C_CVar.GetCVarBool("movieSubtitle")
    end, function()
        if not InCombatLockdown() then
            C_CVar.SetCVar('movieSubtitle', C_CVar.GetCVarBool("movieSubtitle") and '0' or '1')
        end
    end)
    sub2:SetEnabled(not InCombatLockdown())

--WoW
    sub:CreateDivider()
    WoWTools_GossipMixin:Init_WoW_MoveList(self, sub)


--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GossipMixin.addName})




    --缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:set_Scale()
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
        Init_Menu(self.GossipButton, root)
    end)
end