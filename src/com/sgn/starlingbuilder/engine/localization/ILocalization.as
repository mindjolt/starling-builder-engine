/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package com.sgn.starlingbuilder.engine.localization
{
    public interface ILocalization
    {
        function getLocalizedText(key:String):String;

        function getLocales():Array;

        function getKeys():Array;

        function get locale():String;

        function set locale(value:String):void;
    }
}
