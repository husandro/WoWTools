
local Frame, List


local function Save()
    return WoWToolsSave['Plus_Gossip']
end

local function PlayerDataSave()
    return WoWToolsPlayerDate['GossipTextIcon']
end






local function Chat_Menu(_, root)
    local tab= C_GossipInfo.GetOptions() or {}
    table.sort(tab, function(a, b) return a.orderIndex< b.orderIndex end)

    local find={}
    for _, info in pairs(tab) do
        if info.gossipOptionID then
            local set= List:get_saved_all_date(info.gossipOptionID) or {}
            local name= set.name or info.name or ''
            local icon= select(3, WoWTools_TextureMixin:IsAtlas(set.icon or info.icon)) or '     '
            local col= (set.hex and set.hex~='') and '|c'..set.hex
                or (WoWTools_GossipMixin:Get_GossipData()[info.gossipOptionID] and '|cnGREEN_FONT_COLOR:')
                or (PlayerDataSave()[info.gossipOptionID] and '|cffff00ff')
                or ''

            root:CreateCheckbox(
                icon..col..name..info.gossipOptionID,
            function(data)
                return data.gossipOptionID== List:get_gossipID()
            end, function(data)
                List:set_date(data.gossipOptionID)
            end, {gossipOptionID=info.gossipOptionID})

            if not PlayerDataSave()[info.gossipOptionID] then
                table.insert(find, {gossipID=info.gossipOptionID, name=info.name})
            end
        end
    end

    local num=#find
    if num>0 then
        WoWTools_MenuMixin:SetScrollMode(root)
        root:CreateDivider()
        root:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '全部添加' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, ADD))..' '..num,
        function(data)
            for _, info in pairs(data.find) do
                if not PlayerDataSave()[info.gossipID] then
                    PlayerDataSave()[info.gossipID]= {name=info.name}
                end
            end
            List:set_list()
        end, {find=find})

    elseif #tab==0 then
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '无' or NONE)
    end
end





































