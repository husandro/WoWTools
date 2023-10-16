local id, e = ...
local addName= 'DormantSeeds'
local Save={
    --disabled= not e.Player.husandro,
}

local panel= CreateFrame('Frame')
local Button

local ItemTab={
    '208066',--小小的梦境之种
    '208067',--饱满的梦境之种
    '208047',--硕大的梦境之种
}

local function Init()
    Button= e.Cbtn(nil, {size={22,22}, icon=true})
    function Button:set_Point()
        if Save.point then
            self:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            self:SetPoint('CENTER', -100, 100)
        end
    end
    Button.btn={}

    function Button:set_button()
        local index=1
        for _, itemID in pairs(ItemTab) do
            local num= GetItemCount(itemID)
            if num>0 then
                local btn= self.btn[index]
                if not btn then
                    --btn= CreateFrame('ItemButton',nil, self)
                    btn= e.Cbtn(self, {type=true, size={22,22}})
                    btn:SetAttribute('type*', 'item')
                    btn:SetSize(25,25)
                    btn:SetPoint('TOP', index==1 and Button or self.btn[index-1], 'BOTTOM')
                    btn:SetScript('OnEnter', function(self2)
                        if self2.itemID  then
                            e.tips:SetOwner(self, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetItemByID(self2.itemID)
                            e.tips:Show()
                        end
                    end)
                    btn:SetScript('OnLeave', function() e.tips:Hide() end)
                    self.btn[index]= btn
                end
                
                btn.itemID= itemID
                local icon= C_Item.GetItemIconByID(itemID)
                local name= C_Item.GetItemNameByID(itemID) or itemID
                btn:SetAttribute('item*', name)
                btn:SetNormalTexture(icon or 0)
                --btn:SetItem(itemID)
                index= index+1
                print(name)
            end
        end
    end

    Button:set_Point()
    Button:set_button()
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Check({
                name= '|T656681:0|t'..addName,
                tooltip= function()
                    e.tips:SetOwner(SettingsPanel, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetItemByID(208047)
                    e.tips:Show()
                end,
                value= not Save.disabled,
                func= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if not Save.disabled then
                for _, itemID in pairs(ItemTab) do
                    e.LoadDate({id=itemID, type='item'})
                end
                C_Timer.After(2, Init)
            end
        end
    end
end)