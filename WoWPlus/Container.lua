local id, e = ...
local fun=UpdateContainerFrameAnchors
local CONTAINER_SCALE = 0.75;
local function GetInitialContainerFrameOffsetX()
	return EditModeUtil:GetRightActionBarWidth() + 10;
end
local function GetContainerScale()
	local containerFrameOffsetX = GetInitialContainerFrameOffsetX();
	local xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end

	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = containerFrameOffsetX / containerScale;
		yOffset = CONTAINER_OFFSET_Y / containerScale;
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		local framesInColumn = 0;
		local forceScaleDecrease = false;
		for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
			framesInColumn = framesInColumn + 1;
			frameHeight = frame:GetHeight(true);
			if ( freeScreenHeight < frameHeight ) then
				if framesInColumn == 1 then
					-- If this is the only frame in the column and it doesn't fit, then scale must be reduced and the iteration restarted
					forceScaleDecrease = true;
					break;
				else
					-- Start a new column
					column = column + 1;
					framesInColumn = 0; -- kind of a lie, at this point there's actually a single frame in the new column, but this simplifies where to increment.
					leftMostPoint = screenWidth - ( column * frame:GetWidth(true) * containerScale ) - xOffset;
					freeScreenHeight = screenHeight - yOffset;
				end
			end

			freeScreenHeight = freeScreenHeight - frameHeight;
		end

		if forceScaleDecrease or (leftMostPoint < leftLimit) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end

	return math.max(containerScale, CONTAINER_SCALE);
end

local function UpdateContainerFrameAnchors2()
        local containerScale = GetContainerScale();
        local screenHeight = GetScreenHeight() / containerScale;
        -- Adjust the start anchor for bags depending on the multibars
        local xOffset = GetInitialContainerFrameOffsetX() / containerScale;
        local yOffset = CONTAINER_OFFSET_Y / containerScale;
        -- freeScreenHeight determines when to start a new column of bags
        local freeScreenHeight = screenHeight - yOffset;
        local previousBag;
        local firstBagInMostRecentColumn;
        for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            frame:SetScale(containerScale);
            if index == 1 then
                -- First bag
                print(-xOffset, yOffset)
                frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -xOffset, yOffset);
                firstBagInMostRecentColumn = frame;
            elseif (freeScreenHeight < frame:GetHeight()) or previousBag:IsCombinedBagContainer() then
                -- Start a new column
                freeScreenHeight = screenHeight - yOffset;
                frame:SetPoint("BOTTOMRIGHT", firstBagInMostRecentColumn, "BOTTOMLEFT", -11, 0);
                firstBagInMostRecentColumn = frame;
            else
                -- Anchor to the previous bag
                frame:SetPoint("BOTTOMRIGHT", previousBag, "TOPRIGHT", 0, CONTAINER_SPACING);
            end

            previousBag = frame;
            freeScreenHeight = freeScreenHeight - frame:GetHeight();
        end
    end


UpdateContainerFrameAnchors=UpdateContainerFrameAnchors2
local function setUpdateContainerFrameAnchors()

end
--ContainerFrame.lua