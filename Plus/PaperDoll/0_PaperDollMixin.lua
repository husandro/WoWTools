WoWTools_PaperDollMixin={}



WoWTools_PaperDollMixin.ItemButtons={
    [1]	 = "CharacterHeadSlot",
    [2]	 = "CharacterNeckSlot",
    [3]	 = "CharacterShoulderSlot",
    [4]	 = "CharacterShirtSlot",
    [5]	 = "CharacterChestSlot",
    [6]	 = "CharacterWaistSlot",
    [7]	 = "CharacterLegsSlot",
    [8]	 = "CharacterFeetSlot",
    [9]	 = "CharacterWristSlot",
    [10] = "CharacterHandsSlot",
    [11] = "CharacterFinger0Slot",
    [12] = "CharacterFinger1Slot",
    [13] = "CharacterTrinket0Slot",
    [14] = "CharacterTrinket1Slot",
    [15] = "CharacterBackSlot",
    [16] = "CharacterMainHandSlot",
    [17] = "CharacterSecondaryHandSlot",
    [19] = "CharacterTabardSlot",
}


function WoWTools_PaperDollMixin:Is_Left_Slot(slot)
    return slot==1 or slot==2 or slot==3 or slot==15 or slot==5 or slot==4 or slot==19 or slot==9 or slot==17 or slot==18
end
