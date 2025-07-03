local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end

local SetsDataProvider
local TipsLabel










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

    btn.Name:SetPoint('RIGHT', -4, 0)
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
            local meno, collect, numAll = WoWTools_CollectedMixin:SetID(info.setID)
            if meno and numAll then

                text= (text or '').. meno..' '--未收集，数量
                
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
            version= WoWTools_TextureMixin:GetWoWLog(info.expansionID, nil) or (info.expansionID and WoWTools_TextMixin:CN(_G['EXPANSION_NAME'..info.expansionID]))
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

    local numItems= #sources
    for i=1, numItems do
        local index = CollectionWardrobeUtil.GetValidIndexForNumSources(i, numItems)


        local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
        local btn=itemFrame['btn'..i]
        if not btn then
            btn=WoWTools_ButtonMixin:Cbtn(itemFrame, {
                atlas='adventure-missionend-line',
                size={26,10}
            })
            itemFrame['btn'..i]=btn
            if i==1 then
                btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
            else
                btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
            end
            btn:SetScript("OnEnter",function(self)
                WoWTools_SetTooltipMixin:Frame(self)
                self:GetNormalTexture():SetAlpha(1)
            end)
            btn:SetScript("OnMouseDown", function(self)
                WoWTools_ChatMixin:Chat(self.itemLink, nil, true)
            end)
            btn:SetScript("OnLeave",function(self)
                self:GetNormalTexture():SetAlpha(0.5)
                GameTooltip:Hide()
            end)
        end

        btn.itemLink= itemLink
        if sources[index].isCollected then
            btn:GetNormalTexture():SetVertexColor(0,1,0, 0.5)
        else
            btn:GetNormalTexture():SetVertexColor(1,0,0, 0.5)
        end
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
        local texture= WoWTools_TextureMixin:CreateBG(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)
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
    WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame:HookScript('OnShow', function()
        if Save().hideSets then
            TipsLabel:SetText('')
        end
    end)

--幻化，套装，索引
    hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame, 'UpdateSets', function(...) set_Sets_Tooltips(...) end)


--套装，列表
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(...) Set_List_Button(...) end)




    --套装,物品, Link WardrobeSetsCollectionMixin
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', function(...) Init_Wardrobe_DetailsFrame(...) end)
     --hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'DisplaySet', function(...)
        

    return true
end


















function WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    if not Save().hideSets and Init() then
        Init=function()end
    end
end