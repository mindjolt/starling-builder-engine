/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.engine
{
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    /**
     * Default implementation of IAssetMediator
     *
     * @see IAssetMediator
     */
    public class DefaultAssetMediator implements IAssetMediator
    {
        protected var _assetManager:AssetManager;

        public function DefaultAssetMediator(assetManager:AssetManager)
        {
            _assetManager = assetManager;
        }

        /**
         * @inheritDoc
         */
        public function getTexture(name:String):Texture
        {
            return _assetManager.getTexture(name);
        }

        /**
         * @inheritDoc
         */
        public function getTextures(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>
        {
            return _assetManager.getTextures(prefix, result);
        }

        /**
         * @inheritDoc
         */
        public function getExternalData(name:String):Object
        {
            return null;
        }

        /**
         * @inheritDoc
         */
        public function getXml(name:String):XML
        {
            return _assetManager.getXml(name);
        }

        /**
         * @inheritDoc
         */
        public function getObject(name:String):Object
        {
            return _assetManager.getObject(name);
        }
    }
}
