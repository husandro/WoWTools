--界面，菜单

local MountType={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    'Shift', 'Alt', 'Ctrl',
    FLOOR,
}

local function Save()
    return WoWToolsSave['Tools_Mounts']
end


local function removeTable(type, ID)--移除, 表里, 其他同样的项目
    for type2, _ in pairs(Save().Mounts) do
        if type2~=type and type2~=FLOOR then
            Save().Mounts[type2][ID]=nil
        end
    end
end






local function Init_UI_Menu(self, root)
    local frame= self:GetParent()
    local mountID = frame.mountID

    if not mountID then
        root:CreateTitle((WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..' mountID')
        return
    end

    local name, spellID, icon, _, _, _, _, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)
    spellID= spellID or self.spellID

    if not name then
        return
    end

    local col, sub
    for _, type in pairs(MountType) do
        if type=='Shift' or type==FLOOR then
            root:CreateDivider()
        end

        col= (
            (type==MOUNT_JOURNAL_FILTER_DRAGONRIDING and not isForDragonriding)
            --or (type~=MOUNT_JOURNAL_FILTER_DRAGONRIDING and isForDragonriding)
            or not isCollected
            or shouldHideOnChar
            or (isFactionSpecific and faction~=WoWTools_MountMixin.faction)
        ) and '|cff9e9e9e' or ''


        local setData= {type=type, spellID=spellID, mountID=mountID, name=name, icon='|T'..(icon or 0)..':0|t'}
        sub=root:CreateCheckbox(col..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)..' '..WoWTools_TextMixin:CN(type)..' #|cnGREEN_FONT_COLOR:'..WoWTools_MountMixin:Get_Table_Num(type),
            function(data)
                return Save().Mounts[data.type][data.spellID]

            end, function(data)
                if Save().Mounts[data.type][data.spellID] then
                    Save().Mounts[data.type][data.spellID]=nil

                elseif data.type==FLOOR then
                    WoWTools_MountMixin:Set_Item_Spell_Edit(data)
                else
                    if data.type=='Shift' or data.type=='Alt' or data.type=='Ctrl' then--唯一
                        Save().Mounts[data.type]={[data.spellID]=true}
                    else
                        Save().Mounts[data.type][data.spellID]=true
                    end
                    removeTable(data.type, data.spellID)--移除, 表里, 其他同样的项目
                end
                WoWTools_MountMixin.MountButton:settings()
                WoWTools_Mixin:Call(MountJournal_UpdateMountList)
            end, setData
        )
        WoWTools_MountMixin:Set_Mount_Sub_Options(sub, setData)
    end

    root:CreateDivider()
    WoWTools_ToolsMixin:OpenMenu(root, WoWTools_SpellMixin:GetName(spellID) or ('|T'..(icon or 0)..':0|t'..name))
end


















--过滤，列表，Func
local function New_MountJournal_FullUpdate()
    if not MountJournal:IsVisible() then
        return
    end

    local btn= _G['MountJournalFilterButtonWoWTools']
    local spellIDs={}
    for type in pairs(btn.Type or {}) do
        for spellID in pairs(Save().Mounts[type]) do
            spellIDs[spellID]=true
        end
    end
    local newDataProvider = CreateDataProvider();
    for index = 1, C_MountJournal.GetNumDisplayedMounts()  do
        local _, spellID, _, _, _, _, _, _, _, _, _, mountID   = C_MountJournal.GetDisplayedMountInfo(index)
        if mountID and spellID and spellIDs[spellID] then
            newDataProvider:Insert({index = index, mountID = mountID})
        end
    end
    MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);
    if (not MountJournal.selectedSpellID) then
        MountJournal_Select(1);
    end
    MountJournal_UpdateMountDisplay()
end





local function Updata_MountJournal_FullUpdate(self)
    MountJournal_FullUpdate=New_MountJournal_FullUpdate--过滤，列表，Func

    MountJournal.FilterDropdown:Reset()
    WoWTools_Mixin:Call(MountJournal_SetUnusableFilter, true)
    WoWTools_Mixin:Call(MountJournal_FullUpdate, MountJournal)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true);

    self.ResetButton:SetShown(true)
    self:set_text()
end







--过滤，列表，菜单
local function Init_UI_List_Menu(self, root)
    if not self:IsVisible() then
        return
    end

    for _, type in pairs(MountType) do
        root:CreateCheckbox(WoWTools_TextMixin:CN(type)..' #|cnGREEN_FONT_COLOR:'..WoWTools_MountMixin:Get_Table_Num(type), function(data)
            return self.Type[data]
        end, function(data)
            self.Type[data]= not self.Type[data] and true or nil
            Updata_MountJournal_FullUpdate(self)
        end, type)
    end

    root:CreateDivider()
    root:CreateButton('     '..(WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL), function()
        self.Type={
            [MOUNT_JOURNAL_FILTER_GROUND]=true,
            [MOUNT_JOURNAL_FILTER_AQUATIC]=true,
            [MOUNT_JOURNAL_FILTER_FLYING]=true,
            [MOUNT_JOURNAL_FILTER_DRAGONRIDING]=true,
            ['Shift']=true, ['Alt']=true, ['Ctrl']=true,
            [FLOOR]=true,
        }
        Updata_MountJournal_FullUpdate(self)

        return MenuResponse.Refresh
    end)

    root:CreateButton('     '..(WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL), function()
        self:rest_type()
        self.ResetButton:Click()
        return MenuResponse.Refresh
    end)

    root:CreateDivider()
    WoWTools_ToolsMixin:OpenMenu(root, WoWTools_MountMixin.addName)
