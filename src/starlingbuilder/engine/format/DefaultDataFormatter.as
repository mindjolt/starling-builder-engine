/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.format
{
    /**
     * @private
     */
    public class DefaultDataFormatter implements IDataFormatter
    {
        private var _prettyData:Boolean = true;

        public function read(data:Object):Object
        {
            if (data is String)
            {
                return JSON.parse(data as String);
            }
            else
            {
                return data;
            }
        }

        public function write(data:Object):Object
        {
            if (_prettyData)
            {
                return StableJSONEncoder.stringify(data, 2);
            }
            else
            {
                return StableJSONEncoder.stringify(data, 0);
            }
        }

        public function get prettyData():Boolean
        {
            return _prettyData;
        }

        public function set prettyData(value:Boolean):void
        {
            _prettyData = value;
        }
    }
}
