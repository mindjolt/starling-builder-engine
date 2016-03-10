/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package
{
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    import starlingbuilder.engine.IAssetMediator;

    public class AssetMediator implements IAssetMediator
    {
        private var _assetManager:AssetManager;

        public function AssetMediator(assetManager:AssetManager)
        {
            _assetManager = assetManager;
        }

        public function getTexture(name:String):Texture
        {
            return _assetManager.getTexture(name);
        }

        public function getTextures(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>
        {
            return _assetManager.getTextures(prefix, result);
        }

        public function getExternalData(name:String):Object
        {
            return ParsedLayouts[name];
        }
    }
}
