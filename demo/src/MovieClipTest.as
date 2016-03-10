/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package
{
    import starling.core.Starling;
    import starling.display.MovieClip;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class MovieClipTest extends Sprite
    {
        private var _sprite:Sprite;
        private var _movieClip:MovieClip;

        public function MovieClipTest()
        {
            _sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.movieclip_test, false) as Sprite;
            addChild(_sprite);

            _movieClip = _sprite.getChildByName("movieClip") as MovieClip;
            Starling.current.juggler.add(_movieClip);
            _movieClip.play();

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

        override public function dispose():void
        {
            Starling.current.juggler.remove(_movieClip);
            super.dispose();
        }
    }
}
