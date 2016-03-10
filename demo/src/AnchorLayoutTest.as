/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package
{
    import feathers.controls.LayoutGroup;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.display.Stage;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class AnchorLayoutTest extends Sprite
    {
        private var _sprite:Sprite;

        public function AnchorLayoutTest()
        {
            _sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.anchorlayout_test, false) as Sprite;

            var stage:Stage = Starling.current.stage;
            _sprite.width = stage.stageWidth;
            _sprite.height = stage.stageHeight;

            addChild(_sprite);

            addEventListener(TouchEvent.TOUCH, onTouch);
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
