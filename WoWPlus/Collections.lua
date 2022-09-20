local id, e = ...
local tips=GameTooltip
local addName=COLLECTIONS

local Save={
    --str925=true,
}


hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(self, transmogID, icon, name, useSmallIcon, slotState, isHiddenVisual)
        if not self or not self.Name or not self.item or not name then
            return
        end
        local link=self.item:GetItemLink()
        if link then
            local t=''

            local s=select(4,GetItemInfoInstant(link))            
            if s and _G[s] then t='|cffffd000('.._G[s]..')|r '  end

            if isHiddenVisual then
                t=t..HIDE
            else
                if slotState == 3 then
                    t=t..link..' |cffff0000'..NOT_COLLECTED..'|r'
                else
                    t=t..name
                end
            end

            if t~=name and t~=''then self.Name:SetText(t) end
        end
end)

hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)--试衣间
        if not self.item then
            return
        end
        local link=self.item:GetItemLink()
        if not link then return end

        tips:SetHyperlink(link,nil, nil, nil, true)

        if self.isHiddenVisual then
            return
        end
        local frame2=WardrobeCollectionFrame
        if not frame2 then return end

        local frame= frame2.ItemsCollectionFrame
        if not frame or not frame:IsShown() then return end

        local box=WardrobeCollectionFrameSearchBox
        --   if self and self.slotState~=3 then            
        local name=C_Item.GetItemNameByID(link)
        if not name or not box then return end

        box:SetText(name)
        local id=GetItemInfoInstant(link)
        if id then
            local _, sourceId = C_TransmogCollection.GetItemInfo(id)
            if sourceId then
                local category = C_TransmogCollection.GetAppearanceSourceInfo(sourceId)
                if ( category and frame:GetActiveCategory() ~= category ) then
                    frame:SetActiveCategory(category)
                end
            end
        end
        --local button=frame2.SlotsFrame.Buttons[self.slotID]                    
end)--DressUpFrames.lua

