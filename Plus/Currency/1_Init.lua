


local function Save()
	return WoWToolsSave['Currency2']
end








local function Init_Menu(self, root)
	if not self:IsMouseOver() then
		return
	end

	local sub


--追踪
	sub=root:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING,
	function()
		return not Save().Hide
	end, function()
		Save().Hide= not Save().Hide and true or nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)



--重置位置
	WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
		Save().point=nil
		WoWTools_CurrencyMixin:Init_TrackButton()
	end)


--达到上限
	root:CreateDivider()
	sub=root:CreateCheckbox(
		'|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '达到上限' or CAPPED),
	function ()
		return not Save().hideCurrencyMax
	end, function ()
		Save().hideCurrencyMax= not Save().hideCurrencyMax and true or nil
		WoWTools_CurrencyMixin:Init_MaxTooltip()
	end)
	sub:SetTooltip(function (tooltip)
		tooltip:AddLine('CURRENCY_DISPLAY_UPDATE')
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '已达到资源上限' or SPELL_FAILED_CUSTOM_ERROR_248)
	end)


--Plus
	sub=root:CreateCheckbox(
		'Plus',
	function()
		return not Save().notPlus
	end, function()
		Save().notPlus= not Save().notPlus and true or nil
		WoWTools_CurrencyMixin:Init_Plus()
	end)
	sub:SetTooltip(function (tooltip)
		GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
	end)


	root:CreateDivider()
--打开选项
    sub= WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_CurrencyMixin.addName})
--重新加载UI
	WoWTools_MenuMixin:Reload(sub)
end







local function Init()
	local btn= CreateFrame('DropdownButton', 'WoWToolsPlusCurrencyMenuButton', TokenFrame, 'WoWToolsMenuTemplate')
	btn:SetupMenu(Init_Menu)
	btn.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left
	btn:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
	btn:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
	btn:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT', -2, 0)


	WoWTools_CurrencyMixin:Init_Plus()
	WoWTools_CurrencyMixin:Init_TrackButton()
	WoWTools_CurrencyMixin:Init_Currency_Transfer()--货币，转移


	--[[WoWTools_DataMixin:Hook(TokenFrame, 'Update', function(frame)
		WoWTools_CurrencyMixin:Set_ItemInteractionFrame(frame)--套装,转换,货币
	end)]]

	Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

			WoWToolsSave['Currency2']= WoWToolsSave['Currency2'] or {
				tokens={},
				item={},
				Hide=not WoWTools_DataMixin.Player.husandro,
				str=true,
				toRightTrackText=true,--向右平移
				itemButtonUse=WoWTools_DataMixin.Player.husandro,
			}

			Save().ItemInteractionID= nil

			WoWTools_CurrencyMixin.addName= '|A:bags-junkcoin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '货币' or TOKENS)

--添加控制面板
			WoWTools_PanelMixin:OnlyCheck({
				name= WoWTools_CurrencyMixin.addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil

					print(
						WoWTools_CurrencyMixin.addName..WoWTools_DataMixin.Icon.icon2,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end
			})

			--WoWTools_DataMixin.CurrencyUpdateItemLevelID= Save().ItemInteractionID--套装，转换，货币
			--WoWTools_CurrencyMixin:Init_ItemInteractionFrame()


			if Save().disabled then
				self:UnregisterAllEvents()
				self:SetScript('OnEvent', nil)

			else
				--[[for itemID in pairs(Save().item) do
					WoWTools_DataMixin:Load(itemID, 'item')--加载 item quest spell
				end]]

				WoWTools_CurrencyMixin:Init_MaxTooltip()

				if C_AddOns.IsAddOnLoaded('Blizzard_TokenUI') then
					Init()
					self:UnregisterAllEvents()
					self:SetScript('OnEvent', nil)
				end
			end

		elseif arg1=='Blizzard_TokenUI' and Save() then
			Init()
			self:UnregisterAllEvents()
			self:SetScript('OnEvent', nil)
		end
    end
end)