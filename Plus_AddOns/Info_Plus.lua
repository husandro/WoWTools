
local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end














--依赖，移过，提示
local function Find_AddOn_Dependencies(find, check)--依赖，提示
    local addonIndex= check:GetID()
    local tab={}
    for _, depName in pairs({C_AddOns.GetAddOnDependencies(addonIndex)}) do
        tab[depName]=true
    end
    for _, frame in pairs(AddonList.ScrollBox:GetFrames() or {}) do
        if frame.check then
            local show=false
            if find then
                local index= frame:GetID()
                if index== addonIndex or tab[C_AddOns.GetAddOnInfo(index)] then
                    show=true
                end
            end
            frame.check.select:SetShown(show)
        end
    end
end






--AddonList.lua
local function FormatProfilerPercent(pct)
	if pct >= 1 then
		return string.format("%.0f%%", pct);
	elseif pct >= 0.1 then
		return string.format("%.1f%%", pct);
	elseif pct >= 0.01 then
		return string.format("%.2f%%", pct);
	else
		return "0%";
	end
end






local function Create_Check(frame)
    frame.check=CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")

    frame.check:SetSize(20,20)--Fast，选项
    frame.check:SetPoint('RIGHT', frame.Status, 'LEFT')

    frame.check:SetScript('OnClick', function(self)
        Save().fast[self.name]= not Save().fast[self.name] and self:GetID() or nil
        WoWTools_AddOnsMixin:Init_Left_Buttons()
    end)


    frame.check.dep= frame:CreateLine()--依赖，提示
    frame.check.dep:Hide()
    frame.check.dep:SetColorTexture(1, 0.82, 0)
    frame.check.dep:SetStartPoint('BOTTOMLEFT', 55,2)
    frame.check.dep:SetEndPoint('BOTTOMRIGHT', -20,2)
    frame.check.dep:SetThickness(0.5)
    frame.check.dep:SetAlpha(0.2)

    frame.check.select= frame:CreateTexture(nil, 'OVERLAY')--光标，移过提示
    frame.check.select:SetAtlas('CreditsScreen-Selected')
    frame.check.select:SetAllPoints()
    frame.check.select:SetAlpha(0.3)
    frame.check.select:Hide()

    frame.check.Text:SetParent(frame)--索引
    frame.check.Text:ClearAllPoints()
    frame.check.Text:SetPoint('RIGHT', frame.check, 'LEFT')

    frame.check.memoFrame= CreateFrame("Frame", nil, frame.check)
    frame.check.memoFrame.Text= WoWTools_LabelMixin:Create(frame, {justifyH='RIGHT'})
    frame.check.memoFrame.Text:SetPoint('RIGHT', frame.check.Text, 'LEFT', -2, 0)
    frame.check.memoFrame:Hide()
    frame.check.memoFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 1) + elapsed
        if self.elapsed > 1 then
            self.elapsed = 0

            local menory= WoWTools_AddOnsMixin:Get_MenoryValue(self:GetID(), false)

            if menory and C_AddOnProfiler.GetApplicationMetric then
                local appVal = C_AddOnProfiler.GetApplicationMetric(1)
                local overallVal = C_AddOnProfiler.GetOverallMetric(1)
                local addonVal = C_AddOnProfiler.GetAddOnMetric(self.name, 1)
                local relativeTotal = appVal - overallVal + addonVal;
                if relativeTotal > 0 then
                    menory= FormatProfilerPercent(addonVal / relativeTotal * 100.0)..' '..menory
                end
            end

            self.Text:SetText(menory or '')
        end
    end)
    frame.check.memoFrame:SetScript('OnHide', function(self)
        self.Text:SetText('')
        self.elapsed=nil
    end)


    function frame.check:set_leave_alpha()
        local addonIndex= self:GetID()
        self:SetAlpha(Save().fast[self.name] and 1 or 0)
        self.Text:SetAlpha(C_AddOns.GetAddOnDependencies(addonIndex) and 0.3 or 1)
        local check= self:GetParent().Enabled
        check:SetAlpha(check:GetChecked() and 1 or 0)
        Find_AddOn_Dependencies(false, self)--依赖，移过，提示
    end
    function frame.check:set_enter_alpha()
        self:SetAlpha(1)
        self.Text:SetAlpha(1)
        self:GetParent().Enabled:SetAlpha(1)
        Find_AddOn_Dependencies(true, self)--依赖，移过，提示
    end


    frame.check:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_leave_alpha()
    end)
    frame.check:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AddOnsMixin.addName)
        local addonIndex= self:GetID()
        local icon= select(3, WoWTools_TextureMixin:IsAtlas( C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture") or C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas"))) or ''--Atlas or Texture
        GameTooltip:AddDoubleLine(
            format('%s%s |cnGREEN_FONT_COLOR:%d|r', icon, self.name or '', addonIndex),
            format('%s%s', WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, WoWTools_DataMixin.Icon.left)
        )
        GameTooltip:Show()
        self:set_enter_alpha()
    end)
    frame.Enabled:HookScript('OnLeave', function(self)
        self:GetParent().check:set_leave_alpha()
    end)
    frame.Enabled:HookScript('OnEnter', function(self)
        self:GetParent().check:set_enter_alpha()
    end)
    frame:HookScript('OnLeave', function(self)
        self.check:set_leave_alpha()
    end)
    frame:HookScript('OnEnter', function(self)
        self.check:set_enter_alpha()
    end)
