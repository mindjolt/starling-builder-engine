/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.localization
{
    public class DefaultLocalization implements ILocalization
    {
        private var _data:Object;

        private var _locale:String;

        public function DefaultLocalization(data:Object, locale:String = null):void
        {
            _data = data;
            _locale = locale;
        }

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

        public function get locale():String
        {
            return _locale;
        }

        public function set locale(value:String):void
        {
            _locale = value;
        }

    }
}
