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
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.hyperlink then
                local classID, subclassID = select(6, GetItemInfoInstant(info.hyperlink))
                if classID==3 then
                    local btn=Buttons[index]
                    if not btn then
                        --e.Cbtn= function(self, Template, value, SecureAction, name, notTexture, size)
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
                        table.insert(Buttons, btn)
                    end

                    btn.bag=bag
                    btn.slot=slot
                    btn:SetNormalTexture(info.iconFileID or 0)
                    btn:SetShown(true)

                    index= index+1
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
        local sel=e.CPanel(addName, Save.disabled, true)
        sel:SetScript('OnClick', function()
            Save.disabled = not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(Save.disabled), e.onlyChinse and '重新加载UI' or RELOADUI)
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
