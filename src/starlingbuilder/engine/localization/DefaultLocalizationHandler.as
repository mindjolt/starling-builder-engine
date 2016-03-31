/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.localization
{
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.text.TextField;
    import starling.text.TextFieldAutoSize;

    /**
     * Default implementation of ILocalizationHandler
     *
     * @see ILocalizationHandler
     */
    public class DefaultLocalizationHandler implements ILocalizationHandler
    {
        /**
         * @inheritDoc
         */
        public function localize(object:DisplayObject, text:String, paramsDict:Dictionary, locale:String):void
        {
            //Assuming that TextField with auto size will always have pivot align to center
            if (object is TextField)
            {
                var textField:TextField = object as TextField;

                if (textField.autoSize != TextFieldAutoSize.NONE)
                {
                    textField.alignPivot();
                }
            }
        }
    }
}
