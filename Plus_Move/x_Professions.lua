--专业
local function Save()
    return WoWTools_MoveMixin.Save
end














local function initFunc()
    ProfessionsFrame.CraftingPage.P_GetDesiredPageWidth= ProfessionsFrame.CraftingPage.GetDesiredPageWidth
    function ProfessionsFrame.CraftingPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafting.lua
        local size, scale
        local frame= self:GetParent()
        local name= frame:GetName()
        if ProfessionsUtil.IsCraftingMinimized() then
            scale= Save().scale[name..'Mini']
            size= Save().size[name..'Mini']

        else
            scale= Save().scale[name..'Normal']
            size= Save().size[name..'Normal']
        end
        if scale then
            frame:SetScale(scale)
        end
        if size then
            frame:SetSize(size[1], size[2])
            return size[1]
        else
            return self:P_GetDesiredPageWidth()--404
        end
    end

    ProfessionsFrame.OrdersPage.P_GetDesiredPageWidth= ProfessionsFrame.OrdersPage.GetDesiredPageWidth
    function ProfessionsFrame.OrdersPage:GetDesiredPageWidth()--Blizzard_ProfessionsCrafterOrderPage.lua
        local frame= self:GetParent()
        local name= frame:GetName()
        local scale= Save().scale[name..'Order']
        local size= Save().size[name..'Order']
        if scale then
            frame:SetScale(scale)
        end
        if size then
            frame:SetSize(size[1], size[2])
            return size[1]
        else
            return self:P_GetDesiredPageWidth()-- 1105
        end
    end

    ProfessionsFrame.SpecPage.P_GetDesiredPageWidth= ProfessionsFrame.SpecPage.GetDesiredPageWidth
    function ProfessionsFrame.SpecPage:GetDesiredPageWidth()--Blizzard_ProfessionsSpecializations.lua
        local frame= self:GetParent()
        local name= frame:GetName()
        local scale= Save().scale[name..'Spec']
        local size= Save().size[name..'Spec']
        if scale then
            frame:SetScale(scale)
        end
        if size then
            frame:SetSize(size[1], size[2])
            return size[1]
        else
            return self:P_GetDesiredPageWidth()--1144
        end
    end
    
    local function set_on_show(self)
        if not self.ResizeButton then
            return
        end
        C_Timer.After(0.3, function()
            local size, scale
            local name= self:GetName()
            if ProfessionsUtil.IsCraftingMinimized() then
                scale= Save().scale[name..'Mini']
                size= Save().size[name..'Mini']
                self.ResizeButton.minWidth= 404
                self.ResizeButton.minHeight= 650
            elseif self.TabSystem.selectedTabID==1 then
                scale= Save().scale[name..'Normal']
                size= Save().size[name..'Normal']
                self.ResizeButton.minWidth= 830
                self.ResizeButton.minHeight= 580
                if size then
                    self:Refresh()
                end
            elseif self.TabSystem.selectedTabID==2 then
                scale= Save().scale[name..'Spec']
                size= Save().size[name..'Spec']
                self.ResizeButton.minWidth= 1144
                self.ResizeButton.minHeight= 658
            elseif self.TabSystem.selectedTabID==3 then
                scale= Save().scale[name..'Order']
                size= Save().size[name..'Order']
                self.ResizeButton.minWidth= 1050
                self.ResizeButton.minHeight= 240
                if size then
                    self:Refresh()
                end
            end
            if scale then
                self:SetScale(scale)
            end
            if size then
                self:SetSize(size[1], size[2])
            end
        end)
    end
    ProfessionsFrame:HookScript('OnShow', set_on_show)
    for _, tabID in pairs(ProfessionsFrame:GetTabSet() or {}) do
        local btn= ProfessionsFrame:GetTabButton(tabID)
        btn:HookScript('OnClick', function()
            set_on_show(ProfessionsFrame)
       end)
    end
    hooksecurefunc(ProfessionsFrame, 'ApplyDesiredWidth', set_on_show)



    --655 553
    local function set_craftingpage_position(self)
        self.SchematicForm:ClearAllPoints()
        self.SchematicForm:SetPoint('TOPRIGHT', -5, -72)
        self.SchematicForm:SetPoint('BOTTOMRIGHT', 670, 5)
        self.RecipeList:ClearAllPoints()
        self.RecipeList:SetPoint('TOPLEFT', 5, -72)
        self.RecipeList:SetPoint('BOTTOMLEFT', 5, 5)
        self.RecipeList:SetPoint('TOPRIGHT', self.SchematicForm, 'TOPLEFT')
    end
    set_craftingpage_position(ProfessionsFrame.CraftingPage)
    function ProfessionsFrame.CraftingPage:SetMaximized()
        set_craftingpage_position(self)
        self:Refresh(self.professionInfo)
    end
    hooksecurefunc(ProfessionsFrame.CraftingPage, 'SetMinimized', function(self)
        self.SchematicForm.Details:ClearAllPoints()
        self.SchematicForm.Details:SetPoint('BOTTOM', 0, 33)
        self.SchematicForm:SetPoint('BOTTOMRIGHT')
    end)
    ProfessionsFrame.CraftingPage.RankBar:ClearAllPoints()
    ProfessionsFrame.CraftingPage.RankBar:SetPoint('RIGHT', ProfessionsFrame.CraftingPage.Prof1Gear1Slot, 'LEFT', -36, 0)

    ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:ClearAllPoints()
    ProfessionsFrame.CraftingPage.SchematicForm.MinimalBackground:SetAllPoints(ProfessionsFrame.CraftingPage.SchematicForm)

    ProfessionsFrame.SpecPage.TreeView:ClearAllPoints()
    ProfessionsFrame.SpecPage.TreeView:SetPoint('TOPLEFT', 2, -85)
    ProfessionsFrame.SpecPage.TreeView:SetPoint('BOTTOM', 0, 50)
    ProfessionsFrame.SpecPage.DetailedView:ClearAllPoints()
    ProfessionsFrame.SpecPage.DetailedView:SetPoint('TOPLEFT', ProfessionsFrame.SpecPage.TreeView, 'TOPRIGHT', -40, 0)
    ProfessionsFrame.SpecPage.DetailedView:SetPoint('BOTTOMRIGHT', 0, 50)

    ProfessionsFrame.SpecPage.PanelFooter:ClearAllPoints()
    ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMLEFT', 0, 4)
    ProfessionsFrame.SpecPage.PanelFooter:SetPoint('BOTTOMRIGHT')

    ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:ClearAllPoints()
    ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('TOPRIGHT', 0, -92)
    ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetWidth(800)
    ProfessionsFrame.OrdersPage.BrowseFrame.OrderList:SetPoint('BOTTOM', 0, 5)
    ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:ClearAllPoints()
    ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('TOPLEFT', 5, -92)
    ProfessionsFrame.OrdersPage.BrowseFrame.RecipeList:SetPoint('BOTTOMRIGHT', ProfessionsFrame.OrdersPage.BrowseFrame.OrderList, 'BOTTOMLEFT')
    for _, region in pairs({ProfessionsFrame.SpecPage.PanelFooter:GetRegions()}) do
        if region:GetObjectType()=='Texture' then
            region:ClearAllPoints()
            region:SetAllPoints(ProfessionsFrame.SpecPage.PanelFooter)
            break
        end
    end
    hooksecurefunc(ProfessionsRecipeListRecipeMixin, 'Init', function(self)
        self.Label:SetPoint('RIGHT', -22, 0)
    end)
