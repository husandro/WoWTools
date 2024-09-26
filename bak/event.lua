--[[
self:RegisterEvent('UPDATE_FACTION')

self:RegisterEvent('PLAYER_MAP_CHANGED')
self:RegisterEvent('PLAYER_ENTERING_WORLD')

self:RegisterEvent('PET_BATTLE_OPENING_DONE')
self:RegisterEvent('PET_BATTLE_CLOSE')

self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')

self:RegisterEvent('PLAYER_REGEN_DISABLED')
self:RegisterEvent('PLAYER_REGEN_ENABLED')

self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')


FrameUtil.RegisterFrameForEvents(self, table)
FrameUtil.RegisterFrameForUnitEvents(frame, events, ...)
FrameUtil.UnregisterFrameForEvents(self, table)


IsInInstance()
C_PetBattles.IsInBattle()
UnitInVehicle('player')
UnitHasVehicleUI('player')
UnitAffectingCombat('player')
IsMounted()






tooltip:AddLine(e.onlyChinese and '隐藏' or HIDE)
tooltip:AddLine(' ')
tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
tooltip:AddLine(e.onlyChinese and '宠物对战' or SHOW_PET_BATTLES_ON_MAP_TEXT)
tooltip:AddLine(e.onlyChinese and '在副本中' or AGGRO_WARNING_IN_INSTANCE)
tooltip:AddLine(e.onlyChinese and '载具控制' or BINDING_HEADER_VEHICLE)
]]