--自定义，对话，文本，放在主菜单，前
local function Init(isShow)
    if isShow==false then
        return
    end

    Frame= CreateFrame('Frame', 'WoWToolsGossipTextIconOptionsFrame', UIParent)--, 'DialogBorderTemplate')--'ButtonFrameTemplate')
    tinsert (UISpecialFrames, 'WoWToolsGossipTextIconOptionsFrame')
    Frame:Hide()

    List = CreateFrame("Frame", 'WoWToolsGossipTextIconOptionsList', Frame, "WowScrollBoxList")



    local border= CreateFrame('Frame', nil, Frame,'DialogBorderTemplate')
    local Header= CreateFrame('Frame', nil, Frame, 'DialogHeaderTemplate')--DialogHeaderMixin
    Header:Setup('|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '对话替换' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DIALOG_VOLUME, REPLACE)))
    Frame.CloseButton=CreateFrame('Button', nil, Frame, 'UIPanelCloseButton')
    Frame.CloseButton:SetPoint('TOPRIGHT')
    Frame.CloseButton:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
    WoWTools_TextureMixin:SetButton(Frame.CloseButton)


    WoWTools_TextureMixin:SetFrame(border, {alpha=0.5})
    WoWTools_TextureMixin:SetFrame(Header, {alpha=0.7})










    List:SetPoint("TOPLEFT", 12, -30)
    List:SetPoint("BOTTOMRIGHT", -310, 6)

    List.bg= List:CreateTexture(nil, 'BACKGROUND')
    List.bg:SetPoint('TOPLEFT', -35, 80)
    List.bg:SetPoint('BOTTOMRIGHT',35, -72)
    List.bg:SetAtlas('QuestBG-Trading-Post')

    List.ScrollBar= CreateFrame("EventFrame", nil, Frame, "MinimalScrollBar")
    List.ScrollBar:SetPoint("TOPLEFT", List, "TOPRIGHT", 8,0)
    List.ScrollBar:SetPoint("BOTTOMLEFT", List, "BOTTOMRIGHT",8,12)
    WoWTools_TextureMixin:SetScrollBar(List)

    List.view = CreateScrollBoxListLinearView()
    ScrollUtil.InitScrollBoxListWithScrollBar(List, List.ScrollBar, List.view)

    List.view:SetElementInitializer("GossipTitleButtonTemplate", function(btn, info)-- UIPanelButtonTemplate GossipTitleButtonTemplate
        btn.gossipID= info.gossipID
        btn.spellID= info.spellID
        if not btn.delete then
            btn:SetScript("OnClick", function(self)
                List:set_date(self.gossipID)
            end)
            btn:SetScript('OnLeave', function(self) self.delete:SetAlpha(0) end)
            btn:SetScript('OnEnter', function(self) self.delete:SetAlpha(1) end)

            btn.delete= WoWTools_ButtonMixin:Cbtn(btn, {size=18, atlas='common-icon-redx'})
            btn.delete:SetPoint('RIGHT')
            btn.delete:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
            btn.delete:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
            btn.delete:SetScript('OnClick', function(self)
                List:delete_gossip(self:GetParent().gossipID)
            end)
            btn.delete:SetAlpha(0)
            btn:GetFontString():SetPoint('RIGHT')

        end

        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(info.icon)
        if isAtlas then
            btn.Icon:SetAtlas(texture)
        else
            btn.Icon:SetTexture(texture or 0)
        end
        if Save().Gossip_Text_Icon_cnFont then
            btn:GetFontString():SetFont('Fonts\\ARHei.ttf', 14)
        else
            btn:GetFontString():SetFontObject('QuestFontLeft')
        end
        btn:SetText((info.hex and '|c'..info.hex or '')..(info.name or ''))
        btn:Resize()
    end)

    function List:SortOrder(leftInfo, rightInfo)
        if GossipFrame:IsShown() then
            return leftInfo.orderIndex < rightInfo.orderIndex;
        else
            return leftInfo.gossipID < rightInfo.gossipID;
        end
    end

    function List:set_list()
        if self:IsShown() then
            local n=0
            local gossipNum=0--GossipFrame 有多少对话
            self.dataProvider = CreateDataProvider()
            if GossipFrame:IsShown() then
                local tabs={}
                for _, info in pairs(C_GossipInfo.GetOptions() or {}) do
                    local data= PlayerDataSave()[info.gossipOptionID]
                    if data then
                        data.gossipOptionID= info.gossipOptionID
                        data.orderIndex= info.orderIndex
                        data.name= data.name or info.name or info.gossipOptionID
                        table.insert(tabs, data)
                    else
                        gossipNum= gossipNum +1
                    end
                end
                table.sort(tabs, function(a, b) return a.orderIndex< b.orderIndex end)

                for _, data in pairs(tabs) do
                    self.dataProvider:Insert({gossipID=data.gossipOptionID, icon=data.icon, name=data.name, hex=data.hex, spellID=data.spellID})
                end
--GossipFrame 有多少已设置
                self.chat.Text:SetFormattedText('%s%d',
                    gossipNum>0 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e', 
                    gossipNum
                )

                for _ in pairs(PlayerDataSave()) do
                    n=n+1
                end
            else
                for gossipID, data in pairs(PlayerDataSave()) do
                    self.dataProvider:Insert({gossipID=gossipID, icon=data.icon, name=data.name or gossipID, hex=data.hex})
                    n=n+1
                end
                self.chat.Text:SetText('')
            end
            self.view:SetDataProvider(self.dataProvider,  ScrollBoxConstants.RetainScrollPosition)

            self:FullUpdate()--FullUpdateInternal() FullUpdate()
            self.NumLabel:SetText(n)
        else
            self.dataProvider= nil
        end
    end


    function List:update_list()
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames() or {}) do
            if btn.gossipID==self.gossipID then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
        local tab={}
        for _, data in pairs(C_GossipInfo.GetOptions() or {}) do
            tab[data.orderIndex]= data.gossipOptionID
        end
        if not GossipFrame.GreetingPanel.ScrollBox:GetView() then
            return
        end
        for _, b in pairs(GossipFrame.GreetingPanel.ScrollBox:GetFrames() or {}) do
            if tab[b:GetID()]==self.gossipID then
                b:LockHighlight()
            else
                b:UnlockHighlight()
            end
        end
    end


    function List:get_gossipID()--取得gossipID
        return self.ID:GetNumber() or 0
    end
    function List:get_name()--取得，名称
        local name= self.Name:GetText()
        if name=='' then
            return
        else
            return name
        end
    end
    function List:get_icon()--设置，图片
        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(self.Icon:GetText())
        return texture, isAtlas
    end
    function List:set_texture_size()--图片，大小
        self.Texture:SetSize(Save().Gossip_Text_Icon_Size, Save().Gossip_Text_Icon_Size)
    end

    function List:set_all()
        local num= self:get_gossipID()
        local name= self:get_name()
        local icon= self:get_icon()
        local info= PlayerDataSave()[num]
        if info then
            self.gossipID=num
        else
            self.gossipID=nil
        end

        local hex = self.Color.hex or 'ff000000'
        if info then
            if info.icon==icon and info.name==name and (info.hex==hex or (not info.hex and hex=='ff000000')) then--一样，数据
                self.Add:SetNormalAtlas('VignetteEvent')
                self.Add.tooltip=WoWTools_DataMixin.onlyChinese and '已存在' or UPDATE
            else--需要，更新，数据
                self.Add:SetNormalAtlas('common-icon-checkmark')
                self.Add.tooltip=WoWTools_DataMixin.onlyChinese and '需要更新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, UPDATE)
            end
        else
            self.Add:SetNormalAtlas('bags-icon-addslots')
            self.Add.tooltip=WoWTools_DataMixin.onlyChinese and '添加' or ADD
        end
        self.Delete:SetShown(self.gossipID and true or false)--显示/隐藏，删除按钮
        self.Add:SetShown(num>0 and (name or icon or hex~='ff000000') and true or false)--显示/隐藏，添加按钮
    end

