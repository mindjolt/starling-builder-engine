/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine
{
    import starlingbuilder.engine.format.DefaultDataFormatter;
    import starlingbuilder.engine.format.IDataFormatter;
    import starlingbuilder.engine.format.StableJSONEncoder;
    import starlingbuilder.engine.localization.ILocalization;
    import starlingbuilder.engine.util.ObjectLocaterUtil;
    import starlingbuilder.engine.util.ParamUtil;
    import starlingbuilder.engine.util.SaveUtil;

    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;
    import starling.textures.Texture;

    public class UIBuilder implements IUIBuilder
    {
        public static const VERSION:String = "1.0";

        private var _assetMediator:IAssetMediator;

        private var _dataFormatter:IDataFormatter;

        private var _factory:UIElementFactory;

        private var _forEditor:Boolean;

        private var _template:Object;

        private var _localization:ILocalization;

        public function UIBuilder(assetMediator:IAssetMediator, forEditor:Boolean = false, template:Object = null, localization:ILocalization = null)
        {
            _assetMediator = assetMediator;
            _dataFormatter = new DefaultDataFormatter();
            _factory = new UIElementFactory(_assetMediator, forEditor);
            _forEditor = forEditor;
            _template = template;
            _localization = localization;
        }

        public function load(data:Object, trimLeadingSpace:Boolean = true):Object
        {
            if (_dataFormatter)
                data = _dataFormatter.read(data);

            var paramsDict:Dictionary = new Dictionary();

            var root:DisplayObject = loadTree(data.layout, _factory, paramsDict);

            if (trimLeadingSpace && root is DisplayObjectContainer)
                doTrimLeadingSpace(root as DisplayObjectContainer);

            localizeTexts(root, paramsDict);

            return {object:root, params:paramsDict, data:data};
        }

        private function loadTree(data:Object, factory:UIElementFactory, paramsDict:Dictionary):DisplayObject
        {
            var obj:DisplayObject = factory.create(data) as DisplayObject;
            paramsDict[obj] = data;

            var container:DisplayObjectContainer = obj as DisplayObjectContainer;

            if (container)
            {
                if (data.children)
                {
                    for each (var item:Object in data.children)
                    {
                        if (!_forEditor && item.customParams && item.customParams.forEditor)
                            continue;

                        container.addChild(loadTree(item, factory, paramsDict));
                    }
                }

                if (isExternalSource(data))
                {
                    var externalData:Object = _dataFormatter.read(_assetMediator.getExternalData(data.customParams.source));
                    var params:Dictionary = new Dictionary();
                    container.addChild(loadTree(externalData.layout, factory, params));
                    paramsDict[obj] = data;
                }
            }

            return obj;
        }

        public function save(container:DisplayObjectContainer, paramsDict:Object, setting:Object = null):Object
        {
            if (!_template)
            {
                throw new Error("template not found!");
            }

            var data:Object = {};
            data.version = VERSION;
            data.layout = saveTree(container.getChildAt(0), paramsDict);
            data.setting = cloneObject(setting);

            if (_dataFormatter)
            {
                data = _dataFormatter.write(data);
            }

            return data;
        }

        public function isContainer(param:Object):Boolean
        {
            if (param && ParamUtil.isContainer(_template, param.cls) && !param.customParams.source)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public function copy(obj:DisplayObject, paramsDict:Object):String
        {
            if (!_template)
            {
                throw new Error("template not found!");
            }

            return StableJSONEncoder.stringify(saveTree(obj, paramsDict));
        }

        public function paste(string:String):Object
        {
            return {layout:JSON.parse(string)};
        }

        public function setExternalSource(param:Object, name:String):void
        {
            param.customParams.source = name;
        }

        private function isExternalSource(param:Object):Boolean
        {
            if (param && param.customParams && param.customParams.source)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        private function saveTree(object:DisplayObject, paramsDict:Object):Object
        {
            var item:Object = saveElement(object, ParamUtil.getParams(_template, object), paramsDict[object]);

            var container:DisplayObjectContainer = object as DisplayObjectContainer;

            if (container && isContainer(paramsDict[object]))
            {
                item.children = [];

                for (var i:int = 0; i < container.numChildren; ++i)
                {
                    item.children.push(saveTree(container.getChildAt(i), paramsDict));
                }
            }

            return item;
        }

        private function saveElement(obj:Object, params:Array, paramsData:Object):Object
        {
            var item:Object = {params:{}, constructorParams:[], customParams:{}};

            item.cls = ParamUtil.getClassName(obj);

            if (paramsData)
            {
                item.constructorParams = cloneObject(paramsData.constructorParams);
                item.customParams = cloneObject(paramsData.customParams);
                removeDefault(item, ParamUtil.getCustomParams(_template));
            }

            for each (var param:Object in params)
            {
                if (obj.hasOwnProperty(param.name))
                {
                    if (param.hasOwnProperty("cls"))
                    {
                        if (obj[param.name] is Texture)   //special case for saving texture
                        {
                            item.params[param.name] = cloneObject(paramsData.params[param.name]);
                        }
                        else
                        {
                            var subObject:Object = obj[param.name];
                            if (subObject) item.params[param.name] = saveElement(subObject, ParamUtil.getParams(_template, subObject), cloneObject(paramsData.params[param.name]));
                        }
                    }
                    else
                    {
                        if (willSaveProperty(obj, param, item))
                            saveProperty(item.params, obj, param.name);
                    }
                }
            }

            return item;
        }

        private function saveProperty(target:Object, source:Object, name:String):void
        {
            var data:Object = source[name];
            if (data is Number)
            {
                data = roundToDigit(data as Number);
            }
            target[name] = data;
        }

        private function roundToDigit(value:Number, digit:int = 2):Number
        {
            var a:Number = Math.pow(10, digit);
            return Math.round(value * a) / a;
        }

        private static function removeDefault(obj:Object, params:Array):void
        {
            for each (var param:Object in params)
            {
                if (ObjectLocaterUtil.get(obj, param.name) == param.default_value)
                {
                    ObjectLocaterUtil.del(obj, param.name);
                }
            }
        }

        private static function willSaveProperty(obj:Object, param:Object, item:Object):Boolean
        {
            //Won't save default NaN value, plus it's not supported in json format
            if (param.default_value == "NaN" && isNaN(obj[param.name]))
            {
                return false;
            }

            if (param.read_only)
            {
                return false;
            }

            //Custom save rules go to here
            if (!SaveUtil.willSave(obj, param, item))
            {
                return false;
            }

            return param.default_value == undefined || param.default_value != obj[param.name];
        }

        private static function doTrimLeadingSpace(container:DisplayObjectContainer):void
        {
            var minX:Number = int.MAX_VALUE;
            var minY:Number = int.MAX_VALUE;

            var i:int;
            var obj:DisplayObject;

            for (i = 0; i < container.numChildren; ++i)
            {
                obj = container.getChildAt(i);

                var rect:Rectangle = obj.getBounds(container);

                if (rect.x < minX)
                {
                    minX = rect.x;
                }

                if (rect.y < minY)
                {
                    minY = rect.y;
                }
            }

            for (i = 0; i < container.numChildren; ++i)
            {
                obj = container.getChildAt(i);
                obj.x -= minX;
                obj.y -= minY;
            }
        }

        public static function cloneObject(object:Object):Object
        {
            var clone:ByteArray = new ByteArray();
            clone.writeObject(object);
            clone.position = 0;
            return(clone.readObject());
        }

        public function createUIElement(data:Object):Object
        {
            return {object:_factory.create(data), params:data};
        }

        public function get dataFormatter():IDataFormatter
        {
            return _dataFormatter;
        }

        public function set dataFormatter(value:IDataFormatter):void
        {
            _dataFormatter = value;
        }

        public function create(data:Object, trimLeadingSpace:Boolean = true):Object
        {
            return load(data, trimLeadingSpace).object;
        }

        public function localizeTexts(root:DisplayObject, paramsDict:Dictionary):void
        {
            if (_localization && _localization.locale)
            {
                localizeTree(root, paramsDict);
            }
        }

        private function localizeTree(object:DisplayObject, paramsDict:Dictionary):void
        {
            var params:Object = paramsDict[object];

            if (object.hasOwnProperty("text") && params && params.customParams && params.customParams.localizeKey)
            {
                var text:String = _localization.getLocalizedText(params.customParams.localizeKey);
                if (text) object["text"] = text;
            }

            var container:DisplayObjectContainer = object as DisplayObjectContainer;

            if (container)
            {
                for (var i:int = 0; i < container.numChildren; ++i)
                {
                    localizeTree(container.getChildAt(i), paramsDict);
                }
            }
        }

        /**
         *  Helper function to find ui element
         * @param container
         * @param path can be separated by dot (e.g. bottom_container.layout.button1)
         * @return
         */
        public static function find(container:DisplayObjectContainer, path:String):DisplayObject
        {
            var array:Array = path.split(".");

            var obj:DisplayObject;

            for each (var name:String in array)
            {
                if (container == null) return null;

                obj = container.getChildByName(name);
                container = obj as DisplayObjectContainer;
            }

            return obj;
        }
    }
}
