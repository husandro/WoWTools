--[[
EventRegistry:RegisterCallback("CinematicFrame.CinematicStopped", self.OnCinematicStopped, self)
EventRegistry:TriggerEvent("CinematicFrame.CinematicStopped")
EventRegistry:UnregisterCallback("CinematicFrame.CinematicStopped", self)

AsyncCallbackSystem.lua
ItemEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_ITEM);
SpellEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_SPELL);
QuestEventListener = CreateListener(AsyncCallbackAPIType.ASYNC_QUEST);

SpellEventListener:AddCancelableCallback(self:GetSpellID(), callbackFunction)
QuestEventListener:AddCancelableCallback(questID, cb)
ItemEventListener:AddCancelableCallback(self:GetItemID(), callbackFunction)
]]