local id, e = ...
local Save={}
local addName= e.onlyChinse and "镶嵌宝石" or SOCKET_GEMS
local panel=CreateFrame("Frame")

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('SOCKET_INFO_CLOSE')
panel:RegisterEvent('SOCKET_INFO_UPDATE')

local Buttons={}
local function set_Gem()--Blizzard_ItemSocketingUI.lua
    if not ItemSocketingFrame or not ItemSocketingFrame:IsVisible() then
        return
    end
    local index=1
    local items={}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink and info.iconFileID and info.itemID then
                local classID = select(6, GetItemInfoInstant(info.hyperlink))
                
                if classID==3 and not items[info.itemID] then
                    local btn=Buttons[index]
                    if not btn then
                        btn= e.Cbtn(ItemSocketingFrame, nil,nil,nil,nil, true,{25, 25})
                        if index==1 then
                            btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOMRIGHT')
                        else
                            btn:SetPoint('RIGHT', Buttons[index-1], 'LEFT')
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

                        btn.text=e.Cstr(btn)
                        btn.text:SetPoint('BOTTOMRIGHT')
                        table.insert(Buttons, btn)
                    end

                    local text--数量
                    text= GetItemCount(info.itemID)
                    text= text>0 and text or ''
                    if text~='' and info.quality then
                        local hex = select(4, GetItemQualityColor(info.quality))
                        text= hex and '|c'..hex..text..'|r' or text
                    end
                    btn.text:SetText(text)

                    btn.bag=bag
                    btn.slot=slot
                    btn:SetNormalTexture(info.iconFileID)--图标
                    btn:SetShown(true)

                    index= index+1
                    items[info.itemID]=true
                end
            end
        end
    end
    for i= index, #Buttons do
        Buttons[i]:SetShown(false)
    end
end

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(addName, not Save.disabled, true)
        sel:SetScript('OnClick', function()
            Save.disabled = not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '重新加载UI' or RELOADUI)
        end)

        if Save.disabled then
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event=='SOCKET_INFO_UPDATE' then
        panel:RegisterEvent('BAG_UPDATE_DELAYED')
        set_Gem()
    elseif event=='SOCKET_INFO_CLOSE' then
        panel:UnregisterEvent('BAG_UPDATE_DELAYED')

    elseif event=='BAG_UPDATE_DELAYED' then
        set_Gem()
    end
end)
