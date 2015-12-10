/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.util
{
    import flash.display.Stage;
    import flash.geom.Point;
    import flash.system.Capabilities;

    public class StageUtil
    {
        private var _stage:Stage;
        private var _designStageWidth:int;
        private var _designStageHeight:int;

        public function StageUtil(stage:Stage, designStageWidth:int = 640, designStageHeight:int = 960)
        {
            _stage = stage;

            _designStageWidth = designStageWidth;
            _designStageHeight = designStageHeight;
        }

        public function get stageWidth():int
        {
            var iOS:Boolean = isiOS();
            var android:Boolean = isAndroid();

            if (iOS || android)
            {
                return _stage.fullScreenWidth;
            }
            else
            {
                return _stage.stageWidth;
            }
        }

        public function get stageHeight():int
        {
            var iOS:Boolean = isiOS();
            var android:Boolean = isAndroid();

            if (iOS || android)
            {
                return _stage.fullScreenHeight;
            }
            else
            {
                return _stage.stageHeight;
            }
        }

        public function getScaledStageSize(stageWidth:int, stageHeight:int):Point
        {
            var tmp:Number;

            var landscapeMode:Boolean = stageWidth > stageHeight;

            if (landscapeMode)
            {
                tmp = stageWidth;
                stageWidth = stageHeight;
                stageHeight = tmp;
            }

            var maxRatio:Number = 1.0 * _designStageWidth / _designStageHeight;

            var width:Number;
            var height:Number;

            var scale:Number;

            if (1.0 * stageWidth / stageHeight <= maxRatio)
            {
                scale = _designStageWidth / stageWidth;
            }
            else
            {
                scale = _designStageHeight / stageHeight;
            }

            width = scale * stageWidth;
            height = scale * stageHeight;

            if (landscapeMode)
            {
                tmp = width;
                width = height;
                height = tmp;
            }

            return new Point(Math.round(width), Math.round(height));
        }

        public static function isAndroid():Boolean
        {
            return Capabilities.manufacturer.indexOf("Android") != -1;
        }

        public static function isiOS():Boolean
        {
            return Capabilities.manufacturer.indexOf("iOS") != -1;
        }
    }
}