--外观
local wowSave = {
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
local wowSave2=wowSave

local function SetSaveWardroberColleced()--收集所有角色套装数据
    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts()
    for _,v in pairs(wowSave) do
        if v.class==e.Player.class then
            v.numCollected=numCollected
            v.numTotal=numTotal
            break
        end
    end
    local frame2=WardrobeCollectionFrame--显示数据
    if not frame2 or Save.disabledWardrobe then
        return
    end
    local frame=frame2.SetsCollectionFrame.DetailsFrame
    numCollected,numTotal=0, 0
    local m=''
    for _, info in pairs(wowSave) do
        if info.numCollected and info.numTotal and info.numTotal > 0 then
            numCollected = numCollected + info.numCollected
            numTotal = numTotal + info.numTotal
            local value=floor(info.numCollected/info.numTotal*100)
            local t='|A:classicon-'..info.class..':0:0|a'
            t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
            t=t..' '..info.numCollected..'/'..info.numTotal
            t = info.numCollected<info.numTotal and '|c'..select(4,GetClassColor(info.class))..t..'|r' or '|cnGREEN_FONT_COLOR:'..t..'|r'
            m=m..t..'\n'
        end
    end
    m=m..ITEM_PET_KNOWN:format(numCollected, numTotal)..' '.. ('%i%%'):format(numCollected/numTotal*100)
    if not frame.PlayerCoollectedStr then
        frame.PlayerCoollectedStr=e.Cstr(frame)
        frame.PlayerCoollectedStr:SetPoint('BOTTOMLEFT', 10, 60)
        frame.PlayerCoollectedStr:SetJustifyH('LEFT');
    end
    frame.PlayerCoollectedStr:SetText(m)
end

local function InitWardrobe()
    if Save.disabledWardrobe then
        return
    end
    local frame2=WardrobeCollectionFrame
    local list=WardrobeSetsScrollFrameButtonMixin

    local function GetSetsCollectedNum(setID)
        local info=C_TransmogSets.GetSetPrimaryAppearances(setID)
        local numCollected,numAll=0,0
        for _,v in pairs(info) do
            numAll=numAll+1
            if v.collected then
                numCollected=numCollected + 1
            end
        end
        if numCollected==numAll then
            return ' |A:transmog-icon-checkmark:6:6|a ', numAll
        elseif numAll <=9 then
            return e.Icon.number2:format(numAll-numCollected), numAll
        else
            return ' '..numAll-numCollected..' ', numAll
        end
    end
    hooksecurefunc(list, 'Init', function(button, displayData)--外观列表    
        local setID=displayData.setID
        local sets = C_TransmogSets.GetVariantSets(setID)
        if sets and type(sets)=='table' then
            table.insert(sets, C_TransmogSets.GetSetInfo(setID))
            table.sort(sets, function(a, b)
                return a.uiOrder < b.uiOrder
            end)

            local header, Limited, version
            local lable, tip, buttonTip= '', '',''
            local maxNum=0
            for k,info in pairs(sets) do
                local numCollected, numAll = GetSetsCollectedNum(info.setID)

                maxNum= (not maxNum or maxNum<numAll) and numAll or maxNum
                if not header then
                    header= info.name
                    header= info.limitedTimeSet and header..'\n'..e.Icon.clock2..'|cnRED_FONT_COLOR:'..TRANSMOG_SET_LIMITED_TIME_SET..'|r' or header
                    header = info.label and header..'\n|cnBRIGHTBLUE_FONT_COLOR:'..info.label..'|r' or header
                    version=info.expansionID and _G['EXPANSION_NAME'..info.expansionID]
                    header = header ..(version and '\n'..'|cnGREEN_FONT_COLOR:'..version..'|r' or '')..(info.patchID and ' top v.'..info.patchID or '')

                end
                lable=lable..numCollected..' '                
                tip=tip..numCollected..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..(info.setID and ' setID: '..info.setID or '')..'\n'
                buttonTip=buttonTip..numCollected..(info.description or info.name)..(info.limitedTimeSet and e.Icon.clock2 or '')..'\n'
                Limited= info.limitedTimeSet and true or Limited
            end

            button.tips=(version and version..'\n\n' or '')..buttonTip--点击，显示套装情况

            tip=(header and header..'\n\n' or '').. tip
            button:SetScript("OnEnter",function(self2)
                tips:SetOwner(frame2, "ANCHOR_RIGHT",8,-300)
                tips:ClearLines()
                tips:SetText(tip)
                tips:Show()
            end)
            button:SetScript("OnLeave",function()
                    tips:Hide()
            end)
            if button.Label then button.Label:SetText(lable) end

            if not button.maxNum then--套装最大数量
                button.maxNum=e.Cstr(button)
                button.maxNum:SetPoint('RIGHT',-5, 0)
            end
            button.maxNum:SetTextColor(button.Name:GetTextColor())
            button.maxNum:SetText(maxNum~=0 and maxNum or '')

            if Limited and not button.limited then--限时
                button.limited=button:CreateTexture(nil, 'OVERLAY')
                button.limited:SetPoint('TOPRIGHT',-5, -5)
                button.limited:SetSize(15,12)
                button.limited:SetAtlas(e.Icon.clock)
            end
            if button.limited then button.limited:SetShown(Limited) end
            if version and not button.version then--版本
                button.version=e.Cstr(button)
                button.version:SetPoint('BOTTOMRIGHT',-5, 5)
            end
            button.version:SetTextColor(button.Name:GetTextColor())
            button.version:SetText(version or '')
        end
    end)

    hooksecurefunc(list, 'OnClick', function(button, buttonName, down)--点击，显示套装情况Blizzard_Wardrobe.lua
        local frame=frame2.SetsCollectionFrame.DetailsFrame
        if not button.tips or buttonName ~= "LeftButton" then
            if frame.str then frame.str:SetShown(false) end
            return
        end
        if not frame.str then
            frame.str=e.Cstr(frame)
            frame.str:SetPoint('BOTTOMLEFT', frame, 'LEFT', 8 , 0)
            frame.str:SetJustifyH('LEFT')
        end
        frame.str:SetText(button.tips)
        frame.str:SetShown(true)
    end)

    --套装物品Link
    hooksecurefunc(frame2.SetsCollectionFrame, 'SetItemFrameQuality', function(self, itemFrame)
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
                btn=e.Cbtn(itemFrame,nil, true)
                btn:SetNormalAtlas('adventure-missionend-line');
                itemFrame['btn'..i]=btn
                if i==1 then
                    btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
                else
                    btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
                end
                btn:SetSize(26, 10)--32
                btn:SetAlpha(0.2)
                btn:SetScript("OnEnter",function(self2)
                        if not self2.link then
                             return
                        end
                        self2:SetAlpha(1)
                        tips:ClearLines()
                        tips:SetOwner(self2, "ANCHOR_RIGHT")
                        tips:SetHyperlink(self2.link)
                        tips:Show()
                end)
                btn:SetScript("OnMouseDown", function(self2)
                        if ( self2.link ) then
                            local chat=SELECTED_DOCK_FRAME
                            ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)
                        end
                end)
                btn:SetScript("OnLeave",function(self2)
                        self2:SetAlpha(0.2)
                        tips:Hide()
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
    end)--Blizzard_Wardrobe.lua

    local sets =C_TransmogSets.GetAllSets()--所以有套装情况
    if sets then
        local tempSave=wowSave2
        local frame=frame2.SetsCollectionFrame.DetailsFrame
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
            if info.collected and info.all and info.all>0 then
                local value=floor(info.collected/info.all*100)
                local t=info.collected..'/'..info.all..' '
                t=t..((value<10 and '  ') or (value<100 and ' ') or '')..value..'%'
                t=t..'|A:classicon-'..info.class..':0:0|a'
                t='|c'..select(4,GetClassColor(info.class))..t..'|r'                
                m=m..t..'\n'
                collected=info.collected + collected
                all=info.all + all
            end
        end
        if all>0 then
            m=m..collected..'/'..all..' '..('%i%%'):format(collected/all*100)..' '..LFG_LIST_CROSS_FACTION:format(CLASS)
        end
        if a > 0 or h>0 or o>0 then
            m=m..'\n\n'..h..' |A:communities-create-button-wow-horde:0:0|a'
            m=m..'\n'..a..' |A:communities-create-button-wow-alliance:0:0|a'
            m=m..'\n'..o..' |A:communities-guildbanner-background:0:0|a'
            m=m..'\n'..#sets..' '..LFG_LIST_CROSS_FACTION:format(FACTION)
        end
        if not frame.AllSets then
            frame.AllSets=e.Cstr(frame)
            frame.AllSets:SetPoint('BOTTOMRIGHT', -6, 60)
            --frame.AllSets:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -5, -160)
            frame.AllSets:SetJustifyH('RIGHT')
        end
        frame.AllSets:SetText(m)
    end
end

--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("TRANSMOG_SETS_UPDATE_FAVORITE")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            wowSave=WoWToolsSave and WoWToolsSave['WoW-WardrobeCollection'] or wowSave
            SetSaveWardroberColleced()--收集所有角色套装数据

            --添加控制面板        
            local sel=e.CPanel(WARDROBE, not Save.disabledWardrobe)
            sel:SetScript('OnClick', function()
                if Save.disabledWardrobe then
                    Save.disabledWardrobe=nil
                else
                    Save.disabledWardrobe=true
                end
                print(id,addName, WARDROBE, e.GetEnabeleDisable(not Save.disabledWardrobe), '|cnGREEN_FONT_COLOR:/reload|r')                
            end)
    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save
        WoWToolsSave['WoW-WardrobeCollection']=wowSave

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        InitWardrobe()
        SetSaveWardroberColleced()

    elseif event=='TRANSMOG_SETS_UPDATE_FAVORITE' then
        SetSaveWardroberColleced()
    end
end)