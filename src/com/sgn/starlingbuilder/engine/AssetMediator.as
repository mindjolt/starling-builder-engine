package com.sgn.starlingbuilder.engine {
	import com.sgn.starlingbuilder.engine.IAssetMediator;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	/**
	 * ...
	 * @author Aleksey Kutov aka cleptoman
	 */
	public class AssetMediator extends AssetManager implements IAssetMediator {
		
		public function AssetMediator(scaleFactor:Number=1, useMipmaps:Boolean=false) {
			super(scaleFactor, useMipmaps);
			
		}
		

		public function getExternalData(name:String):Object {
			return super.getObject(name);
		}
		
	}

}