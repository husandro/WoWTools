
--目标, 装备
local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end


local KeystoneLabel--挑战, 分数
local StatusLabel--装备，属性








local function set_InspectPaperDollItemSlotButton_Update(frame)
    local unit= InspectFrame.unit

    local slot= frame:GetID()
	local link= (UnitExists(unit) and not Save().hide) and GetInventoryItemLink(unit, slot) or nil
	WoWTools_Mixin:Load({id=link, type='item'})--加载 item quest spell

    --set_Gem(frame, slot, link)

    WoWTools_PaperDollMixin:Set_Item_Tips(frame, slot, link, false)
    WoWTools_PaperDollMixin:Set_Slot_Num_Label(frame, slot, link and true or false)--栏位, 帐号最到物品等级
    WoWTools_ItemStatsMixin:SetItem(frame, link, {point=frame.icon})
    if not frame.OnEnter and not Save().hide then
        frame:SetScript('OnEnter', function(self)
            if self.link then
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(InspectFrame, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.link)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.left)
                GameTooltip:Show()
            end
        end)
        frame:SetScript('OnLeave', GameTooltip_Hide)
        frame:SetScript('OnMouseDown', function(self)
            WoWTools_ChatMixin:Chat(self.link, nil, true)
            --local chat=SELECTED_DOCK_FRAME
            --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self.link, chat)

        end)
    end
    frame.link= link

    if link and not frame.itemLinkText then
        frame.itemLinkText= WoWTools_LabelMixin:Create(frame, {size=16})
        if slot==16 then
            frame.itemLinkText:SetPoint('BOTTOMRIGHT', InspectPaperDollFrame, 'BOTTOMLEFT', 6, 12)
            frame.itemLinkText.isLeft=true
        elseif slot==17 then
            frame.itemLinkText:SetPoint('BOTTOMLEFT', InspectPaperDollFrame, 'BOTTOMRIGHT', -5, 12)
        elseif WoWTools_PaperDollMixin:Is_Left_Slot(slot) then
            frame.itemLinkText:SetPoint('RIGHT', frame, 'LEFT', -2,0)
            frame.itemLinkText.isLeft=true
        else
            frame.itemLinkText:SetPoint('LEFT', frame, 'RIGHT', 5,0)
        end


        frame.itemBG= frame:CreateTexture(nil, 'BACKGROUND')
        frame.itemBG:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
        frame.itemBG:SetAlpha(0.7)
        --frame.itemBG:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
        frame.itemBG:SetPoint('TOPLEFT', frame.itemLinkText)
        frame.itemBG:SetPoint('BOTTOMRIGHT', frame.itemLinkText)
    end
    if frame.itemLinkText then
        if link then
            local itemID= GetInventoryItemID(unit, slot)
            local cnName= e.cn(nil, {itemID=itemID, isName=true})
            if cnName then
                cnName= cnName:match('|cff......(.+)|r') or cnName
                local atlas= link:match('%[(.-) |A') or link:match('%[(.-)]')
                if atlas then
                    link= link:gsub(atlas, cnName)
                end
            end
            local slotTexture= GetInventoryItemTexture(unit, slot)
            if slotTexture then
                if frame.itemLinkText.isLeft then
                    link= '|T'..slotTexture..':22|t'..link
                else
                    link= link..'|T'..slotTexture..':22|t'
                end
            end
        end
        frame.itemLinkText:SetText(link or '')
    end
end










