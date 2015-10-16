/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
    import starling.core.Starling;
    import starling.display.Button;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.display.Stage;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class HUD extends Sprite
    {
        private var _sprite:Sprite;

        public function HUD()
        {
            super();

            var stage:Stage = Starling.current.stage;

            var quad:Quad = new Quad(stage.stageWidth, stage.stageHeight);
            addChild(quad);

            _sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.hud, false) as Sprite;
            addChild(_sprite);

            var topContainer:Sprite = _sprite.getChildByName("top_container") as Sprite;
            var bottomContainer:Sprite = _sprite.getChildByName("bottom_container") as Sprite;

            var settingsButton:Button = _sprite.getChildByName("settings_button") as Button;

            topContainer.x = stage.stageWidth * 0.5;
            topContainer.y = 0;

            bottomContainer.x = stage.stageWidth * 0.5;
            bottomContainer.y = stage.stageHeight;

            settingsButton.x = stage.stageWidth + 4;
            settingsButton.y = stage.stageHeight + 4;

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
