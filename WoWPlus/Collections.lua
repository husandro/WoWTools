local id, e = ...
local addName= COLLECTIONS
local panel=CreateFrame("Frame")
local Save={
    --hideDressUpOutfit= true,--试衣间, 外观列表
    --hideSets= true,--套装, 幻化, 界面
    --hideHeirloom= true,--传家宝
    --hideItems= true,--物品, 幻化, 界面
    --hideToyBox= true,--玩具
}









--外观保存数据wowSave={[1]={class=str,numCollected=number, numTotal=number}
local wowSaveSets = {
    ['1']={['class']='WARRIOR'},
    ['2']={['class']='PALADIN'},
    ['4']={['class']='HUNTER'},
    ['8']={['class']='ROGUE'},
    ['16']={['class']='PRIEST'},
    ['32']={['class']='DEATHKNIGHT'},
    ['64']={['class']='SHAMAN'},
    ['128']={['class']='MAGE'},
    ['256']={['class']='WARLOCK'},
    ['512']={['class']='MONK'},
    ['1024']={['class']='DRUID'},
    ['2048']={['class']='DEMONHUNTER'},
    ['4096']={['class']='EVOKER'},
}
local wowSave2= wowSaveSets--套装, 幻化, 界面
local wowSaveItems={}
local slots = {--wowSaveItems
    "|A:transmog-nav-slot-head:0:0|a",
    "|A:transmog-nav-slot-shoulder:0:0|a",
    "|A:transmog-nav-slot-back:0:0|a",
    "|A:transmog-nav-slot-chest:0:0|a",
    "|A:transmog-nav-slot-shirt:0:0|a",
    "|A:transmog-nav-slot-tabard:0:0|a",
    "|A:transmog-nav-slot-wrist:0:0|a",
    "|A:transmog-nav-slot-hands:0:0|a",
    "|A:transmog-nav-slot-waist:0:0|a",
    "|A:transmog-nav-slot-legs:0:0|a",
    "|A:transmog-nav-slot-feet:0:0|a",
    "|T135139:0|t",--魔杖
    '|T132392:0|t',--13单手斧
    '|A:transmog-nav-slot-mainhand:0:0|a',--14单手剑
    '|T133476:0|t',--15单手锤
    '|T132324:0|t',--16匕首
    '|T132965:0|t',--17拳套
    '|A:transmog-nav-slot-secondaryhand:0:0|a',--18副手
    '|T652302:0|t',--19副手物品    
    '|T132400:0|t',--20双手斧
    '|T135327:0|t',--21双手剑
    '|T133044:0|t',--22双手锤
    '|T135145:0|t',--23法杖
    '|T135129:0|t',--24长柄武器
    '|T135490:0|t',--25弓
    '|T135610:0|t',--26枪械
    '|T135530:0|t',--27弩
    nil,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}




















--###############
--试衣间, 外观列表
--DressUpFrames.lua
local function Init_DressUpFrames()--试衣间, 外观列表
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(self, transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
        local link
        if not Save.hideDressUpOutfit and transmogID then
            if self.item then
                link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID));
            else
                link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID));
            end
        end
        if link and not self.btn then
            self.btn=e.Cbtn(self, {icon=true, size={20,20}})
            self.btn:SetPoint('RIGHT')
            self.btn:SetAlpha(0.3)
            self.btn:SetScript('OnEnter', function(self2, d)
                if self2.link and self2.link:find('item') then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:SetHyperlink(self2.link)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, e.Icon.left)
                    e.tips:AddDoubleLine(e.onlyChinese and '外观' or WARDROBE, e.Icon.right)
                    e.tips:Show()
                end
            end)
            self.btn:SetScript('OnLeave', function ()
                e.tips:Hide()
            end)
            self.btn:SetScript('OnMouseDown', function (self2, d)
                if self2.link then
                    if d=='LeftButton' then
                        local chat=SELECTED_DOCK_FRAME
                        ChatFrame_OpenChat(chat.editBox:GetText()..self2.link, chat)
                    elseif d=='RightButton' then
                        if not IsAddOnLoaded("Blizzard_Collections") then LoadAddOn('Blizzard_Collections') end
                        local wcFrame= WardrobeCollectionFrame
                        if not CollectionsJournal:IsVisible() or not wcFrame:IsVisible() then
                        ToggleCollectionsJournal(5)
                        end
                        if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                            wcFrame:ClickTab(wcFrame.ItemsTab);
                        end
                        if self2.transmogLocation then
                            WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(self2.transmogLocation)
                        end
                        WardrobeCollectionFrameSearchBox:SetText(self2.name or '')
                    end
                end
            end)
        end
        if self.btn then
            self.btn.link=link
            self.btn.name=name
            self.btn.transmogLocation=self.transmogLocation
            if icon then
                self.btn:SetNormalTexture(icon)
            end
            self.btn:SetShown(link and true or false)
        end
    end)

    if DressUpFrame and DressUpFrame.OutfitDetailsPanel then
        local sel= e.Cbtn(DressUpFrame.OutfitDetailsPanel, {icon=Save.hideDressUpOutfit, size={16,16}})
        sel:SetPoint('BOTTOMRIGHT', -5, 10)
        sel:SetAlpha(0.3)
        sel:SetScript('OnMouseDown', function ()
            Save.hideDressUpOutfit= not Save.hideDressUpOutfit and true or nil
            print(id, addName, e.onlyChinese and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.hideDressUpOutfit),e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
            sel:SetNormalAtlas(Save.hideDressUpOutfit and e.Icon.disabled or e.Icon.icon)
        end)
        sel:SetScript('OnEnter', function (self2)
            e.tips:SetOwner(self2, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(e.onlyChinese and '外观列表' or DRESSING_ROOM_APPEARANCE_LIST, e.GetShowHide(not Save.hideDressUpOutfit)..e.Icon.left)
            e.tips:Show()
        end)
        sel:SetScript('OnLeave', function ()
            e.tips:Hide()
        end)
    end
end





































--###############
--套装, 幻化, 界面
--Blizzard_Wardrobe.lua
local function Set_Sets_Colleced()--收集所有角色套装数据
    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts()
    if not numCollected or not numTotal or numTotal<=0 then
        return
    end
    for index, info in pairs(wowSaveSets) do
        if info.class==e.Player.class then
            wowSaveSets[index].numCollected= numCollected
            wowSaveSets[index].numTotal= numTotal
            break
        end
    end

    --显示数据
    local frame= (WardrobeCollectionFrame and WardrobeCollectionFrame.SetsCollectionFrame) and WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
    if not frame or Save.hideSets then
        if frame and frame.PlayerCoollectedStr then
            frame.PlayerCoollectedStr:SetText('')
        end
        return
    end

    numCollected,numTotal=0, 0
    local m=''
    for _, info in pairs(wowSaveSets) do
        if info.numCollected and info.numTotal and info.numTotal > 0 then
            numCollected = numCollected + info.numCollected
            numTotal = numTotal + info.numTotal
            local value=math.modf(info.numCollected/info.numTotal*100)
            local t='|A:classicon-'..info.class..':0:0|a'
            t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
            t=t..' '..info.numCollected..'/'..info.numTotal
            t = info.numCollected<info.numTotal and '|c'..select(4,GetClassColor(info.class))..t..'|r' or '|cnGREEN_FONT_COLOR:'..t..'|r'
            m=m..t..'|n'
        end
    end
    if numTotal>0 then
        m=m..ITEM_PET_KNOWN:format(numCollected, numTotal)..' '.. ('%i%%'):format(numCollected/numTotal*100)
    end
    if not frame.PlayerCoollectedStr then
        frame.PlayerCoollectedStr=e.Cstr(frame)
        frame.PlayerCoollectedStr:SetPoint('BOTTOMLEFT', 10, 60)
        --frame.PlayerCoollectedStr:SetJustifyH('LEFT');
    end
    frame.PlayerCoollectedStr:SetText(m)
end



--[[
local function get_Sets_Text(sets, isToolstips)
    local header, Limited, version, lable, tip, buttonTip
    local maxNum=0
    for _, info in pairs(sets) do
        if info and info.setID then
            local numCollected, _, numAll = e.GetSetsCollectedNum(info.setID)
            if numCollected and numAll then
                maxNum= (not maxNum or maxNum<numAll) and numAll or maxNum

                if not header then
                    header= info.name
                    header= info.limitedTimeSet and header..'|n'..e.Icon.clock2..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '限时套装' or TRANSMOG_SET_LIMITED_TIME_SET)..'|r' or header
                    header = info.label and header..'|n|cnBRIGHTBLUE_FONT_COLOR:'..info.label..'|r' or header
                    version=info.expansionID and _G['EXPANSION_NAME'..info.expansionID]
                    header = header ..(version and '|n'..'|cnGREEN_FONT_COLOR:'..version..'|r' or '')..(info.patchID and ' toc v.'..info.patchID or '')
                end

                lable= (lable or '')..numCollected..' '

                local num= numCollected..'/'..(numAll<=9 and e.Icon.number2:format(numAll) or numAll)

                tip=(tip or '')..num..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..(isToolstips and ' setID: '..info.setID or '')..'|n'

                buttonTip= (buttonTip or '')..num..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..' setID'..info.setID..'|n'

                Limited= info.limitedTimeSet and true or Limited
            end
        end
    end
    
    return header, Limited, version, lable, tip, buttonTip, maxNum
end--]]
local function Init_Wardrobe_Sets()
    --local frame= WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
    

    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(btn, displayData)--外观列表    
        local setID= displayData.setID
        local sets= setID and C_TransmogSets.GetVariantSets(setID)
        if not sets or type(sets)~='table' or Save.hideSets then
           if btn.set_Rest then
            btn:set_Rest()
           end
           return
        end

        if not btn.set_Rest then
            btn:SetScript("OnEnter",function(self)
                if not Save.hideSets then
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")--,8,-300)
                    e.tips:ClearLines()
                    e.tips:AddLine(self.tooltip)
                    e.tips:Show()
                end
            end)
            btn:SetScript("OnLeave",function()
                e.tips:Hide()
            end)
            btn.maxNum=e.Cstr(btn, {size=16, mouse=true})--套装最大数量
            btn.maxNum:SetPoint('BOTTOMRIGHT', btn.Icon)
            btn.maxNum:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.maxNum:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '物品数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, AUCTION_HOUSE_QUANTITY_LABEL))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
            btn.version=e.Cstr(btn)--版本
            btn.version:SetPoint('BOTTOMRIGHT',-5, 5)
            btn.limited=btn:CreateTexture(nil, 'OVERLAY')--限时
            btn.limited:SetSize(16, 16)
            btn.limited:SetAtlas(e.Icon.clock)
            btn.limited:SetPoint('TOPLEFT', btn.Icon)
            btn.limited:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.limited:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '限时套装' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TRANSMOG_SET_LIMITED_TIME_SET, WARDROBE_SETS))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
            btn.numSetsLabel=e.Cstr(btn, {size=16, mouse=true})
            btn.numSetsLabel:SetPoint('BOTTOMLEFT', btn.Icon)
            btn.numSetsLabel:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.numSetsLabel:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '套装数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WARDROBE_SETS, AUCTION_HOUSE_QUANTITY_LABEL))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
            function btn:set_Rest()
                self.maxNum:SetText('')
                self.limited:SetShown(false)
                self.version:SetText('')
                self.numSetsLabel:SetText('')
                self.tooltip=nil
            end
        end

        table.insert(sets, C_TransmogSets.GetSetInfo(setID))
        table.sort(sets, function(a, b)
            return a.uiOrder < b.uiOrder
        end)

        local text, version, isLimited
        local tipsText= btn.Name:GetText()
        tipsText= tipsText and tipsText..'|n' or ''
        local maxNum=0
        
        for index, info in pairs(sets) do
            if info and info.setID then
                local numCollected, _, numAll = e.GetSetsCollectedNum(info.setID, nil, true)
                if numCollected and numAll then
                    if info.setID==setID then maxNum= numAll end
                    text= (text or '')..numCollected..' '
                    version= version or _G['EXPANSION_NAME'..(info.expansionID or '')]
                    isLimited= isLimited or info.limitedTimeSet
                    
                    tipsText= tipsText..'|n '
                        ..(isLimited and e.Icon.clock2 or '')
                        ..((info.description or info.name) or '')
                        ..' '..numCollected.. '/'..numAll
                        --..' setID '..info.setID
                end
            end
        end
        btn.tooltip= tipsText

        btn.Label:SetText(text)

        btn.maxNum:SetTextColor(btn.Name:GetTextColor())
        btn.maxNum:SetText(maxNum~=0 and maxNum or '')--套装最大数量

        btn.limited:SetShown(isLimited and true or false)--限时
       
        btn.version:SetText(version or '')--版本
        btn.version:SetTextColor(btn.Name:GetTextColor())

        local numStes= #sets
        btn.numSetsLabel:SetText(numStes>1 and numStes or '')
        btn.numSetsLabel:SetTextColor(btn.Name:GetTextColor())
    end)

    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'OnClick', function(btn, buttonName)--点击，显示套装情况Blizzard_Wardrobe.lua
        if buttonName == "LeftButton" then
            if btn.tooltip and not WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str then
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str=e.Cstr( WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str:SetPoint('BOTTOMLEFT',  WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, 'LEFT', 8 , 0)
            end
            if WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str then
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str:SetText(btn.tooltip or '')
            end
        end
    end)

    --套装物品Link
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', function(_, itemFrame)
        if Save.hideSets then
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
                btn=e.Cbtn(itemFrame, {icon=true, size={26,10}})
                btn:SetNormalAtlas('adventure-missionend-line');
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
                        e.tips:ClearLines()
                        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                        e.tips:SetHyperlink(self2.link)
                        e.tips:Show()
                end)
                btn:SetScript("OnMouseDown", function(self2)
                        if ( self2.link ) then
                            local chat=SELECTED_DOCK_FRAME
                            ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)
                        end
                end)
                btn:SetScript("OnLeave",function(self2)
                        self2:SetAlpha(0.2)
                        e.tips:Hide()
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
    end)

    local check =e.Cbtn( WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, {icon=not Save.hideSets, size={18,18}})--隐藏选项
    
    function check:set_All_Sets()--所以有套装情况
        if Save.hideSets then
            if  WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets then
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets:SetText('')
            end
            return
        end
        local sets =C_TransmogSets.GetAllSets()
        if sets then
            local tempSave=wowSave2
            local a, h, o=0, 0, 0--联盟, 部落, 其它
            for _, info in pairs(sets) do
                if info and info.classMask and info.setID then
                    local c=info.classMask..''--bit.bor(v.classMask)
                    if tempSave[c] then
                        tempSave[c].collected=tempSave[c].collected or 0
                        if info.collected then
                            tempSave[c].collected=tempSave[c].collected+1
                        end
                        tempSave[c].all=tempSave[c].all and tempSave[c].all + 1 or 1
                    end
                    if info.requiredFaction=='Alliance' then
                        a=a+1
                    elseif info.requiredFaction=='Horde' then
                        h=h+1
                    else
                        o=o+1
                    end
                end
            end
            local m=''
            local collected, all=0 , 0
            for _, info in pairs(tempSave) do
                if info.collected and info.all and info.all>0 and info.class then
                    local value=math.modf(info.collected/info.all*100)
                    local t=info.collected..'/'..info.all..' '
                    t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
                    t=t..'|A:classicon-'..info.class..':0:0|a'
                    t='|c'..select(4,GetClassColor(info.class))..t..'|r'
                    m=m..t..'|n'
                    collected=info.collected + collected
                    all=info.all + all
                end
            end
            if all>0 then
                m=m..collected..'/'..all..' '..('%i%%'):format(collected/all*100)..' '..LFG_LIST_CROSS_FACTION:format(CLASS)
            end
            if a > 0 or h>0 or o>0 then
                m=m..'|n|n'..h..' |A:communities-create-button-wow-horde:0:0|a'
                m=m..'|n'..a..' |A:communities-create-button-wow-alliance:0:0|a'
                m=m..'|n'..o..' |A:communities-guildbanner-background:0:0|a'
                m=m..'|n'..#sets..' '..LFG_LIST_CROSS_FACTION:format(FACTION)
            end
            if not  WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets then
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets=e.Cstr(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets:SetPoint('BOTTOMRIGHT', -6, 60)
                WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets:SetJustifyH('RIGHT')
            end
            WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.AllSets:SetText(m)
        end
    end
    
    check:SetPoint('BOTTOMRIGHT',-16, 28)
    check:SetAlpha(0.5)
    check:SetScript("OnClick", function(self)
        Save.hideSets= not Save.hideSets and true or nil
        if Save.hideSets and WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str then--点击，显示套装情况
            WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.str:SetText('')----点击，显示套装情况Blizzard_Wardrobe.lua
        end
        --print(id, addName, e.GetShowHide(not Save.hideSets), e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        self:set_All_Sets()--所以有套装情况
        Set_Sets_Colleced()--收集所有角色套装数据
        self:SetNormalAtlas(Save.hideSets and e.Icon.disabled or e.Icon.icon)
        self:set_tooltips()
        WardrobeCollectionFrame.SetsCollectionFrame:Refresh()
    end)
    function check:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.onlyChinese and '套装' or WARDROBE_SETS, e.GetShowHide(not Save.hideSets)..e.Icon.left)
        e.tips:Show()
    end
    check:SetScript('OnEnter', check.set_tooltips)
    check:SetScript('OnLeave', function()e.tips:Hide() end)

    check:set_All_Sets()--所以有套装情况
    C_Timer.After(2, Set_Sets_Colleced)--收集所有角色套装数据
end




































--#####
--传家宝
--Blizzard_HeirloomCollection.lua
local function Init_Heirloom()
    hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
        if Save.hideHeirloom then
            if button.isPvP then
                button.isPvP:SetShown(false)
            end
            if button.upLevel then
                button.upLevel:SetShown(false)
            end
            if button.itemLevel then
                button.itemLevel:SetText('')
            end
            for index=1 ,4 do
                local text=button['statText'..index]
                if text then
                    text:SetText('')
                end
            end
            return
        end
        local _, _, isPvP, _, upgradeLevel = C_Heirloom.GetHeirloomInfo(button.itemID);

        local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) or 0;
        local level= maxUp-(upgradeLevel or 0)
        local has = C_Heirloom.PlayerHasHeirloom(button.itemID)
        if has then--需要升级数
            if not button.upLevel then
                button.upLevel = button:CreateTexture(nil, 'OVERLAY')
                button.upLevel:SetPoint('TOPLEFT', -4, 4)
                button.upLevel:SetSize(26,26)
                button.upLevel:SetVertexColor(1,0,0)
                button.upLevel:EnableMouse(true)
                button.upLevel:SetScript('OnLeave', function() e.tips:Hide() end)
                button.upLevel:SetScript('OnEnter', function(self2)
                    if self2.maxUp and self2.upgradeLevel then
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddLine(format(e.onlyChinese and '传家宝升级等级：%d/%d' or HEIRLOOM_UPGRADE_TOOLTIP_FORMAT, self2.upgradeLevel, self2.maxUp))
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:Show()
                    end
                end)
                button.upLevel:SetScript('OnMouseDown', function(self2)
                    local itemID= self2:GetParent().itemID
                    if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                        C_Heirloom.CreateHeirloom(itemID)
                    end
                end)
            end
        end
        if button.upLevel then
            button.upLevel.maxUp= maxUp
            button.upLevel.upgradeLevel= upgradeLevel
            button.upLevel:SetShown(has and level>0)
            if level>0 then
                button.upLevel:SetAtlas(e.Icon.number..level)
            else
                button.upLevel:SetTexture(0)
            end
        end

        if isPvP and not button.isPvP then
            button.isPvP=button:CreateTexture(nil, 'OVERLAY')
            button.isPvP:SetPoint('TOP')
            button.isPvP:SetSize(14, 14)
            button.isPvP:SetAtlas('honorsystem-icon-prestige-6')
            button.isPvP:EnableMouse(true)
            button.isPvP:SetScript('OnLeave', function() e.tips:Hide() end)
            button.isPvP:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '竞技装备' or ITEM_TOURNAMENT_GEAR)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            button.isPvP:SetScript('OnMouseDown', function(self2)
                local itemID= self2:GetParent().itemID
                if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                    C_Heirloom.CreateHeirloom(itemID)
                end
            end)
        end
        if button.isPvP then
            button.isPvP:SetShown(isPvP)
        end
        if not button.moved and button.level then--设置，等级数字，位置
            button.level:ClearAllPoints()
            button.level:SetPoint('TOPRIGHT', button, 'TOPRIGHT')

            button.levelBackground:ClearAllPoints()
            button.levelBackground:SetPoint('TOPRIGHT', button, 'TOPRIGHT',-2,-2)
            button.levelBackground:SetAlpha(0.5)

            button.slotFrameCollected:SetTexture(0)--外框架
            button.slotFrameCollected:SetShown(false)
            button.slotFrameCollected:SetAlpha(0)
            button.moved= true
        end
        if level==0 then
            button.level:SetText('')
        end

        e.Set_Item_Stats(button, C_Heirloom.GetHeirloomLink(button.itemID), {point=button.iconTexture, itemID=button.itemID, hideSet=true, hideLevel=not has, hideStats=not has})--设置，物品，4个次属性，套装，装等，
    end)


    local check=e.Cbtn(HeirloomsJournal, {icon=not Save.hideHeirloom, size={18,18}})
    check:SetPoint('BOTTOMRIGHT',-25, 35)
    check:SetAlpha(0.5)
    function check:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideHeirloom), e.Icon.left)
        e.tips:Show()
    end
    check:SetScript('OnClick',function (self)
        Save.hideHeirloom= not Save.hideHeirloom and true or nil
        self:SetNormalAtlas(Save.hideHeirloom and e.Icon.disabled or e.Icon.icon)
        securecall(HeirloomsJournal.FullRefreshIfVisible, HeirloomsJournal)
        --HeirloomsJournal:FullRefreshIfVisible()
        self:set_tooltips()
    end)
    check:SetScript('OnLeave', function () e.tips:Hide() end)
    check:SetScript('OnEnter', check.set_tooltips)
