/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2
{
    import feathers.controls.Button;
    import feathers.controls.ButtonGroup;
    import feathers.data.ListCollection;

    import flash.utils.Dictionary;

    import starling.core.Starling;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.display.Stage;
    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class LocalizationTest extends Sprite
    {
        private var _sprite:Sprite;
        private var _params:Dictionary;

        public function LocalizationTest()
        {
            var stage:Stage = Starling.current.stage;
            var quad:Quad = new Quad(stage.stageWidth, stage.stageHeight);
            addChild(quad);

            var data:Object = UIBuilderDemo.uiBuilder.load(ParsedLayouts.localization_test, false);
            _sprite = data.object;
            _params = data.params;
            addChild(_sprite);

            var buttonGroup:ButtonGroup = new ButtonGroup();
            buttonGroup.dataProvider = new ListCollection([
                {label:"en_US", triggered: onButton},
                {label:"de_DE", triggered: onButton},
                {label:"es_ES", triggered: onButton},
                {label:"fr_FR", triggered: onButton},
                {label:"cn_ZH", triggered: onButton},
            ]);
            buttonGroup.y = 300;

            addChild(buttonGroup);

            quad.addEventListener(TouchEvent.TOUCH, onTouch);
        }

        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.ENDED)
            {
                removeFromParent(true);
            }
        }

        private function onButton(event:Event):void
        {
            var locale:String = Button(event.target).label;

            UIBuilderDemo.uiBuilder.localization.locale = locale;
            UIBuilderDemo.uiBuilder.localizeTexts(_sprite, _params);
        }
    }
}
