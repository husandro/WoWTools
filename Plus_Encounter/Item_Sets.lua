--战利品, 套装, 收集数 Blizzard_LootJournalItems.lua
local e= select(2, ...)



local function Setings(frame)
    local coll, all, text= 0, 0, nil
    for _, btn in pairs(frame.ItemButtons or {}) do
        local has= false
        local itemLink= not WoWTools_EncounterMixin.Save.hideEncounterJournal and btn:IsShown() and btn.itemLink
        if itemLink then--itemID
            has = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink)
            all= all+1
            coll= has and coll+1 or coll
        end
        WoWTools_ItemStatsMixin:SetItem(btn, itemLink, {hideLevel=true, hideSet=true})

        if has and not btn.collection then
            btn.collection= btn:CreateTexture()
            btn.collection:SetSize(10,10)
            btn.collection:SetPoint('TOP', btn, 'BOTTOM',0,2)
            btn.collection:SetAtlas(WoWTools_DataMixin.Icon.select)
        end
        if btn.collection then
            btn.collection:SetShown(has)
        end
    end
    if not frame.setNum then
        frame.setNum= WoWTools_LabelMixin:Create(frame)
        frame.setNum:SetPoint('RIGHT', frame.SetName)
    end
    if all>0 then
        if coll==all then
            text= format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.select)
        else
            text= format('%s%d/%d', coll==0 and '|cff9e9e9e' or '', coll, all)
        end
    end
    frame.setNum:SetText(text or '')
end








local function Update(self)
    local view = self:GetView()
    if not view or not view.frames then
        return
    end
    for _, frame in pairs(view.frames) do
        Setings(frame)
    end
end





function WoWTools_EncounterMixin:Init_ItemSets() --战利品, 套装, 收集数
    hooksecurefunc(EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox, 'Update', Update)
end
