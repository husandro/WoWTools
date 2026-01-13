
local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end


local ListButton
local ClassButton={}
local SpecButton={}


local function On_Click(self)
    local frame= ListButton:GetParent()

    if frame==HeirloomsJournal then
        HeirloomsJournal:SetClassAndSpecFilters(self.classID, self.specID)

    elseif frame==WardrobeCollectionFrame then
        WardrobeCollectionFrame.ClassDropdown:SetClassFilter(self.classID)
    end
end


local function On_Show(frame)
    if not ListButton:IsShown() then
        return
    end

    if not ListButton:GetParent()~=frame then
        ListButton:SetParent(frame)
    end

    if frame==HeirloomsJournal then
        ListButton:chek_select(C_Heirloom.GetClassAndSpecFilters())

    elseif frame==WardrobeCollectionFrame then
        local searchType = WardrobeCollectionFrame:GetSearchType()
        if searchType == Enum.TransmogSearchType.Items then
            ListButton:chek_select(C_TransmogCollection.GetClassFilter())

        elseif searchType == Enum.TransmogSearchType.BaseSets then
            ListButton:chek_select(C_TransmogSets.GetTransmogSetsClassFilter())
        end
    end
end





local function Cereate_Button(classID, specID, texture, atlas)
    local btn= WoWTools_ButtonMixin:Cbtn(ListButton.frame, {
        size=26,
        text=texture,
        atlas=atlas,
        isType2=true,
    })
    function btn:set_select(class, spec)
        if class==self.classID and spec==self.specID then
            self:LockHighlight()
        else
            self:UnlockHighlight()
        end
    end
    btn:SetScript('OnClick', function(self)
        On_Click(self)
    end)

    btn.classID= classID
    btn.specID= specID

    return btn
end












    local function Init_Spce(classID, spec)
        classID= classID or 0
        spec= spec or 0
        local num= (ListButton:GetParent()==HeirloomsJournal and classID>0) and C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0
        for i = 1, num do
            local specID, _, _, icon, role = GetSpecializationInfoForClassID(classID, i, WoWTools_DataMixin.Player.Sex)
            local btn= SpecButton[i]
            if not btn then
                btn= Cereate_Button(classID, specID, nil, nil)
                btn.roleTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
                btn.roleTexture:SetSize(15,15)
                btn.roleTexture:SetPoint('LEFT', btn, 'RIGHT', -4, 0)
                if i==1 then
                    local texture= btn:CreateTexture()
                    texture:SetPoint('RIGHT', btn, 'LEFT')
                    texture:SetSize(10, 10)
                    texture:SetAtlas('common-icon-rotateleft')
                end
                SpecButton[i]= btn
            end

            btn.classID= classID
            btn.specID= specID
            btn.texture:SetTexture(icon)

            role= role=='DAMAGER' and 'DPS' or role
            btn.roleTexture:SetAtlas('UI-LFG-RoleIcon-'..role..'-Micro')

            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', ClassButton[classID], 'TOPRIGHT', 7 ,0)
            else
                btn:SetPoint('TOP', SpecButton[i-1], 'BOTTOM')
            end
            btn:SetShown(true)
            btn:set_select(classID, spec)
        end
        for i=num+1, #SpecButton do
            SpecButton[i]:SetShown(false)
        end
    end














local function Init()
    if Save().hideHeirloomClassList then
        return
    end

    ListButton= CreateFrame('Button', 'WoWToolsCollectionsClassListButton', HeirloomsJournal, 'WoWToolsButtonTemplate')
    ListButton:SetNormalTexture(WoWTools_DataMixin.Icon.icon)
    ListButton:SetPoint('TOPLEFT', CollectionsJournal, 'TOPRIGHT', 8, -32)
    ListButton:SetScript('OnClick',function (self)
        On_Click(self)
    end)


    ListButton.tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat')
    ListButton.classID= 0
    ListButton.specID= 0


    --过滤，按钮
    ListButton.frame= CreateFrame('Frame', nil, ListButton)
    ListButton.frame:SetPoint('TOPLEFT', ListButton, 'BOTTOMLEFT',0 -80)
    ListButton.frame:SetSize(26, 1)


    for i = 1, GetNumClasses() do--设置，职业
		local data = C_CreatureInfo.GetClassInfo(i)
        if data and data.classFile and data.classID then
            local atlas
            if data.classFile==WoWTools_DataMixin.Player.Class then
                atlas= 'auctionhouse-icon-favorite'
            else
                atlas= WoWTools_UnitMixin:GetClassIcon(nil, nil, data.classFile, {reAtlas=true})
            end
            if atlas then
                local btn= Cereate_Button(data.classID, 0, nil, atlas)
                ClassButton[i]=btn
                btn:SetPoint('TOPLEFT', ClassButton[i-1] or ListButton.frame, 'BOTTOMLEFT')
            end
        end
    end

    function ListButton:chek_select(Class, Spec)
        Class, Spec= Class or 0, Spec or 0
        for _, btn in pairs(ClassButton) do
            btn:set_select(Class, Spec)
        end
        Init_Spce(Class, Spec)
    end

    function ListButton:set_scale()
        self.frame:SetScale(Save().Heirlooms_Class_Scale or 1)
    end


    HeirloomsJournal:HookScript('OnShow', On_Show)
    WoWTools_DataMixin:Hook(HeirloomsJournal, 'RefreshView', On_Show)

    WardrobeCollectionFrame:HookScript('OnShow', On_Show)
    WoWTools_DataMixin:Hook(WardrobeCollectionFrame.ClassDropdown, 'Refresh', function(self)
        On_Show(self:GetParent())
    end)


    ListButton:set_scale()

    Init=function()
        ListButton:set_scale()
        ListButton:SetShown(not Save().hideHeirloomClassList)
    end
end




function WoWTools_CollectionMixin:Init_ClassList()--职业列表
    Init()
end