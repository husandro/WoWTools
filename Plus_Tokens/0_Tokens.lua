local id, e = ...
local addName

WoWTools_TokensMixin={
Save={
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
Button=nil,
TrackButton=nil,
}
local function Save()
	return WoWTools_TokensMixin.Save
end














local function Init()
	
	WoWTools_TokensMixin:Init_Button()
	WoWTools_TokensMixin:Init_Currency_Transfer()--货币，转移

	C_Timer.After(4, function()
		WoWTools_TokensMixin:Init_TrackButton()
		WoWTools_TokensMixin:Init_ScrollBox_Plus()
		
		hooksecurefunc(TokenFrame, 'Update', function(frame)
			WoWTools_TokensMixin:Set_ItemInteractionFrame(frame)--套装,转换,货币
			if WoWTools_TokensMixin.TrackButton then
				WoWTools_TokensMixin:Set_TrackButton_Text()
			else
				WoWTools_TokensMixin:Init_TrackButton()
			end
		end)
		
	end)
end





--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
			WoWTools_TokensMixin.Save= WoWToolsSave['Currency2'] or Save()

			for itemID, _ in pairs(Save().item) do
				e.LoadData({id=itemID, type='item'})--加载 item quest spell
			end
			WoWTools_TokensMixin.addName= '|A:bags-junkcoin:0:0|a'..(e.onlyChinese and '货币' or TOKENS)
			addName = WoWTools_TokensMixin.addName

			--添加控制面板
			e.AddPanel_Check({
				name= addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(e.addName, addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})

            if Save().disabled then
				self:UnregisterEvent('ADDON_LOADED')
			else
				Init()
            end


		elseif arg1=='Blizzard_ItemInteractionUI' then
            hooksecurefunc(ItemInteractionFrame, 'SetupChargeCurrency', function(frame)
				WoWTools_TokensMixin:Set_ItemInteractionFrame(frame)
			end)
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Currency2']= WoWTools_TokensMixin.Save
        end
	end
end)