end








































--###############
--物品, 幻化, 界面
--###############
local function get_Items_Colleced()
    local List={}--保存数据
    for i=1, 29 do
        local all=C_TransmogCollection.GetCategoryTotal(i)
        local name= C_TransmogCollection.GetCategoryInfo(i)
        if name and all>0 then
            table.insert(List, {
                Name=name,
                Icon=slots[i] or e.Icon.icon,
                Collected=C_TransmogCollection.GetCategoryCollectedCount(i),
                All=all,
            })
        end
    end
    local visualsList=C_TransmogCollection.GetIllusions() or {}
    local totale = #visualsList;
    if totale>0 then
        local collected = 0;
        for i, illusion in ipairs(visualsList) do
            if ( illusion.isCollected ) then
                collected = collected + 1;
            end
        end
        table.insert(List, {
            Name=WEAPON_ENCHANTMENT,
            Icon='|A:transmog-nav-slot-enchant:0:0|a',
            Collected=collected,
            All=totale,
        })
    end
    wowSaveItems[e.Player.class]=List


    local Frame= WardrobeCollectionFrame and WardrobeCollectionFrame.ItemsCollectionFrame
    if not Frame then
        return
    elseif Save.hideItems then--禁用
        for class, _ in pairs (wowSaveItems) do
            local label=Frame[addName..class]
            if label then
                label:SetText('')
                label.tip=nil
            end
        end
        if Frame[addName..'All'] then--总数字符
            Frame[addName..'All']:SetText('')
        end
        return
    end

    --设置内容
    local last, initStr
    local totaleCollected, totaleAll, totaleClass = 0, 0, 0--总数
    for class, type in pairs (wowSaveItems) do

        local label=Frame[addName..class]
        if not label then
            label=e.Cstr(Frame)
            if not last then
                initStr=label--总数字符用
                label:SetPoint('BOTTOMRIGHT', 5, 80)
            else
                label:SetPoint('BOTTOMRIGHT', last, 'TOPRIGHT', 0, 2)
            end
            label:SetJustifyH('RIGHT')
            label:EnableMouse(true)
            label:SetScript('OnEnter', function(self2)--鼠标提示
                if self2.tip then
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    local n=1
                    for _, info2 in pairs(self2.tip) do
                        if info2.name then
                            if select(2, math.modf(n/2))==0 then
                                e.tips:AddDoubleLine(info2.name, info2.num, 1,0.5,0, 1, 0.5,0)
                            else
                                e.tips:AddDoubleLine(info2.name, info2.num)
                            end
                        else
                            e.tips:AddLine(' ')
                        end
                        n=n+1
                    end
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName, 1,1,1, 1,1,1)
                    e.tips:Show()
                end
            end)
            label:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        local tip={}--提示用
        local collected, all = 0, 0
        for _, info in pairs(type) do
            collected = collected + info.Collected
            all = all + info.All
            table.insert(tip, {
                name=info.Icon..(info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Name..'|r' or (info.Name..format(' %i%%', info.Collected/info.All*100))),
                num= info.Collected==info.All and '|cnGREEN_FONT_COLOR:'..info.Collected..'/'.. info.All..'|r' or info.Collected..'/'.. info.All
            })
        end
        totaleCollected= totaleCollected+ collected
        totaleAll= totaleAll+ all
        totaleClass= totaleClass +1

        local per=(' %i%%'):format(collected/all*100)
        local collectedText, allText = e.MK(collected,3), e.MK(all,3)

        local col='|c'..select(4,GetClassColor(class))
        label:SetText(col..collectedText..' '..per..'|A:classicon-'..class..':0:0|a|r')

        table.insert(tip,1,{})
        table.insert(tip, 1, {
            name='|A:classicon-'..class..':0:0|a '..col..per..'|r',
            num=col..collectedText..'/'..allText..'|r',
        })
        label.tip=tip

        Frame[addName..class]=label
        last=label
    end

    local str= Frame[addName..'All']--总数字符
    if not str and initStr then
        str=e.Cstr(Frame)
        str:SetPoint('TOPRIGHT', initStr, 'BOTTOMRIGHT', 0, -10)
        str:SetJustifyH('RIGHT')
        Frame[addName..'All']=str
    end
    if str and totaleAll>0 then
        str:SetText(totaleClass..(e.onlyChinese and '职业' or CLASS)..format('  %i%%  ', totaleCollected/totaleAll*100)..e.MK(totaleCollected, 3)..'/'..e.MK(totaleAll,3)..e.Icon.wow2)
    end
