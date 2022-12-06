local id, e= ...
local addName= INVTYPE_BAG
local Save= {sortRightToLeft= true}


local function set_Sort_Rigth_To_Left()--排序:从右到左
    C_Container.SetSortBagsRightToLeft(Save.sortRightToLeft or false)
end

--####
--初始
--####
local function Init()
    ContainerFrameCombinedBagsPortraitButton:HookScript('OnMouseDown',function ()
        UIDropDownMenu_AddSeparator()

        local info={--排序:从右到左
            text= e.onlyChinse and '排序: 从右到左' or CLUB_FINDER_SORT_BY..': '..	INT_SPELL_POINTS_SPREAD_TEMPLATE:format(HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_RIGHT,HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_LEFT),
            checked= C_Container.GetSortBagsRightToLeft(),
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func= function()
                Save.sortRightToLeft= not C_Container.GetSortBagsRightToLeft() and true or nil
                set_Sort_Rigth_To_Left()--排序:从右到左
            end,
        }
        UIDropDownMenu_AddButton(info, 1)
    end)

    set_Sort_Rigth_To_Left()--排序:从右到左
end

--###########
--加载保存数据
--###########
local panel=CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

          --[[
        --添加控制面板        
          local sel=e.CPanel(addName, not Save.disabled)
          sel:SetScript('OnClick', function()
              if Save.disabled then
                  Save.disabled=nil
              else
                  Save.disabled=true
              end
              print(addName, e.GetEnabeleDisable(not Save.disabled), REQUIRES_RELOAD)
          end)

]]


        if not Save.disabled then
            Init()--初始
        end
    end
end)
