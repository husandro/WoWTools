
--目标, 装备
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end











local function set_InspectPaperDollItemSlotButton_Update(self)
    local slot= self:GetID()
	local link= not Save().hide and GetInventoryItemLink(InspectFrame.unit, slot) or nil
	e.LoadData({id=link, type='item'})--加载 item quest spell
    --set_Gem(self, slot, link)
    set_Item_Tips(self, slot, link, false)
    set_Slot_Num_Label(self, slot, link and true or false)--栏位, 帐号最到物品等级
    WoWTools_ItemStatsMixin:SetItem(self, link, {point=self.icon})
    if not self.OnEnter and not Save().hide then
        self:SetScript('OnEnter', function(self2)
            if self2.link then
                e.tips:ClearLines()
                e.tips:SetOwner(InspectFrame, "ANCHOR_RIGHT")
                e.tips:SetHyperlink(self2.link)
                e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.left)
                e.tips:Show()
            end
        end)
        self:SetScript('OnLeave', GameTooltip_Hide)
        self:SetScript('OnMouseDown', function(self2)
            WoWTools_ChatMixin:Chat(self2.link, nil, true)
            --local chat=SELECTED_DOCK_FRAME
            --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)

        end)
    end
    self.link= link

    if link and not self.itemLinkText then
        self.itemLinkText= WoWTools_LabelMixin:Create(self)
        local h=self:GetHeight()/3
        if slot==16 then
            self.itemLinkText:SetPoint('BOTTOMRIGHT', InspectPaperDollFrame, 'BOTTOMLEFT', 6,15)
        elseif slot==17 then
            self.itemLinkText:SetPoint('BOTTOMLEFT', InspectPaperDollFrame, 'BOTTOMRIGHT', -5,15)
        elseif is_Left_Slot(slot) then
            self.itemLinkText:SetPoint('RIGHT', self, 'LEFT', -2,0)
        else
            self.itemLinkText:SetPoint('LEFT', self, 'RIGHT', 5,0)
        end
    end
    if self.itemLinkText then
        if link then
            local itemID= GetInventoryItemID(InspectFrame.unit, slot)
            local cnName= e.cn(nil, {itemID=itemID, isName=true})
            if cnName then
                cnName= cnName:match('|cff......(.+)|r') or cnName
                local atlas= link:match('%[(.-) |A') or link:match('%[(.-)]')
                if atlas then
                    link= link:gsub(atlas, cnName)
                end
            end
        end
        self.itemLinkText:SetText(link or '')
    end
end

local function set_InspectPaperDollFrame_SetLevel()--目标,天赋 装等
    if Save().hide then
        return
    end
    local unit= InspectFrame.unit
    local guid= unit and UnitGUID(unit)
    local info= guid and e.UnitItemLevel[guid]
    if info and info.itemLevel and info.specID  then
        local level= UnitLevel(unit)
        local effectiveLevel= UnitEffectiveLevel(unit)
        local sex = UnitSex(unit)

        local text= WoWTools_UnitMixin:GetPlayerInfo({unit=unit, guid=guid})
        local icon, role = select(4, GetSpecializationInfoByID(info.specID, sex))
        if icon and role then
            text=text..' |T'..icon..':0|t '..e.Icon[role]
        end
        if level and level>0 then
            text= text..' '..level
            if effectiveLevel~=level then
                text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r)'
            end
        end
        text= text..(sex== 2 and ' |A:charactercreate-gendericon-male-selected:0:0|a' or sex==3 and ' |A:charactercreate-gendericon-female-selected:0:0|a' or ' |A:charactercreate-icon-customize-body-selected:0:0|a')
        text= text.. info.itemLevel
        if info.col then
            text= info.col..text..'|r'
        end
        InspectLevelText:SetText(text)
    end
end





--目标，属性
local function Set_Target_Status(frame)--InspectFrame
    if frame.statusLabel then
        frame.statusLabel:settings()
        return
    end
    frame.statusLabel= WoWTools_LabelMixin:Create(InspectPaperDollFrame)
    frame.statusLabel:SetPoint('TOPLEFT', InspectFrameTab1, 'BOTTOMLEFT',0,-2)
    function frame.statusLabel:settings()
        local unit=InspectFrame.unit
        local text
        if not Save().hide and UnitExists(unit) then
            local tab={ 1,2,3,15,5,9, 10,6,7,8,11,12,13,14, 16,17}
            local sta, newSta={}, {}
            for _, slotID in pairs(tab) do
                local itemLink= GetInventoryItemLink(unit, slotID)
                for a,b in pairs(itemLink and C_Item.GetItemStats(itemLink) or {}) do
                    sta[a]= (sta[a] or 0) +b
                end
            end
            for a, b in pairs(sta) do
                table.insert(newSta, {text=e.cn(_G[a] or a), value=b})
            end
            table.sort(newSta, function(a,b) return a.value> b.value end)
            for index, info in pairs(newSta) do
                text= text and text..'|n' or ''
                local col= select(2, math.modf(index/2))==0 and '|cffffffff' or '|cffff7f00'
                text= text..col..info.text..': '..WoWTools_Mixin:MK(info.value, 3)..'|r'
            end
        end
        self:SetText(text or '')
    end
    frame.statusLabel:settings()
end






local function Init_UI()

    WoWTools_PaperDollMixin:Init_ShowHideButton(InspectFrame)


    WoWTools_LabelMixin:Create(nil, {changeFont= InspectLevelText, size=18})

    InspectPaperDollFrame.ViewButton:ClearAllPoints()
    InspectPaperDollFrame.ViewButton:SetPoint('LEFT', InspectLevelText, 'RIGHT',20,0)
    InspectPaperDollFrame.ViewButton:SetSize(25,25)
    InspectPaperDollFrame.ViewButton:SetText(e.onlyChinese and '试' or WoWTools_TextMixin:sub(VIEW,1))

    InspectPaperDollItemsFrame.InspectTalents:SetSize(25,25)
    InspectPaperDollItemsFrame.InspectTalents:SetText(e.onlyChinese and '赋' or WoWTools_TextMixin:sub(TALENT,1))

    InspectFrame:HookScript('OnShow', Set_Target_Status)
    --hooksecurefunc('InspectFrame_UnitChanged', Set_Target_Status)
    hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
    hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
end





local function Init()
    if C_AddOns.IsAddOnLoaded('Blizzard_InspectUI') then
        Init_UI()
    else
        local frame=CreateFrame('Frame')
        frame:RegisterEvent('ADDON_LOADED')
        frame:SetScript('OnEvent', function(self, event)
            if event=='Blizzard_InspectUI' then
                Init_UI()
                self:UnregisterEvents()
            end
        end)

    end
end

function WoWTools_PaperDollMixin:Init_InspectUI()
    Init()
end