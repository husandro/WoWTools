WoWTools_LoadUIMixin= {}


function WoWTools_LoadUIMixin:Journal(index)--加载，收藏，UI
    if not CollectionsJournal then
        do
            CollectionsJournal_LoadUI();
        end
    end
    if not index then
        return
    end
    if
           (index==1 and not MountJournal:IsVisible())
        or (index==2 and not PetJournal:IsVisible())
        or (index==3 and not ToyBox:IsVisible())
        or (index==4 and not HeirloomsJournal:IsVisible())
        or (index==5 and not WardrobeCollectionFrame:IsVisible())
    then
        ToggleCollectionsJournal(index)
    end
end




function WoWTools_LoadUIMixin:GenericTraitUI(systemID, treeID)--加载，Trait，UI
    GenericTraitUI_LoadUI()
    securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, systemID)
    securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, treeID)
    ToggleFrame(GenericTraitFrame)
end

WoWTools_LoadUIMixin:GenericTraitUI(--加载，Trait，UI
    Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID,
    Constants.MountDynamicFlightConsts.TREE_ID
)