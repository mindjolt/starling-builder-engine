/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package com.sgn.starlingbuilder.engine
{
    import com.sgn.starlingbuilder.engine.util.ParamUtil;

    import feathers.textures.Scale3Textures;
    import feathers.textures.Scale9Textures;

    import flash.geom.Rectangle;
    import flash.utils.getDefinitionByName;

    import starling.textures.Texture;

    public class UIElementFactory
    {
        protected var _assetMediator:IAssetMediator;
        protected var _forEditor:Boolean;

        public function UIElementFactory(assetMediator:IAssetMediator, forEditor:Boolean = false)
        {
            _assetMediator = assetMediator;
            _forEditor = forEditor;
        }

        protected function setDefaultParams(obj:Object, data:Object):void
        {
        }

        protected function setDirectParams(obj:Object, data:Object):void
        {
            var array:Array = [];
			var id:String;
			var item:Object;
            for (id in data.params)
            {
                array.push(id);
            }
            sortParams(array, PARAMS);

            for each (id in array)
            {
                item = data.params[id];

                if (item && item.hasOwnProperty("cls"))
                {
                    obj[id] = create(item);
                }
                else if (obj.hasOwnProperty(id))
                {
                    obj[id] = item;
                }
            }
        }

        protected function setDefault(obj:Object, data:Object):void
        {
            setDefaultParams(obj, data);
            setDirectParams(obj, data);
        }

        private function createTexture(param:Object):Object
        {
            var texture:Texture;
            var scaleRatio:Array;

            if (param.cls == ParamUtil.getClassName(Texture))
            {
                texture = _assetMediator.getTexture(param.textureName);
                return texture;
            }
            else if (param.cls == ParamUtil.getClassName(Scale3Textures))
            {
                texture = _assetMediator.getTexture(param.textureName);

                scaleRatio = param.scaleRatio;

                var direction:String = Scale3Textures.DIRECTION_HORIZONTAL;

                if (scaleRatio.length == 3)
                {
                    direction = scaleRatio[2];
                }

                var s3t:Scale3Textures;
                if (direction == Scale3Textures.DIRECTION_HORIZONTAL)
                {
                    s3t = new Scale3Textures(texture, texture.width * scaleRatio[0], texture.width * scaleRatio[1], direction);
                }
                else
                {
                    s3t = new Scale3Textures(texture, texture.height * scaleRatio[0], texture.height * scaleRatio[1], direction);
                }
                return s3t;

            }
            else if (param.cls == ParamUtil.getClassName(Scale9Textures))
            {
                texture = _assetMediator.getTexture(param.textureName);

                scaleRatio = param.scaleRatio;
                var rect:Rectangle = new Rectangle(texture.width * scaleRatio[0], texture.height * scaleRatio[1], texture.width * scaleRatio[2], texture.height * scaleRatio[3]);
                var s9t:Scale9Textures = new Scale9Textures(texture, rect);
                return s9t;
            }
            else
            {
                return null;
            }
        }

        public function create(data:Object):Object
        {
            var obj:Object;
            var constructorParams:Array = data.constructorParams as Array;

            var res:Object = createTexture(data);
            if (res) return res;

            var cls:Class;

            if (!_forEditor && data.customParams && data.customParams.customComponentClass && data.customParams.customComponentClass != "null")
            {
                try
                {
                    cls = getDefinitionByName(data.customParams.customComponentClass) as Class;
                }
                catch (e:Error)
                {
                    trace("Class " + data.customParams.customComponentClass + " can't be instantiated.");
                }
            }

            if (!cls)
            {
                cls = getDefinitionByName(data.cls) as Class;
            }

            var args:Array = createArgumentsFromParams(constructorParams);

            try
            {
                obj = createObjectFromClass(cls, args);
            }
            catch (e:Error)
            {
                obj = createObjectFromClass(cls, []);
            }

            setDefault(obj, data);
            return obj;
        }



        private function createObjectFromClass(cls:Class, args:Array):Object
        {
            switch (args.length)
            {
                case 0:
                    return new cls();
                case 1:
                    return new cls(args[0]);
                case 2:
                    return new cls(args[0], args[1]);
                case 3:
                    return new cls(args[0], args[1], args[2]);
                case 4:
                    return new cls(args[0], args[1], args[2], args[3]);
                case 5:
                    return new cls(args[0], args[1], args[2], args[3], args[4]);
                case 6:
                    return new cls(args[0], args[1], args[2], args[3], args[4], args[5]);
                case 7:
                    return new cls(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
                case 8:
                    return new cls(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
                case 9:
                    return new cls(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
                default:
                    throw new Error("Number of arguments not supported!");
            }
        }

        private function createArgumentsFromParams(params:Array):Array
        {
            var args:Array = [];

            for each (var param:Object in params)
            {
                if (param.hasOwnProperty("value"))
                {
                    args.push(param.value);
                }
                else
                {
                    args.push(create(param));
                }
            }

            return args;

        }

        public static const PARAMS:Object = {"x":1, "y":1, "width":2, "height":2, "scaleX":3, "scaleY":3, "rotation":4};

        public static function sortParams(array:Array, params:Object):void
        {
            array.sort(function(e1:Object, e2:Object):int
            {
                return int(params[e1]) - int(params[e2]);
            });
        }
    }
}
