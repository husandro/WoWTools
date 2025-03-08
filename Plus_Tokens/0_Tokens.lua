local id, e = ...
WoWTools_TokensMixin={
Save={
	--notPlus=true,
	tokens={},--{[currencyID]=true}指定显示，表
	item={},--[202196]= true
	--indicato=nil,--指定显示

	Hide=not e.Player.husandro,
	str=true,
	--scaleTrackButton=1,
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上
	--notAutoHideTrack=true,--自动隐藏
	itemButtonUse=e.Player.husandro,
	--disabledItemTrack=true,禁用，追踪物品

	--hideCurrencyMax=true,--隐藏，已达到资源上限,提示
	--showID=true,--显示ID
},
}
local function Save()
	return WoWTools_TokensMixin.Save
end

function WoWTools_TokensMixin:UpdateTokenFrame()
	e.call(TokenFrame.Update, TokenFrame)
	e.call(TokenFramePopup.CloseIfHidden, TokenFramePopup)
end






local function Init()
	WoWTools_TokensMixin:Init_Button()
	WoWTools_TokensMixin:Init_Other_Button()
	WoWTools_TokensMixin:Init_Currency_Transfer()--货币，转移
	WoWTools_TokensMixin:Init_TrackButton()
	WoWTools_TokensMixin:Init_ScrollBox_Plus()
	WoWTools_TokensMixin:Init_MaxTooltip()

	hooksecurefunc(TokenFrame, 'Update', function(frame)
		WoWTools_TokensMixin:Set_ItemInteractionFrame(frame)--套装,转换,货币

		if WoWTools_TokensMixin.TrackButton then
			WoWTools_TokensMixin:Set_TrackButton_Text()
		else
			WoWTools_TokensMixin:Init_TrackButton()
		end
	end)
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
			WoWTools_TokensMixin.Save= WoWToolsSave['Currency2'] or Save()

			local addName= '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or TOKENS)
			WoWTools_TokensMixin.addName= addName

			--添加控制面板
			e.AddPanel_Check({
				name= addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(WoWTools_Mixin.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})

			if Save().disabled then
				self:UnregisterEvent(event)
			else
				for itemID, _ in pairs(Save().item) do
					WoWTools_Mixin:Load({id=itemID, type='item'})--加载 item quest spell
				end
				Init()
			end

		elseif arg1=='Blizzard_ItemInteractionUI' then
			hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
				WoWTools_TokensMixin:Set_ItemInteractionFrame(frame)
			end)

		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Currency2']= Save()
        end
    end
end)