--设置，颜色，颜色按钮，
    function List:set_color(r, g, b, hex)
        if hex and hex~='' then
            r,g,b= WoWTools_ColorMixin:HEXtoRGB(hex)
        elseif r and g and b then
            hex= WoWTools_ColorMixin:RGBtoHEX(r,g,b)
        else
            r,g,b,hex= 0,0,0, 'ff000000'
        end
        self.Color.r, self.Color.g, self.Color.b, self.Color.hex= r, g, b, hex
        self.Color.Color:SetVertexColor(r,g,b,1)
        self.Name:SetTextColor(r,g,b)
        self:set_all()
    end

    function List:get_saved_all_date(gossipID)
        return PlayerDataSave()[gossipID] or WoWTools_GossipMixin:Get_GossipData()[gossipID]
    end
--读取，已保存数据
    function List:set_date(gossipID)
        if not gossipID then
            return
        end
        local name,icon,hex, name2, info
        for _, info2 in pairs(C_GossipInfo.GetOptions() or {}) do
            if info2 and info2.gossipOptionID==gossipID then
                name2= info2.name
                break
            end
        end
        info= self:get_saved_all_date(gossipID)
        if info then
            name, icon, hex= info.name, info.icon, info.hex
        end
        name= name or name2 or Save().gossipOption[gossipID] or ''
        self.ID:SetNumber(gossipID)
        self.Name:SetText(name)
        self.Icon:SetText(icon or '')
        self:set_color(nil, nil, nil, hex)
        self.GossipText:SetText(name2 or name)
    end


    function List:add_gossip()
        if not self.Add:IsShown() then
            return
        end
        local num= self:get_gossipID()
        local texture = self:get_icon()
        local name= self:get_name()

        local r= self.Color.r or 1
        local g= self.Color.g or 1
        local b= self.Color.b or 1
        local hex= self.Color.hex
        if not hex and r~=1 and g~=1 and r~=1 then
            hex= WoWTools_ColorMixin:RGBtoHEX(r, g, b, 1)
        end
        if hex=='ff000000' then
            hex=nil
        end
        if num and (name or texture or hex) then
            PlayerDataSave()[num]= {
                name= name,
                icon= texture,
                hex= hex,
            }
            self.gossipID= num
            WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
            self:set_list()
        end

        self:set_all()
    end

    function List:delete_gossip(gossipID)
        if gossipID and PlayerDataSave()[gossipID] then
            local info=PlayerDataSave()[gossipID]
            PlayerDataSave()[gossipID]=nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)..'|r|n', gossipID, info.icon, info.hex, info.name)
            self:set_list()
            WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        end
        self:set_all()
    end


    List.ID= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    List.ID:SetSize(234, 22)
    List.ID:SetNumeric(true)
    List.ID:SetPoint('TOPLEFT', List, 'TOPRIGHT', 25, -40)
    List.ID:SetAutoFocus(false)
    List.ID.Instructions:SetText('gossipOptionID '..(WoWTools_DataMixin.onlyChinese and '数字' or 'Numeri'))
    List.ID.searchIcon:SetAtlas('auctionhouse-icon-favorite')
    List.ID:HookScript("OnTextChanged", function(self)
        List:set_all()
        List:update_list()
    end)

    List.Name= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    List.Name:SetPoint('TOPLEFT', List.ID, 'BOTTOMLEFT')
    List.Name:SetSize(250, 22)
    List.Name:SetAutoFocus(false)
    List.Name:ClearFocus()
    List.Name.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '替换文本', format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REPLACE, LOCALE_TEXT_LABEL))
    List.Name.searchIcon:SetAtlas('NPE_ArrowRight')
    List.Name:HookScript("OnTextChanged", function() List:set_all() end)

    List.Name:SetFontObject('QuestFontLeft')
    List.Name.r, List.Name.g, List.Name.b= List.Name:GetTextColor()
    List.Name.texture=List.Name:CreateTexture(nil, 'BORDER')
    List.Name.texture:SetAtlas('QuestBG-Parchment')
    List.Name.texture:SetPoint('TOPLEFT', 8,-4)
    List.Name.texture:SetPoint('BOTTOMRIGHT', -18, 3)
    List.Name.texture:SetTexCoord(0.23243, 0.24698, 0.13550, 0.12206)
    --List.Name.Middle:SetAtlas('QuestBG-Parchment')

    List.Icon= CreateFrame("EditBox", nil, Frame, 'SearchBoxTemplate')
    List.Icon:SetPoint('TOPLEFT', List.Name, 'BOTTOMLEFT')
    List.Icon:SetSize(250, 22)
    List.Icon:SetAutoFocus(false)
    List.Icon:ClearFocus()
    List.Icon.Instructions:SetText((WoWTools_DataMixin.onlyChinese and '图标' or EMBLEM_SYMBOL)..' Texture or Atlas')
    List.Icon.searchIcon:SetAtlas('NPE_ArrowRight')
    List.Icon:HookScript("OnTextChanged", function()
        local texture, isAtlas = List:get_icon()
        if isAtlas and texture then
            List.Texture:SetAtlas(texture)
        else
            List.Texture:SetTexture(texture or 0)
        end
        List:set_all()
    end)

    --设置，TAB键
    List.tabGroup= CreateTabGroup(List.ID, List.Name, List.Icon)
    List.ID:SetScript('OnTabPressed', function() List.tabGroup:OnTabPressed() end)
    List.Icon:SetScript('OnTabPressed', function() List.tabGroup:OnTabPressed() end)
    List.Name:SetScript('OnTabPressed', function() List.tabGroup:OnTabPressed() end)

    --设置，Enter键
    List.ID:SetScript('OnEnterPressed', function() List:add_gossip() end)
    List.Icon:SetScript('OnEnterPressed', function() List:add_gossip() end)
    List.Name:SetScript('OnEnterPressed', function() List:add_gossip() end)



    --图标
    List.Texture= Frame:CreateTexture()
    List.Texture:SetPoint('BOTTOM', List.ID, 'TOP' , 0, 2)
    List:set_texture_size()

    --对话，内容
    List.GossipText= WoWTools_LabelMixin:Create(Frame)
    List.GossipText:SetPoint('TOP', List.Icon, 'BOTTOM', 0,-2)


    --查找，图标，按钮
    List.FindIcon= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='mechagon-projects'})
    List.FindIcon:SetPoint('LEFT', List.Icon, 'RIGHT', 2,0)
    List.FindIcon:SetScript('OnLeave', GameTooltip_Hide)
    List.FindIcon:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选择图标' or COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS)
        if not _G['TAV_CoreFrame'] then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('|cnRED_FONT_COLOR:Texture Atlas Viewer', WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)
        end
        GameTooltip:Show()
    end)


    List.FindIcon:SetScript('OnClick', function(f)
       f.frame:SetShown(not f.frame:IsShown())
    end)


    List.FindIcon.frame= CreateFrame('Frame', 'WoWToolsGossipTextIconFrame_IconSelectorPopupFrame', Frame, 'IconSelectorPopupFrameTemplate')
    List.FindIcon.frame.IconSelector:SetPoint('BOTTOMRIGHT', -10, 36)
    WoWTools_MoveMixin:Setup(List.FindIcon.frame, {notMove=true, setSize=true, minW=524, minH=276, maxW=524,
    sizeRestFunc=function()
        List.FindIcon.frame:SetSize(524, 495)
    end})

    List.FindIcon.frame:Hide()
    List.FindIcon.frame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(WoWTools_DataMixin.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)
    List.FindIcon.frame.BorderBox.IconSelectorEditBox:SetAutoFocus(false)
    List.FindIcon.frame:SetScript('OnShow', function(self)
        IconSelectorPopupFrameTemplateMixin.OnShow(self);
        if self.iconDataProvider==nil then
            self.iconDataProvider= CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
        end
        self:SetIconFilter(self:GetIconFilter() or IconSelectorPopupFrameIconFilterTypes.All);
        --self.BorderBox.IconTypeDropDown:SetSelectedValue(self.BorderBox.IconTypeDropDown:GetSelectedValue() or IconSelectorPopupFrameIconFilterTypes.All);
        self:Update()
        self.BorderBox.IconSelectorEditBox:OnTextChanged()
        local function OnIconSelected(_, icon)
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);
            self.BorderBox.IconSelectorEditBox:SetText(icon)
        end
        self.IconSelector:SetSelectedCallback(OnIconSelected);
    end)

    List.FindIcon.frame:SetScript('OnHide', function(self)
        IconSelectorPopupFrameTemplateMixin.OnHide(self);
        self.iconDataProvider:Release();
        self.iconDataProvider = nil;
    end)
    function List.FindIcon.frame:Update()
        local texture
        texture= List:get_icon()
        if texture then
            texture=tonumber(texture)
        end
        if not texture then
            self.origName = "";
            self.BorderBox.IconSelectorEditBox:SetText("");
            local initialIndex = 1;
            self.IconSelector:SetSelectedIndex(initialIndex);
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
        else
            self.BorderBox.IconSelectorEditBox:SetText(texture);
            self.BorderBox.IconSelectorEditBox:HighlightText();
            self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(texture));
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(texture);
        end
        local getSelection = GenerateClosure(self.GetIconByIndex, self);
        local getNumSelections = GenerateClosure(self.GetNumIcons, self);
        self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
        self.IconSelector:ScrollToSelectedIndex();
        self:SetSelectedIconText();
    end
    function List.FindIcon.frame:OkayButton_OnClick()
        IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
        local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture();
        List.Icon:SetText(iconTexture or '')
        local gossip= List:get_gossipID()
        if gossip==0 then
            List.ID:SetFocus()
        else
            List.Name:SetFocus()
            List:add_gossip()
        end
    end



    if _G['TAV_CoreFrame'] then--查找，图标，按钮， Texture Atlas Viewer， 插件
        List.tav= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='communities-icon-searchmagnifyingglass'})
        List.tav:SetPoint('TOP', List.FindIcon, 'BOTTOM', 0, -2)
        List.tav:SetScript('OnClick', function() _G['TAV_CoreFrame']:SetShown(not _G['TAV_CoreFrame']:IsShown()) end)
        List.tav:SetScript('OnLeave', GameTooltip_Hide)
        List.tav:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine('Texture Atlas Viewer')
            GameTooltip:Show()
        end)
    end

    --颜色
    List.Color= CreateFrame('Button', nil, Frame, 'ColorSwatchTemplate')--ColorSwatchMixin
    List.Color:SetPoint('LEFT', List.ID, 'RIGHT', 2,0)
    List.Color:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    List.Color:SetScript('OnLeave', GameTooltip_Hide)
    function List.Color:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName , WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine((self.hex and format('|c%s|r', self.hex) or '')..(WoWTools_DataMixin.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), WoWTools_DataMixin.Icon.left)
        local col= (not self.hex or self.hex=='ff000000') and '|cff9e9e9e' or ''
        GameTooltip:AddDoubleLine(format('%s%s', col, WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT), WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end
    List.Color:SetScript('OnEnter', List.Color.set_tooltips)
    List.Color:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            local R=self.r or 1
            local G=self.g or 1
            local B=self.b or 1
            WoWTools_ColorMixin:ShowColorFrame(R, G, B, nil, function()--swatchFunc
                local r,g,b = WoWTools_ColorMixin:Get_ColorFrameRGBA()
                List:set_color(r,g,b)
                List:add_gossip()
            end, function()--cancelFunc
                List:set_color(R,G,B)
                List:add_gossip()
            end)
        else
            List:set_color(0,0,0)
            List:add_gossip()
        end
        self:set_tooltips()
    end)

    --添加
    List.Add= WoWTools_ButtonMixin:Cbtn(Frame, {size=22})
    List.Add:SetPoint('LEFT', List.Color, 'RIGHT', 2, 0)
    List.Add:SetScript('OnLeave', GameTooltip_Hide)
    List.Add:SetScript('OnEnter', function(self)
        local num= List:get_gossipID()
        local texture = List:get_icon()
        local name= List:get_name()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName , WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(self.tooltip)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('gossipOptionID', num)
        GameTooltip:AddDoubleLine('name', name)
        GameTooltip:AddDoubleLine('icon', texture)
        GameTooltip:AddDoubleLine('hex', List.Color.hex)
        GameTooltip:Show()
    end)
    List.Add:SetScript('OnClick', function()
        List:add_gossip()
    end)

    --删除，内容
    List.Delete= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='common-icon-redx'})
    List.Delete:SetPoint('BOTTOM', List.Add, 'TOP', 0,2)
    List.Delete:Hide()
    List.Delete:SetScript('OnLeave', GameTooltip_Hide)
    List.Delete:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '删除' or DELETE, List.gossipID)
        GameTooltip:Show()
    end)
    List.Delete:SetScript('OnClick', function()
        List:delete_gossip(List.gossipID)
    end)

    --删除，玩家数据
    List.DeleteAllPlayerData=WoWTools_ButtonMixin:Cbtn(Frame, {
        size=22,
        atlas='bags-button-autosort-up',
        name='WoWToolsGossipDeleteAllPlayerDataButton'
    })
    List.DeleteAllPlayerData:SetPoint('BOTTOMLEFT', List, 'TOPLEFT', -3, 2)
    List.DeleteAllPlayerData:SetScript('OnLeave', GameTooltip_Hide)
    List.DeleteAllPlayerData:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
        GameTooltip:Show()
    end)

    --[[StaticPopupDialogs['WoWTools_Gossip_Delete_All_Player_Data']={
        text=WoWTools_DataMixin.addName..' '..WoWTools_GossipMixin.addName..'|n|n|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        button2= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
        OnAccept = function()
            WoWToolsPlayerDate['GossipTextIcon']= {}
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL, format('|cnGREEN_FONT_COLOR:%s|r', WoWTools_DataMixin.onlyChinese and '完成' or DONE))
            List:set_list()
        end,
    }]]
    List.DeleteAllPlayerData:SetScript('OnClick', function()
        --StaticPopup_Show('WoWTools_Gossip_Delete_All_Player_Data')
        StaticPopup_Show('WoWTools_OK',
        WoWTools_DataMixin.addName..' '..WoWTools_GossipMixin.addName..'|n|n|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        nil,
        {SetValue=function()
            WoWToolsPlayerDate['GossipTextIcon']= {}
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL, format('|cnGREEN_FONT_COLOR:%s|r', WoWTools_DataMixin.onlyChinese and '完成' or DONE))
            List:set_list()
        end})
    end)

    --自定义，对话，文本，数量
    List.NumLabel= WoWTools_LabelMixin:Create(Frame)
    List.NumLabel:SetPoint('LEFT', List.DeleteAllPlayerData, 'RIGHT')




    --图标大小, 设置
    List.Size= WoWTools_PanelMixin:Slider(Frame, {min=8, max=72, value=Save().Gossip_Text_Icon_Size, setp=1, color=false, w=255,
        text= WoWTools_DataMixin.onlyChinese and '图标大小' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        func=function(frame, value)
            value= math.modf(value)
            value= value==0 and 0 or value
            frame:SetValue(value)
            frame.Text:SetText(value)
            Save().Gossip_Text_Icon_Size= value
            List:set_texture_size()
            local icon= List.Texture:GetTexture()--设置，图片，如果没有
            if not icon or icon==0 then
                List.Texture:SetTexture(3847780)
            end
            WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
    end})
    List.Size:SetPoint('TOP', List.Icon, 'BOTTOM', 0, -36)



    --修改，为中文，字体
    --if LOCALE_zhCN or LOCALE_zhTW then
      --  Save().Gossip_Text_Icon_cnFont=nil
    --elseif WoWTools_DataMixin.onlyChinese then
        List.font= CreateFrame("CheckButton", nil, Frame, 'InterfaceOptionsCheckButtonTemplate')--ChatConfigCheckButtonTemplate
        List.font:SetPoint('TOPLEFT', List.Size, 'BOTTOMLEFT', 0, -12)
        List.font:SetChecked(Save().Gossip_Text_Icon_cnFont)
        List.font.Text:SetText('修改字体')
        List.font.Text:SetFont('Fonts\\ARHei.ttf', 12)
        --List.font.Text:SetFont('\\Interface\\AddOns\\WoWTools\\Source\\ARHei.ttf', 12)
        List.font:SetScript('OnLeave', GameTooltip_Hide)
        List.font:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName , WoWTools_GossipMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('Fonts\\ARHei.ttf', '黑体字')
           -- GameTooltip:AddDoubleLine('Interface\\AddOns\\WoWTools\\Source\\ARHei.TTF', '方正准圆')
            GameTooltip:Show()
        end)
        List.font:SetScript('OnMouseDown', function()
            Save().Gossip_Text_Icon_cnFont= not Save().Gossip_Text_Icon_cnFont and true or false
            WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
            List:set_list()
            if not Save().Gossip_Text_Icon_cnFont then
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|cnGREEN_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '需要重新加载UI' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, RELOADUI))
            end
        end)
    --end

    --已打开，对话，列表
    List.chat= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='transmog-icon-chat'})
    List.chat:SetNormalAtlas('transmog-icon-chat')
    List.chat:SetPoint('LEFT', List.Name, 'RIGHT', 2, 0)
    List.chat:SetScript('OnLeave', GameTooltip_Hide)
    List.chat:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName , WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '当前对话' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REFORGE_CURRENT, ENABLE_DIALOG), WoWTools_DataMixin.onlyChinese and '添加' or ADD)
        GameTooltip:Show()
    end)
    List.chat:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self,  function(...)
            Chat_Menu(...)
        end)
    end)

    --GossipFrame 有多少对话
    List.chat.Text= WoWTools_LabelMixin:Create(List.chat, {justifyH='CENTER'})
    List.chat.Text:SetPoint('CENTER', 1, 4.2)



    --默认，自定义，列表
    List.System= WoWTools_ButtonMixin:Cbtn(Frame, {size=22})
    List.System:SetPoint('BOTTOMRIGHT', List.ID, 'TOPRIGHT', 0, 2)
    List.System.Text= WoWTools_LabelMixin:Create(List.System)
    List.System.Text:SetPoint('CENTER')
    function List.System:set_num()--默认，自定义，列表        
        local n=0
        for _ in pairs(WoWTools_GossipMixin:Get_GossipData()) do
            n= n+1
        end
        self:SetNormalTexture(0)
        self.Text:SetText(n)
        self.num=n
    end
    List.System:set_num()
    List.System:SetScript('OnShow', List.System.set_num)
    List.System:SetScript('OnLeave', GameTooltip_Hide)
    List.System:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(format('%s |cnGREEN_FONT_COLOR:%d|r', WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT, self.num or 0), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
        self:set_num()
    end)
    List.System:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            WoWTools_GossipMixin:GossipData_Menu(self)
        elseif d=='RightButton' then
            WoWTools_GossipMixin:Init_Menu_Gossip(self)
        end
    end)



    --导入数据
    List.DataFrame=WoWTools_EditBoxMixin:CreateFrame(Frame,{
        --isInstructions= 'text'
        'WoWToolsGossipTextIconOutInScrollFrame'
    })
    List.DataFrame:Hide()
    List.DataFrame:SetPoint('TOPLEFT', Frame, 'TOPRIGHT', 0, -10)
    List.DataFrame:SetPoint('BOTTOMRIGHT', 310, 8)

    List:SetScript('OnSizeChanged', function(self, width)
        self.DataFrame:SetPoint('BOTTOMRIGHT', width, 8)
    end)

    List.DataFrame.CloseButton= CreateFrame('Button', nil, List.DataFrame, 'UIPanelCloseButton')
    List.DataFrame.CloseButton:SetPoint('TOPRIGHT',0, 13)
    List.DataFrame.CloseButton:SetScript('OnClick', function(self)
        local frame=self:GetParent()
        frame:Hide()
        frame:SetText("")
    end)
    WoWTools_TextureMixin:SetButton(List.DataFrame.CloseButton)

    List.DataFrame.enter= WoWTools_ButtonMixin:Cbtn(List.DataFrame, {size={100, 23}, isUI=true})
    List.DataFrame.enter:SetPoint('BOTTOM', List.DataFrame, 'TOP', 0, 5)
    List.DataFrame.enter:SetFormattedText('|A:Professions_Specialization_arrowhead:0:0|a%s', WoWTools_DataMixin.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
    List.DataFrame.enter:Hide()


    local function get_text_value(text)
        if text then
            local value= text:gsub(' ', '')
            if value~='' and value~='nil' then
                return value:match('"(.+)"') or value
            end
        end
    end

    function List.DataFrame.enter:set_date(tooltips)--导入数据，和提示
        local frame= self:GetParent()
        if not frame then
            return
        end

        local add, del, exist= {}, 0, 0
        local text= string.gsub(frame:GetText() or '', '(%[%d+]={.-})', function(t)

            local num, icon, name, hex= t:match('(%d+).-icon="(.-)", name="(.-)", hex="(.-)"}')
            if not num and not icon and not name and not hex then
                  num, icon, name, hex= t:match('(%d+).-icon=(.-), name=(.-), hex=(.-)}')
            end

            local gossipID= num and tonumber(num)
            if gossipID then

                icon= get_text_value(icon)
                name= get_text_value(name)
                hex= get_text_value(hex)



                if not PlayerDataSave()[gossipID] then
                    if icon or name or hex then
                        table.insert(add, {gossipID=gossipID, tab={icon=icon, name=name, hex=hex}})
                        return ''
                    else
                        del= del+1
                    end
                else
                    exist= exist+1
                end
            end
        end)

        local addText= format('|cnGREEN_FONT_COLOR:%s %d|r', WoWTools_DataMixin.onlyChinese and '添加' or ADD, #add)
        local delText= format('|cffffffff%s %d|r', WoWTools_DataMixin.onlyChinese and '无效的组合' or SPELL_FAILED_CUSTOM_ERROR_455, del)
        local existText= format('|cnRED_FONT_COLOR:%s %d|r', WoWTools_DataMixin.onlyChinese and '已存在' or format(ERR_ZONE_EXPLORED, PROFESSIONS_CURRENT_LISTINGS), exist)
        if not tooltips then
            for _, info in pairs(add) do
                PlayerDataSave()[info.gossipID]= info.tab
                local icon= select(3, WoWTools_TextureMixin:IsAtlas(info.tab.icon)) or ''
                local hex= info.tab.hex and format('|c%s', info.tab.hex) or ''
                local name= info.tab.name or ''
                print(
                    info.gossipID,
                    icon..hex..name
                )
            end

            List:set_list()

            print(WoWTools_DataMixin.Icon.icon2..WoWTools_GossipMixin.addName, '|n', format('%s|n%s|n%s', addText, delText, existText))

            frame:SetText(text)
            self:GetParent():SetInstructions(WoWTools_DataMixin.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        else
            GameTooltip:AddLine(addText)
            GameTooltip:AddLine(delText)
            GameTooltip:AddLine(existText)
        end
    end
    List.DataFrame.enter:SetScript('OnLeave', GameTooltip_Hide)
    List.DataFrame.enter:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '格式' or FORMATTING, '|cffff00ff[gossipOptionID]={icon=, name=, hex=}')
        GameTooltip:AddLine(' ')
        self:set_date(true)
        GameTooltip:Show()
    end)
    List.DataFrame.enter:SetScript('OnClick', function(self)--导入
       self:set_date()

    end)

    List.DataUscita= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='bags-greenarrow'})
    List.DataUscita:SetPoint('LEFT', List.DeleteAllPlayerData, 'RIGHT', 22, 0)
    List.DataUscita:SetScript('OnLeave', GameTooltip_Hide)
    List.DataUscita:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
        GameTooltip:Show()
    end)
    List.DataUscita:SetScript('OnClick', function(self)
        local frame= List.DataFrame
        frame:SetShown(true)
        frame.enter:SetShown(false)
        local text=''
        local tabs= {}
        local old= PlayerDataSave()
        for gossipID, info in pairs(old) do
            info.gossipID= gossipID
            table.insert(tabs, info)
        end
        table.sort(tabs, function(a, b) return a.gossipID<b.gossipID end)
        for _, info in pairs(tabs) do
            --[[text=text..format('[%d]={icon=%s, name=%s, hex=%s}|n',
                            info.gossipID,
                            info.icon or '',
                            info.name or '',
                            info.hex or ''
                        )]]
            text=text..format('[%d]={icon="%s", name="%s", hex="%s"},|n',
                info.gossipID,
                info.icon or '',
                info.name or '',
                info.hex or ''
            )
        end

        text= text:gsub('=""', '=nil')
        frame:SetText(text)
        frame:SetInstructions(WoWTools_DataMixin.onlyChinese and '导出' or SOCIAL_SHARE_TEXT or  HUD_EDIT_MODE_SHARE_LAYOUT)
    end)

    List.DataEnter= WoWTools_ButtonMixin:Cbtn(Frame, {size=22, atlas='Professions_Specialization_arrowhead'})
    List.DataEnter:SetPoint('LEFT', List.DataUscita, 'RIGHT')
    List.DataEnter:SetScript('OnLeave', GameTooltip_Hide)
    List.DataEnter:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_GossipMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '导入' or HUD_CLASS_TALENTS_IMPORT_LOADOUT_ACCEPT_BUTTON)
        GameTooltip:Show()
    end)
    List.DataEnter:SetScript('OnClick', function(self)
        local frame= List.DataFrame
        frame:SetShown(true)
        frame.enter:SetShown(true)
        frame:SetText('')
    end)


    
    List:set_list()
    List:set_color()
    WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame









