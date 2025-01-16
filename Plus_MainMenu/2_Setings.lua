--local e= select(2, ...)
local function Save()
    return WoWTools_PlusMainMenuMixin.Save
end











local MicroButtonNames = {
    'CharacterMicroButton',--菜单
    'ProfessionMicroButton',
    'PlayerSpellsMicroButton',
    'AchievementMicroButton',
    'QuestLogMicroButton',
    'GuildMicroButton',
    'LFDMicroButton',
    'EJMicroButton',
    'CollectionsMicroButton',
    'MainMenuMicroButton',
    'HelpMicroButton',
    'StoreMicroButton',
    'MainMenuBarBackpackButton',--背包
}

local BagButtonNames={
    'CharacterBag0Slot',
    'CharacterBag1Slot',
    'CharacterBag2Slot',
    'CharacterBag3Slot',
    'CharacterReagentBag0Slot',
}

local function Set_MicroButton_OnLeave_Alpha(self)
    local texture= self.Portrait or self:GetNormalTexture()
    if texture then
        texture:SetAlpha(Save().mainMenuAlphaValue)
    end
    if self.Background then
        self.Background:SetAlpha(Save().mainMenuAlphaValue)
    end
end

local function Set_MicroButton_OnEnter_Alpha(self)
    local texture= self.Portrait or self:GetNormalTexture()
    if texture then
        texture:SetAlpha(1)
        --texture:SetVertexColor(1,1,1,1)
    end
    if self.Background then
        self.Background:SetAlpha(1)
    end
end

local function Set_Bag_OnLeave_Alpha(self)
    local name= self:GetName()
    if name then
        local texture= _G[name..'IconTexture']
        if texture then
            texture:SetAlpha(Save().mainMenuAlphaValue)
        end
        texture=_G[name..'NormalTexture']
        if texture then
            texture:SetAlpha(Save().mainMenuAlphaValue)
        end
        if self.texture2 then
            self.texture2:SetAlpha(Save().mainMenuAlphaValue)
        end
    end
end

local function Set_Bag_OnEnter_Alpha(self)
    local name= self:GetName()
    if name then
        local texture= _G[name..'IconTexture']
        if texture then
            texture:SetAlpha(1)
        end
        texture=_G[name..'NormalTexture']
        if texture then
            texture:SetAlpha(1)
        end
    end
end






local IsHookAlpha
local function Set_Alpha()
    if Save().disabled or not Save().enabledMainMenuAlpha then
        return
    end

    for _, name in pairs(MicroButtonNames) do
        local btn= _G[name]
        if btn then
            if not IsHookAlpha then
                btn:HookScript('OnEnter', Set_MicroButton_OnEnter_Alpha)
                btn:HookScript('OnLeave', Set_MicroButton_OnLeave_Alpha)
            end
            Set_MicroButton_OnLeave_Alpha(btn)
        end
    end

    for _, name in pairs(BagButtonNames) do
        local btn= _G[name]
        if btn then
            if not IsHookAlpha then
                btn:HookScript('OnEnter', Set_Bag_OnEnter_Alpha)
                btn:HookScript('OnLeave', Set_Bag_OnLeave_Alpha)
            end
            Set_Bag_OnLeave_Alpha(btn)
        end
    end

    IsHookAlpha=true
end


local function Sett_Label()
    for _, lable in pairs(WoWTools_PlusMainMenuMixin.Labels) do
        WoWTools_LabelMixin:Create(nil, {size=Save().size, changeFont=lable, color=true})
    end
end



function WoWTools_PlusMainMenuMixin:Settings()
    Set_Alpha()
    Sett_Label()
end
