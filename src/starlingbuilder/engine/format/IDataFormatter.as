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
    public interface IDataFormatter
    {
        function read(data:Object):Object;
        function write(data:Object):Object;

        function get prettyData():Boolean;
        function set prettyData(value:Boolean):void;
    }
}
