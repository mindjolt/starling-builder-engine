/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package
{
    import starling.display.Sprite;
    import starling.utils.AssetManager;
    import starlingbuilder.engine.IUIBuilder;
    import starlingbuilder.engine.UIBuilder;

    public class Game extends Sprite
    {
        private var _assetManager:AssetManager;
        private var _assetMediator:AssetMediator;

        public static var uiBuilder:IUIBuilder;

        public function Game()
        {
            _assetManager = new AssetManager();
            _assetMediator = new AssetMediator(_assetManager);
            uiBuilder = new UIBuilder(_assetMediator);

            //_assetManager.enqueue(EmbeddedAssets);
            //_assetManager.enqueue(File.applicationDirectory.resolvePath("textures"));
            _assetManager.loadQueue(function(ratio:Number):void{
                if (ratio == 1)
                {
                    init();
                }
            });
        }

        private function init():void
        {
            var data:Object = JSON.parse(new EmbeddedLayouts.Hello);
            var sprite:Sprite = uiBuilder.create(data) as Sprite;
            addChild(sprite);
        }
    }
}