end

local function Init_Wardrober_Items()--物品, 幻化, 界面
    local Frame=WardrobeCollectionFrame.ItemsCollectionFrame
    Frame.sel=e.Cbtn(Frame, {icon=not Save.hideItems, size={18,18}})
    Frame.sel:SetPoint('BOTTOMRIGHT',-19, 30)
    Frame.sel:SetAlpha(0.5)
    Frame.sel:SetScript('OnMouseDown',function (self2)
        Save.hideItems= not Save.hideItems and true or nil
        print(id, addName,e.GetEnabeleDisable(not Save.hideItems), e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        self2:SetNormalAtlas(Save.hideItems and e.Icon.disabled or e.Icon.icon)
        get_Items_Colleced()
    end)
    Frame.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideItems), e.Icon.left)
        e.tips:Show()
    end)
    Frame.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)

    C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面

    local function get_Link_Item_Type_Source(sourceID, type)
        if sourceID then
            if type=='item' then
                return WardrobeCollectionFrame:GetAppearanceItemHyperlink(sourceID)
            else--if type=='illusion' then
                return select(2, C_TransmogCollection.GetIllusionStrings(sourceID))
            end
        end
    end
    hooksecurefunc(Frame, 'UpdateItems', function(self)--WardrobeItemsCollectionMixin:UpdateItems() Blizzard_Wardrobe.lua local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
        for i= 1, self.PAGE_SIZE do
            local model = self.Models[i];
            if model and model:IsShown() then
                model.itemButton=model.itemButton or {}
                local itemLinks={}
                if not Save.hideItems then
                    local findLinks={}
                    if self.transmogLocation:IsIllusion() then--WardrobeItemsModelMixin:OnMouseDown(button)
                        local link =  get_Link_Item_Type_Source(model.visualInfo.sourceID, 'illusion')--select(2, C_TransmogCollection.GetIllusionStrings(model.visualInfo.sourceID))
                        if link then
                            e.LoadDate({id=link, type='item'})--加载 item quest spell
                            table.insert(itemLinks, {link= link, sourceID= model.visualInfo.sourceID, type='illusion'})
                        end
                    else
                        local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(model.visualInfo.visualID, self:GetActiveCategory(), self.transmogLocation) or {}
                        for index= 1, #sources do
                            local link = get_Link_Item_Type_Source(sources[index],'item')--WardrobeCollectionFrame:GetAppearanceItemHyperlink(sources[index])
                            if link and not findLinks[link] then
                                e.LoadDate({id=link, type='item'})--加载 item quest spell
                                table.insert(itemLinks, {link=link, sourceID=sources[index], type='item'})
                                findLinks[link]=true
                            end
                        end
                    end
                    findLinks=nil

                    local y, x, h =0,0, 11
                    for index, tab in pairs(itemLinks) do
                        local btn= model.itemButton[index]
                        if not btn then
                            btn=e.Cbtn(model, {icon='hide', size=index==1 and {14.4, 14.4} or {h,h}})
                            if index==1 then
                                btn:SetPoint('BOTTOMLEFT', -4, -4)
                            else
                                btn:SetPoint('BOTTOMLEFT', x, y)
                            end

                            if index>1 then
                                btn:SetAlpha(0.5)
                            end

                            btn:SetScript("OnEnter",function(self2)
                                local link2= get_Link_Item_Type_Source(self2.sourceID, self2.type) or self2.link
                                if link2 then
                                    self2:SetAlpha(1)
                                    e.tips:ClearLines()
                                    e.tips:SetOwner(self2:GetParent():GetParent(), "ANCHOR_RIGHT",8,-300)
                                    if self2.illusionID then       
                                        local name, _, sourceText = C_TransmogCollection.GetIllusionStrings(self2.illusionID)
                                        e.tips:AddLine(name)
                                        e.tips:AddLine(' ')
                                        e.tips:AddLine(sourceText, 1,1,1, true)
                                        e.tips:AddLine(' ')
                                        local info = C_TransmogCollection.GetIllusionInfo(self2.illusionID)
                                        if info then
                                            e.tips:AddDoubleLine('visualID '..(info.visualID or ''), 'sourceID '..(info.sourceID or ''))
                                            e.tips:AddDoubleLine(info.icon and '|T'..info.icon..':0|t'..info.icon or '', 'isHideVisual '..(info.isHideVisual and 'true' or 'false'))
                                            e.tips:AddDoubleLine(info.isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'),
                                                                info.isUsable and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '可用' or AVAILABLE)..'|r' or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '不可用' or UNAVAILABLE)..'|r'))
                                            e.tips:AddLine(' ')
                                        end
                                    else
                                        e.tips:SetHyperlink(link2)
                                    end
                                    e.tips:AddLine(' ')
                                    e.tips:AddDoubleLine(e.onlyChinese and '发送' or SEND_LABEL, e.Icon.left)
                                    e.tips:Show()
                                   e.tips:AddDoubleLine(id, addName)
                                 end
                            end)
                            btn:SetScript("OnClick", function(self2)
                                local link2= get_Link_Item_Type_Source(self2.sourceID, self2.type) or self2.link
                                if link2 then
                                    local chat=SELECTED_DOCK_FRAME
                                    ChatFrame_OpenChat((chat.editBox:GetText() or '')..link2, chat)
                                end
                            end)
                            btn:SetScript("OnLeave",function(self2)
                                self2:SetAlpha(0.5)
                                e.tips:Hide()
                            end)
                            model.itemButton[index]=btn
                        end
                        if index~=1 and select(2, math.modf(index / 10))==0 then
                            x= x+ h
                            y=0
                        else
                            y=y+ h
                        end
                        local illusionID= tab.link:match('Htransmogillusion:(%d+)') or tab.type=='illusion'
                        if index==1 then
                            local icon
                            if illusionID and illusionID~=true then
                                local info = C_TransmogCollection.GetIllusionInfo(illusionID)
                                icon= info and info.icon
                            end
                            icon= icon or C_Item.GetItemIconByID(tab.link)
                            if icon then
                                btn:SetNormalTexture(icon)
                            else
                                btn:SetNormalAtlas('adventure-missionend-line')
                            end
                        elseif index<=10 then
                            btn:SetNormalAtlas('services-number-'..(index-1))
                        else
                            btn:SetNormalAtlas('adventure-missionend-line')
                        end
                        btn.link=tab.link
                        btn.sourceID= tab.sourceID
                        btn.type= tab.type
                        btn.illusionID= illusionID
                        btn.index=index
                        btn:SetShown(true)
                    end
                end
                for index= #itemLinks+1, #model.itemButton do
                    model.itemButton[index]:SetShown(false)
                end
            end
        end
    end)
