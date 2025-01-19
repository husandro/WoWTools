--玩具 3
local e= select(2, ...)







local function Update_Button(self)
    if not self.itemID or self.itemID==-1 or not ToyBox:IsVisible() then
        return
    end

    if ToyBox.fanfareToys[self.itemID] then
        self.name:SetTextColor(0,1,0, 1)

    elseif not PlayerHasToy(self.itemID) then
        self.name:SetTextColor(1,1,1,1)
    else
        self.name:SetTextColor(1, 0.82, 0, 1)
    end
    
    self.iconTextureUncollected:SetDesaturated(false)
end






function WoWTools_PlusCollectionMixin:Init_ToyBox()--玩具 3

    hooksecurefunc('ToySpellButton_UpdateButton', Update_Button)
    ToyBox.searchBox:SetPoint('LEFT', ToyBox.progressBar, 'RIGHT', 12,0)
end