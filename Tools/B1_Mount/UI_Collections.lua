--界面，菜单
local function SaveLog()
    return WoWToolsPlayerDate['Tools_Mounts']
end








local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local frame= self:GetParent()
    local mountID = frame.mountID


    if not mountID then
        root:CreateTitle((WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..' mountID')
        return
    end

    local name, spellID, icon, _, _, _, _, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isSteadyFlight = C_MountJournal.GetMountInfoByID(mountID)
    spellID= spellID or frame.spellID

    if not name then
        return
    end

    local col, sub
    for _, mountType in pairs(WoWTools_MountMixin.MountType) do
        local isFloor= mountType=='Floor'
        if isFloor then
            root:CreateDivider()
        end

        col= (
            (mountType=='Dragonriding' and isSteadyFlight)
            or not isCollected
            or shouldHideOnChar
            or (isFactionSpecific and faction~=WoWTools_MountMixin.faction)
        ) and '|cff626262' or ''


        local tab= {type=mountType, spellID=spellID, mountID=mountID, name=name, icon='|T'..(icon or 0)..':0|t'}

        local text=-- col..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
               -- ..' '
                col
                ..(WoWTools_MountMixin.TypeName[mountType] or mountType)
                ..' #|cnGREEN_FONT_COLOR:'..WoWTools_MountMixin:Get_Table_Num(mountType)

        local function getValue(data)
            return SaveLog()[data.type][data.spellID]
        end

        local function setValue(data)
            if SaveLog()[data.type][data.spellID] then
                SaveLog()[data.type][data.spellID]=nil

            elseif data.type=='Floor' then
                WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            else
                if data.type=='Shift' or data.type=='Alt' or data.type=='Ctrl' then--唯一
                    SaveLog()[data.type]={[data.spellID]=true}
                else
                    SaveLog()[data.type][data.spellID]=true
                end
--移除, 表里, 其他同样的项目
                for muntType in pairs(SaveLog()) do
                    if muntType~=data.type and muntType~='Floor' then
                        SaveLog()[muntType][data.spellID]=nil
                    end
                end
            end
            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
            self:setmount_listtext()
            --WoWTools_DataMixin:Call('MountJournal_UpdateMountList')
            return MenuResponse.Refresh
        end

        if mountType=='Floor' or mountType=='Alt' then
            root:CreateDivider()
        end

        if mountType~='Floor' then
            sub= root:CreateRadio(text, getValue, setValue, tab)
        else
            sub= root:CreateCheckbox(text, getValue, setValue, tab)
        end

--二级，菜单
        WoWTools_MountMixin:Set_Mount_Sub_Options(sub, tab)
    end

    root:CreateDivider()
    WoWTools_ToolsMixin:OpenMenu(root, WoWTools_SpellMixin:GetName(spellID))
end




















local function Updata_MountJournal_FullUpdate(self)
    MountJournal_FullUpdate= function()--过滤，列表，Func
        if not MountJournal:IsVisible() then
            return
        end

        local btn= _G['MountJournalFilterButtonWoWTools']
        local spellIDs={}
        for mountType in pairs(btn.Type or {}) do
            for spellID in pairs(SaveLog()[mountType]) do
                spellIDs[spellID]=true
            end
        end
        local newDataProvider = CreateDataProvider()
        for index = 1, C_MountJournal.GetNumDisplayedMounts()  do
            local _, spellID, _, _, _, _, _, _, _, _, _, mountID   = C_MountJournal.GetDisplayedMountInfo(index)
            if mountID and spellID and spellIDs[spellID] then
                newDataProvider:Insert({index = index, mountID = mountID})
            end
        end

        MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition)

        if (not MountJournal.selectedSpellID) then
            MountJournal_Select(1)
        end
        MountJournal_UpdateMountDisplay()
    end

    MountJournal.FilterDropdown:Reset()
    WoWTools_DataMixin:Call('MountJournal_SetUnusableFilter', true)
    WoWTools_DataMixin:Call('MountJournal_FullUpdate', MountJournal)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true)

    self.ResetButton:SetShown(true)
end






--过滤，列表，菜单
local function Init_UI_List_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end


    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        self.Type={}
        for _, mountType in pairs(WoWTools_MountMixin.MountType) do
            self.Type[mountType]= true
        end

        C_MountJournal.SetAllSourceFilters(true)
        C_MountJournal.SetAllTypeFilters(true)

        Updata_MountJournal_FullUpdate(self)

        return MenuResponse.Refresh
    end)

    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        self:rest_type()
        self.ResetButton:Click()
        return MenuResponse.Refresh
    end)

    root:CreateDivider()
    for _, mountType in pairs(WoWTools_MountMixin.MountType) do
        root:CreateCheckbox(
            (WoWTools_MountMixin.TypeName[mountType] or mountType)
                ..' #'
                ..WoWTools_MountMixin:Get_Table_Num(mountType),
        function(data)
            return self.Type[data]
        end, function(data)

            self.Type[data]= not self.Type[data] and true or nil
            if self.Type[data] then
                C_MountJournal.SetAllSourceFilters(true)
                C_MountJournal.SetAllTypeFilters(true)
            end
            Updata_MountJournal_FullUpdate(self)
        end, mountType)
    end

    
    root:CreateDivider()
    WoWTools_ToolsMixin:OpenMenu(root, WoWTools_MountMixin.addName)
