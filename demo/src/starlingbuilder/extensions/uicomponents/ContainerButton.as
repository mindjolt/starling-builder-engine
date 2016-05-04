/**
 * Created by hyh on 4/24/16.
 */
package starlingbuilder.extensions.uicomponents
{
    import flash.geom.Rectangle;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;

    import starling.display.ButtonState;
    import starling.display.DisplayObject;

    import starling.display.DisplayObjectContainer;
    import starling.display.Sprite;

    import starling.events.Event;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import starlingbuilder.engine.util.DisplayObjectUtil;

    /** Dispatched when the user triggers the button. Bubbles. */
    [Event(name="triggered", type="starling.events.Event")]

    /**
     * A button as a container, you can layout whatever you want inside ContainerButton
     */
    public class ContainerButton extends DisplayObjectContainer
    {
        private static const MAX_DRAG_DIST:Number = 50;

        private static var sRect:Rectangle = new Rectangle();

        private var mContents:Sprite;

        private var mScaleWhenDown:Number;
        private var mScaleWhenOver:Number;
        private var mAlphaWhenDown:Number;
        private var mAlphaWhenDisabled:Number;
        private var mUseHandCursor:Boolean;
        private var mEnabled:Boolean;
        private var mState:String;
        private var mTriggerBounds:Rectangle;

        /** Creates a button with a set of state-textures and (optionally) some text.
         *  Any state that is left 'null' will display the up-state texture. Beware that all
         *  state textures should have the same dimensions. */
        public function ContainerButton()
        {
            mState = ButtonState.UP;
            mScaleWhenDown = 0.9;
            mScaleWhenOver = mAlphaWhenDown = 1.0;
            mAlphaWhenDisabled = 0.5;
            mEnabled = true;
            mUseHandCursor = true;
            mTriggerBounds = new Rectangle();

            mContents = new Sprite();
            super.addChildAt(mContents, 0);
            addEventListener(TouchEvent.TOUCH, onTouch);
        }

        /** @inheritDoc */
        public override function dispose():void
        {
            mContents.dispose();
            super.dispose();
        }

        private function onTouch(event:TouchEvent):void
        {
            Mouse.cursor = (mUseHandCursor && mEnabled && event.interactsWith(this)) ?
                    MouseCursor.BUTTON : MouseCursor.AUTO;

            var touch:Touch = event.getTouch(this);
            var isWithinBounds:Boolean;

            if (!mEnabled)
            {
                return;
            }
            else if (touch == null)
            {
                state = ButtonState.UP;
            }
            else if (touch.phase == TouchPhase.HOVER)
            {
                state = ButtonState.OVER;
            }
            else if (touch.phase == TouchPhase.BEGAN && mState != ButtonState.DOWN)
            {
                mTriggerBounds = getBounds(stage, mTriggerBounds);
                mTriggerBounds.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);

                state = ButtonState.DOWN;
            }
            else if (touch.phase == TouchPhase.MOVED)
            {
                isWithinBounds = mTriggerBounds.contains(touch.globalX, touch.globalY);

                if (mState == ButtonState.DOWN && !isWithinBounds)
                {
                    // reset button when finger is moved too far away ...
                    state = ButtonState.UP;
                }
                else if (mState == ButtonState.UP && isWithinBounds)
                {
                    // ... and reactivate when the finger moves back into the bounds.
                    state = ButtonState.DOWN;
                }
            }
            else if (touch.phase == TouchPhase.ENDED && mState == ButtonState.DOWN)
            {
                state = ButtonState.UP;
                if (!touch.cancelled) dispatchEventWith(Event.TRIGGERED, true);
            }
        }

        /** The current state of the button. The corresponding strings are found
         *  in the ButtonState class. */
        public function get state():String { return mState; }
        public function set state(value:String):void
        {
            mState = value;
            refreshState();
        }

        private function refreshState():void
        {
            mContents.x = mContents.y = 0;
            mContents.scaleX = mContents.scaleY = mContents.alpha = 1.0;
            mContents.getBounds(this, sRect);

            switch (mState)
            {
                case ButtonState.DOWN:
                    mContents.alpha = mAlphaWhenDown;
                    mContents.scaleX = mContents.scaleY = mScaleWhenDown;
                    mContents.x = (1 - mScaleWhenDown) * (sRect.x + sRect.width * 0.5);
                    mContents.y = (1 - mScaleWhenDown) * (sRect.y + sRect.height * 0.5);
                    break;
                case ButtonState.UP:
                    break;
                case ButtonState.OVER:
                    mContents.scaleX = mContents.scaleY = mScaleWhenOver;
                    mContents.x = (1 - mScaleWhenOver) * (sRect.x + sRect.width * 0.5);
                    mContents.y = (1 - mScaleWhenOver) * (sRect.y + sRect.height * 0.5);
                    break;
                case ButtonState.DISABLED:
                    mContents.alpha = mAlphaWhenDisabled;
                    break;
                default:
                    throw new ArgumentError("Invalid button state: " + mState);
            }
        }



        /** The scale factor of the button on touch. Per default, a button without a down state
         *  texture will be made slightly smaller, while a button with a down state texture
         *  remains unscaled. */
        public function get scaleWhenDown():Number { return mScaleWhenDown; }
        public function set scaleWhenDown(value:Number):void
        {
            mScaleWhenDown = value;
            if (mState == ButtonState.DOWN) refreshState();
        }

        /** The scale factor of the button while the mouse cursor hovers over it. @default 1.0 */
        public function get scaleWhenOver():Number { return mScaleWhenOver; }
        public function set scaleWhenOver(value:Number):void
        {
            mScaleWhenOver = value;
            if (mState == ButtonState.OVER) refreshState();
        }

        /** The alpha value of the button on touch. @default 1.0 */
        public function get alphaWhenDown():Number { return mAlphaWhenDown; }
        public function set alphaWhenDown(value:Number):void
        {
            mAlphaWhenDown = value;
            if (mState == ButtonState.DOWN) refreshState();
        }

        /** The alpha value of the button when it is disabled. @default 0.5 */
        public function get alphaWhenDisabled():Number { return mAlphaWhenDisabled; }
        public function set alphaWhenDisabled(value:Number):void
        {
            mAlphaWhenDisabled = value;
            if (mState == ButtonState.DISABLED) refreshState();
        }

        /** Indicates if the button can be triggered. */
        public function get enabled():Boolean { return mEnabled; }
        public function set enabled(value:Boolean):void
        {
            if (mEnabled != value)
            {
                mEnabled = value;
                state = value ? ButtonState.UP : ButtonState.DISABLED;
            }
        }

        /** Indicates if the mouse cursor should transform into a hand while it's over the button.
         *  @default true */
        public override function get useHandCursor():Boolean { return mUseHandCursor; }
        public override function set useHandCursor(value:Boolean):void { mUseHandCursor = value; }

        override public function get numChildren():int
        {
            return mContents.numChildren;
        }

        override public function getChildByName(name:String):DisplayObject
        {
            return mContents.getChildByName(name);
        }

        override public function getChildAt(index:int):DisplayObject
        {
            return mContents.getChildAt(index);
        }

        override public function addChild(child:DisplayObject):DisplayObject
        {
            return mContents.addChild(child);
        }

        override public function addChildAt(child:DisplayObject, index:int):DisplayObject
        {
            return mContents.addChildAt(child, index);
        }

        override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject
        {
            return mContents.removeChildAt(index, dispose);
        }

        override public function getChildIndex(child:DisplayObject):int
        {
            return mContents.getChildIndex(child);
        }

        override public function setChildIndex(child:DisplayObject, index:int):void
        {
            mContents.setChildIndex(child, index);
        }

        override public function swapChildrenAt(index1:int,index2:int):void
        {
            mContents.swapChildrenAt(index1, index2);
        }

        override public function sortChildren(compareFunction:Function):void
        {
            mContents.sortChildren(compareFunction);
        }
    }
}