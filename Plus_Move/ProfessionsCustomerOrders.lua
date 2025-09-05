--专业定制
function WoWTools_MoveMixin.Events:Blizzard_ProfessionsCustomerOrders()
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

    WoWTools_DataMixin:Hook(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, btn2 in pairs(f:GetFrames() or {}) do
            btn2.HighlightTexture:SetPoint('RIGHT')
            btn2.NormalTexture:SetPoint('RIGHT')
            btn2.SelectedTexture:SetPoint('RIGHT')
        end
    end)

    ProfessionsCustomerOrdersFrame.Form:HookScript('OnHide', function(f)
        local frame= f:GetParent()
        if not frame.ResizeButton or frame.ResizeButton.disabledSize then
            return
        end
        frame.ResizeButton.setSize=true
        local name= frame:GetName()
        local scale= self:Save().scale[name]
        if scale then
            frame:SetScale(scale)
        end
        local size= self:Save().size[name]
        if size then
            frame:SetSize(size[1], size[2])
        end
    end)

    ProfessionsCustomerOrdersFrame.Form:HookScript('OnShow', function(f)
        local frame= f:GetParent()
        if frame.ResizeButton.disabledSize then
            return
        end
        frame.ResizeButton.setSize= false
        local name= frame:GetName()
        local scale= self:Save().scale[name..'From']
        if scale then
            frame:SetScale(scale)
        end
        if self:Save().size[name] then
            frame:SetSize(825, 568)
        end
    end)

    WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame, {
        setSize=true,
        minW=825,
        minH=200,
        onShowFunc=true,
        scaleStoppedFunc=function()
            local name= ProfessionsCustomerOrdersFrame:GetName()
            local scale= ProfessionsCustomerOrdersFrame:GetScale()
            if ProfessionsCustomerOrdersFrame.Form:IsShown() then
                self:Save().scale[name..'From']= scale
            else
                self:Save().scale[name]= scale
            end
        end,
        scaleRestFunc=function()
            local name= ProfessionsCustomerOrdersFrame:GetName()
            self:Save().scale[name..'From']= nil
            self:Save().scale[name]= nil
        end,
        sizeRestFunc=function()
            ProfessionsCustomerOrdersFrame:SetSize(825, 568)
        end,
    })
    WoWTools_MoveMixin:Setup(ProfessionsCustomerOrdersFrame.Form, {frame=ProfessionsCustomerOrdersFrame})
    WoWTools_MoveMixin:Setup(InspectRecipeFrame)
end