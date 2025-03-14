--法术书




function WoWTools_MoveMixin.Events:Blizzard_PlayerSpells()
    WoWTools_MoveMixin:Setup(PlayerSpellsFrame, {onShowFunc=true})
    for specContentFrame in PlayerSpellsFrame.SpecFrame.SpecContentFramePool:EnumerateActive() do
        WoWTools_MoveMixin:Setup(specContentFrame, {frame=PlayerSpellsFrame})
    end

    WoWTools_MoveMixin:Setup(PlayerSpellsFrame.TalentsFrame, {frame=PlayerSpellsFrame})
    WoWTools_MoveMixin:Setup(PlayerSpellsFrame.TalentsFrame.ButtonsParent, {frame=PlayerSpellsFrame})
    WoWTools_MoveMixin:Setup(PlayerSpellsFrame.SpellBookFrame, {frame=PlayerSpellsFrame})

end