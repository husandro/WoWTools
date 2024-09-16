local e= select(2, ...)
local function Save()
    return WoWTools_GossipMixin.Save
end











local function Movie_SubMenu(root, movieID, dateTime)
--移除
    if dateTime  then

        root:CreateCheckbox(
            e.onlyChinese and '移除' or REMOVE,
        function(data)
            return Save().movie[data.movieID]
        end, function(data)
            Save().movie[data.movieID]= not Save().movie[data.movieID] and data.dateTime or nil
            return MenuResponse.Close
        end, {movieID=movieID, dateTime=dateTime})
        root:CreateSpacer()
    end

--下载
    if not IsMovieLocal(movieID) then
        local sub=root:CreateButton(
            e.onlyChinese and '下载' or 'Download',
        function(data)
            PreloadMovie(data.movieID)
        end, {movieID=movieID, dateTime=dateTime})

        --进度        
        sub:SetTooltip(function(tooltip, description)
            local inProgress, downloaded, total = GetMovieDownloadProgress(description.data.movieID)
            if inProgress and downloaded and total and total>0 then
                tooltip:AddDoubleLine(
                    e.onlyChinese and '进度' or PVP_PROGRESS_REWARDS_HEADER,
                    format('|n%i%%', downloaded/total*100)
                )
            end
        end)
    end
end











local function Init_Menu(self, root)
    local sub, sub2, sub3, num, num2

--启用
    sub=root:CreateCheckbox(
        (e.onlyChinese and '启用' or ENABLE)..'|A:SpecDial_LastPip_BorderGlow:0:0|a',
    function()
        return Save().gossip
    end, function()
        Save().gossip= not Save().gossip and true or nil
        self:set_Texture()--设置，图片
        self:tooltip_Show()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('Alt+'..(e.onlyChinese and '禁用' or DISABLE))
        tooltip:AddLine(e.onlyChinese and '暂时' or BOOSTED_CHAR_SPELL_TEMPLOCK)
    end)

--唯一对话    
    root:CreateDivider()
    root:CreateCheckbox(
        e.onlyChinese and '唯一对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEM_UNIQUE, ENABLE_DIALOG),
    function()
        return  Save().unique
    end, function ()
        Save().unique= not Save().unique and true or nil
    end)

--自定义,闲话
    num=0
    for _ in pairs(Save().gossipOption) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '
        ..(e.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG))
        ..(num==0 and ' |cff9e9e9e' or ' ')
        ..num,
    function()
        return MenuResponse.Open
    end)

--列表，自定义,闲话
    for gossipOptionID, text in pairs(Save().gossipOption) do
        sub2=sub:CreateCheckbox(
            text,
        function(data)
            return Save().gossipOption[data.gossipOptionID]
        end, function(data)
            Save().gossipOption[data.gossipOptionID]= not Save().gossipOption[data.gossipOptionID] and data.text or nil
        end, {gossipOptionID=gossipOptionID, text=text})
        sub2:SetTooltip(function(tooltip, description)
            tooltip:AddLine(description.data.gossipOptionID)
            tooltip:AddLine('gossipOptionID')
        end)
    end
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            e.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().gossipOption={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
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
        (e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE))
        ..e.Icon.mid
        ..((num+num2)==0 and '|cff9e9e9e' or '')
        ..(num..'/'..num2),
    function()
        return not Save().not_Gossip_Text_Icon
    end, function()
        Save().not_Gossip_Text_Icon= not Save().not_Gossip_Text_Icon and true or nil
        WoWTools_GossipMixin:Init_Gossip_Text()
    end)

--对话替换, 打开自定义, Frame
    sub:CreateButton(
        '|A:mechagon-projects:0:0|a'..(e.onlyChinese and '自定义' or CUSTOM)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function ()
        WoWTools_GossipMixin:Init_Options_Frame()
        return MenuResponse.Open
    end)

--默认
    num=0
    for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
        num= num+1
    end
    sub:CreateSpacer()
    sub:CreateTitle(
        (e.onlyChinese and '默认' or DEFAULT)..(num==0 and ' |cff9e9e9e' or ' ')..num
    )



--禁用NPC, 闲话,任务, 选项
    num=0
    for _ in pairs(Save().NPC) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(e.onlyChinese and '禁用NPC' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, 'NPC'))..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '闲话/任务' or (GOSSIP_OPTIONS..'/'..QUESTS_LABEL))
    end)