--插件
    local tavFrame= _G['TAV_InfoPanel']
    if tavFrame and tavFrame.Name then
        local btn= WoWTools_ButtonMixin:Cbtn(tavFrame, {atlas='SpecDial_LastPip_BorderGlow'})
        btn:SetPoint('RIGHT', tavFrame.Name, 'LEFT', -14, 0)
        btn.edit= tavFrame.Name
        btn:SetScript('OnClick', function(self)
            local text= self.edit:GetText()
            if text and text~='' then
                List.Icon:SetText(text)
            end
        end)
    end













--GossipFrame事件
    GossipFrame:HookScript('OnShow', function()--已打开，对话，列表
        if Frame:IsShown() then
            List.chat:SetShown(true)
            List:set_list()
            Frame:set_point()
        end
    end)
    GossipFrame:HookScript('OnHide', function()
        if Frame:IsShown() then
            WoWTools_MoveMixin:SetPoint(Frame)
            List.chat:SetShown(false)
            List:set_list()
        end
    end)


    Frame:SetSize(580, 370)
    Frame:SetFrameStrata('HIGH')

--移动
    WoWTools_MoveMixin:Setup(Frame, {
        minW=370, minH=240, setSize=true,
    sizeRestFunc=function()
        Frame:SetSize(580, 370)
    end})



