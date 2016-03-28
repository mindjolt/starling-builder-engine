/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine
{
    import flash.utils.describeType;

    public class LayoutLoader
    {
        private var _embeddedCls:Class;
        private var _layoutCls:Class;
        private var _preload:Boolean;

        /**
         * Helper class to load layouts
         * @param embeddedCls class with embedded layout
         * @param layoutCls class with parsed layout
         * @param preload whether to preload it. If true, calling load() is not necessary
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
         * @return
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
    }
}
