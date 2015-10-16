/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
    import feathers.controls.List;
    import feathers.controls.renderers.IListItemRenderer;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;

    import starling.display.Button;
    import starling.display.Sprite;
    import starling.events.Event;

    public class MailPopup extends Sprite
    {
        public function MailPopup()
        {
            super();

            var sprite:Sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.mail_popup) as Sprite;
            addChild(sprite);

            var listCollection:ListCollection = new ListCollection();

            for (var i:int = 0; i < 50; ++i)
            {
                listCollection.push(i);
            }

            var list:List = sprite.getChildByName("obj1") as List;
            list.itemRendererFactory = function():IListItemRenderer
            {
                return new MailItemRenderer();
            }
            list.dataProvider = listCollection;


            var button:Button = sprite.getChildByName("generic_exit") as Button;
            button.addEventListener(Event.TRIGGERED, onExit);
        }

        private function onExit(event:Event):void
        {
            PopUpManager.removePopUp(this, true);
        }
    }
}