--Frame 设置
    Frame:SetScript('OnHide', function()
        WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        List:set_list()
        if GossipFrame:IsShown() and GossipFrame.GreetingPanel.ScrollBox:GetView() then
           for _, b in pairs(GossipFrame.GreetingPanel.ScrollBox:GetFrames() or {}) do
                b:UnlockHighlight()
            end
        end
    end)

    Frame:SetScript('OnShow', function()
        WoWTools_LoadUIMixin:UpdateGossipFrame()--更新GossipFrame
        List:set_list()
    end)


    function Frame:set_point()
        if self:IsShown() then
            self:ClearAllPoints()
            if GossipFrame:IsShown() then
                self:SetPoint('TOPLEFT', GossipFrame, 'TOPRIGHT')
            elseif not WoWTools_MoveMixin:SetPoint(self) then
                self:SetPoint('CENTER')
            end
        end
    end

    function Frame:set_shown(show)
        if show==nil then
            show= not self:IsShown()
        end

        self:SetShown(show)

        List.chat:SetShown(GossipFrame:IsShown())
    end


    Frame:set_shown(isShow)
    Frame:set_point()

    Init=function(show)
        Frame:set_shown(show)
        Frame:set_point()
    end
end

















function WoWTools_GossipMixin:Init_Options_Frame(isShow)
    --if self.GossipButton then
    Init(isShow)
end