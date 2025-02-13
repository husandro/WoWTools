local e= select(2, ...)
local function Save()
	return WoWTools_ColorMixin.Save
end



local function Init()
	local Frame= WoWTools_ColorMixin.Frame
	if OpacitySliderFrame then
		Frame.alphaText=WoWTools_LabelMixin:Create(OpacitySliderFrame, {mouse=true, size=14})--14)--透明值，提示
		Frame.alphaText:SetPoint('LEFT', OpacitySliderFrame, 'RIGHT', 5,0)

		OpacitySliderFrame:EnableMouseWheel(true)
		OpacitySliderFrame:SetScript('OnMouseWheel', function(self, d)
			local value= self:GetValue()
			if d== 1 then
				value= value- 0.01
			elseif d==-1 then
				value= value+ 0.01
			end
			value= value> 1 and 1 or value
			value= value< 0 and 0 or value
			self:SetValue(value)
		end)
	else
		Frame.alphaText=WoWTools_LabelMixin:Create(ColorPickerFrame, {mouse=true, size=14})--透明值，提示
		Frame.alphaText:SetPoint('TOP', ColorPickerFrame.Content.ColorSwatchOriginal, 'BOTTOM')
	end
	Frame.alphaText:SetScript('OnLeave', function(self) self:SetAlpha(1) e.tips:Hide() end)
	Frame.alphaText:SetScript('OnEnter', function(self)
		e.tips:SetOwner(self, "ANCHOR_LEFT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:AddDoubleLine(e.onlyChinese and '透明度' or CHANGE_OPACITY, 'Alpha')
		e.tips:Show()
	end)




	local check2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
	check2:SetCheckedTexture('MonsterFriend')
	check2.type2= CreateFrame("CheckButton", nil, ColorPickerFrame, "InterfaceOptionsCheckButtonTemplate")--显示/隐藏
	check2.type2:SetCheckedTexture('MonsterFriend')
	check2:SetPoint("TOPLEFT", ColorPickerFrame, 7, -7)
	check2:SetChecked(not Save().hide)
	check2:SetScript('OnMouseDown', function()
		Save().hide= not Save().hide and true or nil
		if not Save().hide and not Frame then
			Init()
		end
		if Frame then
			Frame:SetShown(not Save().hide)
			print(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName, e.GetShowHide(not Save().hide))
		end
	end)
	check2:SetScript('OnEnter', function()
		e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.GetShowHide(not Save().color)..e.Icon.left)
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:Show()
	end)
	check2:SetScript('OnLeave', GameTooltip_Hide)


	check2.type2:SetPoint("LEFT", check2, 'RIGHT',-4,0)
	check2.type2:SetChecked(Save().selectType2)
	check2.type2:SetScript('OnMouseDown', function()
		Save().selectType2= not Save().selectType2 and true or nil
		print(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName, e.GetEnabeleDisable(Save().selectType2), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
	end)
	check2.type2:SetScript('OnEnter', function()
		e.tips:SetOwner(ColorPickerFrame, "ANCHOR_RIGHT")
		e.tips:ClearLines()
		e.tips:AddDoubleLine(e.onlyChinese and '颜色' or COLOR, 2)
		e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ColorMixin.addName)
		e.tips:Show()
	end)
	check2.type2:SetScript('OnLeave', GameTooltip_Hide)
end






function WoWTools_ColorMixin:Init_Options()
	Init()
end