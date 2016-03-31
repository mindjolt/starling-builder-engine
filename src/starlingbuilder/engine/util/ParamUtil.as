/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.util
{
    import starlingbuilder.engine.UIBuilder;

    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    /**
     * @private
     */
    public class ParamUtil
    {
        public function ParamUtil()
        {
        }

        public static function getParams(template:Object, obj:Object):Array
        {
            var className:String = getClassName(obj);
            return getParamByClassName(template, className);
        }

        public static function getParamByClassName(template:Object, className:String):Array
        {
            var params:Array;

            if (getFlag(template, className, "tag") == "ignore_default")
            {
                params = [];
            }
            else
            {
                params = template.default_component.params.concat();
            }

            if (getFlag(template, className, "tag") == "feathers")
            {
                params = params.concat(template.default_feathers_component.params);
            }

            for each (var item:Object in template.supported_components)
            {
                if (item.cls == className)
                {
                    for each (var param:Object in item.params)
                    {
                        params.push(param);
                    }

                    break;
                }
            }

            return params;
        }

        public static function getClassName(obj:Object):String
        {
            if (obj == null) return "";

            return getQualifiedClassName(obj).replace(/::/g, ".");
        }

        public static function getClassNames(objects:Array):Array
        {
            var res:Array = [];
            for each (var obj:Object in objects)
            {
                res.push(getClassName(obj));
            }
            return res;
        }

        public static function getCustomParams(template:Object):Array
        {
            return template.default_component.customParams as Array;
        }

        public static function getTweenParams(template:Object):Array
        {
            return template.default_component.tweenParams as Array;
        }

        public static function getConstructorParams(template:Object, cls:String):Array
        {
            for each (var item:Object in template.supported_components)
            {
                if (item.cls == cls)
                {
                    return UIBuilder.cloneObject(item.constructorParams) as Array;
                }
            }

            return null;
        }

        public static function getCreateComponentClass(template:Object, cls:String):Class
        {
            for each (var item:Object in template.supported_components)
            {
                if (item.cls == cls && item.createComponentClass)
                {
                    return getDefinitionByName(item.createComponentClass) as Class;
                }
            }

            return null;
        }

        public static function hasFlag(template:Object, cls:String, flag:String):Boolean
        {
            for each (var item:Object in template.supported_components)
            {
                if (item.cls == cls)
                {
                    if (item.hasOwnProperty(flag))
                        return true;
                    else
                        return false;
                }
            }

            return false;

        }

        public static function getFlag(template:Object, cls:String, flag:String):String
        {
            for each (var item:Object in template.supported_components)
            {
                if (item.cls == cls)
                {
                    if (item.hasOwnProperty(flag))
                        return item[flag];
                    else
                        return null;
                }
            }

            return null;
        }

        public static function getDisplayObjectName(cls:String):String
        {
            var index:int = cls.lastIndexOf(".") + 1;
            return cls.substr(index, 1).toLocaleLowerCase() + cls.substr(index + 1);
        }

        public static function createButton(template:Object, cls:String):Boolean
        {
            return hasFlag(template, cls, "createButton");
        }

        public static function scale3Data(template:Object, cls:String):Boolean
        {
            return hasFlag(template, cls, "scale3Data");
        }

        public static function scale9Data(template:Object, cls:String):Boolean
        {
            return hasFlag(template, cls, "scale9Data");
        }

        public static function isContainer(template:Object, cls:String):Boolean
        {
            return hasFlag(template, cls, "container");
        }
    }
}
