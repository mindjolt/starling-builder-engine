/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine.tween
{
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.display.DisplayObjectContainer;

    /**
     * Interface of playing tween set by the editor.
     *
     * <p>
     * You need to manually call start/stop in your project when you want to start/stop a tween.
     * <br>
     * NOTE: The stop method should ALWAYS be called with the start method to avoid memory leak when the components are disposed.
     * <br>
     * The following example shows how to start and stop a tween:
     * </p>
     *
     * <listing version="3.0">
     *     var data:Object = uiBuilder.load(layoutData);
     *     var sprite:Sprite = data.object as Sprite;
     *     var paramsDict:Dictionary = data.params;
     *     <br>
     *     uiBuilder.tweenBuilder.startTween(sprite, paramsDict);
     *     <br>
     *     ...
     *     <br>
     *     uiBuilder.tweenBuilder.stopTween(sprite);</listing>
     *
     * @see starlingbuilder.engine.UIBuilder
     */
    public interface ITweenBuilder
    {
        /**
         * Start tween according tweenData in layout
         *
         * @param root of the DisplayObjects need to tween
         * @param paramsDict A dictionary of the mapping of every UIElement to its layout data
         * @param names array of names (e.g. ["container.button1", "container.button2") to be start tween, if null then start all the available tween
         */
        function start(root:DisplayObject, paramsDict:Dictionary, names:Array = null):void;

        /**
         * Stop tween according tweenData in layout
         *
         * @param root of the DisplayObject needs to be tween
         * @param paramsDict A dictionary of the mapping of every UIElement to its layout data, if null then stop all the available tweens
         * @param names array of names (e.g. ["container.button1", "container.button2") to be stop tween, if null then stop all the available tweens
         */
        function stop(root:DisplayObject, paramsDict:Dictionary = null, names:Array = null):void;
    }
}
