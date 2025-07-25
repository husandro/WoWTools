if BankFrameTab2 then
    return
end

local function Is_Save_WoWData()
    if WoWToolsSave['Plus_Bank2'] then
        return not WoWToolsSave['Plus_Bank2'].disabled and WoWToolsSave['Plus_Bank2'].saveWoWData
    end
end


--[itemID]={num=数量,quality=品质}}
local function Save_Items(self)
    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank={}
    for _, tabData in ipairs(self.purchasedBankTabData or {}) do
        if tabData.ID and tabData.ID~=-1 then
            local numSlot= C_Container.GetContainerNumSlots(tabData.ID)
            for slotID=1, numSlot do
                local data= C_Container.GetContainerItemInfo(tabData.ID, slotID)
                if data and data.itemID then

                    local stackCount= data.stackCount or 1
                    local quality= data.quality or 1

                    if not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank[data.itemID] then
                        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank[data.itemID]= {
                            quality= quality,
                            num= stackCount
                        }

                    else
                        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank[data.itemID]={
                            quality= quality,
                            num= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank[data.itemID].num+ stackCount
                        }
                    end
                end
            end
        end
    end
end


BankPanel:HookScript('OnShow', function(self)
    if Is_Save_WoWData() then
        for _ in ipairs(WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank) do
            return
        end
        Save_Items(self)
    end
end)

hooksecurefunc(BankPanel, 'Clean', function(self)
    if self.bankType~=Enum.BankType.Character then
        return
    end

    if Is_Save_WoWData() then
        Save_Items(self)
    else
        WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank={}
    end
end)