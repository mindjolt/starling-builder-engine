/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.format
{
    public class DefaultDataFormatter implements IDataFormatter
    {
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
            //return JSON.stringify(data, null, 2);

            return StableJSONEncoder.stringify(data);
        }

    }
}
