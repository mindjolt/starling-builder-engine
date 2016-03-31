/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.util
{
    /**
     * @private
     */
    public class ObjectLocaterUtil
    {
        public function ObjectLocaterUtil()
        {
        }

        public static function set(obj:Object, propertyName:String, value:Object):void
        {
            //handle dot access (e.g. foo.bar)
            var array:Array = propertyName.split(".");
            var lastName:Object = array.pop();

            var res:Object = obj;

            for each (var name:String in array)
            {
                res = res[name];
            }

            res[lastName] = value;
        }

        public static function get(obj:Object, propertyName:String):Object
        {
            //handle dot access (e.g. foo.bar)
            var array:Array = propertyName.split(".");

            var res:Object = obj;

            for each (var name:String in array)
            {
                res = res[name];
            }

            return res;
        }

        public static function del(obj:Object, propertyName:String):void
        {
            var array:Array = propertyName.split(".");
            var lastName:Object = array.pop();

            var res:Object = obj;

            for each (var name:String in array)
            {
                res = res[name];
            }

            delete res[lastName];
        }

        public static function hasProperty(obj:Object, propertyName:String):Boolean
        {
            //handle dot access (e.g. foo.bar)
            var array:Array = propertyName.split(".");

            var res:Object = obj;

            for each (var name:String in array)
            {
                if (res.hasOwnProperty(name))
                {
                    res = res[name];
                }
                else
                {
                    return false;
                }
            }

            return true;
        }
    }
}
