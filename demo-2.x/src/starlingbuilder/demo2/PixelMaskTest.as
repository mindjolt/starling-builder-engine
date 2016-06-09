/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2
{
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class PixelMaskTest extends Sprite
    {
        private var _sprite:Sprite;
        public var _fill:Image;

        public function PixelMaskTest()
        {
            _sprite = UIBuilderDemo.uiBuilder.create(starlingbuilder.demo.ParsedLayouts.pixelmask_test, true, this) as Sprite;
            addChild(_sprite);

            addEventListener(TouchEvent.TOUCH, onTouch);

            Starling.current.juggler.tween(_fill, 2, {repeatCount:0, rotation:_fill.rotation + Math.PI * 2});
        }

        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.ENDED)
            {
                removeFromParent(true);
            }
        }

        override public function dispose():void
        {
            Starling.current.juggler.removeTweens(_fill);
            super.dispose();
        }
    }
}

