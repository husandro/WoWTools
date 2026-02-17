local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end
local frame






--头衔
local function Get_Title_Num()
    local tab= PaperDollFrame.TitleManagerPane.titles or GetKnownTitles() or {}
    local num= #tab
    num= num-1
    num= math.max(num, 0)
    return num, GetNumTitles()-num
end


local function Get_PvEPvPLevel()
    local pve, cur, pvp
    pve, cur, pvp= GetAverageItemLevel()
--物品等级 pvp
    pvp= format('%i', pvp or 0)
--物品等级 pvp
    pve= format('%i', pve or 0)
    if pve==0 or cur-pve<=-5 then
        pve= '|cnWARNING_FONT_COLOR:'..pve..'|r'
    end
    return pve, pvp
end




local function Get_EquipmentSet()
    local name, icon, specIcon, nu, specName, setID
    local setIDs=C_EquipmentSet.GetEquipmentSetIDs()
    for _, v in pairs(setIDs) do
        local name2, icon2, _, isEquipped, numItems= C_EquipmentSet.GetEquipmentSetInfo(v)
        if isEquipped then
            name=name2
            name=WoWTools_TextMixin:sub(name, 2, 5)
            if icon2 and icon2~=134400 then
                icon=icon2
            end
            local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(v)
            if specIndex then
                local _, specName2, _, icon3 = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                specName= specName2
                if icon3 then
                    specIcon=icon3
                end
            end
            nu=numItems
            setID= v
            break
        end
    end

    return name, icon, specIcon, nu, specName, setID
end





local function Init_Title_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    local all= GetNumTitles()

    local sub
    local find= 0

    for i=1, all do
        local name = GetTitleName(i)
        if name and name~='' and not name:find('PH') then
            find= find+1
            local cn= WoWTools_TextMixin:CN(name)--, {titleID=i})
            if cn then
                cn= cn:gsub('%%s', '')
                cn= cn=='' and name or cn
                cn= cn~=name and cn or nil
            end
            local col= IsTitleKnown(i) and '|cff606060' or '|cffffffff'
            sub=root:CreateButton(

                col
                ..(cn or name),

            function(data)
                WoWTools_TooltipMixin:Show_URL(true, 'title', data.rightText, nil)
                return MenuResponse.Open

            end, {rightText=col..i, name=name, cn=cn})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(WoWTools_DataMixin.Icon.left..'wowhead.com')
                tooltip:AddLine('index '..description.data.rightText)
                tooltip:AddLine(description.data.name..' ')
                if description.data.cn then
                    tooltip:AddLine(description.data.cn)
                end
            end)
            WoWTools_MenuMixin:SetRightText(sub)

        end
    end
    root:CreateDivider()
    root:CreateTitle('|cnGREEN_FONT_COLOR:'..(#GetKnownTitles()-1)..'|r/'..all..' (|cffffffff'..find..'|r)')
    WoWTools_MenuMixin:SetScrollMode(root)
end























local function Init()
    if Save().notTabPlus then
        return
    end




    frame= CreateFrame('Frame', nil, PaperDollSidebarTab1)
    frame:SetFrameLevel(PaperDollSidebarTab1:GetFrameLevel()+1)













    frame.pve= frame:CreateFontString('WoWToolsPaperItemPvELevelLabel', 'OVERLAY', 'WoWToolsFont2')
    --frame.pve:SetFontHeight(12)
    --frame.pve:SetShadowOffset(1,-1)
    frame.pve:SetPoint('BOTTOM', PaperDollSidebarTab1)
    frame.pve:SetJustifyH('CENTER')
    frame.pve:EnableMouse(true)
    frame.pve:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    frame.pve:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab1, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            (WoWTools_DataMixin.onlyChinese and '物品等级' or LFG_LIST_ITEM_LEVEL_INSTR_SHORT)
            ..WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    frame.pve:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab1, 1)
    end)






    frame.pvp= frame:CreateFontString('WoWToolsPaperItemPvPLevelLabel', 'OVERLAY', 'WoWToolsFont2')
    --frame.pvp:SetFontHeight(12)
    --frame.pvp:SetShadowOffset(1,-1)
    frame.pvp:SetPoint('TOP', PaperDollSidebarTab1, 0, -2)
    frame.pvp:SetJustifyH('CENTER')
    frame.pvp:EnableMouse(true)
    frame.pvp:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab1, 1)
    end)
    frame.pvp:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.pvp:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab1, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            (WoWTools_DataMixin.onlyChinese and 'PvP物品等级' or LFG_LIST_ITEM_LEVEL_PVP_INSTR_SHORT)
            ..WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '最高' or VIDEO_OPTIONS_ULTRA_HIGH)
        )
        --GameTooltip:AddLine(' ')
        --GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
        --GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
    local pvpTexture= frame:CreateTexture(nil, 'OVERLAY')
    pvpTexture:SetSize(12,12)
    pvpTexture:SetPoint('RIGHT', frame.pvp, 'LEFT')
    pvpTexture:SetAtlas('pvptalents-warmode-swords')












--已收集数量
    frame.title= frame:CreateFontString('WoWToolsPaperTitleLabel', 'OVERLAY', 'WoWToolsFont2')
    --frame.title:SetFontHeight(12)
    --frame.title:SetShadowOffset(1,-1)
    frame.title:SetPoint('BOTTOM', PaperDollSidebarTab2)
    frame.title:SetJustifyH('CENTER')
    frame.title:EnableMouse(true)
    frame.title:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab2, 2)--PaperDollFrame.lua
    end)
    frame.title:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.title:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab2, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        local num, notTitle= Get_Title_Num()
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '头衔' or PAPERDOLL_SIDEBAR_TITLES)
        )
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED, num, nil,nil,nil,1,1,1)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED, notTitle, nil,nil,nil,1,1,1)
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)






