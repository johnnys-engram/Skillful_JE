module Skillful.Main
import Skillful.Utils.*

/*
My original implementation of this mod replaced the GetProficiencyMaxLevel function copy-pasting the original code, and only returning the computed
max level for gamedataProficiencyType.Count and gamedataProficiencyType.Invalid. 

While that implementation was dead simple, it had the potential to interfere with other mods that replace the GetProficiencyMaxLevel function. 

Instead, we wrap the function and only modify the returned value if it's in the expected range for the gamedataProficiencyType, otherwise, we return
the original value as it either indicates an error, or that another mod has changed this implementation, and we don't want to break another mod.
*/
@wrapMethod(PlayerDevelopmentData)
private final const func GetProficiencyMaxLevel(type: gamedataProficiencyType) -> Int32 {
    let absoluteMaxLevel: Int32;
    let absoluteMinLevel: Int32;
    let originalProficiencyMaxLevel: Int32;
    let proficiencyRec: ref<Proficiency_Record>;

    originalProficiencyMaxLevel = wrappedMethod(type);

    //-1 indicates an error state in the original GetProficiencyMaxLevel
    if(originalProficiencyMaxLevel == -1) {
        return originalProficiencyMaxLevel;
    }
    //A value less than -1 is undefined behaviour, so we'll warn the user and send the value on it's way, as it could be for another mod.
    if (originalProficiencyMaxLevel < 0) {
        LogSkillful("GetProficiencyMaxLevel returned an unexpected value: " + IntToString(originalProficiencyMaxLevel) + ". This may have been caused by another mod.");
        return originalProficiencyMaxLevel;
    }
    //Count is used to define the the number of actual values in the gamedataProficiencyType enum, and Invalid is used for indicating some sort of error state,
    //and changing these return values would be a very bad idea.
    if(Equals(type, gamedataProficiencyType.Count) || Equals(type, gamedataProficiencyType.Invalid)) {
        return originalProficiencyMaxLevel;
    }


    proficiencyRec = RPGManager.GetProficiencyRecord(type);
    absoluteMinLevel = proficiencyRec.MinLevel();
    absoluteMaxLevel = proficiencyRec.MaxLevel();
    
    //We check that the value is within the min and max bounds for the type, if not, it's likely that another mod is causing this behaviour.
    //As such, we return the original value as we don't want to break someone else's mod.
    if(originalProficiencyMaxLevel < absoluteMinLevel || originalProficiencyMaxLevel > absoluteMaxLevel) {
        LogSkillful("GetProficiencyMaxLevel returned " + IntToString(originalProficiencyMaxLevel) 
            + ", which is outside of the bounds of the specified MinLevel and MaxLevel (" 
            + IntToString(absoluteMinLevel) + ", " + IntToString(absoluteMaxLevel) + ") for " + proficiencyRec.DisplayName()
            + ". This may have been caused by another mod.");
        return originalProficiencyMaxLevel;
    }

    //If no other errors were found, we return the max level for the proficiency, which makes allows the player to keep gaining xp
    return absoluteMaxLevel;
}
