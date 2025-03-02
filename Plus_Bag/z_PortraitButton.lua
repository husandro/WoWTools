

local function Init()
    for index=BACKPACK_CONTAINER, NUM_BAG_FRAMES+ NUM_REAGENTBAG_FRAMES+ NUM_BANKBAGSLOTS do
        local frame= _G['ContainerFrame'..index]
        if frame and frame.PortraitButton then
            frame.PortraitButton:ClearAllPoints()
            --frame.PortraitButton:SetPoint('TOPLEFT', frame.PortraitContainer, 'BOTTOMRIGHT')
            
            if frame.FilterIcon then

            end
            --print(frame.portrait)
            print(frame.FilterIcon.Icon)
        else
            print(index)
        end

    end
end
function WoWTools_BagMixin:Init_PortraitButton()
    --Init()
end
