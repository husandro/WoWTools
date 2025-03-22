
local id, e= ...
local function Save()
    return WoWTools_AddOnsMixin.Save
end
local NewButton











--新建按钮
local function Init()
    NewButton= WoWTools_ButtonMixin:Cbtn(AddonList, {size=26, atlas='communities-chat-icon-plus'})
    WoWTools_AddOnsMixin.NewButton= NewButton


    NewButton:SetPoint('TOPRIGHT', -2, -28)
    NewButton:SetScript('OnLeave', GameTooltip_Hide)
    NewButton:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName , WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '创建一个新配置方案' or CREATE_NEW_COMPACT_UNIT_FRAME_PROFILE)
        GameTooltip:AddLine(' ')

        WoWTools_AddOnsMixin:Show_Select_Tooltip()--提示，当前，选中

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine('|A:communities-chat-icon-plus:0:0|a'..(WoWTools_Mixin.onlyChinese and '新建' or NEW)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    NewButton:SetScript('OnClick',function(self)
        WoWTools_TextureMixin:Edit_Text_Icon(self, {
            text= WoWTools_Mixin.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET,
            texture= 0,
            SetValue=function(newIcon, newText)
                local name= '|T'..(newIcon or 0)..':0|t'..newText
                if Save().buttons[name] then
                    print(name, '|cnRED_FONT_COLOR:',WoWTools_Mixin.onlyChinese and '替换' or REPLACE)
                end
                Save().buttons[name]= select(4 ,WoWTools_AddOnsMixin:Get_AddListInfo())
                WoWTools_Mixin:Call(AddonList_Update)
            end
        })
    end)











    NewButton.Text= WoWTools_LabelMixin:Create(NewButton)--已选中，数量
    NewButton.Text:SetPoint('TOPLEFT', 0, 6)
    --NewButton.Text:SetPoint('BOTTOMRIGHT', NewButton, 'LEFT',0, 1)
    NewButton.Text:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    NewButton.Text:SetScript('OnEnter', function (self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', WoWTools_Mixin.onlyChinese and '已选中', 'Selected')
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)







    NewButton.Text2=WoWTools_LabelMixin:Create(NewButton, {justifyH='RIGHT'})--总内存
    NewButton.Text2:SetPoint('BOTTOMRIGHT', -5, -22)
    --NewButton.Text2:SetPoint('TOPRIGHT', NewButton, 'LEFT', 0, -1)
    NewButton.Text2:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    NewButton.Text2:SetScript('OnEnter', function(self)
        WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')

        local newTab={}
        local need, load, allMomo= 0, 0, 0
        for index=1, C_AddOns.GetNumAddOns() do
            local isLoaded= C_AddOns.IsAddOnLoaded(index)
            local dema= select(2, C_AddOns.IsAddOnLoadable(index))=='DEMAND_LOADED'
            if isLoaded or dema then--已加载, 带加载
                local title = select(2, C_AddOns.GetAddOnInfo(index))
                local iconTexture = C_AddOns.GetAddOnMetadata(index, "IconTexture")
                local iconAtlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
                local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or '    '
                local col= dema and '|cffff00ff' or '|cnGREEN_FONT_COLOR:'
                local memo, value= WoWTools_AddOnsMixin:Get_MenoryValue(index, false)
                memo= memo and ' |cnRED_FONT_COLOR:'..memo..'|r' or ''
                table.insert(newTab, {
                    left=icon..col..title..memo,
                    right=dema and col..WoWTools_TextMixin:CN(_G['ADDON_DEMAND_LOADED']) or ' ',
                    memo=value or 0
                })
                allMomo= allMomo+ (value or 0)
            end

            if dema then
                need= need+1
            elseif isLoaded then
                load= load+1
            end
        end

        table.sort(newTab, function(a, b) return a.memo<b.memo end)
        for _, tab in pairs(newTab) do
            local left= tab.left
            if tab.memo>0 and allMomo>0 then
                local percent= tab.memo/allMomo*100
                if percent>1 then
                    left= format('%s |cffffffff%i%%|r', left, tab.memo/allMomo*100)
                end
            end
           GameTooltip:AddDoubleLine(left, tab.right)
        end

        local allMemberText=''--内存
        if allMomo>0 then
            GameTooltip:AddLine(' ')
            if allMomo<1000 then
                allMemberText= format(' |cnRED_FONT_COLOR:%0.2fKB|r', allMomo)
            else
                allMemberText=format(' |cnRED_FONT_COLOR:%0.2fMB|r', allMomo/1000)
            end
        end

        GameTooltip:AddDoubleLine(
            load..' |cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '已加载' or LOAD_ADDON)..'|r |cnRED_FONT_COLOR:'..allMemberText,
            '|cffff00ff'..need..' '..(WoWTools_Mixin.onlyChinese and '只能按需加载' or ADDON_DEMAND_LOADED)
        )

        GameTooltip:Show()

        self:SetAlpha(0.3)
    end)






    NewButton.Text3=WoWTools_LabelMixin:Create(NewButton, {justifyH='RIGHT'})--总已加载，数量
    NewButton.Text3:SetPoint('RIGHT', NewButton.Text2, 'LEFT', -8, 0)
    NewButton.Text3:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    NewButton.Text3:SetScript('OnEnter', function (self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(format('|cnGREEN_FONT_COLOR:%s', WoWTools_Mixin.onlyChinese and '已加载', LOAD_ADDON), format('|cffff00ff+%s', WoWTools_Mixin.onlyChinese and '只能按需加载' or ADDON_DEMAND_LOADED))
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)






    NewButton:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 3) +elapsed
        if self.elapsed>3 or UnitAffectingCombat('player') then
            self.elapsed=0
            WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
            local value, text= 0, ''
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.IsAddOnLoaded(i) then
                    value= value+ (GetAddOnMemoryUsage(i) or 0)
                end
            end
            if value>0 then
                if value<1000 then
                    text= format('%iKB', value)
                else
                    text= format('%0.2fMB', value/1000)
                end
            end
            self.Text2:SetText(text)
        end
    end)
    NewButton:SetShown(not Save().hideRightList)
end



















--不禁用，本插件
local function Init_NotDisabled_Button()
    local btn= WoWTools_ButtonMixin:Cbtn(AddonList, {size=18})
    btn:SetPoint('LEFT', AddonList.DisableAllButton, 'RIGHT', 2,0)
    btn:SetAlpha(0.3)
    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS)
        GameTooltip:AddDoubleLine(format('%s|TInterface\\AddOns\\WoWTools\\Sesource\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r', WoWTools_Mixin.onlyChinese and '启用' or ENABLE, ''), WoWTools_TextMixin:GetYesNo(Save().enableAllButtn))
        GameTooltip:Show()
        self:SetAlpha(1)
    end
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.3)
        AddonList.DisableAllButton:SetAlpha(1)
        if self.findFrame then
            if self.findFrame.check then
                self.findFrame.check:set_leave_alpha()
            end
            self.findFrame=nil
        end
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        AddonList.DisableAllButton:SetAlpha(0.3)
        if not self.index then
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.GetAddOnInfo(i)== 'WoWTools' then
                    self.index=i
                    break
                end
            end
        end
        if self.index then
            AddonList.ScrollBox:ScrollToElementDataIndex(self.index)
            for index, frame in pairs( AddonList.ScrollBox:GetFrames() or {}) do
                if frame:GetID()==index then
                    if frame.check then
                        frame.check:set_enter_alpha()
                        self.findFrame=frame
                    end
                    break
                end
            end
        end
    end)
    function btn:set_icon()
        self:SetNormalAtlas(Save().enableAllButtn and WoWTools_DataMixin.Icon.icon or WoWTools_DataMixin.Icon.disabled)
    end
    btn:SetScript('OnClick', function(self)
        Save().enableAllButtn= not Save().enableAllButtn and true or nil
        self:set_icon()
        self:set_tooltips()
    end)

    AddonList.DisableAllButton:HookScript('OnClick', function()
        if Save().enableAllButtn then
            C_AddOns.EnableAddOn(id)
            WoWTools_Mixin:Call(AddonList_Update)
        end
    end)
    btn:set_icon()
end













local function Init_Refresh_Button()
    local btn= WoWTools_ButtonMixin:Cbtn(NewButton, {atlas='talents-button-undo', size=18})
    btn:SetPoint('LEFT', AddonList.Dropdown, 'RIGHT', 2,0)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '刷新' or REFRESH)
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function()
        if AddonList.startStatus then
            for i=1,C_AddOns.GetNumAddOns() do
                if AddonList.startStatus[i] then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
        else
            for i=1, C_AddOns.GetNumAddOns() do
                if C_AddOns.IsAddOnLoaded(i) then
                    C_AddOns.EnableAddOn(i)
                else
                    C_AddOns.DisableAddOn(i)
                end
            end
        end
        WoWTools_Mixin:Call(AddonList_Update)
    end)
end





function WoWTools_AddOnsMixin:Init_NewButton_Button()
    do
        Init()
    end
    Init_Refresh_Button()
    Init_NotDisabled_Button()

    local label= WoWTools_LabelMixin:Create(NewButton)--插件，总数
    label:SetPoint('LEFT',AddonListEnableAllButton, 3,0)
    label:SetText(C_AddOns.GetNumAddOns())

end