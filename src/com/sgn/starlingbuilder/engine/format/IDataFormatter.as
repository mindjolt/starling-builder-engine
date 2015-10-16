/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package com.sgn.starlingbuilder.engine.format
{
    public interface IDataFormatter
    {
        function read(data:Object):Object;
        function write(data:Object):Object;
    }
}