--未收集
    frame.titleButton= CreateFrame('DropdownButton', 'WoWToolsTitleMenuButton', PaperDollFrame.TitleManagerPane, 'WoWToolsButtonTemplate')
    frame.titleButton:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    frame.titleButton.owner= 'ANCHOR_RIGHT'
    frame.titleButton.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)
    frame.titleButton.text= frame.titleButton:CreateFontString(nil, 'ARTWORK', 'GameFontDisableSmall')
    frame.titleButton.text:SetPoint('CENTER')
    frame.titleButton:SetFrameLevel(PaperDollFrame.TitleManagerPane.ScrollBox:GetFrameLevel()+1)
    frame.titleButton:SetPoint('TOPRIGHT', -16, 2)
    frame.titleButton:SetupMenu(Init_Title_Menu)





    local w, h
--套装，名称
    --frame.setName=WoWTools_LabelMixin:Create(PaperDollSidebarTab3, {justifyH='CENTER'})
    frame.setName= frame:CreateFontString('WoWToolsPaperTitleLabel', 'OVERLAY', 'WoWToolsFont2')
    --frame.setName:SetFontHeight(12)
    --frame.setName:SetShadowOffset(1,-1)
    frame.setName:SetPoint('BOTTOM', PaperDollSidebarTab3, 2, 0)
    frame.setName:EnableMouse(true)
    frame.setName:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab3, 3)--PaperDollFrame.lua
    end)
    frame.setName:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.setName:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab3, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '名称' or NAME)
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

--套装图标图标
    frame.setTexture= frame:CreateTexture(nil, 'OVERLAY')
    frame.setTexture:SetPoint('CENTER', PaperDollSidebarTab3, 1, -2)
    w, h= PaperDollSidebarTab3:GetSize()
    frame.setTexture:SetSize(w-4, h-4)

--天赋图标
    frame.specTexture=frame:CreateTexture(nil, 'OVERLAY')
    frame.specTexture:SetPoint('BOTTOMLEFT', PaperDollSidebarTab3, 'BOTTOMRIGHT')
    h, w= PaperDollSidebarTab3:GetSize()
    frame.specTexture:SetSize(h/3+2, w/3+2)
    frame.specTexture:EnableMouse(true)
    frame.specTexture:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab3, 3)--PaperDollFrame.lua
    end)
    frame.specTexture:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.specTexture:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab3, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '专精' or SPECIALIZATION)
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

--套装数量
    --NumLabel=WoWTools_LabelMixin:Create(PaperDollSidebarTab3, {justifyH='RIGHT'})
    frame.setNum= frame:CreateFontString('WoWToolsPaperTitleLabel', 'OVERLAY', 'GameFontHighlightOutline')
    frame.setNum:SetFontHeight(12)
    frame.setNum:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT',0, 4)
    frame.setNum:EnableMouse(true)
    frame.specTexture:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab3, 3)--PaperDollFrame.lua
    end)
    frame.setNum:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    frame.setNum:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(PaperDollSidebarTab3, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            WoWTools_DataMixin.Icon.icon2
            ..format(
                WoWTools_DataMixin.onlyChinese and "%d件物品" or ITEMS_VARIABLE_QUANTITY,
                tonumber(self:GetText() or 0) or 0
            )
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)











    function frame:settings()

       local pve, pvp, title, notCollected
       local name, icon, specIcon, nu, specName, setID
        if not Save().notTabPlus then
--物品等级
            pve, pvp= Get_PvEPvPLevel()
--头衔
            title, notCollected= Get_Title_Num()
--装备管理
            name, icon, specIcon, nu, specName, setID= Get_EquipmentSet()
        end

--pve装等
        self.pve:SetText(pve or '')
--pvp装有情
        self.pvp:SetText(pvp or '')
--头衔
        self.title:SetText(title and title>0 and title or '')
        self.titleButton.text:SetText(notCollected or '')
        self.titleButton:SetWidth(math.max(self.titleButton.text:GetStringWidth()+12, 23))

--套装，名称
        self.setName:SetText(WoWTools_TextMixin:sub(name, 2, 4,true) or '')
        self.setName.tooltip2= name
        self.setName.setID= setID

    --套装图标图标
        self.setTexture:SetTexture(icon or 0)
        self.setTexture:SetShown(icon and true or false)

    --天赋图标
        self.specTexture:SetTexture(specIcon or 0)
        self.specTexture:SetShown(specIcon and true or false)
        self.specTexture.tooltip2= specIcon and (specIcon and "|T"..specIcon..':0|t' or '')..specName or nil
        self.specTexture.setID= setID

    --套装数量
        self.setNum:SetText(nu or '')
        self.setNum.tooltip2= nu and (WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..nu or nil
        self.setNum.setID= setID
    end

    frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
    end)
    frame:SetScript('OnShow', function(self)
        if Save().notTabPlus then
            return
        end
        self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        self:settings()
    end)
    frame:SetScript('OnEvent', frame.settings)

    WoWTools_DataMixin:Hook('GearSetButton_SetSpecInfo', function()
       frame:settings()
    end)

    if PaperDollFrame:IsShown() then
        frame:settings()
    end

    Init=function()
        local show= not Save().notTabPlus
        frame:SetShown(show)
        frame.titleButton:SetShown(show)
    end
end









function WoWTools_PaperDollMixin:Init_TabPlus()
    Init()
end