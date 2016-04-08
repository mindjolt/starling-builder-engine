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
     * Default implementation of ILocalization
     *
     * @see ILocalization
     * @see http://wiki.starling-framework.org/builder/localization Using Localization
     */
    public class DefaultLocalization implements ILocalization
    {
        private var _data:Object;
        private var _locale:String;

        /**
         * Constructor
         * @param data localization data
         * @param locale current locale
         */
        public function DefaultLocalization(data:Object, locale:String = null):void
        {
            _data = data;
            _locale = locale;
        }

        /**
         * @inheritDoc
         */
        public function getLocalizedText(key:String):String
        {
            if (_locale && _data.hasOwnProperty(key) && _data[key].hasOwnProperty(_locale))
            {
                return _data[key][_locale];
            }
            else
            {
                return null;
            }
        }

        /**
         * @inheritDoc
         */
        public function getLocales():Array
        {
            var locales:Array = [];

            for (var key:String in _data)
            {
                var item:Object = _data[key];

                for (var locale:String in item)
                {
                    locales.push(locale);
                }

                break;
            }

            return locales;
        }

        private var _keys:Array;

        /**
         * @inheritDoc
         */
        public function getKeys():Array
        {
            if (!_keys)
            {
                _keys = [];

                for (var key:String in _data)
                {
                    _keys.push(key);
                }

                _keys.sort();
            }

            return _keys;
        }

        /**
         * @inheritDoc
         */
        public function get locale():String
        {
            return _locale;
        }

        /**
         * @inheritDoc
         */
        public function set locale(value:String):void
        {
            _locale = value;
        }

    }
}
