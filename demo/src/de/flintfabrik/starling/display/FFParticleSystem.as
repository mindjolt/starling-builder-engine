// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package de.flintfabrik.starling.display
{
	import de.flintfabrik.starling.display.FFParticleSystem.Frame;
	import de.flintfabrik.starling.display.FFParticleSystem.Particle;
	import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;
	import de.flintfabrik.starling.utils.ColorArgb;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import starling.animation.IAnimatable;
	import starling.animation.Juggler;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.filters.FragmentFilter;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.MatrixUtil;
	import starling.utils.VertexData;
	
	/**
	 * <p>The FFParticleSystem is an extension for the <a target="_top" href="http://starling-framework.org">Starling Framework</a>.
	 * It's basically an optimized version of the original ParticleSystem combined with Starling's QuadBatch class.
	 *
	 * <p>In addition it comes with a few new features:
	 * <ul>
	 *   <li>particle pooling</li>
	 *   <li>multi buffering</li>
	 *   <li>batching (of particle systems)</li>
	 *   <li>animated Texture loops</li>
	 *   <li>random start frame</li>
	 *   <li>ATF support</li>
	 *   <li>filter support</li>
	 *   <li>optional custom sorting, code and variables</li>
	 *   <li>calculating exact bounds (optional)</li>
	 *   <li>spawnTime</li>
	 *   <li>fadeInTime</li>
	 *   <li>fadeOutTime</li>
	 *   <li>emit angle aligned particle rotation</li>
	 * </ul>
	 * </p>
	 *
	 * <p>This extension has been kindly sponsored by the fabulous <a target="_top" href="http://colinnorthway.com/">Colin Northway</a>. :)</p>
	 *
	 * <a target="_top" href="http://www.flintfabrik.de/blog/">Live Demo</a>
	 *
	 * @author Michael Trenkler
	 * @see http://flintfabrik.de
	 * @see #FFParticleSystem()
	 * @see #init() FFParticleSystem.init()
	 */
	public class FFParticleSystem extends DisplayObject implements IAnimatable
	{
		public static const EMITTER_TYPE_GRAVITY:int = 0;
		public static const EMITTER_TYPE_RADIAL:int = 1;
		/**
		 * The maximum number of particles possible (16383 or 0x3FFF).
		 */
		public static const MAX_CAPACITY:int = 16383;
		
		/**
		 * If the systems duration exceeds as well as all particle lifespans, a complete event is fired and
		 * the system will be stopped. If this value is set to true, the particles will be returned to the pool.
		 * This does not affect any manual calls of stop.
		 * @see #start()
		 * @see #stop()
		 */
		public static var autoClearOnComplete:Boolean = true;
		/**
		 * If the systems duration exceeds as well as all particle lifespans, a complete event is fired and
		 * the system will be stopped. If this value is set to true, the particles will be returned to the pool.
		 * This does not affect any manual calls of stop.
		 * @see #start()
		 * @see #stop()
		 */
		public var autoClearOnComplete:Boolean = FFParticleSystem.autoClearOnComplete;
		/**
		 * Forces the the sort flag for custom sorting on every frame instead of setting it when particles are removed.
		 */
		public var forceSortFlag:Boolean = false;
		
		/**
		 * Set this Boolean to automatically add/remove the system to/from juggler, on calls of start()/stop().
		 * @see #start()
		 * @see #stop()
		 * @see #defaultJuggler
		 * @see #juggler()
		 */
		public static var automaticJugglerManagement:Boolean = true;
		
		/**
		 * Default juggler to use when <a href="#automaticJugglerManagement">automaticJugglerManagement</a>
		 * is active (by default this value is the Starling's juggler).
		 * Setting this value will affect only new particle system instances.
		 * Juggler to use can be also manually set by particle system instance.
		 * @see #automaticJugglerManagement
		 * @see #juggler()
		 */
		public static var defaultJuggler:Juggler = Starling.juggler;
		private var mJuggler:Juggler = FFParticleSystem.defaultJuggler;
		
		private var mBatched:Boolean = false;
		private var mBatching:Boolean = true;
		private var mBounds:Rectangle;
		private var mCompleted:Boolean;
		private var mCustomFunc:Function = undefined;
		private var mDisposed:Boolean = false;
		private var mFadeInTime:Number = 0;
		private var mFadeOutTime:Number = 0;
		private var mFilter:FragmentFilter = null;
		private var mMaxCapacity:int;
		private var mNumBatchedParticles:int = 0;
		private var mNumParticles:int = 0;
		private var mPlaying:Boolean = false;
		private var mRandomStartFrames:Boolean = false;
		private var mSmoothing:String = TextureSmoothing.BILINEAR;
		private var mSortFunction:Function = undefined;
		private var mSpawnTime:Number = 0;
		private var mSystemAlpha:Number = 1;
		private var mTexture:Texture;
		private var mTinted:Boolean = false;
		private var mPremultipliedAlpha:Boolean = false;
		private var mExactBounds:Boolean = false;
		
		// particles / data / buffers
		private static var sBufferSize:uint = 0;
		private static var sIndices:Vector.<uint>;
		private static var sIndexBuffer:IndexBuffer3D;
		private static var sParticlePool:Vector.<Particle>;
		private static var sPoolSize:uint = 0;
		private static var sVertexBufferIdx:int = -1;
		private static var sVertexBuffers:Vector.<VertexBuffer3D>;
		private static var sNumberOfVertexBuffers:int;
		private var mParticles:Vector.<Particle>;
		private var mVertexData:VertexData;
		
		// emitter configuration
		private var mEmitterType:int; // emitterType
		private var mEmitterXVariance:Number; // sourcePositionVariance x
		private var mEmitterYVariance:Number; // sourcePositionVariance y
		
		// particle configuration
		private var mMaxNumParticles:int; // maxParticles
		private var mLifespan:Number; // particleLifeSpan
		private var mLifespanVariance:Number; // particleLifeSpanVariance
		private var mStartSize:Number; // startParticleSize
		private var mStartSizeVariance:Number; // startParticleSizeVariance
		private var mEndSize:Number; // finishParticleSize
		private var mEndSizeVariance:Number; // finishParticleSizeVariance
		private var mEmitAngle:Number; // angle
		private var mEmitAngleVariance:Number; // angleVariance
		private var mEmitAngleAlignedRotation:Boolean = false;
		private var mStartRotation:Number; // rotationStart
		private var mStartRotationVariance:Number; // rotationStartVariance
		private var mEndRotation:Number; // rotationEnd
		private var mEndRotationVariance:Number; // rotationEndVariance
		
		// gravity configuration
		private var mSpeed:Number; // speed
		private var mSpeedVariance:Number; // speedVariance
		private var mGravityX:Number; // gravity x
		private var mGravityY:Number; // gravity y
		private var mRadialAcceleration:Number; // radialAcceleration
		private var mRadialAccelerationVariance:Number; // radialAccelerationVariance
		private var mTangentialAcceleration:Number; // tangentialAcceleration
		private var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance
		
		// radial configuration 
		private var mMaxRadius:Number; // maxRadius
		private var mMaxRadiusVariance:Number; // maxRadiusVariance
		private var mMinRadius:Number; // minRadius
		private var mMinRadiusVariance:Number; // minRadiusVariance
		private var mRotatePerSecond:Number; // rotatePerSecond
		private var mRotatePerSecondVariance:Number; // rotatePerSecondVariance
		
		// color configuration
		private var mStartColor:ColorArgb = new ColorArgb(1, 1, 1, 1); // startColor
		private var mStartColorVariance:ColorArgb = new ColorArgb(0, 0, 0, 0); // startColorVariance
		private var mEndColor:ColorArgb = new ColorArgb(1, 1, 1, 1); // finishColor
		private var mEndColorVariance:ColorArgb = new ColorArgb(0, 0, 0, 0); // finishColorVariance
		
		// texture animation
		private var mAnimationLoops:Number = 1.0;
		private var mAnimationLoopLength:int = 1;
		private var mFirstFrame:uint = 0;
		private var mFrameLUT:Vector.<Frame>;
		private var mFrameLUTLength:uint;
		private var mFrameTime:Number;
		private var mLastFrame:uint = uint.MAX_VALUE;
		private var mNumberOfFrames:int = 1;
		private var mTextureAnimation:Boolean = false;
		
		private var mBlendFuncSource:String;
		private var mBlendFuncDestination:String;
		private var mEmissionRate:Number; // emitted particles per second
		private var mEmissionTime:Number = -1;
		private var mEmissionTimePredefined:Number = -1;
		private var mEmitterX:Number = 0.0;
		private var mEmitterY:Number = 0.0;
		
		/**
		 * A point to set your emitter position.
		 * @see #emitterX
		 * @see #emitterY
		 */
		public var emitter:Point = new Point();
		
		private var mEmitterObject:Object;
		
		/** Helper objects. */
		
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sHelperPoint:Point = new Point();
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		private static var sRenderMatrix:Matrix3D = new Matrix3D;
		private static var sInstances:Vector.<FFParticleSystem> = new <FFParticleSystem>[];
		private static var sProgramNameCache:Dictionary = new Dictionary();
		
		private static var sLUTsCreated:Boolean = false;
		private static var sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
		private static var sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
		private static var sFixedPool:Boolean = false;
		private static var sRandomSeed:uint = 1;
		
		/*
		   Too bad, [Inline] doesn't work in inlined functions?!
		   This has been inlined by hand in initParticle() a lot
		   [Inline]
		   private static function random():Number
		   {
		   return ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000);
		   }
		 */
		
		/**
		 * Creates a FFParticleSystem instance.
		 *
		 * <p><strong>Note:  </strong>For best performance setup the system buffers by calling
		 * <a href="#FFParticleSystem.init()">FFParticleSystem.init()</a> <strong>before</strong> you create any instances!</p>
		 *
		 * <p>The config file has to be a XML in the following format, known as .pex file</p>
		 *
		 * <p><strong>Note:  </strong>It's strongly recommended to use textures with mipmaps.</p>
		 *
		 * <p><strong>Note:  </strong>You shouldn't create any instance before Starling created the context. Just wait some
		 * frames. Otherwise this might slow down Starling's creation process, since every FFParticleSystem instance is listening
		 * for onContextCreated events, which are necessary to handle a context loss properly.</p>
		 *
		 * @example The following example shows a complete .pex file, starting with the newly introduced properties of this version:
		   <listing version="3.0">
		   &lt;?xml version="1.0"?&gt;
		   &lt;particleEmitterConfig&gt;
		
		   &lt;animation&gt;
		   &lt;isAnimated value="1"/&gt;
		   &lt;loops value="10"/&gt;
		   &lt;firstFrame value="0"/&gt;
		   &lt;lastFrame value="-1"/&gt;
		   &lt;/animation&gt;
		
		   &lt;spawnTime value="0.02"/&gt;
		   &lt;fadeInTime value="0.1"/&gt;
		   &lt;fadeOutTime value="0.1"/&gt;
		   &lt;tinted value="1"/&gt;
		   &lt;emitAngleAlignedRotation value="1"/&gt;
		
		   &lt;texture name="texture.png"/&gt;
		   &lt;sourcePosition x="300.00" y="300.00"/&gt;
		   &lt;sourcePositionVariance x="0.00" y="200"/&gt;
		   &lt;speed value="150.00"/&gt;
		   &lt;speedVariance value="75"/&gt;
		   &lt;particleLifeSpan value="10"/&gt;
		   &lt;particleLifespanVariance value="2"/&gt;
		   &lt;angle value="345"/&gt;
		   &lt;angleVariance value="25.00"/&gt;
		   &lt;gravity x="0.00" y="0.00"/&gt;
		   &lt;radialAcceleration value="0.00"/&gt;
		   &lt;tangentialAcceleration value="0.00"/&gt;
		   &lt;radialAccelVariance value="0.00"/&gt;
		   &lt;tangentialAccelVariance value="0.00"/&gt;
		   &lt;startColor red="1" green="1" blue="1" alpha="1"/&gt;
		   &lt;startColorVariance red="1" green="1" blue="1" alpha="0"/&gt;
		   &lt;finishColor red="1" green="1" blue="1" alpha="1"/&gt;
		   &lt;finishColorVariance red="0" green="0" blue="0" alpha="0"/&gt;
		   &lt;maxParticles value="500"/&gt;
		   &lt;startParticleSize value="50"/&gt;
		   &lt;startParticleSizeVariance value="25"/&gt;
		   &lt;finishParticleSize value="25"/&gt;
		   &lt;FinishParticleSizeVariance value="25"/&gt;
		   &lt;duration value="-1.00"/&gt;
		   &lt;emitterType value="0"/&gt;
		   &lt;maxRadius value="100.00"/&gt;
		   &lt;maxRadiusVariance value="0.00"/&gt;
		   &lt;minRadius value="0.00"/&gt;
		   &lt;rotatePerSecond value="0.00"/&gt;
		   &lt;rotatePerSecondVariance value="0.00"/&gt;
		   &lt;blendFuncSource value="770"/&gt;
		   &lt;blendFuncDestination value="771"/&gt;
		   &lt;rotationStart value="0.00"/&gt;
		   &lt;rotationStartVariance value="0.00"/&gt;
		   &lt;rotationEnd value="0.00"/&gt;
		   &lt;rotationEndVariance value="0.00"/&gt;
		   &lt;emitAngleAlignedRotation value="0"/&gt;
		   &lt;/particleEmitterConfig&gt;
		   </listing>
		 *
		 * @param	config A SystemOptions instance
		 *
		 * @see #init() FFParticleSystem.init()
		 */
		public function FFParticleSystem(config:SystemOptions)
		{
			if (config == null)
				throw new ArgumentError("config must not be null");
			
			sInstances.push(this);
			initInstance(config);
		}
		
		/**
		 * creating vertex and index buffers for the number of particles.
		 * @param	numParticles a value between 1 and 16383
		 */
		private static function createBuffers(numParticles:uint):void
		{
			if (sVertexBuffers)
				for (var i:int = 0; i < sVertexBuffers.length; ++i)
					sVertexBuffers[i].dispose();
			if (sIndexBuffer)
				sIndexBuffer.dispose();
			
			var context:Context3D = Starling.context;
			if (context == null)
				throw new MissingContextError();
			if (context.driverInfo == "Disposed")
				return;
			
			sVertexBuffers = new Vector.<VertexBuffer3D>();
			sVertexBufferIdx = -1;
			if (ApplicationDomain.currentDomain.hasDefinition("flash.display3D.Context3DBufferUsage"))
			{
				for (i = 0; i < sNumberOfVertexBuffers; ++i)
				{
					sVertexBuffers[i] = context.createVertexBuffer.call(context, numParticles * 4, VertexData.ELEMENTS_PER_VERTEX, "dynamicDraw"); // Context3DBufferUsage.DYNAMIC_DRAW; hardcoded for backward compatibility
				}
			}
			else
			{
				for (i = 0; i < sNumberOfVertexBuffers; ++i)
				{
					sVertexBuffers[i] = context.createVertexBuffer(numParticles * 4, VertexData.ELEMENTS_PER_VERTEX);
				}
			}
			
			var zeroBytes:ByteArray = new ByteArray();
			zeroBytes.length = numParticles * 16 * VertexData.ELEMENTS_PER_VERTEX; // numParticle * verticesPerParticle * bytesPerVertex * ELEMENTS_PER_VERTEX
			for (i = 0; i < sNumberOfVertexBuffers; ++i)
			{
				sVertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, numParticles * 4);
			}
			zeroBytes.length = 0;
			
			if (!sIndices)
			{
				sIndices = new Vector.<uint>();
				var numVertices:int = 0;
				var indexPosition:int = -1;
				for (i = 0; i < MAX_CAPACITY; ++i)
				{
					sIndices[++indexPosition] = numVertices;
					sIndices[++indexPosition] = numVertices + 1;
					sIndices[++indexPosition] = numVertices + 2;
					
					sIndices[++indexPosition] = numVertices + 1;
					sIndices[++indexPosition] = numVertices + 3;
					sIndices[++indexPosition] = numVertices + 2;
					numVertices += 4;
				}
			}
			sIndexBuffer = context.createIndexBuffer(numParticles * 6);
			sIndexBuffer.uploadFromVector(sIndices, 0, numParticles * 6);
		}
		
		private function addedToStageHandler(e:starling.events.Event):void
		{
			mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
			
			if (e)
			{
				getParticlesFromPool();
				if (mPlaying)
					start(mEmissionTime);
			}
		}
		
		/**
		 * Calculating property changes of a particle.
		 * @param	aParticle
		 * @param	passedTime
		 */
		
		[Inline]
		
		final private function advanceParticle(aParticle:Particle, passedTime:Number):void
		{
			var particle:Particle = aParticle;
			
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			if (mEmitterType == EMITTER_TYPE_RADIAL)
			{
				particle.emitRotation += particle.emitRotationDelta * passedTime;
				particle.emitRadius += particle.emitRadiusDelta * passedTime;
				var angle:uint = (particle.emitRotation * 325.94932345220164765467394738691) & 2047;
				particle.x = mEmitterX - sCosLUT[angle] * particle.emitRadius;
				particle.y = mEmitterY - sSinLUT[angle] * particle.emitRadius;
			}
			else if (particle.radialAcceleration || particle.tangentialAcceleration)
			{
				var distanceX:Number = particle.x - particle.startX;
				var distanceY:Number = particle.y - particle.startY;
				var distanceScalar:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
				if (distanceScalar < 0.01)
					distanceScalar = 0.01;
				
				var radialX:Number = distanceX / distanceScalar;
				var radialY:Number = distanceY / distanceScalar;
				var tangentialX:Number = radialX;
				var tangentialY:Number = radialY;
				
				radialX *= particle.radialAcceleration;
				radialY *= particle.radialAcceleration;
				
				var newY:Number = tangentialX;
				tangentialX = -tangentialY * particle.tangentialAcceleration;
				tangentialY = newY * particle.tangentialAcceleration;
				
				particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
				particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
			}
			else
			{
				particle.velocityX += passedTime * mGravityX;
				particle.velocityY += passedTime * mGravityY;
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
			}
			
			particle.scale += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;
			
			if (mTextureAnimation)
			{
				particle.frame = particle.frame + particle.frameDelta * passedTime;
				particle.frameIdx = particle.frame;
				if (particle.frameIdx > mFrameLUTLength)
					particle.frameIdx = mFrameLUTLength;
			}
			
			if (mTinted)
			{
				particle.colorRed += particle.colorDeltaRed * passedTime;
				particle.colorGreen += particle.colorDeltaGreen * passedTime;
				particle.colorBlue += particle.colorDeltaBlue * passedTime;
				particle.colorAlpha += particle.colorDeltaAlpha * passedTime;
			}
		}
		
		/**
		 * Loops over all particles and adds/removes/advances them according to the current time;
		 * writes the data directly to the raw vertex data.
		 *
		 * <p>Note: This function is called by Starling's Juggler, so there will most likely be no reason for
		 * you to call it yourself, unless you want to implement slow/quick motion effects.</p>
		 *
		 * @param	passedTime
		 */
		
		public function advanceTime(passedTime:Number):void
		{
			var sortFlag:Boolean = forceSortFlag;
			
			mFrameTime += passedTime;
			if (!mParticles)
			{
				if (mEmissionTime)
				{
					mEmissionTime -= passedTime;
					if (mEmissionTime != Number.MAX_VALUE)
						mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
				}
				else
				{
					stop(autoClearOnComplete);
					complete();
					return;
				}
				return;
			}
			
			var particleIndex:int = 0;
			var particle:Particle;
			if (mEmitterObject != null)
			{
				mEmitterX = emitter.x = mEmitterObject.x;
				mEmitterY = emitter.y = mEmitterObject.y;
			}
			else
			{
				mEmitterX = emitter.x;
				mEmitterY = emitter.y;
			}
			
			// advance existing particles
			while (particleIndex < mNumParticles)
			{
				particle = mParticles[particleIndex];
				
				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime);
					++particleIndex;
				}
				else
				{
					particle.active = false;
					
					if (particleIndex != --mNumParticles)
					{
						var nextParticle:Particle = mParticles[mNumParticles];
						mParticles[mNumParticles] = particle; // put dead p at end
						mParticles[particleIndex] = nextParticle;
						sortFlag = true;
					}
					
					if (mNumParticles == 0 && mEmissionTime < 0)
					{
						stop(autoClearOnComplete);
						complete();
						return;
					}
				}
			}
			
			// create and advance new particles
			
			if (mEmissionTime > 0)
			{
				const timeBetweenParticles:Number = 1.0 / mEmissionRate;
				
				while (mFrameTime > 0 && mNumParticles < mMaxCapacity)
				{
					if (mNumParticles == capacity)
						raiseCapacity(capacity);
					
					particle = mParticles[mNumParticles];
					initParticle(particle);
					advanceParticle(particle, mFrameTime);
					
					++mNumParticles;
					
					mFrameTime -= timeBetweenParticles;
				}
				
				if (mEmissionTime != Number.MAX_VALUE)
					mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
			}
			else if (!mCompleted && mNumParticles == 0)
			{
				stop(autoClearOnComplete);
				complete();
				return;
			}
			
			// update vertex data
			
			if (!mParticles)
				return;
			
			if (mCustomFunc !== null)
			{
				mCustomFunc(mParticles, mNumParticles);
			}
			
			if (sortFlag && mSortFunction !== null)
			{
				mParticles = mParticles.sort(mSortFunction);
			}
			
			var vertexID:int = 0;
			
			var red:Number;
			var green:Number;
			var blue:Number;
			var particleAlpha:Number;
			
			var rotation:Number;
			var x:Number, y:Number;
			var xOffset:Number, yOffset:Number;
			var rawData:Vector.<Number> = mVertexData.rawData;
			var frameDimensions:Frame;
			
			var angle:uint;
			var cos:Number;
			var sin:Number;
			var cosX:Number;
			var cosY:Number;
			var sinX:Number;
			var sinY:Number;
			var position:uint;
			const DEG90RAD:Number = Math.PI * 0.5;
			
			if (mSpawnTime || mFadeInTime || mFadeOutTime)
			{
				var deltaTime:Number;
				for (var i:int = 0; i < mNumParticles; ++i)
				{
					particle = mParticles[i];
					deltaTime = particle.currentTime / particle.totalTime;
					
					if (mSpawnTime)
						particle.spawnFactor = deltaTime < mSpawnTime ? deltaTime / mSpawnTime : 1;
					
					if (mFadeInTime)
						particle.fadeInFactor = deltaTime < mFadeInTime ? deltaTime / mFadeInTime : 1;
					
					if (mFadeOutTime)
					{
						deltaTime = 1 - deltaTime;
						particle.fadeOutFactor = deltaTime < mFadeOutTime ? deltaTime / mFadeOutTime : 1;
					}
				}
			}
			
			for (i = 0; i < mNumParticles; ++i)
			{
				vertexID = i << 2;
				particle = mParticles[i];
				frameDimensions = mFrameLUT[particle.frameIdx];
				
				red = particle.colorRed;
				green = particle.colorGreen;
				blue = particle.colorBlue;
				
				particleAlpha = particle.colorAlpha * particle.fadeInFactor * particle.fadeOutFactor * mSystemAlpha;
				
				rotation = particle.rotation;
				if (frameDimensions.rotated)
				{
					rotation -= DEG90RAD;
				}
				
				x = particle.x;
				y = particle.y;
				
				xOffset = frameDimensions.particleHalfWidth * particle.scale * particle.spawnFactor;
				yOffset = frameDimensions.particleHalfHeight * particle.scale * particle.spawnFactor;
				
				if (rotation)
				{
					angle = (rotation * 325.94932345220164765467394738691) & 2047;
					cos = sCosLUT[angle];
					sin = sSinLUT[angle];
					cosX = cos * xOffset;
					cosY = cos * yOffset;
					sinX = sin * xOffset;
					sinY = sin * yOffset;
					
					position = vertexID << 3; // * 8
					rawData[position] = x - cosX + sinY;
					rawData[++position] = y - sinX - cosY;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureX;
					rawData[++position] = frameDimensions.textureY;
					
					rawData[++position] = x + cosX + sinY;
					rawData[++position] = y + sinX - cosY;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureWidth;
					rawData[++position] = frameDimensions.textureY;
					
					rawData[++position] = x - cosX - sinY;
					rawData[++position] = y - sinX + cosY;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureX;
					rawData[++position] = frameDimensions.textureHeight;
					
					rawData[++position] = x + cosX - sinY;
					rawData[++position] = y + sinX + cosY;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureWidth;
					rawData[++position] = frameDimensions.textureHeight;
					
				}
				else
				{
					position = vertexID << 3; // * 8
					rawData[position] = x - xOffset;
					rawData[++position] = y - yOffset;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureX;
					rawData[++position] = frameDimensions.textureY;
					
					rawData[++position] = x + xOffset;
					rawData[++position] = y - yOffset;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureWidth;
					rawData[++position] = frameDimensions.textureY;
					
					rawData[++position] = x - xOffset;
					rawData[++position] = y + yOffset;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureX;
					rawData[++position] = frameDimensions.textureHeight;
					
					rawData[++position] = x + xOffset;
					rawData[++position] = y + yOffset;
					rawData[++position] = red;
					rawData[++position] = green;
					rawData[++position] = blue;
					rawData[++position] = particleAlpha;
					rawData[++position] = frameDimensions.textureWidth;
					rawData[++position] = frameDimensions.textureHeight;
				}
			}
			
			if (mExactBounds)
			{
				var posX:int = 0;
				var posY:int = 1;
				var tX:Number = 0;
				var tY:Number = 0;
				var minX:Number = Number.MAX_VALUE;
				var maxX:Number = Number.MIN_VALUE;
				var minY:Number = Number.MAX_VALUE;
				var maxY:Number = Number.MIN_VALUE;
				
				for (i = mNumParticles * 4; i > 0; --i)
				{
					tX = rawData[posX];
					tY = rawData[posY];
					if (minX > tX)
						minX = tX;
					if (maxX < tX)
						maxX = tX;
					if (minY > tY)
						minY = tY;
					if (maxY < tY)
						maxY = tY;
					posX += 8;
					posY += 8;
				}
				mBounds.x = minX;
				mBounds.y = minY;
				mBounds.width = maxX - minX;
				mBounds.height = maxY - minY;
			}
		}
		
		/**
		 * Remaining initiation of the current instance (for JIT optimization).
		 * @param	config
		 */
		private function initInstance(config:SystemOptions):void
		{
			parseSystemOptions(config);
			
			if (!mFrameLUT)
			{
				if (mTexture is SubTexture)
				{
					var st:SubTexture = SubTexture(mTexture);
					var frame:Frame = new Frame(1, 1, st.clipping.x, st.clipping.y, st.clipping.width, st.clipping.height, st.rotated);
					frame.particleHalfWidth = (mTexture.width) >> 1;
					frame.particleHalfHeight = (mTexture.height) >> 1;
					mFrameLUT = new <Frame>[frame];
				}
				else
				{
					mFrameLUT = new <Frame>[new Frame(mTexture.root.width, mTexture.root.height, 0, 0, mTexture.width, mTexture.height)];
				}
			}
			
			mEmissionRate = mMaxNumParticles / mLifespan;
			mEmissionTime = 0.0;
			mFrameTime = 0.0;
			mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
			if (!sVertexBuffers || !sVertexBuffers[0])
				init();
			
			if (defaultJuggler == null)
				defaultJuggler = Starling.juggler;
			
			addEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			addedToStageHandler(null)
		
		}
		
		/**
		 * Initiation of anything shared between all systems. Call this function <strong>before</strong> you create any instance
		 * to set a custom size of your pool and Stage3D buffers.
		 *
		 * <p>If you don't call this method explicitly before createing an instance, the first constructor will
		 * create a default pool and buffers; which is OK but might slow down especially mobile devices.</p>
		 *
		 * <p>Set the <em>poolSize</em> to the absolute maximum of particles created by all particle systems together. Creating the pool
		 * will only hit you once (unless you dispose/recreate it/context loss). It will not harm runtime, but a number way to big will waste
		 * memory and take a longer creation process.</p>
		 *
		 * <p>If you're satisfied with the number of particles and want to avoid any accidental enhancement of the pool, set <em>fixed</em>
		 * to true. If you're not sure how much particles you will need, and fear particle systems might not show up more than the consumption
		 * of memory and a little slowdown for newly created particles, set <em>fixed</em> to false.</p>
		 *
		 * <p>The <em>bufferSize</em> determins how many particles can be rendered by one particle system. The <strong>minimum</strong>
		 * should be the maxParticles value set number in your pex file.</p>
		 * <p><strong>Note:   </strong>The bufferSize is always fixed!</p>
		 * <p><strong>Note:   </strong>If you want to profit from batching, take a higher value, e. g. enough for 5 systems. But avoid
		 * choosing an unrealistic high value, since the complete buffer will have to be uploaded each time a particle system (batch) is drawn.</p>
		 *
		 * <p>The <em>numberOfBuffers</em> sets the amount of vertex buffers in use by the particle systems. Multi buffering can avoid stalling of
		 * the GPU but will also increases it's memory consumption.</p>
		 *
		 * @param	poolSize Length of the particle pool.
		 * @param	fixed Whether the poolSize has a fixed length.
		 * @param	bufferSize The maximum number of particles which can be rendered with one draw call. between 1 and 16383. If you do not set this value, it will be set to 16383, which is it's maximum value.
		 * @param	numberOfBuffers The amount of vertex buffers used by the particle system for multi buffering.
		 *
		 * @see #FFParticleSystem()
		 * @see #dispose() FFParticleSystem.dispose()
		 * @see #disposePool() FFParticleSystem.disposePool()
		 * @see #disposeBuffers() FFParticleSystem.disposeBuffers()
		 */
		public static function init(poolSize:uint = 16383, fixed:Boolean = false, bufferSize:uint = 0, numberOfBuffers:uint = 1):void
		{
			
			//registerPrograms();
			
			if (!bufferSize && sBufferSize)
				bufferSize = sBufferSize;
			if (bufferSize > MAX_CAPACITY)
			{
				bufferSize = MAX_CAPACITY;
				trace("Warning: bufferSize exceeds the limit and is set to it's maximum value (16383)");
			}
			else if (bufferSize <= 0)
			{
				bufferSize = MAX_CAPACITY;
				trace("Warning: bufferSize can't be lower than 1 and is set to it's maximum value (16383)");
			}
			sBufferSize = bufferSize;
			sNumberOfVertexBuffers = numberOfBuffers;
			createBuffers(sBufferSize);
			
			//run once
			if (!sLUTsCreated)
				initLUTs();
			
			if (!sParticlePool)
			{
				sFixedPool = fixed;
				sParticlePool = new Vector.<Particle>();
				sPoolSize = poolSize;
				var i:int = -1;
				while (++i < sPoolSize)
					sParticlePool[i] = new Particle();
			}
			
			if (defaultJuggler == null)
				defaultJuggler = Starling.juggler;
			
			// handle a lost device context
			Starling.current.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
		}
		
		/**
		 * Creats look up tables for sin and cos, to reduce function calls.
		 */
		private static function initLUTs():void
		{
			for (var i:int = 0; i < 0x800; ++i)
			{
				sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
				sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
			}
			sLUTsCreated = true;
		}
		
		/**
		 * Sets the start values for a newly created particle, according to your system settings.
		 *
		 * <p>Note:
		 * 		The following snippet ...
		 *
		 * 			(((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
		 *
		 * 		... is a pseudo random number generator; directly inlined; to reduce function calls.
		 * 		Unfortunatelly it seems impossible to inline within inline functions.</p>
		 *
		 * @param	aParticle
		 */
		[Inline]
		
		final private function initParticle(aParticle:Particle):void
		{
			var particle:Particle = aParticle;
			
			// for performance reasons, the random variances are calculated inline instead
			// of calling a function
			
			var lifespan:Number = mLifespan + mLifespanVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (lifespan <= 0.0)
				return;
			
			particle.active = true;
			particle.currentTime = 0.0;
			particle.totalTime = lifespan;
			
			particle.x = mEmitterX + mEmitterXVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.y = mEmitterY + mEmitterYVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.startX = mEmitterX;
			particle.startY = mEmitterY;
			
			var angleDeg:Number = (mEmitAngle + mEmitAngleVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0));
			var angle:uint = (angleDeg * 325.94932345220164765467394738691) & 2047;
			var speed:Number = mSpeed + mSpeedVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.velocityX = speed * sCosLUT[angle];
			particle.velocityY = speed * sSinLUT[angle];
			
			particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.emitRadiusDelta = mMaxRadius / lifespan;
			particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.emitRadiusDelta = (mMinRadius + mMinRadiusVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0) - particle.emitRadius) / lifespan;
			particle.emitRotation = mEmitAngle + mEmitAngleVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			var startSize:Number = mStartSize + mStartSizeVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			var endSize:Number = mEndSize + mEndSizeVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (startSize < 0.1)
				startSize = 0.1;
			if (endSize < 0.1)
				endSize = 0.1;
			
			var firstFrameWidth:Number = mFrameLUT[0].particleHalfWidth << 1;
			particle.scale = startSize / firstFrameWidth;
			particle.scaleDelta = ((endSize - startSize) / lifespan) / firstFrameWidth;
			particle.frameIdx = particle.frame = mRandomStartFrames ? mAnimationLoopLength * ((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x80000000) : 0;
			particle.frameDelta = mNumberOfFrames / lifespan;
			
			// colors
			var startColorRed:Number = mStartColor.red;
			var startColorGreen:Number = mStartColor.green;
			var startColorBlue:Number = mStartColor.blue;
			var startColorAlpha:Number = mStartColor.alpha;
			
			if (mStartColorVariance.red != 0)
				startColorRed += mStartColorVariance.red * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.green != 0)
				startColorGreen += mStartColorVariance.green * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.blue != 0)
				startColorBlue += mStartColorVariance.blue * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mStartColorVariance.alpha != 0)
				startColorAlpha += mStartColorVariance.alpha * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			var endColorRed:Number = mEndColor.red;
			var endColorGreen:Number = mEndColor.green;
			var endColorBlue:Number = mEndColor.blue;
			var endColorAlpha:Number = mEndColor.alpha;
			
			if (mEndColorVariance.red != 0)
				endColorRed += mEndColorVariance.red * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.green != 0)
				endColorGreen += mEndColorVariance.green * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.blue != 0)
				endColorBlue += mEndColorVariance.blue * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			if (mEndColorVariance.alpha != 0)
				endColorAlpha += mEndColorVariance.alpha * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			
			particle.colorRed = startColorRed;
			particle.colorGreen = startColorGreen;
			particle.colorBlue = startColorBlue;
			particle.colorAlpha = startColorAlpha;
			
			particle.colorDeltaRed = (endColorRed - startColorRed) / lifespan;
			particle.colorDeltaGreen = (endColorGreen - startColorGreen) / lifespan;
			particle.colorDeltaBlue = (endColorBlue - startColorBlue) / lifespan;
			particle.colorDeltaAlpha = (endColorAlpha - startColorAlpha) / lifespan;
			
			// rotation
			if (mEmitAngleAlignedRotation)
			{
				var startRotation:Number = angleDeg + mStartRotation + mStartRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				var endRotation:Number = angleDeg + mEndRotation + mEndRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			}
			else
			{
				startRotation = mStartRotation + mStartRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
				endRotation = mEndRotation + mEndRotationVariance * (((sRandomSeed = (sRandomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
			}
			
			particle.rotation = startRotation;
			particle.rotationDelta = (endRotation - startRotation) / lifespan;
			
			particle.spawnFactor = 1;
			particle.fadeInFactor = 1;
			particle.fadeOutFactor = 1;
		}
		
		/**
		 * Setting the complete state and throwing the event.
		 */
		private function complete():void
		{
			if (!mCompleted)
			{
				mCompleted = true;
				dispatchEventWith(starling.events.Event.COMPLETE);
			}
		}
		
		/**
		 * Disposes the system instance and frees it's resources
		 */
		public override function dispose():void
		{
			sInstances.splice(sInstances.indexOf(this), 1);
			removeEventListener(starling.events.Event.ADDED_TO_STAGE, addedToStageHandler);
			stop(true);
			mBatched = false;
			super.filter = mFilter = null;
			removeFromParent();
			
			super.dispose();
			mDisposed = true;
		}
		
		/**
		 *  Whether the system has been disposed earlier
		 */
		public function get disposed():Boolean
		{
			return mDisposed;
		}
		
		/**
		 * Disposes the created particle pool and Stage3D buffers, shared by all instances.
		 * Warning: Therefore all instances will get disposed as well!
		 */
		public static function dispose():void
		{
			Starling.current.stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated);
			
			disposeBuffers();
			disposePool();
		}
		
		/**
		 * Disposes the Stage3D buffers and therefore disposes all system instances!
		 * Call this function to free the GPU resources or if you have to set
		 * the buffers to another size.
		 */
		public static function disposeBuffers():void
		{
			for (var i:int = sInstances.length - 1; i >= 0; --i)
			{
				sInstances[i].dispose();
			}
			if (sVertexBuffers)
			{
				for (i = 0; i < sNumberOfVertexBuffers; ++i)
				{
					sVertexBuffers[i].dispose();
					sVertexBuffers[i] = null;
				}
				sVertexBuffers = null;
				sNumberOfVertexBuffers = 0;
			}
			if (sIndexBuffer)
			{
				sIndexBuffer.dispose();
				sIndexBuffer = null;
			}
			sBufferSize = 0;
		}
		
		/**
		 * Clears the current particle pool.
		 * Warning: Also disposes all system instances!
		 */
		public static function disposePool():void
		{
			for (var i:int = sInstances.length - 1; i >= 0; --i)
			{
				sInstances[i].dispose();
			}
			sParticlePool = null;
		}
		
		/** @inheritDoc */
		public override function set filter(value:FragmentFilter):void
		{
			if (!mBatched)
				mFilter = value;
			super.filter = value;
		}
		
		/**
		 * Returns a rectangle in stage dimensions (to support filters) if possible, or an empty rectangle
		 * at the particle system's position. Calculating the actual bounds would be too expensive.
		 */
		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			if (resultRect == null)
				resultRect = new Rectangle();
			
			if (targetSpace == this || targetSpace == null) // optimization
			{
				if (mBounds)
					resultRect = mBounds;
				else if (stage)
				{
					// return full stage size to support filters ... may be expensive, but we have no other options, do we?
					resultRect.x = 0;
					resultRect.y = 0;
					resultRect.width = stage.stageWidth;
					resultRect.height = stage.stageHeight;
				}
				else
				{
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					resultRect.width = resultRect.height = 0;
				}
				return resultRect;
			}
			else if (targetSpace)
			{
				if (mBounds)
				{
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, mBounds.x, mBounds.y, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					MatrixUtil.transformCoords(sHelperMatrix, mBounds.width, mBounds.height, sHelperPoint);
					resultRect.width = sHelperPoint.x
					resultRect.height = sHelperPoint.y;
				}
				else if (stage)
				{
					// return full stage size to support filters ... may be pretty expensive
					resultRect.x = 0;
					resultRect.y = 0;
					resultRect.width = stage.stageWidth;
					resultRect.height = stage.stageHeight;
				}
				else
				{
					getTransformationMatrix(targetSpace, sHelperMatrix);
					MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
					resultRect.x = sHelperPoint.x;
					resultRect.y = sHelperPoint.y;
					resultRect.width = resultRect.height = 0;
				}
				
				return resultRect;
			}
			return resultRect = mBounds;
		
		}
		
		/**
		 * Takes particles from the pool and assigns them to the system instance.
		 * If the particle pool doesn't have enough unused particles left, it will
		 * - either create new particles, if the pool size is expandable
		 * - or return false, if the pool size has been fixed
		 *
		 * Returns a Boolean for success
		 *
		 * @return
		 */
		private function getParticlesFromPool():Boolean
		{
			if (mParticles)
				return true;
			
			if (mDisposed)
				return false;
			
			if (sParticlePool.length >= mMaxNumParticles)
			{
				mParticles = new Vector.<Particle>(mMaxNumParticles, true);
				var particleIdx:int = mMaxNumParticles;
				var poolIdx:int = sParticlePool.length;
				
				sParticlePool.fixed = false;
				while (particleIdx)
				{
					mParticles[--particleIdx] = sParticlePool[--poolIdx];
					mParticles[particleIdx].active = false;
					sParticlePool[poolIdx] = null;
				}
				sParticlePool.length = poolIdx;
				sParticlePool.fixed = true;
				
				mVertexData = new VertexData(mMaxNumParticles * 4);
				mNumParticles = 0;
				raiseCapacity(mMaxNumParticles - mParticles.length);
				return true;
			}
			
			if (sFixedPool)
				return false;
			
			var i:int = sParticlePool.length - 1;
			var len:int = mMaxNumParticles;
			sParticlePool.fixed = false;
			while (++i < len)
				sParticlePool[i] = new Particle();
			sParticlePool.fixed = true;
			return getParticlesFromPool();
		}
		
		/**
		 * (Re)Inits the system (after context loss)
		 * @param	event
		 */
		private static function onContextCreated(event:flash.events.Event):void
		{
			createBuffers(sBufferSize);
		}
		
		private function parseSystemOptions(systemOptions:SystemOptions):void
		{
			if (!systemOptions)
				return;
			
			const DEG2RAD:Number = 1 / 180 * Math.PI;
			
			mTextureAnimation = Boolean(systemOptions.isAnimated);
			mAnimationLoops = int(systemOptions.loops);
			mFirstFrame = int(systemOptions.firstFrame);
			mLastFrame = int(systemOptions.lastFrame);
			mRandomStartFrames = Boolean(systemOptions.randomStartFrames);
			mTinted = Boolean(systemOptions.tinted);
			mSpawnTime = Number(systemOptions.spawnTime);
			mFadeInTime = Number(systemOptions.fadeInTime);
			mFadeOutTime = Number(systemOptions.fadeOutTime);
			mEmitterType = int(systemOptions.emitterType);
			mMaxNumParticles = int(systemOptions.maxParticles);
			emitter.x = mEmitterX = Number(systemOptions.sourceX);
			emitter.y = mEmitterY = Number(systemOptions.sourceY);
			mEmitterXVariance = Number(systemOptions.sourceVarianceX);
			mEmitterYVariance = Number(systemOptions.sourceVarianceY);
			mLifespan = Number(systemOptions.lifespan);
			lifespanVariance = Number(systemOptions.lifespanVariance);
			mEmitAngle = Number(systemOptions.angle) * DEG2RAD;
			mEmitAngleVariance = Number(systemOptions.angleVariance) * DEG2RAD;
			mStartSize = Number(systemOptions.startParticleSize);
			mStartSizeVariance = Number(systemOptions.startParticleSizeVariance);
			mEndSize = Number(systemOptions.finishParticleSize);
			mEndSizeVariance = Number(systemOptions.finishParticleSizeVariance);
			mStartRotation = Number(systemOptions.rotationStart) * DEG2RAD;
			mStartRotationVariance = Number(systemOptions.rotationStartVariance) * DEG2RAD;
			mEndRotation = Number(systemOptions.rotationEnd) * DEG2RAD;
			mEndRotationVariance = Number(systemOptions.rotationEndVariance) * DEG2RAD;
			mEmissionTimePredefined = Number(systemOptions.duration);
			mEmissionTimePredefined = mEmissionTimePredefined < 0 ? Number.MAX_VALUE : mEmissionTimePredefined;
			
			mGravityX = Number(systemOptions.gravityX);
			mGravityY = Number(systemOptions.gravityY);
			mSpeed = Number(systemOptions.speed);
			mSpeedVariance = Number(systemOptions.speedVariance);
			mRadialAcceleration = Number(systemOptions.radialAcceleration);
			mRadialAccelerationVariance = Number(systemOptions.radialAccelerationVariance);
			mTangentialAcceleration = Number(systemOptions.tangentialAcceleration);
			mTangentialAccelerationVariance = Number(systemOptions.tangentialAccelerationVariance);
			
			mMaxRadius = Number(systemOptions.maxRadius);
			mMaxRadiusVariance = Number(systemOptions.maxRadiusVariance);
			minRadius = Number(systemOptions.minRadius);
			mMinRadiusVariance = Number(systemOptions.minRadiusVariance);
			mRotatePerSecond = Number(systemOptions.rotatePerSecond) * DEG2RAD;
			mRotatePerSecondVariance = Number(systemOptions.rotatePerSecondVariance) * DEG2RAD;
			
			mStartColor.red = Number(systemOptions.startColor.red);
			mStartColor.green = Number(systemOptions.startColor.green);
			mStartColor.blue = Number(systemOptions.startColor.blue);
			mStartColor.alpha = Number(systemOptions.startColor.alpha);
			
			mStartColorVariance.red = Number(systemOptions.startColorVariance.red);
			mStartColorVariance.green = Number(systemOptions.startColorVariance.green);
			mStartColorVariance.blue = Number(systemOptions.startColorVariance.blue);
			mStartColorVariance.alpha = Number(systemOptions.startColorVariance.alpha);
			
			mEndColor.red = Number(systemOptions.finishColor.red);
			mEndColor.green = Number(systemOptions.finishColor.green);
			mEndColor.blue = Number(systemOptions.finishColor.blue);
			mEndColor.alpha = Number(systemOptions.finishColor.alpha);
			
			mEndColorVariance.red = Number(systemOptions.finishColorVariance.red);
			mEndColorVariance.green = Number(systemOptions.finishColorVariance.green);
			mEndColorVariance.blue = Number(systemOptions.finishColorVariance.blue);
			mEndColorVariance.alpha = Number(systemOptions.finishColorVariance.alpha);
			
			mBlendFuncSource = String(systemOptions.blendFuncSource);
			mBlendFuncDestination = String(systemOptions.blendFuncDestination);
			mEmitAngleAlignedRotation = Boolean(systemOptions.emitAngleAlignedRotation);
			
			exactBounds = Boolean(systemOptions.excactBounds);
			mTexture = systemOptions.texture;
			mPremultipliedAlpha = Boolean(systemOptions.premultipliedAlpha);
			
			mFilter = systemOptions.filter;
			mCustomFunc = systemOptions.customFunction;
			mSortFunction = systemOptions.sortFunction;
			forceSortFlag = systemOptions.forceSortFlag;
			
			mFrameLUT = systemOptions.mFrameLUT;
			
			mAnimationLoopLength = mLastFrame - mFirstFrame + 1;
			mNumberOfFrames = mFrameLUT.length - 1 - (mRandomStartFrames && mTextureAnimation ? mAnimationLoopLength : 0);
			mFrameLUTLength = mFrameLUT.length - 1;
		}
		
		/**
		 * Returns current properties to SystemOptions Object
		 * @param	target A SystemOptions instance
		 */
		public function exportSystemOptions(target:SystemOptions = null):SystemOptions
		{
			if (!target)
				target = new SystemOptions(mTexture);
			
			const RAD2DEG:Number = 180 / Math.PI;
			
			target.isAnimated = mTextureAnimation;
			target.loops = mAnimationLoops;
			target.firstFrame = mFirstFrame;
			target.lastFrame = mLastFrame;
			target.randomStartFrames = mRandomStartFrames;
			target.tinted = mTinted;
			target.premultipliedAlpha = mPremultipliedAlpha;
			target.spawnTime = mSpawnTime;
			target.fadeInTime = mFadeInTime;
			target.fadeOutTime = mFadeOutTime;
			target.emitterType = mEmitterType;
			target.maxParticles = mMaxNumParticles;
			target.sourceX = mEmitterX;
			target.sourceY = mEmitterY;
			target.sourceVarianceX = mEmitterXVariance;
			target.sourceVarianceY = mEmitterYVariance;
			target.lifespan = mLifespan;
			target.lifespanVariance = mLifespanVariance;
			target.angle = mEmitAngle * RAD2DEG;
			target.angleVariance = mEmitAngleVariance * RAD2DEG;
			target.startParticleSize = mStartSize;
			target.startParticleSizeVariance = mStartSizeVariance;
			target.finishParticleSize = mEndSize;
			target.finishParticleSizeVariance = mEndSizeVariance;
			target.rotationStart = mStartRotation * RAD2DEG;
			target.rotationStartVariance = mStartRotationVariance * RAD2DEG;
			target.rotationEnd = mEndRotation * RAD2DEG;
			target.rotationEndVariance = mEndRotationVariance * RAD2DEG;
			target.duration = mEmissionTimePredefined == Number.MAX_VALUE ? -1 : mEmissionTimePredefined;
			
			target.gravityX = mGravityX;
			target.gravityY = mGravityY;
			target.speed = mSpeed;
			target.speedVariance = mSpeedVariance;
			target.radialAcceleration = mRadialAcceleration;
			target.radialAccelerationVariance = mRadialAccelerationVariance;
			target.tangentialAcceleration = mTangentialAcceleration;
			target.tangentialAccelerationVariance = mTangentialAccelerationVariance;
			
			target.maxRadius = mMaxRadius;
			target.maxRadiusVariance = mMaxRadiusVariance;
			target.minRadius = mMinRadius;
			target.minRadiusVariance = mMinRadiusVariance;
			target.rotatePerSecond = mRotatePerSecond * RAD2DEG;
			target.rotatePerSecondVariance = mRotatePerSecondVariance * RAD2DEG;
			
			target.startColor = mStartColor;
			target.startColorVariance = mStartColorVariance;
			target.finishColor = mEndColor;
			target.finishColorVariance = mEndColorVariance;
			
			target.blendFuncSource = mBlendFuncSource;
			target.blendFuncDestination = mBlendFuncDestination;
			target.emitAngleAlignedRotation = mEmitAngleAlignedRotation;
			
			target.excactBounds = mExactBounds;
			target.texture = mTexture;
			
			target.filter = mFilter;
			target.customFunction = mCustomFunc;
			target.sortFunction = mSortFunction;
			target.forceSortFlag = forceSortFlag;
			
			target.mFrameLUT = mFrameLUT;
			
			target.firstFrame = mFirstFrame;
			target.lastFrame = mLastFrame;
			
			return target;
		}
		
		/**
		 * Removes the system from the juggler and stops animation.
		 */
		public function pause():void
		{
			if (automaticJugglerManagement)
				mJuggler.remove(this);
			mPlaying = false;
		}
		
		private function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(mMaxCapacity, capacity + byAmount);
			
			if (oldCapacity < newCapacity)
				mVertexData.numVertices = newCapacity * 4;
		}
		
		///////////////////////////////// QUAD BATCH EXCERPT /////////////////////////////////
		
		// program management
		
		private function getProgram(tinted:Boolean):Program3D
		{
			var target:Starling = Starling.current;
			var programName:String;
			
			if (mTexture)
				programName = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);
			
			var program:Program3D = target.getProgram(programName);
			
			if (!program)
			{
				// this is the input data we'll pass to the shaders:
				// 
				// va0 -> position
				// va1 -> color
				// va2 -> texCoords
				// vc0 -> alpha
				// vc1 -> mvpMatrix
				// fs0 -> texture
				
				var vertexShader:String;
				var fragmentShader:String;
				
				if (!mTexture) // Quad-Shaders
				{
					vertexShader = "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va1, vc0 \n"; // multiply alpha (vc0) with color (va1)
					
					fragmentShader = "mov oc, v0       \n"; // output color
				}
				else // Image-Shaders
				{
					vertexShader = tinted ? "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va1, vc0 \n" + // multiply alpha (vc0) with color (va1)
					"mov v1, va2      \n" // pass texture coordinates to fragment program
					: "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
					"mov v1, va2      \n"; // pass texture coordinates to fragment program
					
					fragmentShader = tinted ? "tex ft1,  v1, fs0 <???> \n" + // sample texture 0
					"mul  oc, ft1,  v0       \n" // multiply color with texel color
					: "tex  oc,  v1, fs0 <???> \n"; // sample texture 0
					
					fragmentShader = fragmentShader.replace("<???>", RenderSupport.getTextureLookupFlags(mTexture.format, mTexture.mipMapping, mTexture.repeat, smoothing));
				}
				
				program = target.registerProgramFromSource(programName, vertexShader, fragmentShader);
			}
			
			return program;
		}
		
		private static function getImageProgramName(tinted:Boolean, mipMap:Boolean = true, repeat:Boolean = false, format:String = "bgra", smoothing:String = "bilinear"):String
		{
			var bitField:uint = 0;
			
			if (tinted)
				bitField |= 1;
			if (mipMap)
				bitField |= 1 << 1;
			if (repeat)
				bitField |= 1 << 2;
			
			if (smoothing == TextureSmoothing.NONE)
				bitField |= 1 << 3;
			else if (smoothing == TextureSmoothing.TRILINEAR)
				bitField |= 1 << 4;
			
			if (format == Context3DTextureFormat.COMPRESSED)
				bitField |= 1 << 5;
			else if (format == "compressedAlpha")
				bitField |= 1 << 6;
			
			var name:String = sProgramNameCache[bitField];
			
			if (name == null)
			{
				name = "QB_i." + bitField.toString(16);
				sProgramNameCache[bitField] = name;
			}
			
			return name;
		}
		
		///////////////////////////////// QUAD BATCH EXCERPT END /////////////////////////////////
		
		///////////////////////////////// QUAD BATCH MODIFICATIONS /////////////////////////////////
		
		/** Indicates if specific particle system can be batch to another without causing a state change.
		 *  A state change occurs if the system uses a different base texture, has a different
		 *  'tinted', 'smoothing', 'repeat' or 'blendMode' (blendMode, blendFactorSource,
		 *  blendFactorDestination) setting, or if it has a different filter instance.
		 *
		 *  <p>In Starling it is not recommended to use the same filter instance for multiple
		 *  DisplayObjects. Sharing a filter instance between instances of the FFParticleSystem is
		 *  AFAIK the only existing exception to this rule IF the systems will get batched.</p>
		 */
		public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture, pma:Boolean, smoothing:String, blendMode:String, blendFactorSource:String, blendFactorDestination:String, filter:FragmentFilter):Boolean
		{
			if (mNumParticles == 0)
				return false;
			else if (mTexture != null && texture != null)
				return mTexture.base != texture.base || mTexture.repeat != texture.repeat || mPremultipliedAlpha != pma || mSmoothing != smoothing || mTinted != (tinted || parentAlpha != 1.0) || this.blendMode != blendMode || this.mBlendFuncSource != blendFactorSource || this.mBlendFuncDestination != blendFactorDestination || this.mFilter != filter;
			else
				return true;
		}
		
		/** @inheritDoc */
		private static var sHelperRect:Rectangle = new Rectangle();
		
		public override function render(support:RenderSupport, parentAlpha:Number):void
		{
			mNumBatchedParticles = 0;
			getBounds(stage, batchBounds);
			
			if (mNumParticles)
			{
				if (mBatching)
				{
					if (!mBatched)
					{
						var first:int = parent.getChildIndex(this);
						var last:int = first;
						var numChildren:int = parent.numChildren;
						
						while (++last < numChildren)
						{
							var next:DisplayObject = parent.getChildAt(last);
							if (next is FFParticleSystem)
							{
								var nextps:FFParticleSystem = FFParticleSystem(next);
								
								if (nextps.mParticles && !nextps.isStateChange(mTinted, alpha, mTexture, mPremultipliedAlpha, mSmoothing, blendMode, mBlendFuncSource, mBlendFuncDestination, mFilter))
								{
									
									var newcapacity:int = numParticles + mNumBatchedParticles + nextps.numParticles;
									if (newcapacity > sBufferSize)
										break;
									
									mVertexData.rawData.fixed = false;
									nextps.mVertexData.copyTo(this.mVertexData, (numParticles + mNumBatchedParticles) * 4, 0, nextps.numParticles * 4);
									mVertexData.rawData.fixed = true;
									mNumBatchedParticles += nextps.numParticles;
									
									nextps.mBatched = true;
									
									//disable filter of batched system temporarily
									nextps.filter = null;
									
									nextps.getBounds(stage, sHelperRect);
									if (batchBounds.intersects(sHelperRect))
										batchBounds = batchBounds.union(sHelperRect);
								}
								else
								{
									break;
								}
							}
							else
							{
								break;
							}
						}
						renderCustom(support, alpha * parentAlpha, support.blendMode);
					}
				}
				else
				{
					renderCustom(support, alpha * parentAlpha, support.blendMode);
				}
			}
			//reset filter
			super.filter = mFilter;
			mBatched = false;
		}
		
		/** @private */
		private var batchBounds:Rectangle = new Rectangle();
		
		private function renderCustom(support:RenderSupport, parentAlpha:Number = 1.0, blendMode:String = null):void
		{
			sVertexBufferIdx = ++sVertexBufferIdx % sNumberOfVertexBuffers;
			
			if (mNumParticles == 0 || !sVertexBuffers)
				return;
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();
			
			// make this call to keep the statistics display in sync.
			// to play it safe, it's done in a backwards-compatible way here.
			if (support.hasOwnProperty("raiseDrawCount"))
				support.raiseDrawCount();
			
			//alpha *= this.alpha;
			
			var program:String = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);
			
			var context:Context3D = Starling.context;
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = mPremultipliedAlpha ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			if (context == null)
				throw new MissingContextError();
			
			context.setBlendFactors(mBlendFuncSource, mBlendFuncDestination);
			
			MatrixUtil.convertTo3D(support.mvpMatrix, sRenderMatrix);
			
			context.setProgram(getProgram(mTinted));
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha, 1);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sRenderMatrix, true);
			context.setTextureAt(0, mTexture.base);
			
			sVertexBuffers[sVertexBufferIdx].uploadFromVector(mVertexData.rawData, 0, Math.min(sBufferSize * 4, mVertexData.rawData.length / 8));
			
			context.setVertexBufferAt(0, sVertexBuffers[sVertexBufferIdx], VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			if (mTinted)
				context.setVertexBufferAt(1, sVertexBuffers[sVertexBufferIdx], VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, sVertexBuffers[sVertexBufferIdx], VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			if (batchBounds)
				support.pushClipRect(batchBounds);
			context.drawTriangles(sIndexBuffer, 0, (Math.min(sBufferSize, mNumParticles + mNumBatchedParticles)) * 2);
			if (batchBounds)
				support.popClipRect();
			
			context.setVertexBufferAt(2, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setTextureAt(0, null);
		}
		
		///////////////////////////////// QUAD BATCH MODIFICATIONS END /////////////////////////////////
		
		/**
		 * Adds the system to the juggler and resumes the animation.
		 */
		public function resume():void
		{
			if (automaticJugglerManagement)
				mJuggler.add(this);
			mPlaying = true;
		}
		
		/**
		 * Starts the system to emit particles and adds it to the defaultJuggler if automaticJugglerManagement is enabled.
		 * @param	duration Emitting time in seconds.
		 */
		public function start(duration:Number = 0):void
		{
			if (mCompleted)
				reset();
			
			if (mEmissionRate != 0 && !mCompleted)
			{
				if (duration == 0)
				{
					duration = mEmissionTimePredefined;
				}
				else if (duration < 0)
				{
					duration = Number.MAX_VALUE;
				}
				mPlaying = true;
				mEmissionTime = duration;
				mFrameTime = 0;
				if (automaticJugglerManagement)
					mJuggler.add(this);
			}
		}
		
		/**
		 * Stopping the emitter creating particles.
		 * @param	clear Unlinks the particles returns them back to the pool and stops the animation.
		 */
		public function stop(clear:Boolean = false):void
		{
			mEmissionTime = 0.0;
			
			if (clear)
			{
				if (automaticJugglerManagement)
					mJuggler.remove(this);
				
				mPlaying = false;
				returnParticlesToPool();
				dispatchEventWith(starling.events.Event.CANCEL);
			}
		}
		
		/**
		 * Resets complete state and enables the system to play again if it has not been disposed.
		 * @return
		 */
		public function reset():Boolean
		{
			if (!mDisposed)
			{
				mEmissionRate = mMaxNumParticles / mLifespan;
				mFrameTime = 0.0;
				mPlaying = false;
				while (mNumParticles)
				{
					mParticles[--mNumParticles].active = false;
				}
				mMaxCapacity = mMaxNumParticles ? Math.min(MAX_CAPACITY, mMaxNumParticles) : MAX_CAPACITY;
				mCompleted = false;
				if (!mParticles)
					getParticlesFromPool();
				return mParticles != null;
			}
			return false;
		}
		
		private function returnParticlesToPool():void
		{
			mNumParticles = 0;
			
			if (mParticles)
			{
				// handwritten concat to avoid gc
				var particleIdx:int = mParticles.length;
				var poolIdx:int = sParticlePool.length - 1;
				sParticlePool.fixed = false;
				while (particleIdx)
					sParticlePool[++poolIdx] = mParticles[--particleIdx];
				sParticlePool.fixed = true;
				mParticles = null;
			}
			mVertexData = null;
			
			// link cache to next waiting system
			if (sFixedPool)
			{
				for (var i:int = 0; i < sInstances.length; ++i)
				{
					var instance:FFParticleSystem = sInstances[i];
					if (instance != this && !instance.mCompleted && instance.mPlaying && instance.parent && instance.mParticles == null)
					{
						if (instance.getParticlesFromPool())
							break;
					}
				}
			}
		}
		
		private function updateEmissionRate():void
		{
			emissionRate = mMaxNumParticles / mLifespan;
		}
		
		/** @inheritDoc */
		override public function get alpha():Number
		{
			return mSystemAlpha;
		}
		
		override public function set alpha(value:Number):void
		{
			mSystemAlpha = value;
		}
		
		/**
		 * Enables/Disables System internal batching.
		 *
		 * Only FFParticleSystems which share the same parent and are siblings next to each other, can be batched.
		 * Of course the rules of "stateChanges" also apply.
		 * @see #isStateChange()
		 */
		public function get batching():Boolean
		{
			return mBatching;
		}
		
		public function set batching(value:Boolean):void
		{
			mBatching = value;
		}
		
		/**
		 * Source blend factor of the particles.
		 *
		 * @see #blendFactorDestination
		 * @see flash.display3D.Context3DBlendFactor
		 */
		public function get blendFuncSource():String
		{
			return mBlendFuncSource;
		}
		
		public function set blendFuncSource(value:String):void
		{
			mBlendFuncSource = value;
		}
		
		/**
		 * Destination blend factor of the particles.
		 * @see #blendFactorSource
		 * @see flash.display3D.Context3DBlendFactor;
		 */
		public function get blendFuncDestination():String
		{
			return mBlendFuncDestination;
		}
		
		public function set blendFuncDestination(value:String):void
		{
			mBlendFuncDestination = value;
		}
		
		/**
		 * The number of particles, currently fitting into the vertexData instance of the system. (Not necessaryly all of them are visible)
		 */
		[Inline]
		
		final public function get capacity():int
		{
			return mVertexData ? mVertexData.numVertices / 4 : 0;
		}
		
		/**
		 * Returns complete state of the system. The value is true if the system is done or has been
		 * stopped with the parameter clear.
		 */
		
		public function get completed():Boolean
		{
			return mCompleted;
		}
		
		/**
		 * A custom function that can be applied to run code after every particle
		 * has been advanced, (sorted) and before it will be written to buffers/uploaded to the GPU.
		 *
		 * @default undefined
		 */
		public function set customFunction(func:Function):void
		{
			mCustomFunc = func;
		}
		
		public function get customFunction():Function
		{
			return mCustomFunc;
		}
		
		/**
		 * The number of particles, currently used by the system. (Not necessaryly all of them are visible).
		 */
		public function get numParticles():int
		{
			return mNumParticles;
		}
		
		/**
		 * The duration of one animation cycle.
		 */
		public function get cycleDuration():Number
		{
			return mMaxNumParticles / mEmissionRate;
		}
		
		/**
		 * Number of emitted particles/second.
		 */
		public function get emissionRate():Number
		{
			return mEmissionRate;
		}
		
		public function set emissionRate(value:Number):void
		{
			mEmissionRate = value;
		}
		
		/**
		 * Angle of the emitter in degrees.
		 */
		public function get emitAngle():Number
		{
			return mEmitAngle;
		}
		
		public function set emitAngle(value:Number):void
		{
			mEmitAngle = value;
		}
		
		/**
		 * Wheather the particles rotation should respect the emit angle at birth or not.
		 */
		public function set emitAngleAlignedRotation(value:Boolean):void
		{
			mEmitAngleAlignedRotation = value;
		}
		
		public function get emitAngleAlignedRotation():Boolean
		{
			return mEmitAngleAlignedRotation;
		}
		
		/**
		 * Variance of the emit angle in degrees.
		 */
		public function get emitAngleVariance():Number
		{
			return mEmitAngleVariance;
		}
		
		public function set emitAngleVariance(value:Number):void
		{
			mEmitAngleVariance = value;
		}
		
		/**
		 * The type of the emitter.
		 *
		 * @see #EMITTER_TYPE_GRAVITY
		 * @see #EMITTER_TYPE_RADIAL
		 */
		public function get emitterType():int
		{
			return mEmitterType;
		}
		
		public function set emitterType(value:int):void
		{
			mEmitterType = value;
		}
		
		/**
		 * An Object setting the emitter position automatically.
		 *
		 * @see #emitter
		 * @see #emitterX
		 * @see #emitterY
		 */
		public function get emitterObject():Object
		{
			return mEmitterObject;
		}
		
		public function set emitterObject(obj:Object):void
		{
			mEmitterObject = obj;
		}
		
		/**
		 * Emitter x position.
		 *
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterY
		 */
		public function get emitterX():Number
		{
			return emitter.x;
		}
		
		public function set emitterX(value:Number):void
		{
			emitter.x = value;
		}
		
		/**
		 * Variance of the emitters x position.
		 *
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterX
		 */
		public function get emitterXVariance():Number
		{
			return mEmitterXVariance;
		}
		
		public function set emitterXVariance(value:Number):void
		{
			mEmitterXVariance = value;
		}
		
		/**
		 * Emitter y position.
		 *
		 * @see #emitterX
		 * @see #emitterObject
		 * @see #emitter
		 */
		public function get emitterY():Number
		{
			return emitter.y;
		}
		
		public function set emitterY(value:Number):void
		{
			emitter.y = value;
		}
		
		/**
		 * Variance of the emitters position.
		 *
		 * @see #emitter
		 * @see #emitterObject
		 * @see #emitterY
		 */
		public function get emitterYVariance():Number
		{
			return mEmitterYVariance;
		}
		
		public function set emitterYVariance(value:Number):void
		{
			mEmitterYVariance = value;
		}
		
		/**
		 * Returns true if the system is currently emitting particles.
		 * @see playing
		 * @see start()
		 * @see stop()
		 */
		public function get emitting():Boolean
		{
			return Boolean(mEmissionTime);
		}
		
		/**
		 * Final particle color.
		 * @see #endColor
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #tinted
		 */
		public function get endColor():ColorArgb
		{
			return mEndColor;
		}
		
		public function set endColor(value:ColorArgb):void
		{
			if (value)
				mEndColor = value;
		}
		
		/**
		 * Variance of final particle color
		 * @see #endColorVariance
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #tinted
		 */
		public function get endColorVariance():ColorArgb
		{
			return mEndColorVariance;
		}
		
		public function set endColorVariance(value:ColorArgb):void
		{
			if (value)
				mEndColorVariance = value;
		}
		
		/**
		 * Final particle rotation in degrees.
		 * @see #endRotationVariance
		 * @see #startRotation
		 * @see #startRotationVariance
		 */
		public function get endRotation():Number
		{
			return mEndRotation;
		}
		
		public function set endRotation(value:Number):void
		{
			mEndRotation = value;
		}
		
		/**
		 * Variation of final particle rotation in degrees.
		 * @see #endRotation
		 * @see #startRotation
		 * @see #startRotationVariance
		 */
		public function get endRotationVariance():Number
		{
			return mEndRotationVariance;
		}
		
		public function set endRotationVariance(value:Number):void
		{
			mEndRotationVariance = value;
		}
		
		/**
		 * Final particle size in pixels.
		 *
		 * The size is calculated according to the width of the texture.
		 * If the particle is animated and SubTextures have differnt dimensions, the size is
		 * based on the width of the first frame.
		 *
		 * @see #endSizeVariance
		 * @see #startSize
		 * @see #startSizeVariance
		 */
		public function get endSize():Number
		{
			return mEndSize;
		}
		
		public function set endSize(value:Number):void
		{
			mEndSize = value;
		}
		
		/**
		 * Variance of the final particle size in pixels.
		 * @see #endSize
		 * @see #startSize
		 * @see #startSizeVariance
		 */
		public function get endSizeVariance():Number
		{
			return mEndSizeVariance;
		}
		
		public function set endSizeVariance(value:Number):void
		{
			mEndSizeVariance = value;
		}
		
		/**
		 * Whether the bounds of the particle system will be calculated or set to screen size.
		 * The bounds will be used for clipping while rendering, therefore depending on the size;
		 * the number of particles; applied filters etc. this setting might in-/decrease performance.
		 *
		 * Keep in mind:
		 * - that the bounds of batches will be united.
		 * - filters may have to change the texture size (performance impact)
		 *
		 * @see #getBounds()
		 */
		public function get exactBounds():Boolean
		{
			return mExactBounds;
		}
		
		public function set exactBounds(value:Boolean):void
		{
			mBounds = value ? new Rectangle() : null;
			mExactBounds = value;
		}
		
		/**
		 * The time to fade in spawning particles; set as percentage according to it's livespan.
		 */
		public function get fadeInTime():Number
		{
			return mFadeInTime;
		}
		
		public function set fadeInTime(value:Number):void
		{
			mFadeInTime = Math.max(0, Math.min(value, 1));
		}
		
		/**
		 * The time to fade out dying particles; set as percentage according to it's livespan.
		 */
		public function get fadeOutTime():Number
		{
			return mFadeOutTime;
		}
		
		public function set fadeOutTime(value:Number):void
		{
			mFadeOutTime = Math.max(0, Math.min(value, 1));
		}
		
		/**
		 * The horizontal gravity value.
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get gravityX():Number
		{
			return mGravityX;
		}
		
		public function set gravityX(value:Number):void
		{
			mGravityX = value;
		}
		
		/**
		 * The vertical gravity value.
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get gravityY():Number
		{
			return mGravityY;
		}
		
		public function set gravityY(value:Number):void
		{
			mGravityY = value;
		}
		
		/**
		 * Lifespan of each particle in seconds.
		 * Setting this value also affects the emissionRate which is calculated in the following way
		 *
		 * 		emissionRate = maxNumParticles / mLifespan
		 *
		 * @see #emissionRate
		 * @see #maxNumParticles
		 * @see #lifespanVariance
		 */
		public function get lifespan():Number
		{
			return mLifespan;
		}
		
		public function set lifespan(value:Number):void
		{
			mLifespan = Math.max(0.01, value);
			mLifespanVariance = Math.min(mLifespan, mLifespanVariance);
			updateEmissionRate();
		}
		
		/**
		 * Variance of the particles lifespan.
		 * Setting this value does NOT affect the emissionRate.
		 * @see #lifespan
		 */
		public function get lifespanVariance():Number
		{
			return mLifespanVariance;
		}
		
		public function set lifespanVariance(value:Number):void
		{
			mLifespanVariance = Math.min(mLifespan, value);
			;
		}
		
		/**
		 * The maximum number of particles processed by the system.
		 * It has to be a value between 1 and 16383, however it can never be bigger than maxNumParticles.
		 * @see #maxNumParticles
		 */
		public function get maxCapacity():uint
		{
			return mMaxCapacity;
		}
		
		public function set maxCapacity(value:uint):void
		{
			mMaxCapacity = Math.min(MAX_CAPACITY, maxNumParticles, value);
		}
		
		/**
		 * The maximum number of particles taken from the particle pool between 1 and 16383
		 * Changeing this value while the system is running may impact performance.
		 *
		 * @see #maxCapacity
		 */
		public function get maxNumParticles():uint
		{
			return mMaxNumParticles;
		}
		
		public function set maxNumParticles(value:uint):void
		{
			returnParticlesToPool();
			mMaxCapacity = Math.min(MAX_CAPACITY, value);
			mMaxNumParticles = maxCapacity;
			var success:Boolean = getParticlesFromPool();
			if (!success)
				stop();
			
			updateEmissionRate();
		}
		
		/**
		 * The maximum emitter radius.
		 * @see #maxRadiusVariance
		 * @see #EMITTER_TYPE_RADIAL
		 */
		public function get maxRadius():Number
		{
			return mMaxRadius;
		}
		
		public function set maxRadius(value:Number):void
		{
			mMaxRadius = value;
		}
		
		/**
		 * Variance of the emitter's maximum radius.
		 * @see #maxRadius
		 * @see #EMITTER_TYPE_RADIAL
		 */
		public function get maxRadiusVariance():Number
		{
			return mMaxRadiusVariance;
		}
		
		public function set maxRadiusVariance(value:Number):void
		{
			mMaxRadiusVariance = value;
		}
		
		/**
		 * The minimal emitter radius.
		 * @see #EMITTER_TYPE_RADIAL
		 */
		public function get minRadius():Number
		{
			return mMinRadius;
		}
		
		public function set minRadius(value:Number):void
		{
			mMinRadius = value;
		}
		
		/**
		 * The minimal emitter radius variance.
		 * @see #EMITTER_TYPE_RADIAL
		 */
		public function get minRadiusVariance():Number
		{
			return mMinRadiusVariance;
		}
		
		public function set minRadiusVariance(value:Number):void
		{
			mMinRadiusVariance = value;
		}
		
		/**
		 * The number of unused particles remaining in the particle pool.
		 */
		public static function get particlesInPool():uint
		{
			return sParticlePool.length;
		
		}
		
		/**
		 * Whether the system is playing or paused.
		 *
		 * <p><strong>Note:</strong> If you're not using automaticJugglermanagement the returned value may be wrong.</p>
		 * @see emitting
		 */
		public function get playing():Boolean
		{
			return mPlaying;
		}
		
		/**
		 * The number of all particles created for the particle pool.
		 */
		public static function get poolSize():uint
		{
			return sPoolSize;
		}
		
		/**
		 * Overrides the standard premultiplied alpha value set by the system.
		 */
		public function get premultipliedAlpha():Boolean
		{
			return mPremultipliedAlpha;
		}
		
		public function set premultipliedAlpha(value:Boolean):void
		{
			mPremultipliedAlpha = value;
		}
		
		/**
		 * Radial acceleration of particles.
		 * @see #radialAccelerationVariance
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get radialAcceleration():Number
		{
			return mRadialAcceleration;
		}
		
		public function set radialAcceleration(value:Number):void
		{
			mRadialAcceleration = value;
		}
		
		/**
		 * Variation of the particles radial acceleration.
		 * @see #radialAcceleration
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get radialAccelerationVariance():Number
		{
			return mRadialAccelerationVariance;
		}
		
		public function set radialAccelerationVariance(value:Number):void
		{
			mRadialAccelerationVariance = value;
		}
		
		/**
		 * If this property is set to a number, new initiated particles will start at a random frame.
		 * This can be done even though isAnimated is false.
		 */
		public function get randomStartFrames():Boolean
		{
			return mRandomStartFrames;
		}
		
		public function set randomStartFrames(value:Boolean):void
		{
			mRandomStartFrames = value;
		}
		
		/**
		 * Particles rotation per second in degerees.
		 * @see #rotatePerSecondVariance
		 */
		public function get rotatePerSecond():Number
		{
			return mRotatePerSecond;
		}
		
		public function set rotatePerSecond(value:Number):void
		{
			mRotatePerSecond = value;
		}
		
		/**
		 * Variance of the particles rotation per second in degerees.
		 * @see #rotatePerSecond
		 */
		public function get rotatePerSecondVariance():Number
		{
			return mRotatePerSecondVariance;
		}
		
		public function set rotatePerSecondVariance(value:Number):void
		{
			mRotatePerSecondVariance = value;
		}
		
		/**
		 *  Sets the smoothing of the texture.
		 *  It's not recommended to change this value.
		 *  @default TextureSmoothing.BILINEAR
		 */
		public function get smoothing():String
		{
			return mSmoothing;
		}
		
		public function set smoothing(value:String):void
		{
			if (TextureSmoothing.isValid(value))
				mSmoothing = value;
		}
		
		/**
		 * A custom function that can be set to sort the Vector of particles.
		 * It will only be called if particles get added/removed.
		 * Anyway it should only be applied if absolutely necessary.
		 * Keep in mind, that it sorts the complete Vector.<Particle> and not just the active particles!
		 *
		 * @default undefined
		 * @see Vector#sort()
		 */
		public function set sortFunction(func:Function):void
		{
			mSortFunction = func;
		}
		
		public function get sortFunction():Function
		{
			return mSortFunction;
		}
		
		/**
		 * The particles start color.
		 * @see #startColorVariance
		 * @see #endColor
		 * @see #endColorVariance
		 * @see #tinted
		 */
		public function get startColor():ColorArgb
		{
			return mStartColor;
		}
		
		public function set startColor(value:ColorArgb):void
		{
			if (value)
				mStartColor = value;
		}
		
		/**
		 * Variance of the particles start color.
		 * @see #startColor
		 * @see #endColor
		 * @see #endColorVariance
		 * @see #tinted
		 */
		public function get startColorVariance():ColorArgb
		{
			return mStartColorVariance;
		}
		
		public function set startColorVariance(value:ColorArgb):void
		{
			if (value)
				mStartColorVariance = value;
		}
		
		/**
		 * The particles start size.
		 *
		 * The size is calculated according to the width of the texture.
		 * If the particle is animated and SubTextures have differnt dimensions, the size is
		 * based on the width of the first frame.
		 *
		 * @see #startSizeVariance
		 * @see #endSize
		 * @see #endSizeVariance
		 */
		public function get startSize():Number
		{
			return mStartSize;
		}
		
		public function set startSize(value:Number):void
		{
			mStartSize = value;
		}
		
		/**
		 * Variance of the particles start size.
		 * @see #startSize
		 * @see #endSize
		 * @see #endSizeVariance
		 */
		public function get startSizeVariance():Number
		{
			return mStartSizeVariance;
		}
		
		public function set startSizeVariance(value:Number):void
		{
			mStartSizeVariance = value;
		}
		
		/**
		 * Start rotation of the particle in degrees.
		 * @see #startRotationVariance
		 * @see #endRotation
		 * @see #endRotationVariance
		 */
		public function get startRotation():Number
		{
			return mStartRotation;
		}
		
		public function set startRotation(value:Number):void
		{
			mStartRotation = value;
		}
		
		/**
		 * Variation of the particles start rotation in degrees.
		 * @see #startRotation
		 * @see #endRotation
		 * @see #endRotationVariance
		 */
		public function get startRotationVariance():Number
		{
			return mStartRotationVariance;
		}
		
		public function set startRotationVariance(value:Number):void
		{
			mStartRotationVariance = value;
		}
		
		/**
		 * The time to scale new born particles from 0 to it's actual size; set as percentage according to it's livespan.
		 */
		public function get spawnTime():Number
		{
			return mSpawnTime;
		}
		
		public function set spawnTime(value:Number):void
		{
			mSpawnTime = Math.max(0, Math.min(value, 1));
		}
		
		/**
		 * The particles velocity in pixels.
		 * @see #speedVariance
		 */
		public function get speed():Number
		{
			return mSpeed;
		}
		
		public function set speed(value:Number):void
		{
			mSpeed = value;
		}
		
		/**
		 * Variation of the particles velocity in pixels.
		 * @see #speed
		 */
		public function get speedVariance():Number
		{
			return mSpeedVariance;
		}
		
		public function set speedVariance(value:Number):void
		{
			mSpeedVariance = value;
		}
		
		/**
		 * Tangential acceleration of particles.
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get tangentialAcceleration():Number
		{
			return mTangentialAcceleration;
		}
		
		public function set tangentialAcceleration(value:Number):void
		{
			mTangentialAcceleration = value;
		}
		
		/**
		 * Variation of the particles tangential acceleration.
		 * @see #EMITTER_TYPE_GRAVITY
		 */
		public function get tangentialAccelerationVariance():Number
		{
			return mTangentialAccelerationVariance;
		}
		
		public function set tangentialAccelerationVariance(value:Number):void
		{
			mTangentialAccelerationVariance = value;
		}
		
		/**
		 * The Texture/SubTexture which has been passed to the constructor.
		 */
		public function get texture():Texture
		{
			return mTexture;
		}
		
		/**
		 * Enables/Disables particle coloring
		 * @see #startColor
		 * @see #startColorVariance
		 * @see #endColor
		 * @see #endColorVariance
		 */
		public function get tinted():Boolean
		{
			return mTinted;
		}
		
		public function set tinted(value:Boolean):void
		{
			mTinted = value;
		}
		
		/**
		 * Juggler to use when <a href="#automaticJugglerManagement">automaticJugglerManagement</a>
		 * is active.
		 * @see #automaticJugglerManagement
		 */
		public function get juggler():Juggler
		{
			return mJuggler;
		}
		
		public function set juggler(value:Juggler):void
		{
			// Not null and different required
			if (value == null || value == mJuggler)
				return;
			
			// Remove from current and add to new if needed
			if (mJuggler.contains(this))
			{
				mJuggler.remove(this);
				value.add(this);
			}
			
			mJuggler = value;
		}
	
	}
}
