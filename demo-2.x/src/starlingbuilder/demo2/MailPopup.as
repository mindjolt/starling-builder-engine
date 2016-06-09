/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2 {
    import feathers.controls.List;
    import feathers.controls.renderers.IListItemRenderer;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;

    import starling.display.Button;
    import starling.display.Sprite;
    import starling.events.Event;

    public class MailPopup extends Sprite
    {
        //auto bind variables
        public var _list:List;
        public var _exitButton:Button;

        public function MailPopup()
        {
            super();

            var sprite:Sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.mail_popup, true, this) as Sprite;
            addChild(sprite);

            var listCollection:ListCollection = new ListCollection();

            for (var i:int = 1; i <= 50; ++i)
            {
                listCollection.push({label: ("You received a gift " + i)});
            }

            _list.itemRendererFactory = function():IListItemRenderer
            {
                return new MailItemRenderer();
            }
            _list.dataProvider = listCollection;

            _exitButton.addEventListener(Event.TRIGGERED, onExit);
        }

        private function onExit(event:Event):void
        {
            PopUpManager.removePopUp(this, true);
        }
    }
}
