local e= select(2, ...)
if e.Player.class~='HUNTER' then
    return
end


local AllListFrame
local MAX_SUMMONABLE_HUNTER_PETS = Constants.PetConsts_PostCata.MAX_SUMMONABLE_HUNTER_PETS or 5
local EXTRA_PET_STABLE_SLOT_LUA_INDEX = (Constants.PetConsts_PostCata.EXTRA_PET_STABLE_SLOT or 5) + 1;
local NUM_PET_SLOTS_HUNTER = Constants.PetConsts_PostCata.NUM_PET_SLOTS_HUNTER or 205


local function Save()
    return WoWTools_StableFrameMixin.Save
end






local function get_text_byte(text)
    local num=0
    if type(text)=='number' then
        num= text
    elseif type(text)=='string' then
         for i=1, #text do
            num= num+ (string.byte(text, i) or 0)
         end
    end
    return num
end




local Is_In_Search
local function sort_pets_list(type)
    if Is_In_Search then
        return
    end
    Is_In_Search= true

    do
        local tab= {}
        for _, btn in pairs(AllListFrame.Buttons) do
            if btn.petData and btn.petData.slotID then
                local info = C_StableInfo.GetStablePetInfo(btn.petData.slotID) or {}
                table.insert(tab, {
                    slotID= get_text_byte(info.slotID),
                    petNumber= get_text_byte(info.petNumber),
                    type= get_text_byte(info.type),
                    creatureID= get_text_byte(info.CreatureID),
                    uiModelSceneID= get_text_byte(info.uiModelSceneID),
                    displayID= get_text_byte(info.displayID),
                    name= get_text_byte(info.name),
                    specialization= get_text_byte(info.specialization),
                    icon= get_text_byte(info.icon),
                    familyName= get_text_byte(info.familyName)
                })

            end
        end
        table.sort(tab, function(a, b)
            return a[type] < b[type]
        end)

        if not Save().sortDown then--点击，从前，向后
            for i, newTab in pairs(tab) do
                do
                    local index= i+  MAX_SUMMONABLE_HUNTER_PETS
                    C_StableInfo.SetPetSlot(newTab.slotID, index)
                end
            end
        else
            local all= #AllListFrame.Buttons
            for i, newTab in pairs(tab) do
                do
                    local newIndex= all-i+1
                    C_StableInfo.SetPetSlot(newTab.slotID, newIndex)
                end
            end
        end
    end
    Is_In_Search=nil
end










local function set_button_size(btn)
    local n= Save().all_List_Size or 28
    AllListFrame.s= n
    btn:SetSize(n, n)
    btn.Icon:SetSize(n, n)
    local s= n*0.5
    btn.BackgroundMask:SetSize(s, s)
    local w= n+ ((85-72)/72)*n--0.287
    local h= n+ ((100-72)/72)*n--0.515
    btn.Highlight:SetSize(w, h)
end








local function created_button(index)
    local btn= CreateFrame('Button', nil, AllListFrame, 'StableActivePetButtonTemplate', index)
    btn:HookScript('OnEnter', function(self)
        if self.petData then
            WoWTools_StableFrameMixin:Set_Tooltips(self, self.petData)
            e.tips:Show()
        end
    end)
    --set_button_size(btn)

    btn.Border:SetTexture(nil)
    btn.Border:ClearAllPoints()
    btn.Border:Hide()
    btn.Text= WoWTools_LabelMixin:Create(btn,{size=10, color={r=1,g=1,b=1,a=0.2}, layer='BACKGROUND'})
    btn.Text:SetPoint('CENTER', btn.Background)
    btn.Text:SetText(index)
    btn.Icon:SetDrawLayer('BORDER')
    hooksecurefunc(btn, 'SetPet', function(self)
        self.Icon:SetTexCoord(0, 1, 0, 1);
    end)
    return btn
end










--初始，宠物列表
local function Init()
    if AllListFrame or not Save().show_All_List then
        if AllListFrame then
            AllListFrame:Settings()
        end
        return
    end





    AllListFrame= CreateFrame('Frame', 'WoWTools_StableFrameAllList', StableFrame)
    AllListFrame:SetPoint('TOPLEFT', StableFrame, 'TOPRIGHT', StableFrame.Topper:IsShown() and 0 or 12,0)
    AllListFrame:SetSize(1,1)
    AllListFrame:Hide()

    AllListFrame.Buttons={}
    AllListFrame.s= Save().all_List_Size or 28
    AllListFrame.Bg= AllListFrame:CreateTexture(nil, "BACKGROUND")

    AllListFrame.Bg:SetTexCoord(1,0,1,0)
    AllListFrame.Bg:SetPoint('TOPLEFT')

    for i= EXTRA_PET_STABLE_SLOT_LUA_INDEX, NUM_PET_SLOTS_HUNTER do
        local btn= created_button(i)
        AllListFrame.Buttons[i]= btn
    end

    function AllListFrame:set_point()
        if not self:IsShown() then return end

        local x, y = 0, 0
        local btnY
        local s= StableFrame:GetHeight()
        for _, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', x, y)
            y= y-self.s
            if -y> s then
                btnY=btn
                y=0
                x=x+ self.s
            end
        end
        AllListFrame.Bg:ClearAllPoints()
        AllListFrame.Bg:SetPoint('TOPLEFT', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX])
        AllListFrame.Bg:SetPoint('BOTTOM', btnY)
        AllListFrame.Bg:SetPoint('RIGHT', AllListFrame.Buttons[NUM_PET_SLOTS_HUNTER])
    end



    function AllListFrame:Refresh()
        local show= self:IsShown()
        for _, btn in pairs(AllListFrame.Buttons) do
            btn:SetPet(show and C_StableInfo.GetStablePetInfo(btn:GetID()) or nil)
        end
        self.btn6:settings()
    end

    hooksecurefunc(StableFrame, 'Refresh', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)
    AllListFrame:SetScript('OnHide', AllListFrame.Refresh)
    AllListFrame:SetScript('OnShow', function(self)
        self:Refresh()
        self:set_point()
    end)

    StableFrame:HookScript('OnSizeChanged', function()
        if AllListFrame:IsShown() then
            AllListFrame:Refresh()
        end
    end)


    StableFrame:HookScript('OnSizeChanged', function()
        AllListFrame:set_point()
    end)


    --第6个，提示，如果，没有专精支持，它会禁用，所有，建立一个
    AllListFrame.btn6= created_button(MAX_SUMMONABLE_HUNTER_PETS)
    AllListFrame.btn6:SetPoint('BOTTOM', AllListFrame.Buttons[EXTRA_PET_STABLE_SLOT_LUA_INDEX],'TOP')
    function AllListFrame.btn6:settings()
        local show= self:GetParent():IsShown() and not StableFrame.ActivePetList.BeastMasterSecondaryPetButton:IsEnabled()
        self:SetPet(show and C_StableInfo.GetStablePetInfo(self:GetID()) or nil)
        self:SetShown(show)
    end

     
    function AllListFrame:Settings()
        self:SetShown(Save().show_All_List)
        self.Bg:SetAtlas(Save().showTexture and 'pet-list-bg' or 'footer-bg')
        self.s= Save().all_List_Size
        for _, btn2 in pairs(self.Buttons) do
            set_button_size(btn2)
        end
        self:set_point()
    end
    AllListFrame:Settings()
end












function WoWTools_StableFrameMixin:Set_StableFrame_List()
    Init()
end

function WoWTools_StableFrameMixin:sort_pets_list(type)
    sort_pets_list(type)
end