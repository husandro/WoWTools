local e= select(2, ...)
local function Save()
    return WoWTools_TokensMixin.Save
end


















local function Init_TrackButton_Menu(self)
    if not self.Menu then
        self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
        e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
            if menuList=='ITEMS' then
                WoWTools_TokensMixin:MenuList_Item(level)
                return
            end
            local info={
                text= e.onlyChinese and '显示' or SHOW,
                tooltipOnButton=true,
                tooltipTitle=e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE),
                checked= Save().str,
                keepShownOnClick=true,
                disabled= Save().itemButtonUse and UnitAffectingCombat('player'),
                func= function()
                    Save().str= not Save().str and true or nil
                    TrackButton:set_Texture()
                    TrackButton.Frame:set_shown()
                    print(e.addName, WoWTools_TokensMixin.addName, e.GetShowHide(Save().str))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text=e.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME),
                checked= Save().nameShow,
                keepShownOnClick=true,
                func= function()
                    Save().nameShow= not Save().nameShow and true or nil
                    WoWTools_TokensMixin:Set_TrackButton_Text()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            info={
                text= e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT,
                checked= Save().toRightTrackText,
                keepShownOnClick=true,
                icon= 'NPE_ArrowRight',
                func= function()
                    Save().toRightTrackText = not Save().toRightTrackText and true or nil
                    for _, btn in pairs(TrackButton.btn) do
                        btn.text:ClearAllPoints()
                        btn:set_Text_Point()
                    end
                    Set_TrackButton_Text()
                end
            }

            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info={
                text=e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
                icon='bags-greenarrow',
                checked= Save().toTopTrack,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '重新加载UI' or RELOADUI)..'|n'..SLASH_RELOAD1,
                disabled= UnitAffectingCombat('player'),
                func= function()
                    Save().toTopTrack = not Save().toTopTrack and true or nil
                    WoWTools_Mixin:Reload()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            info={
                text=e.onlyChinese and '物品' or ITEMS,
                checked= not Save().disabledItemTrack,
                menuList='ITEMS',
                hasArrow=true,
                keepShownOnClick=true,
                disabled= UnitAffectingCombat('player'),
                func= function()
                    Save().disabledItemTrack = not Save().disabledItemTrack and true or nil
                    Set_TrackButton_Text()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            e.LibDD:UIDropDownMenu_AddSeparator(level)
            e.LibDD:UIDropDownMenu_AddButton({
                text= e.onlyChinese and '选项' or OPTIONS,
                notCheckable=true,
                icon= 'mechagon-projects',
                func= function()
                    if not Initializer then
                        e.OpenPanelOpting()
                    end
                    e.OpenPanelOpting(Initializer, addName)
                end
            }, level)
        end, 'MENU')
    end
    e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
end







function WoWTools_TokensMixin:Init_TrackButton_Menu(frame)
    Init_TrackButton_Menu(frame)
    --MenuUtil.CreateContextMenu(frame, Init_TrackButton_Menu)
end