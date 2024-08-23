--[[
local cooldown = self.cooldown;
	local start, duration, enable = C_Container.GetItemCooldown(self.itemID);
	if (cooldown and start and duration) then
		if (enable) then
			cooldown:Hide();
		else
			cooldown:Show();
		end
		CooldownFrame_Set(cooldown, start, duration, enable);
	else
		cooldown:Hide();
	end
]]