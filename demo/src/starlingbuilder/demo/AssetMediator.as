/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo
{
    import starling.utils.AssetManager;

    import starlingbuilder.engine.DefaultAssetMediator;

    import starlingbuilder.engine.IAssetMediator;

    public class AssetMediator extends DefaultAssetMediator implements IAssetMediator
    {
        public function AssetMediator(assetManager:AssetManager):void
        {
            super(assetManager);
        }

        override public function getExternalData(name:String):Object
        {
            return ParsedLayouts[name];
        }
    }
}
