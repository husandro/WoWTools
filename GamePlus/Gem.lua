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
    local gem1007= select(2, GetSocketItemInfo())== 4638590 --204000, 204030

    for bag= Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info
                and info.hyperlink
                and info.itemID
                and (
                        (gem1007 and info.itemID>=204000 and info.itemID<=204030)
                    or (not gem1007 and (info.itemID<204000 or info.itemID>204030))
                )
            then
                --local classID, subclassID = select(6, GetItemInfoInstant(info.hyperlink))
                e.LoadDate({id=info.hyperlink, type='item'})

                local level= GetDetailedItemLevelInfo(info.hyperlink) or 0
                local classID, _, _, expacID= select(12, GetItemInfo(info.hyperlink))

                if classID==3
                    and (e.Player.levelMax and e.ExpansionLevel== expacID or not e.Player.levelMax)--最高等级
                    and (not links[info.itemID] or links[info.itemID]~= level)--装等不一样
                then
                    table.insert(items, {
                        info= info,
                        bag= bag,
                        slot=slot,
                        level= level,
                    })
                    links[info.itemID]= level
                end
            end
        end
    end
    links=nil

    table.sort(items, function(a, b)
        if a.info.quality== b.info.quality then
           return a.level>b.level
        else
           return a.info.quality>b.info.quality
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
        btn.level:SetText(items[index].level>1 and items[index].level or '')

        btn:SetItemButtonCount(GetItemCount(info.hyperlink))

        btn.bag= items[index].bag
        btn.slot= items[index].slot
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
panel:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')

local ExtraActionButton1Point--记录打开10.07 宝石戒指, 额外技能条,位置
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
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        --[[elseif arg1=='Blizzard_ItemSocketingUI' then--10.07 原石宝石，提示

            ItemSocketingFrame.setTipsFrame= CreateFrame("Frame", nil, ItemSocketingFrame)
            ItemSocketingFrame.setTipsFrame:SetFrameStrata('HIGH')

            local x,y,n= 54,-22,0
            for i=204000, 204030 do
                local classID= select(6, GetItemInfoInstant(i))
                if classID==3 then
                    e.LoadDate({id=i, type='item'})
                    local icon= C_Item.GetItemIconByID(i)
                    if icon then
                        local texture= ItemSocketingFrame.setTipsFrame:CreateTexture()
                        texture:SetSize(20,20)
                        texture:SetTexture(icon)
                        texture:EnableMouse(true)
                        texture.id= i
                        texture:SetScript('OnEnter', function(self2)
                            e.tips:SetOwner(self2, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetItemByID(self2.id)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, addName)
                            e.tips:Show()
                        end)
                        texture:SetScript('OnLeave', function() e.tips:Hide() end)
                        n=n+1

                        texture:SetPoint('TOPLEFT', ItemSocketingFrame, 'TOPLEFT',x, y)
                        local one,two= math.modf(n / 14)
                        if two==0 and one==1 then
                            x=-2
                            y=y -20
                        else
                            x=x+20
                        end
                    end
                end
            end
            ItemSocketingFrame.setTipsFrame:SetShown(select(2,GetSocketItemInfo())== 4638590)--10.07 原石宝石，提示]]
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='SOCKET_INFO_UPDATE' then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        set_Gem()

        local gem1007= select(2, GetSocketItemInfo())== 4638590
        if ItemSocketingFrame.setTipsFrame then
            ItemSocketingFrame.setTipsFrame:SetShown(gem1007)--10.07 原石宝石，提示
        end

        if not IsInInstance() and gem1007 and ExtraActionButton1 and ExtraActionButton1:IsShown() and ExtraActionButton1.icon and ItemSocketingFrame and ItemSocketingFrame:IsVisible() then
            local icon= ExtraActionButton1.icon:GetTexture()
            if icon==4638590 or icon==876370 then
                if not ExtraActionButton1Point then
                    ExtraActionButton1Point= {ExtraActionButton1:GetPoint(1)}--记录打开10.07 宝石戒指, 额外技能条,位置
                    ExtraActionButton1:ClearAllPoints()
                    ExtraActionButton1:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOMRIGHT', 0, 30)
                end
            end
        end

    elseif event=='SOCKET_INFO_CLOSE' then
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')

        if ItemSocketingFrame and ItemSocketingFrame.setTipsFrame then
            ItemSocketingFrame.setTipsFrame:SetShown(false)--10.07 原石宝石，提示
        end

        if ExtraActionButton1Point then--记录打开10.07 宝石戒指, 额外技能条,位置
            ExtraActionButton1:ClearAllPoints()
            ExtraActionButton1:SetPoint(ExtraActionButton1Point[1], ExtraActionButton1Point[2], ExtraActionButton1Point[3], ExtraActionButton1Point[4], ExtraActionButton1Point[5])
            ExtraActionButton1Point=nil
        end

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Gem()
    end
end)