end


















local function Create_Button(frame)

    frame.WoWToolsButton= CreateFrame('DropdownButton', nil, frame, 'WoWToolsMenuTemplate')
    frame.WoWToolsButton:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga')
    frame.WoWToolsButton:SetPoint('BOTTOMRIGHT')
    frame.WoWToolsButton:SetupMenu(Init_Menu)

    frame.WoWToolsButton.Text= frame:CreateFontString(nil, 'BORDER', 'GameFontNormalSmall2') --WoWTools_LabelMixin:Create(frame.WoWToolsButton, {justifyH='RIGHT'})--nil, frame.name, nil,nil,nil,'RIGHT')
    frame.WoWToolsButton.Text:SetJustifyH('RIGHT')
    frame.WoWToolsButton.Text:SetPoint('RIGHT', frame, 0,-2)

    frame.WoWToolsButton:SetAlpha(0)
    frame.WoWToolsButton:SetScript('OnLeave', function(self)
        self:SetAlpha(0)
        GameTooltip:Hide()
    end)
    frame.WoWToolsButton:SetScript('OnEnter', function(self)
        local text= self.Text:GetText() or ''
        if text~='' then
            GameTooltip_ShowSimpleTooltip(GameTooltip,
            text,
            SimpleTooltipConstants.NoOverrideColor,
            SimpleTooltipConstants.DoNotWrapText,
            self,
            "ANCHOR_RIGHT"
        )
        end
        self:SetAlpha(1)
    end)
    frame:HookScript('OnLeave', function(self) self.WoWToolsButton:SetAlpha(0) end)
    frame:HookScript('OnEnter', function(self) self.WoWToolsButton:SetAlpha(1) end)


    function frame.WoWToolsButton:setmount_listtext()
        local text
        local spellID= self:GetParent().spellID
        for _, mountType in pairs(WoWTools_MountMixin.MountType) do
            local ID= SaveLog()[mountType][spellID]
            if ID then
                text= text and text..'|n' or ''
                if mountType=='Floor' and type(ID)=='table' then
                    local num=CountTable(ID)
                    if num >1 then
                        text=text..HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(num)
                    end
                end
                text= text..(WoWTools_MountMixin.TypeName[mountType] or mountType)
            end
        end
        self.Text:SetText(text or '')--提示， 文本
    end
end












--初始，坐骑界面
local function Init()
    WoWTools_DataMixin:Hook('MountJournal_InitMountButton',function(frame)--Blizzard_MountCollection.lua
        if not frame.spellID or not frame.mountID then
            if frame and frame.WoWToolsButton then
                frame.WoWToolsButton:SetShown(false)
                frame.WoWToolsButton.Text:SetText('')
            end
            return
        end

        if not frame.WoWToolsButton then
            Create_Button(frame)
        end

        frame.WoWToolsButton.mountID= frame.mountID
        frame.WoWToolsButton.spellID= frame.spellID

        frame.WoWToolsButton:setmount_listtext()
        frame.WoWToolsButton:SetShown(true)
    end)

    local btn= CreateFrame('DropdownButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'WowStyle1FilterDropdownTemplate')
    btn:SetPoint('BOTTOMLEFT', MountJournal.FilterDropdown, 'TOPLEFT', 0, 6)
    btn:SetText('Tools')

    MountJournal.FilterDropdown.ResetButton:HookScript('OnClick', function()
        if _G['MountJournalFilterButtonWoWTools'].ResetButton:IsShown() then
            _G['MountJournalFilterButtonWoWTools'].ResetButton:Click()
        end
    end)

    btn.MountJournal_FullUpdate= MountJournal_FullUpdate

    function btn:rest_type()
        self.Type={}
    end

--重置
    btn.ResetButton:SetScript('OnClick', function(self)
        local p= self:GetParent()
        MountJournal_FullUpdate= p.MountJournal_FullUpdate
        MountJournal.FilterDropdown:Reset()
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true)
        WoWTools_DataMixin:Call('MountJournal_SetUnusableFilter',true)
        WoWTools_DataMixin:Call('MountJournal_FullUpdate', MountJournal)
        self:Hide()
        p:rest_type()
    end)

    MountJournal.MountCount:ClearAllPoints()
    MountJournal.MountCount:SetPoint('BOTTOMRIGHT', MountJournalSearchBox, 'TOPRIGHT', 0, 4)

    btn:rest_type()
    btn:SetupMenu(Init_UI_List_Menu)--过滤，列表，菜单

    Init=function()end
end





function WoWTools_MountMixin:Init_MountJournal()
     if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
        Init()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Collections' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end
end

















