local e= select(2, ...)
if e.Player.class~='HUNTER' then
    return
end


local function Save()
    return WoWTools_StableFrameMixin.Save
end













local function Init_Menu(_, root)

    --所有宠物
        root:CreateCheckbox(
            '|A:dressingroom-button-appearancelist-up:0:0|a'..(e.onlyChinese and '所有宠物' or BATTLE_PETS_TOTAL_PETS),
        function()
            return Save().show_All_List
        end, function()
            Save().show_All_List= not Save().show_All_List and true or nil
            WoWTools_StableFrameMixin:Set_StableFrame_List()--初始，宠物列表
            return MenuResponse.Close
        end)


        if Save().show_All_List then
    --排序
            root:CreateDivider()
            root:CreateCheckbox(
                e.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
            function()
                return not Save().sortDown
            end, function()
                Save().sortDown= not Save().sortDown and true or nil
            end)

            local tab={
                ['petNumber']=  'petNumber',
                [e.onlyChinese and '类型' or TYPE]= 'type',
                ['creatureID']= 'creatureID',
                ['uiModelSceneID']= 'uiModelSceneID',
                ['displayID']= 'displayID',
                [e.onlyChinese and '名称' or NAME]= 'name',
                [e.onlyChinese and '天赋' or TALENT]= 'specialization',
                [e.onlyChinese and '图标' or EMBLEM_SYMBOL]='icon',
                ['familyName']= 'familyName',
            }
            for text, name in pairs(tab) do
                root:CreateButton(text, function(data)
                    WoWTools_StableFrameMixin:sort_pets_list(data.name)
                    return MenuResponse.Open
                end, {name=name})
            end

    --图标尺寸
            root:CreateDivider()
            root:CreateSpacer()
            WoWTools_MenuMixin:CreateSlider(root, {
                getValue=function()
                    return Save().all_List_Size or 28
                end, setValue=function(value)
                    Save().all_List_Size=value
                    local AllListFrame= _G['WoWTools_StableFrameAllList']
                    if AllListFrame then
                        AllListFrame:Settings()
                    end
                    
                end,
                name=e.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
                minValue=8,
                maxValue=72,
                step=1,
                bit=nil,
            })
            root:CreateSpacer()
        end

    --显示，材质
        WoWTools_MenuMixin:ShowTexture(root, function()
            return Save().showTexture
        end, function()
            Save().showTexture= not Save().showTexture and true or nil
            WoWTools_StableFrameMixin:Set_UI_Texture()
            WoWTools_StableFrameMixin:Set_StableFrame_List()
        end)

    --选项
        root:CreateDivider()
        WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_StableFrameMixin.addName})
    end






local function Init()
    local btn= WoWTools_ButtonMixin:CreateMenu(StableFrameCloseButton)
    btn:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)


    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_StableFrameMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
    end

    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)

    btn:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)
end








function WoWTools_StableFrameMixin:Init_Menu()
    Init()
end