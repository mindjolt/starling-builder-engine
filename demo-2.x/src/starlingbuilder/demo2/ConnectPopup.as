/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2 {
    import feathers.core.PopUpManager;

    import starling.display.Button;
    import starling.display.Sprite;
    import starling.events.Event;

    public class ConnectPopup extends Sprite
    {
        public function ConnectPopup()
        {
            super();

            var sprite:Sprite = UIBuilderDemo.uiBuilder.load(ParsedLayouts.connect_popup).object;
            addChild(sprite);

            var button:Button = sprite.getChildByName("generic_exit") as Button;
            button.addEventListener(Event.TRIGGERED, onExit);
        }

        private function onExit(event:Event):void
        {
            PopUpManager.removePopUp(this, true);
        }
    }
}
