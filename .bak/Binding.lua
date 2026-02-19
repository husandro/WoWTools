    local action = "INTERACTTARGET";
    local bindingIndex = C_KeyBindings.GetBindingIndex(action);
    local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
    initializer:AddSearchTags(GetBindingName(action));
    WoWTools_PetBattleMixin.Layout:AddInitializer(initializer);
