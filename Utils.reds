module Skillful.Utils
import Skillful.Constants.*

public final static func Log(message: String) -> Void {
    LogDM(ModDefinition.Name() + ": " + message);
}