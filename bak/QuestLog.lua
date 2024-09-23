--[[

function QuestLogScrollFrameMixin:ScrollToQuest(questID)
	local headerIndex = C_QuestLog.GetHeaderIndexForQuest(questID);
	if not headerIndex then
		return;
	end

	local targetHeader;
	local headerPools = { QuestScrollFrame.headerFramePool, QuestScrollFrame.campaignHeaderFramePool, QuestScrollFrame.campaignHeaderMinimalFramePool, QuestScrollFrame.covenantCallingsHeaderFramePool };
	for i, headerPool in ipairs(headerPools) do
		for header in headerPool:EnumerateActive() do
			if header.questLogIndex == headerIndex then
				targetHeader = header;
				break;
			end
		end
		if targetHeader then
			break;
		end
	end
	if not targetHeader then
		return;
	end

	-- this will find the frame for this quest as well as the last one for same header
	local titleFrames = { };
	for titleFrame in QuestScrollFrame.titleFramePool:EnumerateActive() do
		tinsert(titleFrames, titleFrame);
	end
	table.sort(titleFrames, function (lhsPair, rhsPair)
		return lhsPair.layoutIndex < rhsPair.layoutIndex;
	end);

	local targetTitle, lastTitleInHeader;
	local lastLayoutIndex;
	for i, titleFrame in ipairs(titleFrames) do
		if lastTitleInHeader then
			if titleFrame.layoutIndex == lastTitleInHeader.layoutIndex + 1 then
				lastTitleInHeader = titleFrame;
			else
				break;
			end
		elseif titleFrame.questID == questID then
			targetTitle = titleFrame;
			lastTitleInHeader = titleFrame;
		end
	end
	if not targetTitle then
		return;
	end

	local scrollRange = QuestScrollFrame:GetVerticalScrollRange();
	if scrollRange == 0 then
		-- nothing to scroll
		return;
	end

	local titleTop = targetTitle:GetTop();
	local titleBottom = targetTitle:GetBottom();
	local scrollFrameTop = QuestScrollFrame:GetTop();
	local scrollFrameBottom = QuestScrollFrame:GetBottom();

	if titleTop <= scrollFrameTop and titleBottom >= scrollFrameBottom then
		-- the quest is fully visible already
		return;
	end

	local offset = QuestScrollFrame:GetVerticalScroll();
	local headerTop = targetHeader:GetTop();
	local scrollFrameHeight = scrollFrameTop - scrollFrameBottom;

	-- A section is, in order of everything being able to fit in the displayable area
	-- 1. header and all quests in that header
	-- 2. header and all quests up to relevant quest, inclusive
	-- 3. relevant quest
	local sectionTop = titleTop;
	local sectionBottom = titleBottom;
	local canFitHeader = (headerTop - titleBottom) < scrollFrameHeight;
	if canFitHeader then
		sectionTop = headerTop;
		if lastTitleInHeader ~= targetTitle then
			local lastTitleBottom = lastTitleInHeader:GetBottom();
			local canFitAll = (headerTop - lastTitleBottom) < scrollFrameHeight;
			if canFitAll then
				sectionBottom = lastTitleBottom;
			end
		end
	end

	-- check if the top of the section is scrolled above the top
	local deltaTop = scrollFrameTop - sectionTop;
	if deltaTop < 0 then
		QuestScrollFrame:SetVerticalScroll(math.max(offset + deltaTop, 0));
		-- done
		return;
	end

	-- check if the bottom of the section is scrolled below the bottom
	local deltaBottom = scrollFrameBottom - sectionBottom;
	if deltaBottom > 0 then
		QuestScrollFrame:SetVerticalScroll(math.min(offset + deltaBottom, scrollRange));
		-- done
		return;
	end

	-- at this point the section is fully visible, nothing to do
end













function QuestMapQuestOptions_ShareQuest(questID)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID);
	QuestLogPushQuest(questLogIndex);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);
end
]]