local id, e = ...
local Save={}
local addName= SOCKET_GEMS
local panel=CreateFrame("Frame")

local Buttons={}
local function set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    if not ItemSocketingFrame or not ItemSocketingFrame:IsVisible() then
        return
    end
    
    local items={}
    local links={}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink then
                --local classID, subclassID = select(6, GetItemInfoInstant(info.hyperlink))
                local classID, subclassID, _, expacID= select(12, GetItemInfo(info.hyperlink))
                if classID==3 and not links[info.hyperlink] then
                    e.LoadDate({id=info.hyperlink, type='item'})
                    table.insert(items, {
                        info= info,
                        bag= bag,
                        slot=slot,
                        subclassID = subclassID,
                        expacID= expacID or 0,
                        level= GetDetailedItemLevelInfo(info.hyperlink) or 0,
                    })
                    links[info.hyperlink]= true
                end
            end
        end
    end
    links=nil

--[[
local function sort_Level(a, b)
    return a> b
end
local function sort_Quality(a, b)
    return a> b
end
local function sort_subClass(a, b)
    return a>b
end
local function sort_ExpacID(a, b)
    return a>b
end]]

    table.sort(items, function(a, b)
        if a.expacID> b.expacID then
            return true
        elseif a.info.quality> b.info.quality then
            return true
        elseif a.level > b.level then
            return true
        else
            if a.subclassID > b.subclassID then
                return true
            else
                return false
            end
        end
    end)

    for index=1, #items do
        local btn=Buttons[index]
        if not btn then
            btn= CreateFrame('ItemButton',nil, ItemSocketingFrame)
            btn:SetSize(25,25)
            if index==1 then
                btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT',-10,-6)
            elseif select(2, math.modf(index / 9))==0 then
                local y=math.modf(index / 9)
                btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT',-10, -y*44)
            else
                btn:SetPoint('RIGHT', Buttons[index-1], 'LEFT', -13,0)
            end
            btn:SetScript('OnMouseDown', function(self, d)
                if self.bag and self.slot then
                    if d=='LeftButton' then
                        C_Container.PickupContainerItem(self.bag, self.slot)
                    elseif d=='RightButton' then
                        ClearCursor()
                    end
                end
            end)
            btn:SetScript('OnEnter', function(self)
                if self.bag and self.slot then
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetBagItem(self.bag, self.slot)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end
            end)
            btn:SetScript('OnLeave', function() e.tips:Hide() end)

            btn.level=e.Cstr(btn)
            btn.level:SetPoint('TOP',0,5)

            table.insert(Buttons, btn)
        end

        local info= items[index].info
        btn.level:SetText((items[index].level and items[index].level>1) and items[index].level or '')
        --local hex = info.quality and select(4, GetItemQualityColor(info.quality))

        --[[local text--数量
        text= GetItemCount(info.itemID)
        text= text>1 and text or ''
        if text~='' and hex then
            text= hex and '|c'..hex..text..'|r' or text
        end
        btn.text:SetText(text)]]

        btn:SetItemButtonCount(GetItemCount(info.hyperlink))

        btn.bag= items[index].bag
        btn.slot=  items[index].slot
        btn:SetItem(info.hyperlink)
        btn:SetShown(true)
    end

    for index= #items+1, #Buttons, 1 do
        Buttons[index]:SetShown(false)
        Buttons[index]:Reset()
    end

    items=nil
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('SOCKET_INFO_CLOSE')
panel:RegisterEvent('SOCKET_INFO_UPDATE')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel('|T4555592:0|t'..(e.onlyChinese and '镶嵌宝石' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='SOCKET_INFO_UPDATE' then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        set_Gem()
    elseif event=='SOCKET_INFO_CLOSE' then
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Gem()
    end
end)
