--专业
local function Save()
    return WoWToolsSave['Plus_Move']
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
    end


    set_on_show(ProfessionsFrame)

    for _, tabID in pairs(ProfessionsFrame:GetTabSet() or {}) do
        local btn= ProfessionsFrame:GetTabButton(tabID)
        btn:HookScript('OnClick', function()
            C_Timer.After(0.5, function()
                set_on_show(ProfessionsFrame)
            end)
       end)
    end

    WoWTools_DataMixin:Hook(ProfessionsFrame, 'ApplyDesiredWidth', function(self)
        set_on_show(self)
    end)



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
    WoWTools_DataMixin:Hook(ProfessionsFrame.CraftingPage, 'SetMinimized', function(self)
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
    WoWTools_DataMixin:Hook(ProfessionsRecipeListRecipeMixin, 'Init', function(self)
        self.Label:SetPoint('RIGHT', -22, 0)
    end)

    initFunc=function()end
end








function WoWTools_MoveMixin.Events:Blizzard_Professions()

    initFunc()

    local name= ProfessionsFrame:GetName()

    self:Setup(ProfessionsFrame, {
        setSize=true,
        scaleStoppedFunc=function()
            local sacle= ProfessionsFrame:GetScale()
            if ProfessionsUtil.IsCraftingMinimized() then
                Save().scale[name..'Mini']= sacle
            elseif ProfessionsFrame.TabSystem.selectedTabID==2 then
                Save().scale[name..'Spec']= sacle
            elseif ProfessionsFrame.TabSystem.selectedTabID==3 then
                Save().scale[name..'Order']= sacle
            else
                Save().scale[name..'Normal']= sacle
            end
        end,
        scaleRestFunc=function()
            if ProfessionsUtil.IsCraftingMinimized() then
                Save().scale[name..'Mini']= nil
            elseif ProfessionsFrame.TabSystem.selectedTabID==2 then
                Save().scale[name..'Spec']= nil
            elseif ProfessionsFrame.TabSystem.selectedTabID==3 then
                Save().scale[name..'Order']= nil
            else
                Save().scale[name..'Normal']= nil
            end
        end,
        sizeRestTooltipColorFunc=function()
            if ProfessionsUtil.IsCraftingMinimized() then
                return Save().size[name..'Mini'] and '' or '|cff9e9e9e'
            elseif ProfessionsFrame.TabSystem.selectedTabID==2 then
                return Save().size[name..'Spec'] and '' or '|cff9e9e9e'
            elseif ProfessionsFrame.TabSystem.selectedTabID==3 then
                return Save().size[name..'Order'] and '' or '|cff9e9e9e'
            else
                return Save().size[name..'Normal'] and '' or '|cff9e9e9e'
            end
        end,
        sizeStopFunc=function()
            local size= {ProfessionsFrame:GetSize()}

            if ProfessionsUtil.IsCraftingMinimized() then
                name= name..'Mini'
            elseif ProfessionsFrame.TabSystem.selectedTabID==2 then
                name= name..'Spec'
            elseif ProfessionsFrame.TabSystem.selectedTabID==3 then
                name= name..'Order'
            else
                name= name..'Normal'
            end
            Save().size[name]= size
            ProfessionsFrame:Refresh()
            --ProfessionsFrame:Refresh(ProfessionsFrame.professionInfo)
        end,
        sizeRestFunc=function()
            if ProfessionsUtil.IsCraftingMinimized() then
                ProfessionsFrame:SetSize(404, 658)

            elseif ProfessionsFrame.TabSystem.selectedTabID==2 then
                ProfessionsFrame:SetSize(1144, 658)

            elseif ProfessionsFrame.TabSystem.selectedTabID==3 then
                ProfessionsFrame:SetSize(1105, 658)

            else
                ProfessionsFrame:SetSize(942, 658)
            end
            ProfessionsFrame:Refresh()
            Save().size[name..'Spec']=nil
            Save().size[name..'Order']=nil
            Save().size[name..'Normal']=nil
            Save().size[name..'Mini']=nil
        end
    })

    self:Setup(ProfessionsFrame.CraftingPage.CraftingOutputLog, {frame=ProfessionsFrame})
end