/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine
{
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;

    import starlingbuilder.engine.localization.ILocalizationHandler;

    import starlingbuilder.engine.tween.ITweenBuilder;

    public interface IUIBuilder
    {
        /**
         *
         * @param data
         * layout file data
         *
         * @param trimLeadingSpace
         * whether to trim the leading space on the top level elements
         * set to True if load from the game, set to False if load from the editor
         *
         * @return
         * An object with
         * {container:Sprite, params:Dictionary, data:data};
         *
         * object
         * the sprite to create,
         *
         * params
         * A Dictionary of the mapping of every UIElement to its layout data
         *
         * data
         * the as3 plain object format of the layout
         *
         */
        function load(data:Object, trimLeadingSpace:Boolean = true):Object


        /**
         *
         * @param container
         * Display object container needed to export to layout
         *
         *
         * @param paramsDict
         * A Dictionary of the mapping of every UIElement to its layout data
         *
         *
         * @param setting
         * project setting like canvas size, background info used by the editor
         *
         * @return
         * layout file data
         */
        function save(container:DisplayObjectContainer, paramsDict:Object, setting:Object = null):Object


        /**
         *
         * @param data
         * data in as3 plain object format
         *
         * @return
         * starling display object
         */
        function createUIElement(data:Object):Object

        
        /**
         *
         * @param param of the display object
         * @return if the object is a container recognized by ui editor
         */
        function isContainer(param:Object):Boolean


        /**
         *
         * @param obj
         * @param paramsDict
         * @return
         */
        function copy(obj:DisplayObject, paramsDict:Object):String


        /**
         *
         * @param string
         * @return
         */
        function paste(string:String):Object


        /**
         *
         * @param param of the display object
         * @param name file name without extension
         */
        function setExternalSource(param:Object, name:String):void


        /**
         *
         * @param root of the DisplayObject needs to be localize
         * @param A Dictionary of the mapping of every UIElement to its layout data
         */
        function localizeTexts(root:DisplayObject, paramsDict:Dictionary):void


        /**
         * Short cut for load().object
         *
         * @param data
         * @param trimLeadingSpace
         * @return
         */
        function create(data:Object, trimLeadingSpace:Boolean = true):Object


        /**
         * Tween Builder getter
         */
        function get tweenBuilder():ITweenBuilder


        /**
         * Tween Builder setter
         */
        function set tweenBuilder(value:ITweenBuilder):void


        /**
         * localizationHandler getter
         */
        function get localizationHandler():ILocalizationHandler


        /**
         * localizationHandler setter
         */
        function set localizationHandler(value:ILocalizationHandler):void


        /**
         * prettyData getter
         */
        function get prettyData():Boolean


        /**
         * prettyData setter
         * @param value
         */
        function set prettyData(value:Boolean):void
        
    }
}
