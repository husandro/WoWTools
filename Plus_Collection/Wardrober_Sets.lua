local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end

local SetsDataProvider
local TipsLabel




local function GetSetsCollectedNum(setID)--套装 , 收集数量, 返回: 图标, 数量, 最大数, 文本
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID) or {}
    local numCollected, numAll=0,0
    for _,v in pairs(info) do
        numAll=numAll+1
        if v.collected then
            numCollected=numCollected + 1
        end
    end
    if numAll>0 then
        if numCollected==numAll then
            return '|A:AlliedRace-UnlockingFrame-Checkmark:12:12|a', numCollected, numAll--, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r'
        elseif numCollected==0 then
            return '|cff9e9e9e'..numAll-numCollected..'|r ', numCollected, numAll,  '|cff9e9e9e'..numCollected..'|r/'..numAll--, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        else
            return numAll-numCollected, numCollected, numAll, '|cffffffff'..numCollected..'|r/'..numAll--, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
end





















 --幻化，套装，索引 WardrobeCollectionFrame.SetsTransmogFrame
 local function set_Sets_Tooltips(self)--UpdateSets
    if not self:IsVisible() then
        return
    end

    local idexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE
    for i= 1, self.PAGE_SIZE do
        local model = self.Models[i]
        if model and model:IsShown() then
            local idex--索引
            if not Save().hideItems then
                idex= i + idexOffset
                if not model.Text then
                    model.Text= WoWTools_LabelMixin:Create(model)
                    model.Text:SetPoint('TOPRIGHT',1,0)
                    model.Text:SetAlpha(0.5)
                end
            end
            if model.Text then
                model.Text:SetText(idex or '')
            end
        end
    end
end















local function Init_Button(btn)
    if btn.set_Rest then
        return
    end

    btn:SetScript("OnEnter",function(self)
        if not Save().hideSets then
            GameTooltip:SetOwner(self.Icon or self, "ANCHOR_LEFT")--,8,-300)
            GameTooltip:ClearLines()
            --GameTooltip:AddDoubleLine('setID', self.setID)
            GameTooltip:AddLine(self.tooltip)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave",function()
        GameTooltip:Hide()
    end)

    btn.version=WoWTools_LabelMixin:Create(btn)--版本
    btn.version:SetPoint('BOTTOMRIGHT',-5, 5)

    btn.limited=btn.IconFrame:CreateTexture(nil, 'OVERLAY')--限时
    btn.limited:SetSize(12, 12)
    btn.limited:SetAtlas('socialqueuing-icon-clock')
    btn.limited:SetPoint('TOPRIGHT', btn.IconFrame.Icon)
    btn.limited:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    btn.limited:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '限时套装' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TRANSMOG_SET_LIMITED_TIME_SET, WARDROBE_SETS))
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    btn.numSetsLabel=WoWTools_LabelMixin:Create(btn.IconFrame, {size=16, mouse=true})
    btn.numSetsLabel:SetPoint('BOTTOMLEFT', btn.IconFrame.Icon)
    btn.numSetsLabel:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    btn.numSetsLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '套装数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WARDROBE_SETS, AUCTION_HOUSE_QUANTITY_LABEL))
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    function btn:set_Rest()
        self.Label:SetText('')

        self.limited:SetShown(false)

        self.version:SetText('')
        self.numSetsLabel:SetText('')

        self.tooltip=nil
    end
end




















local function Set_List_Button(btn, displayData)
    if not btn:IsVisible() then
        return
    end

    local setID= displayData.setID or btn.setID
    if Save().hideSets or not setID then
        if btn.set_Rest then
            btn:set_Rest()
        end
        return
    end

    Init_Button(btn)

    local tipsText= WoWTools_TextMixin:CN(displayData.name or btn.Name:GetText() or '')..(displayData.label and displayData.name~= displayData.label and '|n'..WoWTools_TextMixin:CN(displayData.label) or '')
    tipsText= tipsText and tipsText..'|n' or ''

    local variantSets = SetsDataProvider:GetVariantSets(setID) or {}
    if #variantSets==0 then
        table.insert(variantSets, C_TransmogSets.GetSetInfo(setID))
    end
    SetsDataProvider:ClearSets()

    local text, isLimited, patch, version--版本
    for _, info in pairs(variantSets) do
        if info and info.setID then
            local meno, collect, numAll = GetSetsCollectedNum(info.setID)
            if meno and numAll then

                text= (text or '').. meno..' '--未收集，数量
                --version= version or _G['EXPANSION_NAME'..(info.expansionID or '')]--版本
                isLimited= isLimited or info.limitedTimeSet--限时套装

                local name= info.description or info.name or ''
                name= WoWTools_TextMixin:CN(name)
                name= numAll==collect and '|cnGREEN_FONT_COLOR:'..name..'|r' or name--已收集

                local isCollected= collect== numAll--是否已收

                local tip= (collect==0 and '|cff9e9e9e'..collect..'|r' or collect)
                            ..'/'..numAll--收集数量
                            ..' '..meno..(not isCollected and ' ' or '')
                            ..name--名称
                            ..(info.limitedTimeSet and '|A:socialqueuing-icon-clock:0:0|a' or '')--限时套装
                            ..' '..info.setID
                            --..(info.setID==btn.setID and ' '..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or '')
                tipsText= tipsText..'|n'..(isCollected and '|cnGREEN_FONT_COLOR:'..tip..'|r' or tip)
            end
            patch= patch or (info.patchID and info.patchID>0 and 'v'..(info.patchID/10000))
            version= version or (info.expansionID and WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..info.expansionID]))
        end
    end

    btn.tooltip= tipsText
        ..((patch or version) and '|n' or '')

        ..(version and '|n'..version or '')..(patch and ' '..patch or '')

    local r, g, b= btn.Name:GetTextColor()
    r,g,b= r or 1, g or 1, b or 1

    btn.Label:SetText(text)
    btn.Label:SetTextColor(r, g, b)

    btn.limited:SetShown(isLimited)--限时


    btn.version:SetText(version or '')--版本
    btn.version:SetTextColor(r, g, b)

    local numStes= #variantSets
    btn.numSetsLabel:SetText(numStes>1 and numStes or '')
    btn.numSetsLabel:SetTextColor(r, g, b)

    variantSets= nil
