local function Init()
    PetName:SetAlpha(0)
    PetFrameManaBarText:SetAlpha(0)

    PetFrameHealthBarTextLeft:ClearAllPoints()
    PetFrameHealthBarTextLeft:SetPoint('TOPLEFT', PetPortrait, 'TOPRIGHT',0, 1.5)

    PetFrameHealthBarTextRight:ClearAllPoints()
    PetFrameHealthBarTextRight:SetPoint('BOTTOMRIGHT', PetFrameHealthBar, 'TOPRIGHT', 0, 1.5)

    PetFrameHealthBarText:ClearAllPoints()
    PetFrameHealthBarText:SetPoint('BOTTOM', PetFrameHealthBar, 'TOP', 0, 1.5)

    Init=function()end
end


function WoWTools_UnitMixin:Init_PetFrame()
    Init()
end