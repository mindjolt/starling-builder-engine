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

    /**
     *  Interface for getting assets from the project
     *
     *  <p>
     *  You should implement your AssetMediator in your project.
     *  It can be a simple wrapper of starling.utils.AssetManager.
     *  </p>
     *
     *  The following example is a simple implementation of IAssetMediator
     *
     *  <listing version="3.0">
     *      public class AssetMediator
     *      {
     *          private var _assetManager:AssetManager;
     *          <br>
     *          public function AssetMediator(assetManager:AssetManager)
     *          {
     *              _assetManager = assetManager;
     *          }
     *          <br>
     *          public function getTexture(name:String):Texture
     *          {
     *              return _assetManager.getTexture(name);
     *          }
     *          <br>
     *          public function getTextures(prefix:String="", result:Vector.&lt;Texture&gt;=null):Vector.&lt;Texture&gt;
     *          {
     *              return _assetManager.getTextures(prefix, result);
     *          }
     *          <br>
     *          public function getExternalData(name:String):Object
     *          {
     *              return null;
     *          }
     *      }</listing>
     *
     *      @see UIBuilder
     */
    public interface IAssetMediator
    {
        /**
         * Get texture by name.
         * This method has the same signature of starling.utils.AssetManager.getTexture
         * @param name name of the texture
         * @return texture with matched name
         */
        function getTexture(name:String):Texture

        /**
         * Get textures by prefix.
         * This method has the same signature of starling.utils.AssetManager.getTextures
         * Only used by MovieClip.
         * @param prefix prefix of the textures
         * @param result vector of the matched textures to return
         * @return vector of the matched textures
         */
        function getTextures(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>

        /**
         * Get external data by name.
         * Only used by loading external data (a layout referencing other layouts)
         * @param name of the layout
         * @return external data with matched name
         */
        function getExternalData(name:String):Object;

        /**
         *  This method is used to get XML data.
         *  You can make it simply return null if you don't use the feature.
         * @param name
         * @return
         */
        function getXml(name:String):XML;

        /**
         *  This method is used to get other data (JSON data, etc)
         *  You can make it simply return null if you don't use the feature.
         * @param name
         * @return
         */
        function getObject(name:String):Object;

        /**
         * This method is used to get custom data, it opens up possibility to support 3rd party libraries that require other dependencies
         * @param type
         * @param name
         * @return
         */
        function getCustomData(type:String, name:String):Object;
    }
}
