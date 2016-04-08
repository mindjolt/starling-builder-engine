/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.localization
{
    /**
     * Interface of localizing display objects. It's used in both the editor and the project.
     * Once passed into UIBuilder, the localization will work automatically when UIBuilder.load() is called
     *
     * @see starlingbuilder.engine.UIBuilder
     */
    public interface ILocalization
    {
        /**
         * Get localized text from key
         * @param key key of the text
         * @return localized text
         */
        function getLocalizedText(key:String):String;

        /**
         * Get all the available locales (only used in the editor).
         * @return array of locales
         */
        function getLocales():Array;

        /**
         * Get all the available keys (only used in the editor).
         * Only used in editor.
         * @return array of keys
         */
        function getKeys():Array;

        /**
         * Current locale property.
         */
        function get locale():String;

        /**
         * @private
         */
        function set locale(value:String):void;
    }
}