end
















--列表，内容
local function Init_Set_List(self, addonIndex)
    if not addonIndex then
        if self.check then
            self.check:SetShown(false)
        end
        return
    end

    if not self.check then
        Create_Check(self)
    end

    local name, title= C_AddOns.GetAddOnInfo(addonIndex)
    local isChecked= Save().fast[name] and true or false
    if isChecked then
        Save().fast[name]= addonIndex
    end

    local iconTexture = C_AddOns.GetAddOnMetadata(addonIndex, "IconTexture")
    local iconAtlas = C_AddOns.GetAddOnMetadata(addonIndex, "IconAtlas")

    if not iconTexture and not iconAtlas then--去掉，没有图标，提示
       self.Title:SetText(title or name)
    end

    self.check:SetID(addonIndex)
    self.check:SetCheckedTexture(iconTexture or 'orderhalltalents-done-glow')
    self.check.name= name
    self.check.isDependencies= C_AddOns.GetAddOnDependencies(addonIndex) and true or false
    self.check:SetChecked(isChecked)--fast
    self.check:SetAlpha(isChecked and 1 or 0.1)

    self.check.Text:SetText(addonIndex or '')--索引
    self.check.memoFrame:SetID(addonIndex)
    self.check.memoFrame.name=name
    self.check.memoFrame:SetShown(C_AddOns.IsAddOnLoaded(addonIndex))


    if self.check.isDependencies then--依赖
        self.check.select:SetVertexColor(0,1,0)
        self.check.Text:SetTextColor(0.5,0.5,0.5)
        self.check.Text:SetAlpha(0.3)
        self.check.dep:SetShown(false)
    else
        self.check.select:SetVertexColor(1,1,1)
        self.check.Text:SetTextColor(1, 0.82, 0)
        self.check.Text:SetAlpha(1)
        self.check.dep:SetShown(true)
    end
    self.Status:SetAlpha(0.5)
    self.Enabled:SetAlpha(self.Enabled:GetChecked() and 1 or 0)
    self.check:SetShown(true)
end


















