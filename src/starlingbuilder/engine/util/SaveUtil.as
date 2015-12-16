/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.util
{
    public class SaveUtil
    {
        public static function willSave(object:Object, param:Object, item:Object):Boolean
        {
            if (object.hasOwnProperty("text") && param.name == "text" && item && item.customParams && item.customParams.localizeKey)
            {
                return false;
            }

            return true;
        }
    }
}
