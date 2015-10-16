/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
    import feathers.controls.renderers.LayoutGroupListItemRenderer;

    import starling.display.Sprite;

    public class MailItemRenderer extends LayoutGroupListItemRenderer
    {
        private var _sprite:Sprite;

        public function MailItemRenderer()
        {
            super();
        }

        override protected function initialize():void
        {
            if (_sprite == null)
            {
                _sprite = UIBuilderDemo.uiBuilder.create(ParsedLayouts.mail_item) as Sprite;
                addChild(_sprite);
            }
        }
    }
}
