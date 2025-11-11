local P_Save= {
	--disabled=true,
	--hide=true,
	--autoShow=true,--自动显示
	--sacle=1,

	logColor={},--保存，历史记录
	--logMaxColor=10,--设置，最多保存30个颜色
	--selectType2=true,--更多颜色

	saveColor={},--保存4个颜色
	notHideFuori= WoWTools_DataMixin.Player.husandro,--自动隐藏
}


local function Save()
	return WoWToolsSave['Plus_Color']
end





local function Show_ClorFrame()
	if not Save().autoShow then
		return
	end
	--C_Timer.After(2, function()

	WoWTools_ColorMixin:ShowColorFrame(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b, 1, nil, nil)

	print(
		WoWTools_ColorMixin.addName..WoWTools_DataMixin.Icon.icon2,
		'|cnGREEN_FONT_COLOR:'
		..(WoWTools_DataMixin.onlyChinese and '自动显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW))

	)

end




--原生，去掉，在框架外，会自动关闭
local function Set_Event(self, event)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self:IsShown()
			and not DoesAncestryIncludeAny(self, GetMouseFoci())
			--and not _G['WoWToolsColorPickerFrameButton']:IsMenuOpen()
			and not Save().notHideFuori--自动隐藏
			and not Menu.GetManager():IsAnyMenuOpen()

		then
			if self.cancelFunc then
				self.cancelFunc(self.previousValues);
			end
			self:Hide();
		end
	end
end




local function Init()
	do
		WoWTools_ColorMixin:Init_Menu()
	end
	WoWTools_ColorMixin:Init_EditBox()
	WoWTools_ColorMixin:Init_SelectColor()
	WoWTools_ColorMixin:Init_Log()
	WoWTools_ColorMixin:Init_Other()

	Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")



panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
			WoWToolsSave['Plus_Color']= WoWToolsSave['Plus_Color'] or P_Save
			P_Save=nil

			WoWTools_ColorMixin.addName= '|A:colorblind-colorwheel:0:0|a'..(WoWTools_DataMixin.onlyChinese and '颜色选择器' or COLOR_PICKER)

			--添加控制面板
			WoWTools_PanelMixin:Check_Button({
				checkName= WoWTools_ColorMixin.addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(
						WoWTools_ColorMixin.addName..WoWTools_DataMixin.Icon.icon2,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end,
				buttonText='|A:colorblind-colorwheel:0:0|a'..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW),
				buttonFunc= function()
					WoWTools_ColorMixin:ShowColorFrame(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b, 1, nil, nil)
				end,
			})

			if Save().disabled then
				WoWTools_ColorMixin:Init_CODE()
				self:SetScript('OnEvent', nil)
				self:UnregisterAllEvents()

			else
				self:RegisterEvent('PLAYER_ENTERING_WORLD')
				ColorPickerFrame:SetScript('OnEvent', Set_Event)--原生，去掉，在框架外，会自动关闭

				ColorPickerFrame:HookScript('OnShow', function()
					Init()
				end)
				self:UnregisterEvent(event)
			end
        end

	elseif event=='PLAYER_ENTERING_WORLD' then
		Show_ClorFrame()
		self:SetScript('OnEvent', nil)
		self:UnregisterEvent(event)
    end
end)