/**
 * Created by hyh on 4/30/16.
 */
package starlingbuilder.extensions.particle
{
    import de.flintfabrik.starling.display.FFParticleSystem;
    import de.flintfabrik.starling.display.FFParticleSystem.SystemOptions;

    import flash.geom.Matrix;
    import flash.geom.Point;

    import flash.geom.Rectangle;

    import starling.display.DisplayObject;

    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.utils.MatrixUtil;

    public class FFParticleSprite extends Sprite
    {
        // helper objects
        private static var sHelperMatrix:Matrix = new Matrix();
        private static var sHelperPoint:Point = new Point();

        private static var _optionCache:Object = {};

        private var _particleId:String;
        private var _texture:Texture;
        private var _config:XML;

        private var _cacheParticle:Boolean = true;

        private var _sprite:FFParticleSystem;

        public function FFParticleSprite()
        {
            super();
        }

        public function get texture():Texture
        {
            return _texture;
        }

        public function set texture(value:Texture):void
        {
            _texture = value;
            createParticle();
        }

        public function get config():XML
        {
            return _config;
        }

        public function set config(value:XML):void
        {
            _config = value;
            createParticle();
        }

        public function get particleId():String
        {
            return _particleId;
        }

        public function set particleId(value:String):void
        {
            _particleId = value;
            createParticle();
        }

        private function createParticle():void
        {
            if (_sprite)
            {
                _sprite.removeFromParent(true);
                _sprite = null;
            }

            if (_texture == null || _config == null || _particleId == null || _particleId == "")
                return;

            _sprite = new FFParticleSystem(getSystemOptions());
            _sprite.touchable = false;
            _sprite.start();
            addChild(_sprite);
        }

        private function getSystemOptions():SystemOptions
        {
            if (!(_particleId in _optionCache) || !_cacheParticle)
            {
                _optionCache[_particleId] = SystemOptions.fromXML(_config, _texture);
            }

            return _optionCache[_particleId];
        }

        public static function addSystemOptions(particleId:String, config:XML, texture:Texture):void
        {
            _optionCache[particleId] = SystemOptions.fromXML(config, texture);
        }

        public static function removeSystemOptions(particleId:String):void
        {
            delete _optionCache[particleId];
        }

        public function get cacheParticle():Boolean
        {
            return _cacheParticle;
        }

        public function set cacheParticle(value:Boolean):void
        {
            _cacheParticle = value;
        }

        override public function getBounds(targetSpace:DisplayObject, out:Rectangle=null):Rectangle
        {
            if (out == null) out = new Rectangle();

            getTransformationMatrix(targetSpace, sHelperMatrix);
            MatrixUtil.transformCoords(sHelperMatrix, 0.0, 0.0, sHelperPoint);
            out.setTo(sHelperPoint.x, sHelperPoint.y, 0, 0);

            return out;
        }
    }
}
