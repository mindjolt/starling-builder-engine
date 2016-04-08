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

    /**
     *  Interface for cases that localization needs special treatment (e.g. change to a different font for some languages)
     *  Once passed into UIBuilder, the callback will be fired automatically when the localization is happening.
     *
     *  @see starlingbuilder.engine.UIBuilder
     */
    public interface ILocalizationHandler
    {
        /**
         * Callback function when a display object is localized
         * @param object display object
         * @param text text of the display object
         * @param paramsDict params dictionary of meta data
         * @param locale the current locale
         */
        function localize(object:DisplayObject, text:String, paramsDict:Dictionary, locale:String):void
    }
}
