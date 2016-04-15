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
    import flash.utils.describeType;

    /**
     * Helper class to load layouts
     *
     * <p>This class provide an easy and efficient way to load layout files from embedded data, parse the data and cached it into memory.
     * The following example load and parse the layout data from EmbeddedLayout class to ParsedLayout class:
     * </p>
     *
     * <listing version="3.0">
     * public class EmbeddedLayout
     * {
     *     [Embed(source="layouts/connect_popup.json", mimeType="application/octet-stream")]
     *     public static const connect_popup:Class;
     *     <br>
     *     [Embed(source="layouts/mail_popup.json", mimeType="application/octet-stream")]
     *     public static const mail_popup:Class;
     * }
     * <br>
     * public class ParsedLayout
     * {
     *     public static var connect_popup:Object;
     *     <br>
     *     public static var mail_popup:Object;
     * }
     * <br>
     * //loader with preload option
     * var loader:LayoutLoader = new LayoutLoader(EmbeddedLayout, ParsedLayout);
     * var sprite:Sprite = uiBuilder.create(ParsedLayout.connect_popup) as Sprite;
     * <br>
     * //loader without preload option
     * var loader2:LayoutLoader = new LayoutLoader(EmbeddedLayout, ParsedLayout, false);
     * var sprite2:Sprite = uiBuilder.create(loader2.loadByClass(EmbeddedLayout.connect_popup));</listing>
     *
     * @see http://github.com/mindjolt/starling-builder-engine/tree/master/demo Starling Builder demo project
     *
     */
    public class LayoutLoader
    {
        private var _embeddedCls:Class;
        private var _layoutCls:Class;
        private var _preload:Boolean;
        private var _layoutMapper:Dictionary;

        /**
         * Constructor
         * @param embeddedCls class with embedded layout
         * @param layoutCls class with parsed layout
         * @param preload whether to preload it. If set to true, calling load() or loadByClass() is not necessary
         */
        public function LayoutLoader(embeddedCls:Class, layoutCls:Class, preload:Boolean = true)
        {
            _embeddedCls = embeddedCls;
            _layoutCls = layoutCls;
            _preload = preload;

            if (_preload)
                preloadLayouts();
        }

        /**
         * Load a layout with name, only need to use it when preload = false
         * @param name layout name
         * @return parsed as3 object
         */
        public function load(name:String):Object
        {
            if (!(name in _layoutCls))
                throw new Error("Layout class has no property " + name);

            if (_layoutCls[name] == null)
            {
                if (!(name in _embeddedCls))
                    throw new Error("Embedded class has no property " + name);

                _layoutCls[name] = JSON.parse(new _embeddedCls[name]);
            }

            return _layoutCls[name];
        }

        /**
         * Traverse all the public static variable of the embedded class, parse and assign to the same public static variable of the layout class
         */
        private function preloadLayouts():void
        {
            var name:String;
            var description:XML = describeType(_embeddedCls);
            var constants:XMLList = description..constant;
            for each(var constant:XML in constants)
            {
                name = constant.@name;
                _layoutCls[name] = JSON.parse(new _embeddedCls[name]());
            }
        }

        /**
         * Load a layout with the embedded data, only need to use it when preload = false
         * @param cls embedded data class
         * @return parsed as3 object
         */
        public function loadByClass(cls:Class):Object
        {
            if (_layoutMapper == null)
                mapLayout();

            var data:* = _layoutMapper[cls];

            if (data == null)
            {
                throw new Error("Layout data cannot be null!");
            }
            else if (data is String)
            {
                var name:String = data as String;

                if (_layoutCls[name] == null)
                    _layoutCls[name] = JSON.parse(new _embeddedCls[name]);

                _layoutMapper[cls] = _layoutCls[name];
            }

            return _layoutMapper[cls];
        }

        private function mapLayout():void
        {
            _layoutMapper = new Dictionary();

            var name:String;
            var description:XML = describeType(_embeddedCls);
            var constants:XMLList = description..constant;
            for each(var constant:XML in constants)
            {
                name = constant.@name;
                _layoutMapper[_embeddedCls[name]] = name;
            }
        }
    }
}