end






--###
--玩具
--###
local function Init_ToyBox()
    local function ToyFun(self)
        if Save.hideToyBox then
            self:SetAlpha(1)
            return
        end
        local isUas=C_ToyBox.IsToyUsable(self.itemID)
        local _, duration, enable = GetItemCooldown(self.itemID)
        if not isUas then
            self:SetAlpha(0.5)
        elseif enable==1 and duration>0 then
            self:SetAlpha(0.4)
            self.name:SetTextColor(1,0,0)
        else
            self:SetAlpha(1)
        end
    end

    hooksecurefunc('ToySpellButton_OnClick', ToyFun)--Blizzard_ToyBox.lua
    hooksecurefunc('ToySpellButton_UpdateButton', ToyFun)

    local toyframe=ToyBox
    toyframe.sel=e.Cbtn(toyframe, {icon=not Save.hideToyBox, size={18,18}})
    toyframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    toyframe.sel:SetAlpha(0.5)
    toyframe.sel:SetScript('OnMouseDown',function (self2)
        Save.hideToyBox= not Save.hideToyBox and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.hideToyBox), e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        self2:SetNormalAtlas(Save.hideToyBox and e.Icon.disabled or e.Icon.icon)
    end)
    toyframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideToyBox), e.Icon.left)
        e.tips:Show()
    end)
    toyframe.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)