local function set_InspectPaperDollFrame_SetLevel()--目标,天赋 装等
    local key
    local unit= InspectFrame.unit
    if not Save().hide and unit and UnitExists(unit) then
        local guid= unit and UnitGUID(unit)
        local info= guid and e.UnitItemLevel[guid]
        if info then
            local level= UnitLevel(unit)
            local effectiveLevel= UnitEffectiveLevel(unit)
            local sex = UnitSex(unit)

            local text= WoWTools_UnitMixin:GetPlayerInfo({unit=unit, guid=guid})

            local icon, role = select(4, GetSpecializationInfoByID(info.specID, sex))
            if icon and role then
                text=text..'|T'..icon..':0|t'..e.Icon[role]
            end
            if level and level>0 then
                text= text..level
                if effectiveLevel~=level then
                    text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r)'
                end
            end
            text= text..(sex== 2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or sex==3 and '|A:charactercreate-gendericon-female-selected:0:0|a' or '|A:charactercreate-icon-customize-body-selected:0:0|a')
            text= text.. info.itemLevel
            if info.col then
                text= info.col..text..'|r'
            end
            InspectLevelText:SetText(text)
        end

        info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
        if info and info.currentSeasonScore and info.currentSeasonScore>0 then
            key= WoWTools_WeekMixin:KeystoneScorsoColor(info.currentSeasonScore,true)
        end
    end

    KeystoneLabel:SetText(key or '')
end

















local function Init_UI()
--显示/隐藏，按钮
    WoWTools_PaperDollMixin:Init_ShowHideButton(InspectFrame)

--更改, 名称大小
    function InspectLevelText:set_font_size()
        WoWTools_LabelMixin:Create(nil, {changeFont=self, size= Save().hide and 12 or 22, justifyH='CENTER'})
    end

    if not Save().hide then
        InspectLevelText:set_font_size()
    end

--装备，属性
    StatusLabel= WoWTools_LabelMixin:Create(InspectPaperDollFrame, {size=14})
    StatusLabel:SetPoint('TOPLEFT', InspectFrameTab1, 'BOTTOMLEFT',0,-4)

    function InspectFrame:set_status_label()
        local unit=self.unit
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
        StatusLabel:SetText(text or '')
    end
    InspectFrame:HookScript('OnShow', InspectFrame.set_status_label)

--挑战, 分数
    KeystoneLabel=  WoWTools_LabelMixin:Create(InspectPaperDollFrame, {size=18})
    KeystoneLabel:SetPoint('BOTTOMLEFT', 10, 5)

--试衣间, 按钮
    InspectPaperDollFrame.ViewButton:ClearAllPoints()
    InspectPaperDollFrame.ViewButton:SetPoint('TOPRIGHT', -5, -28)
    InspectPaperDollFrame.ViewButton:SetSize(28,28)
    InspectPaperDollFrame.ViewButton:SetText(WoWTools_Mixin.onlyChinese and '试' or WoWTools_TextMixin:sub(VIEW,1))
    InspectPaperDollFrame.ViewButton:HookScript('OnLeave', GameTooltip_Hide)
    InspectPaperDollFrame.ViewButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '试衣间' or DRESSUP_FRAME)
        GameTooltip:Show()
    end)

--天赋，按钮
    InspectPaperDollItemsFrame.InspectTalents:SetSize(28,28)
    InspectPaperDollItemsFrame.InspectTalents:SetText(WoWTools_Mixin.onlyChinese and '赋' or WoWTools_TextMixin:sub(TALENT,1))
    InspectPaperDollItemsFrame.InspectTalents:HookScript('OnLeave', GameTooltip_Hide)
    InspectPaperDollItemsFrame.InspectTalents:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '天赋' or INSPECT_TALENTS_BUTTON)
        GameTooltip:Show()
    end)

    hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
    hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
end


    --InspectFrame:HookScript('OnShow', Set_Target_Status)
    --hooksecurefunc('InspectFrame_UnitChanged', Set_Target_Status)








local function Init()
    if C_AddOns.IsAddOnLoaded('Blizzard_InspectUI') then
        Init_UI()
    else
        local frame=CreateFrame('Frame')
        frame:RegisterEvent('ADDON_LOADED')
        frame:SetScript('OnEvent', function(self, _, arg1)
            if arg1=='Blizzard_InspectUI' then
                Init_UI()
                self:UnregisterAllEvents()
            end
        end)

    end
end





function WoWTools_PaperDollMixin:Init_InspectUI()
    Init()
end