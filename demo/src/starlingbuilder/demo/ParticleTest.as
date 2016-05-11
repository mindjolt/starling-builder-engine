/**
 * Created by hyh on 5/11/16.
 */
package starlingbuilder.demo
{
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    public class ParticleTest extends Sprite
    {
        public function ParticleTest()
        {
            super();
            addChild(UIBuilderDemo.uiBuilder.create(ParsedLayouts.particle_test, false) as Sprite);
            addEventListener(TouchEvent.TOUCH, onTouch);
        }

        private function onTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(this);
            if (touch && touch.phase == TouchPhase.ENDED)
            {
                removeFromParent(true);
            }
        }
    }
}
