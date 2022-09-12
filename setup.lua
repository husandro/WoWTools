
local id, e = ...
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)

  if event == "ADDON_LOADED" and arg1 == id then
        Save=WoWToolsSave or {WoWToolsSave=true}
    
        self.panel = CreateFrame("Frame")
        self.panel.name = "HelloWorld"
      
        local cb = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 20, -20)
        cb.Text:SetText("Print when you jump")
        cb.SetValue = function(self2, value)
          Save.WoWToolsSave = (value == "1") -- value can be either "0" or "1"
        end
        cb:SetChecked(Save.WoWToolsSave) -- set the initial checked state
      
        local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
        btn:SetPoint("TOPLEFT", cb, 0, -40)
        btn:SetText("Click me")
        btn:SetWidth(100)
        btn:SetScript("OnClick", function()
          if Save.WoWToolsSave then Save.WoWToolsSave=nil else Save.WoWToolsSave=true end
          print(Save.WoWToolsSave)
        end)
      
        InterfaceOptions_AddCategory(self.panel)
		hooksecurefunc("JumpOrAscendStart", function()
			print(Save.WoWToolsSave)
		end)
	end
end)
--[[
SLASH_WOWTOOLS1 = "/WOW"
SLASH_WOWTOOLS2 = "/WoWTools"

SlashCmdList.WOWTOOLS = function(msg, editBox)
	InterfaceOptionsFrame_OpenToCategory(frame.panel)
	InterfaceOptionsFrame_OpenToCategory(frame.panel)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
    elseif event == "PLAYER_LOGOUT" then
    end
end)]]