end



































--#########
--坐骑, 界面
--#########
local function Init_Mount()
    hooksecurefunc('MountJournal_UpdateMountDisplay', function()--坐骑
        if not MountJournal.MountDisplay.infoButton then
            MountJournal.MountDisplay.infoButton= e.Cbtn(MountJournal.MountDisplay, {size={22,22}, atlas='QuestNormal'})
            MountJournal.MountDisplay.infoButton:SetPoint('BOTTOMRIGHT', MountJournal.MountDisplay.ModelScene.TogglePlayer, 'TOPRIGHT',0, 2)
            MountJournal.MountDisplay.infoButton.text= e.Cstr(MountJournal.MountDisplay, {copyFont= MountJournal.MountCount.Label, color=false, justifyH='LEFT'})
            MountJournal.MountDisplay.infoButton.text:SetPoint('BOTTOMLEFT', 2, 2)
            
            function MountJournal.MountDisplay.infoButton:set_Alpha()
                self:SetAlpha(Save.ShowMountDisplayInfo and 0.2 or 1)
            end
            function MountJournal.MountDisplay.infoButton:set_Tooltips()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '显示信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INFO), e.GetShowHide(Save.ShowMountDisplayInfo))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end
            function MountJournal.MountDisplay.infoButton:set_Text()
                local text
                if Save.ShowMountDisplayInfo then
                    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)
                    text= 'mountID '..MountJournal.selectedMountID
                        ..'|nanimID '..(animID or '')
                        ..'|nisSelfMount '.. (isSelfMount and 'true' or 'false')
                        ..'|nmountTypeID '..(mountTypeID or '')
                        ..'|nspellVisualKitID '..(spellVisualKitID or '')
                        ..'|nuiModelSceneID '..(uiModelSceneID or '')
                        ..'|ncreatureDisplayInfoID '..(creatureDisplayInfoID or '')
        
                        local _, spellID, icon, _, _, sourceType= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                        text= text..'|nspellID '..(spellID or '')
                                    ..'|nicon '..(icon and '|T'..icon..':0:0|t'..icon or '')
                                    ..'|nsourceType '..(sourceType or '').. (sourceType and _G['BATTLE_PET_SOURCE_'..sourceType] and ' ('.._G['BATTLE_PET_SOURCE_'..sourceType]..')' or '')
                end
                self.text:SetText(text or '')
            end
            MountJournal.MountDisplay.infoButton:SetScript('OnClick', function(self)
                Save.ShowMountDisplayInfo= not Save.ShowMountDisplayInfo and true or nil
                self:set_Text()
                self:set_Alpha()
                self:set_Tooltips()
            end)
            MountJournal.MountDisplay.infoButton:SetScript('OnLeave', function() e.tips:Hide() end)
            MountJournal.MountDisplay.infoButton:SetScript('OnEnter', MountJournal.MountDisplay.infoButton.set_Tooltips)
            MountJournal.MountDisplay.infoButton:set_Alpha()
        end
        MountJournal.MountDisplay.infoButton:set_Text()
    end)
