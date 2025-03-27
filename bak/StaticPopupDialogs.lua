---@diagnostic disable: undefined-global, redefined-local, assign-type-mismatch, undefined-field, inject-field, missing-parameter, redundant-parameter, unused-local, trailing-space, param-type-mismatch, duplicate-set-field
--[[
https://warcraft.wiki.gg/wiki/Creating_simple_pop-up_dialog_boxes
WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI
WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT

exclusive=boolean 当显示任何其他弹出窗口时，隐藏，
whileDead=boolean 即使玩家是鬼魂也会显示对话框
acceptDelay=numberi 5秒后启用
compactItemFrame = boolean
hideOnEscape = 1,
timeout = 0,


StaticPopup.lua

hasEditBox = 1,
editBoxInstructions=text,--提示内容
editBoxYMargin = 35,
maxLetters = 32,
autoCompleteSource = GetAutoCompleteResults,
autoCompleteArgs = { AUTOCOMPLETE_LIST.ADDFRIEND.include, AUTOCOMPLETE_LIST.ADDFRIEND.exclude },
showAlert = 1,
alertTopCenterAlign = 1;
displayVertical = 1,
cover = true,
ignoreKeys = true,
spinner = true,
info.OnAccept and info.OnButton1 ) then
info.OnCancel and info.OnButton2 ) then
info.OnCancel
not info.whileDead and UnitIsDeadOrGhost("player") and  ) then
not info.interruptCinematic and InCinematic() then
info.exclusive ) then StaticPopup_HideExclusive() end
info.cancels ) then
which == "CAMP") or (which == "QUIT") ) then
which == "DEATH" ) then
info.fullScreenCover dialog.CoverFrame:SetShown(info.fullScreenCover);
not info.noCancelOnReuse ) then
info.preferredIndex ) then index = info.preferredIndex end
info.extraButton
(which == "DEATH") or
(which == "CAMP") or
(which == "QUIT") or
(which == "DUEL_OUTOFBOUNDS") or
(which == "RECOVER_CORPSE") or
(which == "RESURRECT") or
(which == "RESURRECT_NO_SICKNESS") or
(which == "INSTANCE_BOOT") or
(which == "GARRISON_BOOT") or
(which == "INSTANCE_LOCK") or
(which == "CONFIRM_SUMMON") or
(which == "CONFIRM_SUMMON_SCENARIO") or
(which == "CONFIRM_SUMMON_STARTING_AREA") or
(which == "BFMGR_INVITED_TO_ENTER") or
(which == "AREA_SPIRIT_HEAL") or
(which == "CONFIRM_REMOVE_COMMUNITY_MEMBER") or
(which == "CONFIRM_DESTROY_COMMUNITY_STREAM") or
(which == "CONFIRM_RUNEFORGE_LEGENDARY_CRAFT") or
(which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then

info.text = text_arg1;
info.timeout = text_arg2;
info.closeButton
info.closeButtonIsHide

]]




















function StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( info.OnAccept and info.OnButton1 ) then
		error("Dialog "..which.. " cannot have both OnAccept and OnButton1");
	end
	if ( info.OnCancel and info.OnButton2 ) then
		error("Dialog "..which.. " cannot have both OnCancel and OnButton2");
	end

	if ( UnitIsDeadOrGhost("player") and not info.whileDead ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( InCinematic() and not info.interruptCinematic ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( info.exclusive ) then
		StaticPopup_HideExclusive();
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and (frame.which == info.cancels) ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( (which == "CAMP") or (which == "QUIT") ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( which == "DEATH" ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = StaticPopup_GetDialog(index);
			if ( frame and frame:IsShown() and not StaticPopupDialogs[frame.which].whileDead ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);
	if ( dialog ) then
		if ( not info.noCancelOnReuse ) then
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog, dialog.data, "override");
			end
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( info.preferredIndex ) then
			index = info.preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = StaticPopup_GetDialog(i);
			if ( frame and not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and info.preferredIndex ) then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i];
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if ( not dialog ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	dialog.CoverFrame:SetShown(info.fullScreenCover);

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;
	local bottomSpace = info.extraButton ~= nil and (dialog.extraButton:GetHeight() + 60) or 16;

	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	text:Show();
	if ( (which == "DEATH") or
	     (which == "CAMP") or
		 (which == "QUIT") or
		 (which == "DUEL_OUTOFBOUNDS") or
		 (which == "RECOVER_CORPSE") or
		 (which == "RESURRECT") or
		 (which == "RESURRECT_NO_SICKNESS") or
		 (which == "INSTANCE_BOOT") or
		 (which == "GARRISON_BOOT") or
		 (which == "INSTANCE_LOCK") or
		 (which == "CONFIRM_SUMMON") or
		 (which == "CONFIRM_SUMMON_SCENARIO") or
		 (which == "CONFIRM_SUMMON_STARTING_AREA") or
		 (which == "BFMGR_INVITED_TO_ENTER") or
		 (which == "AREA_SPIRIT_HEAL") or
		 (which == "CONFIRM_REMOVE_COMMUNITY_MEMBER") or
		 (which == "CONFIRM_DESTROY_COMMUNITY_STREAM") or
		 (which == "CONFIRM_RUNEFORGE_LEGENDARY_CRAFT") or
		 (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") then
		dialog.SubText:SetText(" ");	-- The text will be filled in later.
		dialog.SubText.text_arg1 = text_arg1;
		dialog.SubText.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetFormattedText(info.text, text_arg1, MINUTES);
	elseif ( which == "SPELL_CONFIRMATION_PROMPT" or which == "SPELL_CONFIRMATION_WARNING" or which == "SPELL_CONFIRMATION_PROMPT_ALERT" or which == "SPELL_CONFIRMATION_WARNING_ALERT" ) then
		text:SetText(text_arg1);
		info.text = text_arg1;
		info.timeout = text_arg2;
	elseif ( which == "CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(data.respecCost, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, text_arg1, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
	elseif  ( which == "BUYOUT_AUCTION_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(text_arg1, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, BUYOUT_AUCTION_CONFIRMATION_STRING);
	else
		text:SetFormattedText(info.text, text_arg1, text_arg2);
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	end

	-- Show or hide the close button
	if ( info.closeButton ) then
		local closeButton = dialog.CloseButton;
		if ( info.closeButtonIsHide ) then
			closeButton:SetNormalAtlas("RedButton-Exit");
			closeButton:SetPushedAtlas("RedButton-exit-pressed");
		else
			closeButton:SetNormalAtlas("RedButton-MiniCondense");
			closeButton:SetPushedAtlas("RedButton-MiniCondense-pressed");
		end
		closeButton:Show();
	else
		dialog.CloseButton:Hide();
	end

	-- Set the editbox of the dialog
	local editBox = _G[dialog:GetName().."EditBox"];
	if ( info.hasEditBox ) then
		editBox:Show();

		editBox.Instructions:SetText(info.editBoxInstructions or "");

		if ( info.maxLetters ) then
			editBox:SetMaxLetters(info.maxLetters);
			editBox:SetCountInvisibleLetters(info.countInvisibleLetters);
		end
		if ( info.maxBytes ) then
			editBox:SetMaxBytes(info.maxBytes);
		end
		editBox:SetText("");
		if ( info.editBoxWidth ) then
			editBox:SetWidth(info.editBoxWidth);
		else
			editBox:SetWidth(130);
		end

		editBox:ClearAllPoints();
		editBox:SetPoint("BOTTOM", 0, 29 + bottomSpace);
	else
		editBox:Hide();
	end

	--See StaticPopup_ShowGenericDropdown
	dialog.Dropdown:SetShown(info.hasDropdown);

	-- Show or hide money frame
	if ( info.hasMoneyFrame ) then
		_G[dialog:GetName().."MoneyFrame"]:Show();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	elseif ( info.hasMoneyInputFrame ) then
		local moneyInputFrame = _G[dialog:GetName().."MoneyInputFrame"];
		moneyInputFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		-- Set OnEnterPress for money input frames
		if ( info.EditBoxOnEnterPressed ) then
			moneyInputFrame.gold:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.silver:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.copper:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			moneyInputFrame.gold:SetScript("OnEnterPressed", nil);
			moneyInputFrame.silver:SetScript("OnEnterPressed", nil);
			moneyInputFrame.copper:SetScript("OnEnterPressed", nil);
		end
	else
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	end

	dialog.ItemFrame:ClearAllPoints();
	dialog.SubText:ClearAllPoints();
	local itemFrameXOffset = -60;
	local itemFrameYOffset = -6;
	local subTextSpacingYOffset = info.normalSizedSubText and -18 or -6;
	if ( info.itemFrameAboveSubtext and info.hasItemFrame and info.subText ) then
		dialog.ItemFrame:SetPoint("TOP", dialog.text, "BOTTOM", itemFrameXOffset, itemFrameYOffset);
		-- Other components (like the moneyFrame) can be anchored under subtext so we anchor to the item frame instead of the bottom of the window.
		dialog.SubText:SetPoint("TOP", dialog.ItemFrame, "BOTTOM", -itemFrameXOffset, subTextSpacingYOffset);
	else
		dialog.ItemFrame:SetPoint("BOTTOM", itemFrameXOffset, bottomSpace + (info.compactItemFrame and 29 or 39));
		dialog.SubText:SetPoint("TOP", dialog.text, "BOTTOM", 0, subTextSpacingYOffset);
	end

	dialog.ItemFrame.itemID = nil;
	-- Show or hide item button
	if ( info.hasItemFrame ) then
		dialog.ItemFrame:Show();
		if ( data and type(data) == "table" ) then
			dialog.ItemFrame:SetCustomOnEnter(data.itemFrameOnEnter);

			local itemFrameCallback = data.itemFrameCallback;
			if ( itemFrameCallback ) then
				itemFrameCallback(dialog.ItemFrame);
			else
				if ( data.useLinkForItemInfo ) then
					dialog.ItemFrame:RetrieveInfo(data);
				end
				dialog.ItemFrame:DisplayInfo(data.link, data.name, data.color, data.texture, data.count, data.tooltip);
			end
		end
	else
		dialog.ItemFrame:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = info.timeout or 0;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	dialog.insertedFrame = insertedFrame;
	if ( info.subText ) then
		dialog.SubText:SetFontObject(info.normalSizedSubText and "GameFontNormal" or "GameFontNormalSmall");
		dialog.SubText:SetText(info.subText);
		dialog.SubText:Show();
	else
		dialog.SubText:Hide();
	end

	if ( insertedFrame ) then
		insertedFrame:SetParent(dialog);
		insertedFrame:ClearAllPoints();
		if ( dialog.SubText:IsShown() ) then
			insertedFrame:SetPoint("TOP", dialog.SubText, "BOTTOM");
		else
			insertedFrame:SetPoint("TOP", text, "BOTTOM");
		end
		insertedFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
	elseif ( dialog.SubText:IsShown() ) then
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
	else
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
	end
	-- Clear out data
	dialog.data = data;

	-- Set the buttons of the dialog
	local button1 = _G[dialog:GetName().."Button1"];
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	local button4 = _G[dialog:GetName().."Button4"];

	local buttons = {button1, button2, button3, button4};
	for index, button in ipairs_reverse(buttons) do
		button:SetText(info["button"..index]);
		button:Hide();
		button:SetWidth(1);
		button:ClearAllPoints();
		button.PulseAnim:Stop();

		if not (info["button"..index] and ( not info["DisplayButton"..index] or info["DisplayButton"..index](dialog))) then
			table.remove(buttons, index);
		end
	end

	dialog.numButtons = #buttons;

	local buttonTextMargin = 20;
	local minButtonWidth = 120;
	local maxButtonWidth = minButtonWidth;
	for index, button in ipairs(buttons) do
		local buttonWidth = button:GetTextWidth() + buttonTextMargin;
		maxButtonWidth = math.max(maxButtonWidth, buttonWidth);
	end

	local function InitButton(button, index)
		if info[string.format("button%dPulse", index)] then
			button.PulseAnim:Play();
		end
		button:Enable();
		button:Show();
	end

	-- Button layout logic depends on the width of the dialog, so this needs to be resized to account
	-- for any configuration options first. It will be resized again after the buttons have been arranged.
	StaticPopup_Resize(dialog, which);

	local buttonPadding = 10;
	local totalButtonPadding = (#buttons - 1) * buttonPadding;
	local totalButtonWidth = #buttons * maxButtonWidth;
	local totalWidth;
	local uncondensedTotalWidth = totalButtonWidth + totalButtonPadding;
	if uncondensedTotalWidth < dialog:GetWidth() then
		for index, button in ipairs(buttons) do
			button:SetWidth(maxButtonWidth);
			InitButton(button, index);
		end
		totalWidth = uncondensedTotalWidth;
	else
		totalWidth = totalButtonPadding;
		for index, button in ipairs(buttons) do
			local buttonWidth = math.max(minButtonWidth, button:GetTextWidth()) + buttonTextMargin;
			button:SetWidth(buttonWidth);
			totalWidth = totalWidth + buttonWidth;
			InitButton(button, index);
		end
	end

	if #buttons > 0 then
		if info.verticalButtonLayout then
			buttons[1]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -16);
			for index = 2, #buttons do
				buttons[index]:SetPoint("TOP", buttons[index-1], "BOTTOM", 0, -6);
			end
		else
			local offset = totalWidth / 2;
			buttons[1]:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", -offset, bottomSpace);
			for index = 2, #buttons do
				buttons[index]:SetPoint("BOTTOMLEFT", buttons[index-1], "BOTTOMRIGHT", buttonPadding, 0);
			end
		end
	end

	if info.extraButton then
		local extraButton = dialog.extraButton;
		extraButton:Show();
		extraButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 22);
		extraButton:SetText(info.extraButton);
		--widen if too small, but reset to 128 otherwise
		local width = 128
		local padding = 40;
		local textWidth = extraButton:GetTextWidth() + padding;
		width = math.max(width, textWidth);
		extraButton:SetWidth(width);

		dialog.Separator:Show();
	else
		dialog.extraButton:Hide();
		dialog.Separator:Hide();
	end

	-- Show or hide the alert icon
	local alertIcon = _G[dialog:GetName().."AlertIcon"];
	local dataShowsAlert = (which == "GENERIC_CONFIRMATION") and data.showAlert;
	if ( dataShowsAlert or info.showAlert ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 10);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.showAlertGear ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.customAlertIcon ) then
		alertIcon:SetTexture(info.customAlertIcon);
		if ( button3:IsShown() ) then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	else
		alertIcon:SetTexture();
		alertIcon:Hide();
	end

	dialog.Spinner:Hide();

	if ( info.StartDelay ) then
		dialog.startDelay = info.StartDelay(dialog);
		if (not dialog.startDelay or dialog.startDelay <= 0) then
			button1:Enable();
		else
			button1:Disable();
		end
	elseif info.acceptDelay then
		dialog.acceptDelay = info.acceptDelay;
		button1:Disable();
	else
		dialog.startDelay = nil;
		dialog.acceptDelay = nil;
		button1:Enable();
	end

	editBox:SetSecureText(info.editBoxSecureText);
	editBox.hasAutoComplete = info.autoCompleteSource ~= nil;
	if ( editBox.hasAutoComplete ) then
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, info.autoCompleteSource, unpack(info.autoCompleteArgs));
	else
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
	end

	dialog.DarkOverlay:Hide();

	dialog:SetWindow(nil);

	-- Finally size and show the dialog
	StaticPopup_SetUpPosition(dialog);
	dialog:Show();

	StaticPopup_Resize(dialog, which);

	if ( info.sound ) then
		PlaySound(info.sound);
	end

	return dialog;
end
