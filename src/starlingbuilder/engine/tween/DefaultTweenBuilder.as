/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.tween
{
    import flash.utils.Dictionary;
    import starling.animation.Tween;
    import starling.core.Starling;
    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;

    import starlingbuilder.engine.UIBuilder;

    public class DefaultTweenBuilder implements ITweenBuilder
    {
        private var _saveData:Dictionary;

        public function DefaultTweenBuilder()
        {
            _saveData = new Dictionary();
        }

        public function start(root:DisplayObject, paramsDict:Dictionary, names:Array = null):void
        {
            stop(root, paramsDict, names);

            var array:Array = getDisplayObjectsByNames(root, paramsDict, names);

            for each (var obj:DisplayObject in array)
            {
                var data:Object = paramsDict[obj];

                var tweenData:Object = data.tweenData;

                if (tweenData)
                {
                    if (tweenData is Array)
                    {
                        for each (var item:Object in tweenData)
                            createTweenFrom(obj, item);
                    }
                    else
                    {
                        createTweenFrom(obj, tweenData);
                    }
                }
            }
        }

        private function getDisplayObjectsByNames(root:DisplayObject, paramsDict:Dictionary, names:Array):Array
        {
            var array:Array = [];

            if (names)
            {
                for each (var name:String in names)
                {
                    array.push(UIBuilder.find(root as DisplayObjectContainer, name));
                }
            }
            else
            {
                for (var obj:DisplayObject in paramsDict)
                {
                    if (paramsDict[obj].hasOwnProperty("tweenData"))
                        array.push(obj);
                }
            }

            return array;
        }

        /*
        example data1:
        {"time":1, "properties":{"scaleX":0.9, "scaleY":0.9, "repeatCount":0, "reverse":true}}

        example data2:
        [{"properties":{"repeatCount":0,"scaleY":0.9,"reverse":true,"scaleX":0.9},"time":1},{"properties":{"repeatCount":0,"alpha":0,"reverse":true},"time":0.5}]
        */
        private function createTweenFrom(obj:DisplayObject, data:Object):void
        {
            if (!data.hasOwnProperty("time"))
            {
                trace("Missing tween param: time");
                return;
            }

            if (!data.hasOwnProperty("properties"))
            {
                trace("Missing tween param: properties");
                return;
            }

            var initData:Object = saveInitData(obj, data.properties);

            setFrom(obj, data.from);

            var tween:Tween = Starling.current.juggler.tween(obj, data.time, data.properties) as Tween;

            if (!_saveData[obj]) _saveData[obj] = [];

            _saveData[obj].push({tween:tween, init:initData});
        }

        public function stop(root:DisplayObject, paramsDict:Dictionary = null, names:Array = null):void
        {
            if (paramsDict == null || names == null)
            {
                stopAll(root);
            }
            else
            {
                var array:Array = getDisplayObjectsByNames(root, paramsDict, names);

                for each (var obj:DisplayObject in array)
                {
                    stopTween(obj);
                }
            }
        }

        private function stopTween(obj:DisplayObject):void
        {
            var array:Array = _saveData[obj];

            if (array)
            {
                for each (var data:Object in array)
                {
                    var initData:Object = data.init;
                    recoverInitData(obj, initData);

                    var tween:Tween = data.tween;
                    Starling.current.juggler.remove(tween);
                }
            }

            delete _saveData[obj];
        }

        private function setFrom(obj:Object, from:Object):void
        {
            for (var name:String in from)
            {
                if (obj.hasOwnProperty(name))
                {
                    obj[name] = from[name];
                }
            }
        }

        private function recoverInitData(obj:Object, initData:Object):void
        {
            for (var name:String in initData)
            {
                obj[name] = initData[name];
            }
        }

        private function saveInitData(obj:Object, properties:Object):Object
        {
            var data:Object = {};

            for (var name:String in properties)
            {
                if (obj.hasOwnProperty(name))
                {
                    data[name] = obj[name];
                }
            }

            return data;
        }

        private function stopAll(root:DisplayObject):void
        {
            var container:DisplayObjectContainer = root as DisplayObjectContainer;

            for (var obj:DisplayObject in _saveData)
            {
                if (root === obj || container && container.contains(obj))
                    stopTween(obj);
            }
        }

    }
}
