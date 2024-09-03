self:RegisterEvent('UPDATE_FACTION')

self:RegisterEvent('PLAYER_MAP_CHANGED')
self:RegisterEvent('PLAYER_ENTERING_WORLD')

self:RegisterEvent('PET_BATTLE_OPENING_DONE')
self:RegisterEvent('PET_BATTLE_CLOSE')

self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')

self:RegisterEvent('PLAYER_REGEN_DISABLED')
self:RegisterEvent('PLAYER_REGEN_ENABLED')





IsInInstance()
C_PetBattles.IsInBattle()
UnitInVehicle('player')
UnitAffectingCombat('player')