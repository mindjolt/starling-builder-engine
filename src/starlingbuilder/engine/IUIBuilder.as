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

    import starlingbuilder.engine.localization.ILocalization;

    import starlingbuilder.engine.localization.ILocalizationHandler;

    import starlingbuilder.engine.tween.ITweenBuilder;

    /**
     * Main interface of the Starling Builder engine API
     *
     * @see UIBuilder
     */
    public interface IUIBuilder
    {
        /**
         * Load from layout data, create display objects and the associated meta data
         *
         * @param data
         * layout data
         *
         * @param trimLeadingSpace
         * whether to trim the leading space on the top level elements
         * set to true if loading a popup, set to false if loading a hud
         *
         * @param binder
         * An optional object you want to bind properties with UI components with the same name, if name starts with "_"
         *
         * @return
         * An object with {object:Sprite, params:Dictionary, data:data};
         *
         * <p>object: the sprite to create</p>
         * <p>params: A Dictionary of the mapping of every UIElement to its layout data</p>
         * <p>data: the as3 plain object format of the layout</p>
         *
         * @see #create()
         *
         */
        function load(data:Object, trimLeadingSpace:Boolean = true, binder:Object = null):Object


        /**
         * Save display object container to layout data
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
        function save(container:DisplayObjectContainer, paramsDict:Object, version:String, setting:Object = null):Object


        /**
         * Create UI element from data
         *
         * @param data
         * data in as3 plain object format
         *
         * @return
         * starling display object
         */
        function createUIElement(data:Object):Object

        
        /**
         * @private
         *
         * Whether param is a container
         *
         * @param param of the display object
         * @return if the object is a container recognized by ui editor
         */
        function isContainer(param:Object):Boolean


        /**
         * @private
         *
         * Copy a display object to layout data
         *
         * @param obj display object or array of display objects copy from
         * @param paramsDict params dictionary of meta data
         * @return
         */
        function copy(obj:Object, paramsDict:Object):String


        /**
         * @private
         *
         * Paste layout data to display object
         * @param string layout data
         * @return display object
         */
        function paste(string:String):Object


        /**
         * @private
         */
        function setExternalSource(param:Object, name:String):void


        /**
         * Localize texts in display object
         *
         * @param root of the DisplayObject needs to be localize
         * @param A Dictionary of the mapping of every UIElement to its layout data
         */
        function localizeTexts(root:DisplayObject, paramsDict:Dictionary):void


        /**
         * Create display objects from layout.
         * Short cut for load().object
         *
         * @see #load()
         */
        function create(data:Object, trimLeadingSpace:Boolean = true, binder:Object = null):Object


        /**
         * Tween builder property
         */
        function get tweenBuilder():ITweenBuilder


        /**
         * @private
         */
        function set tweenBuilder(value:ITweenBuilder):void

        /**
         * Localization property
         */
        function get localization():ILocalization

        /**
         * @private
         */
        function set localization(value:ILocalization):void

        /**
         * Localization handler property
         */
        function get localizationHandler():ILocalizationHandler


        /**
         * @private
         */
        function set localizationHandler(value:ILocalizationHandler):void

        /**
         * Display object handler
         */
        function get displayObjectHandler():IDisplayObjectHandler;

        /**
         * @private
         */
        function set displayObjectHandler(value:IDisplayObjectHandler):void;

        /**
         * @private
         *
         * Whether to save data as pretty format
         *
         * @default true
         */
        function get prettyData():Boolean


        /**
         * @private
         */
        function set prettyData(value:Boolean):void
        
    }
}
