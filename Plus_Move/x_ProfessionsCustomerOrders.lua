--专业定制
local function Save()
    return WoWTools_MoveMixin.Save
end



local function initFunc()
    ProfessionsCustomerOrdersFrame.BrowseOrders:ClearAllPoints()
    ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('TOPLEFT')
    ProfessionsCustomerOrdersFrame.BrowseOrders:SetPoint('BOTTOMRIGHT')
    ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:ClearAllPoints()
    ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('TOPRIGHT', 0, -72)
    ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetWidth(660)
    ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList:SetPoint('BOTTOM', 0, 29)
    ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:ClearAllPoints()
    ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('TOPLEFT', 0, -72)
    ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList:SetPoint('BOTTOMRIGHT', ProfessionsCustomerOrdersFrame.BrowseOrders.RecipeList, 'BOTTOMLEFT', 4, 0)
    ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox:SetPoint('RIGHT', -12,0)
    ProfessionsCustomerOrdersFrame.MyOrdersPage:ClearAllPoints()
    ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('TOPLEFT')
    ProfessionsCustomerOrdersFrame.MyOrdersPage:SetPoint('BOTTOMRIGHT')
    hooksecurefunc(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox, 'Update', function(self)
        if not self:GetView() then
            return
        end
        for _, btn2 in pairs(self:GetFrames() or {}) do
            btn2.HighlightTexture:SetPoint('RIGHT')
            btn2.NormalTexture:SetPoint('RIGHT')
            btn2.SelectedTexture:SetPoint('RIGHT')
        end
    end)
    ProfessionsCustomerOrdersFrame.Form:HookScript('OnHide', function(self)
        local frame= self:GetParent()
        if frame.ResizeButton.disabledSize then
            return
        end
        frame.ResizeButton.setSize=true
        local name= frame:GetName()
        local scale= Save().scale[name]
        if scale then
            frame:SetScale(scale)
        end
        local size= Save().size[name]
        if size then
            frame:SetSize(size[1], size[2])
        end
    end)
    ProfessionsCustomerOrdersFrame.Form:HookScript('OnShow', function(self)
        local frame= self:GetParent()
        if frame.ResizeButton.disabledSize then
            return
        end
        frame.ResizeButton.setSize= false
        local name= frame:GetName()
        local scale= Save().scale[name..'From']
        if scale then
            frame:SetScale(scale)
        end
        if Save().size[name] then
            frame:SetSize(825, 568)
        end
    end)
end

local function scaleStoppedFunc(btn)
    local self= btn.target
    local name= btn.name
    if self.Form:IsShown() then
        Save().scale[name..'From']= self:GetScale()
    else
        Save().scale[name]= self:GetScale()
    end
end

local function scaleRestFunc(btn)
    local name= btn.name
    if btn.target.Form:IsShown() then
        Save().scale[name..'From']= nil
    else
        Save().scale[name]= nil
    end
end

local function sizeRestFunc(btn)
    btn.target:SetSize(825, 568)
end


local function Init()
    initFunc()
    WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame, {
        setSize=true,
        minW=825,
        minH=200,
        onShowFunc=true,
        scaleStoppedFunc=scaleStoppedFunc,
        scaleRestFunc=scaleRestFunc,
        sizeRestFunc=sizeRestFunc,
    })
    WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame.Form, {frame=ProfessionsCustomerOrdersFrame})
    WoWTools_MoveMixin:Setup(InspectRecipeFrame)
end




WoWTools_MoveMixin.ADDON_LOADED['Blizzard_ProfessionsCustomerOrders']= Init