end

    --[[
local showPlayer = GetCVarBool("mountJournalShowPlayer");
if not disablePlayerMountPreview and not showPlayer then
    disablePlayerMountPreview = true;
end
if not disablePlayerMountPreview then
    if MountJournal.MountDisplay.infoText then
        MountJournal.MountDisplay.infoText:SetText('')
    end
    return
end
    
过滤, 选项
    local mountTypeStrings = {
        [Enum.MountType.Ground] = MOUNT_JOURNAL_FILTER_GROUND,--0
        [Enum.MountType.Flying] = MOUNT_JOURNAL_FILTER_FLYING,
        [Enum.MountType.Aquatic] = MOUNT_JOURNAL_FILTER_AQUATIC,
        [Enum.MountType.Dragonriding] = MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    };

    local function set_Check()
        local Filtertab={
            {text = COLLECTED, set = function(value) C_MountJournal.SetCollectedFilterSetting(1, not value) end, isSet = function() C_MountJournal.GetCollectedFilterSetting(1) end},
            {text = NOT_COLLECTED, set = function(value) C_MountJournal.SetCollectedFilterSetting(2, not value) end, isSet = function() C_MountJournal.GetCollectedFilterSetting(2) end},
            {text = MOUNT_JOURNAL_FILTER_UNUSABLE,set = function(value) C_MountJournal.SetCollectedFilterSetting(3, not value) end, isSet = function() C_MountJournal.GetCollectedFilterSetting(3) end},
            {text= '-'},
        }
        for i = 1, Enum.MountTypeMeta.NumValues do
            if not C_MountJournal.IsValidTypeFilter(i) then
                break;
            end
            table.insert(Filtertab, {text= mountTypeStrings[i - 1],
                set=function(value)
                    C_MountJournal.SetTypeFilter(i, not value);
                    e.call(MountJournalResetFiltersButton_UpdateVisibility)
                end,
                isSet=function() return C_MountJournal.IsTypeChecked(i) end
            })
        end

        local y= 0
        for _, tab in pairs(Filtertab) do
            if tab.text~='-' then
                local check= MountJournal.MountDisplay[tab.text]
                if not check then
                    check= CreateFrame("CheckButton", nil, MountJournal.MountDisplay, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
                    check:SetPoint('LEFT', 0, y)
                    check:SetScript('OnClick', function()
                        tab.set(not tab.isSet)
                    end)
                    MountJournal.MountDisplay[tab.text]=check
                end
                check:SetChecked(tab.isSet())
                check.Text:SetText(tab.text)
            end
            y= y-18
        end
    end
    set_Check()
    hooksecurefunc('MountJournalResetFiltersButton_UpdateVisibility', set_Check)]]


--###########
--加载保存数据
--###########

























panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("TRANSMOGRIFY_ITEM_UPDATE")
panel:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            wowSaveSets=WoWToolsSave['WoW-CollectionWardrobeSets'] or wowSaveSets
            wowSaveItems=WoWToolsSave['WoW-CollectionWardrobeItems'] or wowSaveItems

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '收藏' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            --[[添加控制面板        
            local sel=e.AddPanel_Check('|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '收藏' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)]]

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init_DressUpFrames()--试衣间, 外观列表
                C_Timer.After(2, Set_Sets_Colleced)--收集所有角色套装数据
                C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面
            end

        elseif arg1=='Blizzard_Collections' then
            Init_ToyBox()--玩具
            Init_Heirloom()--传家宝
            Init_Wardrober_Items()--物品, 幻化, 界面
            Init_Wardrobe_Sets()--套装, 幻化, 界面
            Init_Mount()--坐骑, 界面
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
            WoWToolsSave['WoW-CollectionWardrobeSets']=wowSaveSets
            WoWToolsSave['WoW-CollectionWardrobeItems']=wowSaveItems
        end

    elseif event=='TRANSMOG_SETS_UPDATE_FAVORITE' then
        C_Timer.After(2, Set_Sets_Colleced)--收集所有角色套装数据

    elseif event=='TRANSMOGRIFY_ITEM_UPDATE' then
        C_Timer.After(2, get_Items_Colleced)--物品, 幻化, 界面
    end
end)
