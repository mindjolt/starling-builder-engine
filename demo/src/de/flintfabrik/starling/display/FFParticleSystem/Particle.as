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
	public class Particle
    {
		
		public var x:Number = 0.0;
        public var y:Number = 0.0;
        public var scale:Number = 1.0;
        public var rotation:Number = 0.0;
        public var alpha:Number = 1.0;
        public var currentTime:Number = 0;
        public var totalTime:Number = 1.0;
		
		public var colorRed:Number = 1.0;
		public var colorGreen:Number = 1.0;
		public var colorBlue:Number = 1.0;
		public var colorAlpha:Number = 1.0;
		
		public var colorDeltaRed:Number = 0.0;
		public var colorDeltaGreen:Number = 0.0;
		public var colorDeltaBlue:Number = 0.0;
		public var colorDeltaAlpha:Number = 0.0;
		
        public var startX:Number = 0.0;
		public var startY:Number = 0.0;
        public var velocityX:Number = 0.0;
		public var velocityY:Number = 0.0;
        public var radialAcceleration:Number = 0.0;
        public var tangentialAcceleration:Number = 0.0;
        public var emitRadius:Number = 1.0;
		public var emitRadiusDelta:Number = 0.0;
        public var emitRotation:Number = 0.0;
		public var emitRotationDelta:Number = 0.0;
        public var rotationDelta:Number = 0.0;
        public var scaleDelta:Number = 0.0;
		public var frameIdx:int = 0;
		public var frame:Number = 0;
		public var frameDelta:Number = 0;
		
		public var fadeInFactor:Number = 0;
		public var fadeOutFactor:Number = 0;
		public var spawnFactor:Number = 0;
		
		public var active:Boolean = false;

		public var customValues:Object;
		
		public function Particle() { }
    }
}
