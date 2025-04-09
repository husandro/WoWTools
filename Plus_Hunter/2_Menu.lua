
if WoWTools_DataMixin.Player.Class~='HUNTER' then
    return
end


local function Save()
    return WoWToolsSave['Plus_StableFrame']
end













local function Init_Menu(_, root)
    local sub
    --所有宠物
        root:CreateCheckbox(
            '|A:dressingroom-button-appearancelist-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '所有宠物' or BATTLE_PETS_TOTAL_PETS),
        function()
            return Save().show_All_List
        end, function()
            Save().show_All_List= not Save().show_All_List and true or nil
            WoWTools_HunterMixin:Set_StableFrame_List()--初始，宠物列表
            return MenuResponse.Close
        end)

        root:CreateDivider()

        if Save().show_All_List then
    --排序
            sub=root:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '升序' or PERKS_PROGRAM_ASCENDING,
            function()
                return not Save().sortDown
            end, function()
                Save().sortDown= not Save().sortDown and true or nil
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '排序' or STABLE_FILTER_BUTTON_LABEL)
            end)

            for _, tab in pairs( {
                {name='petNumber', type= 'petNumber'},
                {name='creatureID', type='creatureID'},
                {name='uiModelSceneID', type='uiModelSceneID'},
                {name='displayID', type='displayID'},
                {name=WoWTools_DataMixin.onlyChinese and '类型' or TYPE, type='type'},
                {name=WoWTools_DataMixin.onlyChinese and '名称' or NAME, type='name'},
                {name=WoWTools_DataMixin.onlyChinese and '专精' or SPECIALIZATION, type='specialization'},
                {name=WoWTools_DataMixin.onlyChinese and '图标' or EMBLEM_SYMBOL, type='icon'},
                {name=WoWTools_DataMixin.onlyChinese and '族系' or STABLE_SORT_TYPE_LABEL, type="familyName"}
            }) do
                sub=root:CreateButton(tab.name, function(data)
                    WoWTools_HunterMixin:sort_pets_list(data.type)
                    return MenuResponse.Open
                end, {type=tab.type})
                sub:SetTooltip(function(tooltip)
                    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '排序' or STABLE_FILTER_BUTTON_LABEL)
                end)
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
                name=WoWTools_DataMixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
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
            WoWTools_HunterMixin:Set_UI_Texture()
            WoWTools_HunterMixin:Set_StableFrame_List()
        end)

        root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and 'HUD提示信息' or HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
        function()
            return not Save().HideTips
        end, function()
            Save().HideTips= not Save().HideTips and true or nil
        end)


    --选项
        root:CreateDivider()
        WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HunterMixin.addName})
    end






local function Init()
    local btn= WoWTools_ButtonMixin:Menu(StableFrameCloseButton)
    btn:SetPoint('RIGHT', StableFrameCloseButton, 'LEFT', -2, 0)


    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_HunterMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(
            (_G['WoWTools_StableFrameAllList'] and '' or '|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE),
            (Save().all_List_Size or 22)..WoWTools_DataMixin.Icon.mid
        )
        GameTooltip:Show()
    end

    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', btn.set_tooltips)

    btn:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
    end)

    btn:EnableMouseWheel(true)
    btn:SetScript('OnMouseWheel', function(self, d)
        local AllListFrame= _G['WoWTools_StableFrameAllList']
        if not AllListFrame then
            return
        end

        local value= Save().all_List_Size or 22
        if d==1 then
           value= value+ 1
        elseif d==-1 then
            value= value-1
        end

        value= min(value, 72)
        value= max(value, 8)

        Save().all_List_Size=value

        AllListFrame:Settings()

        self:set_tooltips()
    end)
end








function WoWTools_HunterMixin:Init_Menu()
    Init()
end