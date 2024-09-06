--[[
Journal(index)--加载，收藏，UI
GenericTraitUI(systemID, treeID)--加载，Trait，UI
Professions(recipeID)
MajorFaction(factionID)
]]

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



--加载，Trait，UI
function WoWTools_LoadUIMixin:GenericTraitUI(systemID, treeID)
    GenericTraitUI_LoadUI()
    securecallfunction(GenericTraitFrame.SetSystemID, GenericTraitFrame, systemID)
    securecallfunction(GenericTraitFrame.SetTreeID, GenericTraitFrame, treeID)
    ToggleFrame(GenericTraitFrame)
end


--Blizzard_DragonflightLandingPage.lua
--驭空术
function WoWTools_LoadUIMixin:Dragonriding()
    self:GenericTraitUI(Enum.ExpansionLandingPageType.Dragonflight, Constants.MountDynamicFlightConsts.TREE_ID)
end






function WoWTools_LoadUIMixin:Professions(recipeID)
    do
        if not ProfessionsFrame then
            ProfessionsFrame_LoadUI()
        end
    end
    if recipeID then
        if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
            local parentTradeSkillID= select(3, C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID))            
            if parentTradeSkillID then
                OpenProfessionUIToSkillLine(parentTradeSkillID)
            end
            C_TradeSkillUI.OpenRecipe(recipeID)
        --else
            --Professions.InspectRecipe(recipeID)
        end
    end
end






--宏伟宝库
function WoWTools_LoadUIMixin:WeeklyRewards()
    if not UnitAffectingCombat('player') then
        if not WeeklyRewardsFrame then
            WeeklyRewards_LoadUI()
        elseif WeeklyRewardsFrame:IsShown() then
            WeeklyRewardsFrame:Hide()
        else
            WeeklyRewards_ShowUI()--WeeklyReward.lua
        end
    end
end



--派系声望
function WoWTools_LoadUIMixin:MajorFaction(factionID)
    if factionID and MajorFactionRenownFrame and MajorFactionRenownFrame.majorFactionID==factionID then
        MajorFactionRenownFrame:Hide()
    else
        ToggleMajorFactionRenown(factionID)
    end
end