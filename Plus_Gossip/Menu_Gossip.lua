local e= select(2, ...)
local addName
local addName2

local function Save()
    return WoWTools_GossipMixin.Save
end













--###########
--对话，主菜单
--###########
local function Init_Menu(self, level, type)
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
                print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT,
            notCheckable=true,
            keepShownOnClick=true,
            func= function()
                StaticPopupDialogs['WoWTools_Gossip_RESET_TO_DEFAULT']={
                    text=e.addName..' '..addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    button1= e.onlyChinese and '重置' or RESET,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnAccept = function()
                        WoWTools_GossipMixin.Save=nil
                        e.Reload()
                    end,
                }
                StaticPopup_Show('WoWTools_Gossip_RESET_TO_DEFAULT')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif type=='CUSTOM' then
        for gossipOptionID, text in pairs(Save().gossipOption) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='gossipOptionID '..gossipOptionID,
                tooltipText='|n'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE),
                arg1= gossipOptionID,
                func=function(_, arg1)
                    Save().gossipOption[arg1]=nil
                    print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, text, 'gossipOptionID:', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            tooltipOnButton= true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            notCheckable=true,
            func= function()
                if IsShiftKeyDown() then
                    Save().gossipOption={}
                    print(e.addName, addName, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='DISABLE' then--禁用NPC, 闲话,任务, 选项
        for npcID, name in pairs(Save().NPC) do
            info={
                text=name,
                tooltipOnButton=true,
                tooltipTitle= 'NPC '..npcID,
                tooltipText= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                notCheckable= true,
                arg1= npcID,
                func= function(_, arg1)
                    Save().NPC[arg1]=nil
                    print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, 'NPC', arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= 'Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save().NPC={}
                    print(e.addName, addName, e.onlyChinese and '自定义' or CUSTOM, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)


    elseif type=='PlayerChoiceFrame' then
        for spellID, rarity in pairs(Save().choice) do
            e.LoadData({id=spellID, type='spell'})
            local icon= C_Spell.GetSpellTexture(spellID)
            local name= C_Spell.GetSpellLink(spellID) or ('spellID '..spellID)
            rarity= rarity+1
            local hex= select(4, C_Item.GetItemQualityColor(rarity))
            local quality=(hex and '|c'..hex or '')..(e.cn(_G['ITEM_QUALITY'..rarity..'_DESC']) or rarity)
            info={
                text=(icon and '|T'..icon..':0|t' or '')..name..' '.. quality,
                tooltipOnButton=true,
                tooltipTitle= e.Icon.left.. (e.onlyChinese and '移除' or REMOVE),
                tooltipText= 'spellID '..spellID,
                notCheckable= true,

                arg1=spellID,
                func= function(_, arg1)
                    Save().choice[arg1]=nil
                    print(e.addName, addName, e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '移除' or REMOVE, C_Spell.GetSpellLink(arg1) or ('spellID '..arg1))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle='Shift+'..e.Icon.left,
            func= function()
                if IsShiftKeyDown() then
                    Save().choice={}
                    print(e.addName, addName, e.onlyChinese and '选择' or CHOOSE, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
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
                                print(e.addName, addName, arg1, e.onlyChinese and '存在' or 'Exist')
                            else
                                PreloadMovie(arg1)
                                local inProgress2, downloaded2, total2 = GetMovieDownloadProgress(arg1)
                                print(e.addName, addName, inProgress2 and downloaded2 and total2 and format('%i%%', downloaded/total*100) or total2)
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

    elseif type=='Movie' then
        for movieID, dateTime in pairs(Save().movie) do
            local isDownload= IsMovieLocal(movieID)-- IsMoviePlayable(movieID)
            local inProgress, downloaded, total = GetMovieDownloadProgress(movieID)
            info={
                text= movieID,
                tooltipOnButton=true,
                tooltipTitle= dateTime,
                tooltipText= '|n'
                            ..e.Icon.left..(e.onlyChinese and '播放' or EVENTTRACE_BUTTON_PLAY)
                            ..'|nShift+'..e.Icon.left..(e.onlyChinese and '移除' or REMOVE)
                            ..(isDownload and '|cff9e9e9e' or '')
                            ..'|nCtrl+'..e.Icon.left..(e.onlyChinese and '下载' or 'Download')
                            ..(inProgress and downloaded and total and format('|n%i%%', downloaded/total*100) or ''),
                notCheckable=true,
                disabled= UnitAffectingCombat('player'),
                colorCode= not isDownload and '|cff9e9e9e' or nil,
                arg1= movieID,
                func= function(_, arg1)
                    if not IsModifierKeyDown() then
                        e.LibDD:CloseDropDownMenus()
                        MovieFrame_PlayMovie(MovieFrame, arg1)
                    elseif IsControlKeyDown() then
                        if IsMovieLocal(movieID) then
                            print(e.addName, addName, arg1, e.onlyChinese and '存在' or 'Exist')
                        else
                            PreloadMovie(arg1)
                            local inProgress2, downloaded2, total2 = GetMovieDownloadProgress(arg1)
                            print(e.addName, addName, inProgress2 and downloaded2 and total2 and format('%i%%', downloaded/total*100) or total2)
                        end
                    elseif IsShiftKeyDown() then
                        Save().movie[arg1]=nil
                        print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, 'movieID', arg1)
                    end
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        info={
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            tooltipOnButton=true,
            tooltipTitle='Shift+'..e.Icon.left,
            notCheckable=true,
            func= function()
                if IsShiftKeyDown() then
                    Save().movie={}
                    print(e.addName, addName, e.onlyChinese and '清除全部' or CLEAR_ALL)
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '跳过' or RENOWN_LEVEL_UP_SKIP_BUTTON,
            checked= Save().stopMovie,
            tooltipOnButton=true,
            tooltipTitle=e.onlyChinese and '已经播放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ANIMA_DIVERSION_NODE_SELECTED, EVENTTRACE_BUTTON_PLAY),
            keepShownOnClick=true,
            func= function ()
                Save().stopMovie= not Save().stopMovie and true or nil
                print(e.addName, addName, e.GetEnabeleDisable(Save().stopMovie))
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinese and '动画字幕' or CINEMATIC_SUBTITLES,
            tooltipOnButton=true,
            tooltipTitle='CVar movieSubtitle',
            checked= C_CVar.GetCVarBool("movieSubtitle"),
            disabled= UnitAffectingCombat('player'),
            keepShownOnClick=true,
            func= function()
                C_CVar.SetCVar('movieSubtitle', C_CVar.GetCVarBool("movieSubtitle") and '0' or '1')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text='WoW',
            notCheckable=true,
            hasArrow=true,
            menuList='WoWMovie',
            keepShownOnClick=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    elseif type=='Gossip_Text_Icon_Options' then--自定义，对话，文本，2级菜单
        local num=0
        for _ in pairs(Save().Gossip_Text_Icon_Player) do
            num= num+1
        end
        info={
            text= format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '自定义' or CUSTOM, num),
            notCheckable=true,
            tooltipOnButton=true,
            icon='mechagon-projects',
            func= function()
                WoWTools_GossipMixin:Init_Options_Frame()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local num=0
        for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
            num= num+1
        end
        info={
            text=format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '默认' or DEFAULT, num),
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    if type then
        return
    end

    info={
        text=e.onlyChinese and '启用' or ENABLE,
        checked= Save().gossip,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle=format('Alt+%s', e.onlyChinese and '禁用' or DISABLE),
        tooltipText= format('(%s)', e.onlyChinese and '暂时' or BOOSTED_CHAR_SPELL_TEMPLOCK..'|ntemporary'),
        func= function ()
            Save().gossip= not Save().gossip and true or nil
            self:set_Texture()--设置，图片
            self:tooltip_Show()
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    info={--唯一
        text= e.onlyChinese and '唯一对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEM_UNIQUE, ENABLE_DIALOG),
        checked= Save().unique,
        keepShownOnClick=true,
        func= function()
            Save().unique= not Save().unique and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    local n=0
    for _ in pairs(Save().gossipOption) do
        n=n+1
    end
    info={--自定义,闲话,选项
        text=format('%s |cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '自动对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, ENABLE_DIALOG), n),
        menuList='CUSTOM',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    n=0
    for _ in pairs(Save().NPC) do
        n=n+1
    end
    info={--禁用NPC, 闲话,任务, 选项
        text=format('%s NPC |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '禁用' or DISABLE, n),
        menuList='DISABLE',
        tooltipOnButton=true,
        tooltipTitle= addName,
        tooltipText= addName2,
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    n=0
    for _ in pairs(Save().Gossip_Text_Icon_Player) do
        n=n+1
    end
    for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
        n=n+1
    end
    info={
        text=format('%s, |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE), n),
        tooltipOnButton=true,
        tooltipTitle=e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
        checked= not Save().not_Gossip_Text_Icon,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='Gossip_Text_Icon_Options',
        func= function()
           Save().not_Gossip_Text_Icon= not Save().not_Gossip_Text_Icon and true or nil
           WoWTools_GossipMixin:Init_Gossip_Text()
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    n=0
    for _ in pairs(Save().choice) do
        n=n+1
    end
    info={--PlayerChoiceFrame
        text=format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '选择' or CHOOSE, n),
        menuList='PlayerChoiceFrame',
        tooltipOnButton=true,
        tooltipTitle='PlayerChoiceFrame',
        tooltipText= 'Blizzard_PlayerChoice',
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    n=0
    for _ in pairs(Save().movie) do
        n=n+1
    end
    info={
        text= format('%s |cnGREEN_FONT_COLOR:%d|r', e.onlyChinese and '电影' or 'Movie', n),
        menuList='Movie',
        tooltipOnButton=true,
        notCheckable=true,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '打开选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, OPTIONS),
        notCheckable=true,
        keepShownOnClick=true,
        hasArrow=true,
        menuList='OPTIONS',
        func= function()
            e.OpenPanelOpting(nil, '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(e.onlyChinese and '对话和任务' or addName))
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end





function WoWTools_GossipMixin:Init_Menu_Gossip(...)
    addName= self.addName
    addName2= self.addName2
    Init_Menu(...)
end