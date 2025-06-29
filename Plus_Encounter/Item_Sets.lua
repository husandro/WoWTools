--战利品, 套装, 收集数 Blizzard_LootJournalItems.lua
local function Save()
    return WoWToolsSave['Adventure_Journal']
end



local function Init()
    hooksecurefunc(LootJournalItemSetButtonMixin, 'Init', function(frame, data)
        local text
        if not frame.setNum then
            frame.setNum= WoWTools_LabelMixin:Create(frame)
            frame.setNum:SetPoint('RIGHT', frame.SetName)
        end
        if not Save().hideEncounterJournal and data and data.setID then
            text= WoWTools_CollectedMixin:SetID(data.setID, true)--套装, 收集数
        end
        for _, btn in pairs(frame.ItemButtons or {}) do
            if btn.itemID then
                if C_Item.IsItemDataCachedByID(btn.itemID) then
                    WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {hideLevel=true, hideSet=true, itemID=btn.itemID})
                else
                    C_Timer.After(1, function()
                        WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {hideLevel=true, hideSet=true})
                    end)
                end
            end
        end
        frame.setNum:SetText(text or '')
    end)

--LootJournalItemSetsMixin
    hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame, 'ConfigureItemButton', function(_, btn)
        WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {
            itemID=btn.itemID,
            hideLevel=true,
            hideSet=true
        })
    end)

    Init=function()end
end


function WoWTools_EncounterMixin:Init_ItemSets() --战利品, 套装, 收集数
    Init()
    --hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox, 'Update', Update)
end