--列表，禁用NPC, 闲话,任务, 选项
    for npcID, name in pairs(Save().NPC) do
        sub2=sub:CreateCheckbox(
            name,
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
        sub:CreateButton(
            e.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().NPC={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end


--PlayerChoiceFrame
    num=0
    for _ in pairs(Save().choice) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(e.onlyChinese and '选择' or CHOOSE)..(num==0 and ' |cff9e9e9e' or ' ')..num,
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
        local quality=(hex and '|c'..hex or '')..(e.cn(_G['ITEM_QUALITY'..rarity..'_DESC']) or rarity)

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
        sub:CreateButton(
            e.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().choice={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end


--视频
    root:CreateDivider()
    num=0
    for _ in pairs(Save().movie) do
        num=num+1
    end
    sub=root:CreateButton(
        '     '..(e.onlyChinese and '视频' or VIDEOOPTIONS_MENU)..(num==0 and ' |cff9e9e9e' or ' ')..num,
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
            tooltip:AddLine(e.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY)
        end)
        Movie_SubMenu(sub2, movieID, dateTime)
    end
    if num>0 then
        sub:CreateDivider()
    end
    if num>1 then
        sub:CreateButton(
            e.onlyChinese and '清除全部' or CLEAR_ALL,
        function()
            Save().movie={}
        end)
        WoWTools_MenuMixin:SetGridMode(sub, num)
    end

--跳过，视频，
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON,
    function()
        return Save().stopMovie
    end, function()
        Save().stopMovie= not Save().stopMovie and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '已经播放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ANIMA_DIVERSION_NODE_SELECTED, EVENTTRACE_BUTTON_PLAY))
    end)

--动画字幕
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '动画字幕' or CINEMATIC_SUBTITLES,
    function()
        return C_CVar.GetCVarBool("movieSubtitle")
    end, function()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar('movieSubtitle', C_CVar.GetCVarBool("movieSubtitle") and '0' or '1')
        end
    end)
    sub2:SetEnabled(not UnitAffectingCombat('player'))

--WoW
    sub2=sub:CreateButton('WoW', function() return MenuResponse.Open end)
    for _, movieEntry in pairs(MOVIE_LIST or WoWTools_GossipMixin:Get_MoveData()) do
        for _, movieID in pairs(movieEntry.movieIDs) do
            sub3=sub2:CreateButton(
                e.cn(movieEntry.title or movieEntry.text or _G["EXPANSION_NAME"..movieEntry.expansion]) or movieID,
            function(data)
                MovieFrame_PlayMovie(MovieFrame, data.movieID)
            end, {movieID=movieID})
            sub3:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.movieID)
            end)
            Movie_SubMenu(sub3, movieID, nil)
        end
    end
end










--###########
--对话，主菜单
--[[###########
local function Init(self, level, type)

    if not Save().gossip then
        e.LibDD:UIDropDownMenu_AddButton({
            text=e.GetEnabeleDisable(false),
            checked=true,
            func=function()
                Save().gossip= true
                self:set_Texture()--设置，图片
                self:tooltip_Show()
                self:update_gossip_frame()
            end
        }, level)
        return
    end
    local info
    if type=='OPTIONS' then
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            notCheckable=true,
            colorCode=not Save().point and '|cff9e9e9e',
            keepShownOnClick=true,
            func= function()
                Save().point=nil
                self:ClearAllPoints()
                self:set_Point()
                print(e.addName, WoWTools_GossipMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT,
            notCheckable=true,
            keepShownOnClick=true,
            func= function()
                StaticPopupDialogs['WoWTools_Gossip_RESET_TO_DEFAULT']={
                    text=e.addName..' '..WoWTools_GossipMixin.addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    button1= e.onlyChinese and '重置' or RESET,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnAccept = function()
                        WoWTools_GossipMixin.Save=nil
                        WoWTools_Mixin:Reload()
                    end,
                }
                StaticPopup_Show('WoWTools_Gossip_RESET_TO_DEFAULT')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)





    
    elseif type=='WoWMovie' then
        for _, movieEntry in pairs(MOVIE_LIST or WoWTools_GossipMixin:Get_MoveData()) do
            for _, movieID in pairs(movieEntry.movieIDs) do
                local isDownload= IsMovieLocal(movieID)-- IsMoviePlayable(movieID)
                local inProgress, downloaded, total = GetMovieDownloadProgress(movieID)
                info={
                    text= (movieEntry.title or movieEntry.text or _G["EXPANSION_NAME"..movieEntry.expansion])..' '..movieID,
                    tooltipOnButton=true,
                    tooltipTitle= e.Icon.left..(e.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY),
                    tooltipText=(isDownload and '|cff9e9e9e' or '')
                                ..'Ctrl+'..e.Icon.left..(e.onlyChinese and '下载' or 'Download')
                                ..(inProgress and downloaded and total and format('|n%i%%', downloaded/total*100) or ''),
                    notCheckable=true,
                    disabled= UnitAffectingCombat('player'),
                    colorCode= not isDownload and '|cff9e9e9e' or nil,
                    icon= movieEntry.upAtlas,
                    arg1= movieID,
                    func= function(_, arg1)
                        if IsControlKeyDown() then
                            if IsMovieLocal(arg1) then
                                print(e.addName, WoWTools_GossipMixin.addName, arg1, e.onlyChinese and '存在' or 'Exist')
                            else
                                PreloadMovie(arg1)
                                local inProgress2, downloaded2, total2 = GetMovieDownloadProgress(arg1)
                                print(e.addName, WoWTools_GossipMixin.addName, inProgress2 and downloaded2 and total2 and format('%i%%', downloaded/total*100) or total2)
                            end
                        elseif not IsModifierKeyDown() then
                            e.LibDD:CloseDropDownMenus()
                            MovieFrame_PlayMovie(MovieFrame, arg1)
                        end
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

    


    if type then
        return
    end
















    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '打开选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS),
        notCheckable=true,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='OPTIONS',
        func= function()
            e.OpenPanelOpting(nil, '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or WoWTools_GossipMixin.addName))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end]]





function WoWTools_GossipMixin:Init_Menu_Gossip(frame, root)
    Init_Menu(frame, root)
end