if BankFrameTab2 then
    return
end

local function Save()
    return WoWToolsSave['Plus_Bank2']
end


hooksecurefunc(BankPanel, 'Clean', function(self)
    if self.bankType~=Enum.BankType.Character then
        return
    end

    WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Bank={}

    if not Save().saveWoWData then
        return
    end

    --[itemID]={num=数量,quality=品质}}

    for _, bankTabData in ipairs(self.purchasedBankTabData or {}) do
        if bankTabData.ID~=-1 then
            local numSlot= C_Container.GetContainerNumSlots(bankTabData.ID)
            for slotID=1, numSlot do
                local data= C_Container.GetContainerItemInfo(bankTabData.ID, slotID)
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
end)