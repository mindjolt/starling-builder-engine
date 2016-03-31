/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.util
{
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import starling.display.DisplayObject;

    /**
     * @private
     */
    public class DisplayObjectUtil
    {
        public static const LEFT:String = "left";
        public static const RIGHT:String = "right";
        public static const CENTER:String = "center";
        public static const TOP:String = "top";
        public static const BOTTOM:String = "bottom";

        public static function movePivotTo(obj:DisplayObject, x:Number, y:Number):void
        {
            var rect1:Rectangle =  obj.getBounds(obj.parent);

            obj.pivotX = x;
            obj.pivotY = y;

            var rect2:Rectangle = obj.getBounds(obj.parent);

            obj.x += rect1.x - rect2.x;
            obj.y += rect1.y - rect2.y;
        }

        public static function setPivotTo(obj:DisplayObject, x:Number, y:Number):void
        {
            obj.pivotX = x;
            obj.pivotY = y;
        }

        public static function movePivotToAlign(obj:DisplayObject, hAlign:String = "center", vAlign:String = "center"):void
        {
            var p:Point = getPivotPoint(obj, hAlign, vAlign);
            movePivotTo(obj, p.x, p.y);
        }


        private static function getPivotPoint(obj:DisplayObject, hAlign:String, vAlign:String):Point
        {
            var bounds:Rectangle = obj.getBounds(obj);

            var pivotX:Number;
            var pivotY:Number;

            if (hAlign == LEFT)        pivotX = bounds.x;
            else if (hAlign == CENTER) pivotX = bounds.x + bounds.width / 2.0;
            else if (hAlign == RIGHT)  pivotX = bounds.x + bounds.width;
            else throw new ArgumentError("Invalid horizontal alignment: " + hAlign);

            if (vAlign == TOP)         pivotY = bounds.y;
            else if (vAlign == CENTER) pivotY = bounds.y + bounds.height / 2.0;
            else if (vAlign == BOTTOM) pivotY = bounds.y + bounds.height;
            else throw new ArgumentError("Invalid vertical alignment: " + vAlign);

            return new Point(pivotX, pivotY);
        }
    }
}