end








local function scaleStoppedFunc(btn)
    local self= btn.target
    local sacle= self:GetScale()
    local name= btn.name
    if ProfessionsUtil.IsCraftingMinimized() then
        Save().scale[name..'Mini']= sacle
    elseif self.TabSystem.selectedTabID==2 then
        Save().scale[name..'Spec']= sacle
    elseif self.TabSystem.selectedTabID==3 then
        Save().scale[name..'Order']= sacle
    else
        Save().scale[name..'Normal']= sacle
    end
end


local function scaleRestFunc(btn)
    local self= btn.target
    local name= btn.name
    if ProfessionsUtil.IsCraftingMinimized() then
        Save().scale[name..'Mini']= nil
    elseif self.TabSystem.selectedTabID==2 then
        Save().scale[name..'Spec']= nil
    elseif self.TabSystem.selectedTabID==3 then
        Save().scale[name..'Order']= nil
    else
        Save().scale[name..'Normal']= nil
    end
end



local function sizeRestTooltipColorFunc(btn)
    local name= btn.name
    if ProfessionsUtil.IsCraftingMinimized() then
        return Save().size[name..'Mini'] and '' or '|cff9e9e9e'
    elseif btn.target.TabSystem.selectedTabID==2 then
        return Save().size[name..'Spec'] and '' or '|cff9e9e9e'
    elseif btn.target.TabSystem.selectedTabID==3 then
        return Save().size[name..'Order'] and '' or '|cff9e9e9e'
    else
        return Save().size[name..'Normal'] and '' or '|cff9e9e9e'
    end
end



local function sizeStopFunc(btn)
    local self= btn.target
    local name= btn.name
    local size= {self:GetSize()}
    if ProfessionsUtil.IsCraftingMinimized() then
        Save().size[name..'Mini']= size
    elseif self.TabSystem.selectedTabID==2 then
        Save().size[name..'Spec']= size
    elseif self.TabSystem.selectedTabID==3 then
        Save().size[name..'Order']= size
        self:Refresh()
    else
        Save().size[name..'Normal']= size
        self:Refresh()
    end
end






local function sizeRestFunc(btn)
    local self= btn.target
    local name= btn.name
    if ProfessionsUtil.IsCraftingMinimized() then
        self:SetSize(404, 658)
        Save().size[name..'Mini']=nil
    elseif self.TabSystem.selectedTabID==2 then
        self:SetSize(1144, 658)
        Save().size[name..'Spec']=nil
    elseif self.TabSystem.selectedTabID==3 then
        self:SetSize(1105, 658)
        Save().size[name..'Order']=nil
    else
        self:SetSize(942, 658)
        Save().size[name..'Normal']=nil
        self:Refresh(self.professionInfo)
    end
end



function WoWTools_MoveMixin.Events:Blizzard_Professions()

    initFunc()

    WoWTools_MoveMixin:Setup(ProfessionsFrame, {
        setSize=true,
        scaleStoppedFunc=scaleStoppedFunc,
        scaleRestFunc=scaleRestFunc,
        sizeRestTooltipColorFunc=sizeRestTooltipColorFunc,
        sizeStopFunc=sizeStopFunc,
        sizeRestFunc=sizeRestFunc
    })
end