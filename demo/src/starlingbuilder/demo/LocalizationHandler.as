/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo
{
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.text.TextField;

    import starlingbuilder.engine.localization.DefaultLocalizationHandler;

    public class LocalizationHandler extends DefaultLocalizationHandler
    {
        public function LocalizationHandler()
        {
            super();
        }

        override public function localize(object:DisplayObject, text:String, paramsDict:Dictionary, locale:String):void
        {
            var textField:TextField = object as TextField;
            if (textField)
            {
                if (locale == "cn_ZH")
                    textField.fontName = "_sans";
            }

            super.localize(object, text, paramsDict, locale);
        }
    }
}