local function Init()
    if Save().disabledInfoPlus then
        return
    end

    WoWTools_DataMixin:Hook('AddonList_InitAddon', function(entry, treeNode)
        local addonIndex = treeNode:GetData().addonIndex
        Init_Set_List(entry, addonIndex)--列表，内容
    end)

    WoWTools_DataMixin:Hook('AddonTooltip_Update', function(self)
        --WoWTools_AddOnsMixin:Update_Usage()--更新，使用情况
        local index= self:GetID()
        local va= WoWTools_AddOnsMixin:Get_MenoryValue(index, true)
        if va then
            local iconTexture = C_AddOns.GetAddOnMetadata(index, "IconTexture")
            local iconAtlas = C_AddOns.GetAddOnMetadata(index, "IconAtlas")
            local icon= iconTexture and format('|T%s:0|t', iconTexture..'') or (iconAtlas and format('|A:%s:0:0|a', iconAtlas)) or ''
            AddonTooltip:AddLine(icon..va, 1,0.82,0)
            AddonTooltip:Show()
        end
    end)





--不禁用，本插件
    local btn= CreateFrame('Button', 'WoWToolsAddonsNotDisableButton', AddonList, 'WoWToolsButtonTemplate')
    btn:SetSize(18, 18)
    btn:SetPoint('LEFT', AddonList.DisableAllButton, 'RIGHT', 2,0)
    btn:SetAlpha(0.3)
    function btn:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '全部禁用' or DISABLE_ALL_ADDONS)
        GameTooltip:AddDoubleLine(format('%s|TInterface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga:0|t|cffff00ffWoW|r|cff00ff00Tools|r', WoWTools_DataMixin.onlyChinese and '启用' or ENABLE, ''), WoWTools_TextMixin:GetYesNo(Save().enableAllButtn))
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
        if Save().enableAllButtn then
            self:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        else
            self:SetNormalAtlas('talents-button-reset')
        end
    end
    btn:SetScript('OnClick', function(self)
        Save().enableAllButtn= not Save().enableAllButtn and true or nil
        self:set_icon()
        self:set_tooltips()
    end)
    btn:set_icon()

    AddonList.DisableAllButton:HookScript('OnClick', function()
        if Save().enableAllButtn then
            C_AddOns.EnableAddOn('WoWTools')
            WoWTools_DataMixin:Call(AddonList_Update)
        end
    end)
    


    





    
    btn= CreateFrame('Button', 'WoWToolsAddOnsRefeshButton', AddonList, 'WoWToolsButtonTemplate')
    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetSize(14, 14)
    btn.texture:SetAtlas('talents-button-undo')
    btn.texture:SetPoint('CENTER')

    btn:SetPoint('LEFT', AddonList.Dropdown, 'RIGHT')
    btn.tooltip= WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT

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
        WoWTools_DataMixin:Call(AddonList_Update)
    end)





--加载过期插件
    AddonList.ForceLoad:ClearAllPoints()
    AddonList.ForceLoad:SetPoint('LEFT', btn, 'RIGHT')
    for _, label in pairs({AddonList.ForceLoad:GetRegions()}) do
        local text= label:GetObjectType()=="FontString" and label:GetText()
        if text and (text==ADDON_FORCE_LOAD or text=='加载过期插件') then
            label:SetText('')
            label:ClearAllPoints()
            break
        end
    end
    AddonList.ForceLoad:HookScript('OnLeave', function() GameTooltip:Hide() end)
    AddonList.ForceLoad:HookScript('OnEnter', function(f)
        GameTooltip:SetOwner(f, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '加载过期插件' or ADDON_FORCE_LOAD)
        GameTooltip:Show()
    end)

    btn= WoWTools_ButtonMixin:Cbtn(AddonList, {
        size=22,
        atlas='NPE_ArrowDown',
        name='WoWToolsFactionListExpandButton'
    })


    btn=WoWTools_ButtonMixin:Cbtn(AddonList, {
		size=22,
		atlas='NPE_ArrowUp',
		name='WoWToolsFactionListCollapsedButton',
	})

    AddonList.SearchBox:ClearAllPoints()
    AddonList.SearchBox:SetPoint('LEFT', btn, 'RIGHT', 6, 0)
    AddonList.SearchBox:SetPoint('LEFT', -36, 0)













    Init=function()end
end










function WoWTools_AddOnsMixin:Init_Info_Plus()
    Init()
end