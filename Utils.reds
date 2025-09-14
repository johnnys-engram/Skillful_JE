module Skillful.Utils
import Skillful.Constants.*

public func LogSkillful(message: String) -> Void {
    LogDM(ModDefinition.Name() + ": " + message);
}