/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo2 {
    import feathers.controls.renderers.LayoutGroupListItemRenderer;

    import starling.display.Sprite;
    import starling.text.TextField;

    public class MailItemRenderer extends LayoutGroupListItemRenderer
    {
        public var _text:TextField;

        private var _sprite:Sprite;

        public function MailItemRenderer()
        {
            super();
        }

        override protected function initialize():void
        {
            if (_sprite == null)
            {
                _sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.mail_item, true, this) as Sprite;
                addChild(_sprite);
            }
        }

        override public function set data(value:Object):void
        {
            super.data = value;

            if (_data)
                _text.text = _data.label;
        }
    }
}