end





















--套装物品 Link
local function Init_Wardrobe_DetailsFrame(_, itemFrame)
    if not itemFrame:IsVisible() then
        return
    end

    if Save().hideSets  then
        if itemFrame.indexbtn then
            for i = 1, itemFrame.indexbtn do
                local btn=itemFrame['btn'..i]
                if btn then
                    btn:SetShown(false)
                end
            end
            itemFrame.indexbtn=nil
        end
        return
    end
        
    local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
    local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
    local sources = C_TransmogSets.GetSourcesForSlot(itemFrame:GetParent():GetParent():GetSelectedSetID(), slot)
    if ( #sources == 0 ) then
        tinsert(sources, sourceInfo)
    end
    CollectionWardrobeUtil.SortSources(sources, sourceInfo.visualID, itemFrame.sourceID)
    local numItems=#sources
    for i=1, numItems do
        local index = CollectionWardrobeUtil.GetValidIndexForNumSources(i, numItems)
        local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
        local btn=itemFrame['btn'..i]
        if not btn then
            btn=WoWTools_ButtonMixin:Cbtn(itemFrame, {icon=WoWTools_DataMixin.Icon.icon, size={26,10}})
            btn:SetNormalAtlas('adventure-missionend-line')
            itemFrame['btn'..i]=btn
            if i==1 then
                btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
            else
                btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
            end
            btn:SetAlpha(0.2)
            btn:SetScript("OnEnter",function(self2)
                    if not self2.link then
                         return
                    end
                    self2:SetAlpha(1)
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
                    GameTooltip:SetHyperlink(self2.link)
                    GameTooltip:Show()
            end)
            btn:SetScript("OnMouseDown", function(self2)
                WoWTools_ChatMixin:Chat(self2.link, nil, true)
                --local chat=SELECTED_DOCK_FRAME
                --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)

            end)
            btn:SetScript("OnLeave",function(self2)
                    self2:SetAlpha(0.2)
                    GameTooltip:Hide()
            end)
        end
        btn.link=link
        btn:SetShown(true)
    end
    if itemFrame.indexbtn and itemFrame.indexbtn > numItems then
        for i = numItems+1, itemFrame.indexbtn do
            local btn=itemFrame['btn'..i]
            if btn then
                btn:SetShown(false)
            end
        end
    end
    itemFrame.indexbtn=numItems
end

















local function Init()
    SetsDataProvider= CreateFromMixins(WardrobeSetsDataProviderMixin)

    --点击，按钮信息
    TipsLabel= WoWTools_LabelMixin:Create(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, {size=14})
    TipsLabel:SetPoint('BOTTOMLEFT', WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, 'BOTTOMRIGHT', 8, 8)
    if not WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.Background then
        local texture= WoWTools_TextureMixin:CreateBackground(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)
        texture:SetPoint('TOPLEFT', TipsLabel, -4, 4)
        texture:SetPoint('BOTTOMRIGHT', TipsLabel, 4, -4)
    end
    --点击，显示套装情况Blizzard_Wardrobe.lua
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'OnClick', function(btn, buttonName)
        if not btn:IsVisible() then
            return
        end
        if buttonName == "LeftButton" or not Save().hideSets then
            TipsLabel:SetText(btn.tooltip or '')--点击，按钮信息
        else
            TipsLabel:SetText("")
        end
    end)
    WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame:HookScript('OnShow', function(self)
        if Save().hideSets then
            TipsLabel:SetText('')
        end
    end)

    --幻化，套装，索引
    hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame, 'UpdateSets', set_Sets_Tooltips)


    --套装，列表
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', Set_List_Button)




    --套装,物品, Link
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', Init_Wardrobe_DetailsFrame)

    return true
end


















function WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    if not Save().hideSets and Init() then
        Init=function()end
    end
end