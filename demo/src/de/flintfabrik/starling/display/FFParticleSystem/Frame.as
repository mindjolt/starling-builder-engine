// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2011 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package de.flintfabrik.starling.display.FFParticleSystem
{
	
	public class Frame
	{
		
		public var particleHalfWidth:Number = 1.0;
		public var particleHalfHeight:Number = 1.0;
		public var textureX:Number = 0.0;
		public var textureY:Number = 0.0;
		public var textureWidth:Number = 1.0;
		public var textureHeight:Number = 1.0;
		public var rotated:Boolean = false;
		
		public function Frame(nativeTextureWidth:Number = 64, nativeTextureHeight:Number = 64, x:Number = 0.0, y:Number = 0.0, width:Number = 64.0, height:Number = 64.0, rotated:Boolean = false)
		{
			textureX = x / nativeTextureWidth;
			textureY = y / nativeTextureHeight;
			textureWidth = (x + width) / nativeTextureWidth;
			textureHeight = (y + height) / nativeTextureHeight;
			particleHalfWidth = (width) >> 1;
			particleHalfHeight = (height) >> 1;
			this.rotated = rotated;
		}
	}
}
