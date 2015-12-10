/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
    import starlingbuilder.engine.util.StageUtil;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import starling.core.Starling;

    [SWF(frameRate=60, width=640, height=960)]
    public class Main extends Sprite
    {
        private var _starling : Starling;

        public function Main()
        {
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function _start(e:Event):void
        {
            _starling.start();
        }

        private function onEnterFrame(event:Event):void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            init();
        }

        private function init():void
        {
            Starling.handleLostContext = true;

            _starling = new Starling(UIBuilderDemo, stage);

            var stageUtil:StageUtil = new StageUtil(stage);
            var size:Point = stageUtil.getScaledStageSize();
            _starling.stage.stageWidth = size.x;
            _starling.stage.stageHeight = size.y;
            _starling.showStats = true ;
            _starling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, _start);
        }
    }
}

