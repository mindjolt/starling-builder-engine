/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2 {
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class TweenTest extends Sprite
    {
        private var _sprite:Sprite;

        public function TweenTest()
        {
            var data:Object = UIBuilderDemo.uiBuilder.load(ParsedLayouts.tween_test, false);
            _sprite = data.object as Sprite;
            addChild(_sprite);

            UIBuilderDemo.uiBuilder.tweenBuilder.start(_sprite, data.params);

            addEventListener(TouchEvent.TOUCH, onTouch);
        }

        override public function dispose():void
        {
            UIBuilderDemo.uiBuilder.tweenBuilder.stop(_sprite);
            super.dispose();
        }

        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.ENDED)
            {
                removeFromParent(true);
            }
        }
    }
}