end































--初始，坐骑界面
local function Init()
    hooksecurefunc('MountJournal_InitMountButton',function(frame)--Blizzard_MountCollection.lua
        if not frame or not frame.spellID then
            if frame and frame.btn then
                frame.btn:SetShown(false)
            end
            return
        end
        local text
        for _, type in pairs(MountType) do
            local ID=Save().Mounts[type][frame.spellID]
            if ID then
                text= text and text..'|n' or ''
                if type==FLOOR then
                    local num=0
                    for _, _ in pairs(ID) do
                        num=num+1
                    end
                    text=text..'|cnGREEN_FONT_COLOR:'..num..'|r'
                end
                text= text..WoWTools_TextMixin:CN(type)
            end
        end
         if not frame.WoWToolsButton then--建立，图标，菜单
            frame.WoWToolsButton=WoWTools_ButtonMixin:Cbtn(frame, {
                atlas='orderhalltalents-done-glow',
                size=22
            })
            frame.WoWToolsButton:SetPoint('BOTTOMRIGHT')
            frame.WoWToolsButton:SetAlpha(0)
            frame.WoWToolsButton:SetScript('OnEnter', function(self)
                self:SetAlpha(1)
            end)
            frame.WoWToolsButton:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
            frame.WoWToolsButton:SetScript('OnClick', function(self)
                MenuUtil.CreateContextMenu(self, Init_UI_Menu)--界面，菜单
            end)
            frame:HookScript('OnLeave', function(self)self.WoWToolsButton:SetAlpha(0) end)
            frame:HookScript('OnEnter', function(self) self.WoWToolsButton:SetAlpha(1) end)
            frame.WoWToolsText=WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT'})--nil, frame.name, nil,nil,nil,'RIGHT')
            frame.WoWToolsText:SetPoint('TOPRIGHT',0,-2)
            frame.WoWToolsText:SetFontObject('GameFontNormal')
            frame.WoWToolsText:SetAlpha(0.5)
        end
        frame.WoWToolsButton.mountID= frame.mountID
        frame.WoWToolsButton.spellID= frame.spellID
        frame.WoWToolsButton:SetShown(true)
        frame.WoWToolsText:SetText(text or '')--提示， 文本
    end)

    --[[if not MountJournal.MountDisplay.tipsMenu then
        MountJournal.MountDisplay.tipsMenu= WoWTools_ButtonMixin:Cbtn(MountJournal.MountDisplay, {icon=true, size={22,22}})
        MountJournal.MountDisplay.tipsMenu:SetPoint('LEFT')
        MountJournal.MountDisplay.tipsMenu:SetAlpha(0.3)
        MountJournal.MountDisplay.tipsMenu:SetScript('OnMouseDown', function(self)
            WoWTools_MountMixin:Init_Menu(self)
            self:SetAlpha(1)
        end)
        MountJournal.MountDisplay.tipsMenu:SetScript('OnLeave', function(self) self:SetAlpha(0.3) end)
    end]]

    --local btn= CreateFrame('DropDownToggleButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'UIResettableDropdownButtonTemplate')--SharedUIPanelTemplates.lua
    local btn= CreateFrame('DropdownButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'WowStyle1FilterDropdownTemplate')
    btn:SetPoint('BOTTOMLEFT', MountJournal.FilterDropdown, 'TOPLEFT', 0, 6)
    --btn:SetWidth(MountJournal.FilterDropdown:GetWidth())

    MountJournal.FilterDropdown.ResetButton:HookScript('OnClick', function()
        if btn.ResetButton:IsShown() then
            btn.ResetButton:Click()
        end
    end)

    btn.MountJournal_FullUpdate= MountJournal_FullUpdate

    function btn:rest_type()
        self.Type={}
    end
    function btn:set_text()
        for type in pairs(self.Type or {}) do
            self:SetText(WoWTools_TextMixin:CN(type))
            return
        end
        self:SetText('Tools')
    end

--重置
    btn.ResetButton:SetScript('OnClick', function(self)
        local frame= self:GetParent()
        MountJournal_FullUpdate= frame.MountJournal_FullUpdate
        frame:set_text()
        MountJournal.FilterDropdown:Reset()
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true);
        WoWTools_Mixin:Call(MountJournal_SetUnusableFilter,true)
        WoWTools_Mixin:Call(MountJournal_FullUpdate, MountJournal)
        self:Hide()
        self:GetParent():rest_type()
    end)

    MountJournal.MountCount:ClearAllPoints()
    MountJournal.MountCount:SetPoint('BOTTOMRIGHT', MountJournalSearchBox, 'TOPRIGHT', 0, 4)

    btn:rest_type()
    btn:set_text()
    btn:SetupMenu(Init_UI_List_Menu)--过滤，列表，菜单    
end





function WoWTools_MountMixin:Init_MountJournal()
    Init()
end

















