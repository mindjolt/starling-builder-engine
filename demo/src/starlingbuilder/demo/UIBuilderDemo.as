/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo {
    import feathers.controls.List;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.FlowLayout;
    import feathers.layout.HorizontalLayout;
    import feathers.layout.TiledRowsLayout;
    import feathers.layout.VerticalLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;
    import starling.filters.BlurFilter;
    import starling.utils.AssetManager;

    import starlingbuilder.engine.IUIBuilder;
    import starlingbuilder.engine.LayoutLoader;
    import starlingbuilder.engine.UIBuilder;
    import starlingbuilder.engine.localization.DefaultLocalization;
    import starlingbuilder.engine.localization.ILocalization;
    import starlingbuilder.engine.tween.DefaultTweenBuilder;
    import starlingbuilder.extensions.particle.FFParticleSprite;

    public class UIBuilderDemo extends Sprite
    {
        public static const SHOW_POPUP:String = "showPopup";
        public static const SHOW_LIST:String = "showList";
        public static const SHOW_HUD:String = "showHUD";
        public static const SHOW_LOCALIZATION:String = "showLocalization";
        public static const SHOW_TWEEN:String = "showTween";
        public static const SHOW_EXTERNAL_ELEMENT:String = "showExternalElement";
        public static const SHOW_MOVIE_CLIP:String = "showMovieClip";
        public static const SHOW_LAYOUT:String = "showLayout";
        public static const SHOW_ANCHOR_LAYOUT:String = "showAnchorLayout";
        public static const SHOW_CONTAINER_BUTTON:String = "showContainerButton";
        public static const SHOW_PARTICLE_BUTTON:String = "showParticleButton";

        public static const linkers:Array = [AnchorLayout, FlowLayout, HorizontalLayout, VerticalLayout, TiledRowsLayout, BlurFilter, FFParticleSprite];

        private var _assetMediator:starlingbuilder.demo.AssetMediator;

        public static var uiBuilder:IUIBuilder;
        public static var assetManager:AssetManager;

        public function UIBuilderDemo()
        {
            assetManager = new AssetManager();
            _assetMediator = new starlingbuilder.demo.AssetMediator(assetManager);

            var localization:ILocalization = new DefaultLocalization(JSON.parse(new EmbeddedAssets.strings), "en_US");
            uiBuilder = new UIBuilder(_assetMediator, false, null, localization, new DefaultTweenBuilder());
            uiBuilder.localizationHandler = new LocalizationHandler();

            new MetalWorksMobileTheme(false);

            var loader:LayoutLoader = new LayoutLoader(starlingbuilder.demo.EmbeddedLayouts, ParsedLayouts);

            assetManager.enqueue(EmbeddedAssets);
            //assetManager.enqueue(File.applicationDirectory.resolvePath("textures"));
            assetManager.loadQueue(function(ratio:Number):void{
                if (ratio == 1)
                {
                    createButtons();
                }
            });
        }

        private function createButtons():void
        {
            var list:List = new List();
            list.dataProvider = new ListCollection(createButtonData());
            list.addEventListener(Event.TRIGGERED, onListTrigger);
            list.width = Starling.current.stage.stageWidth;
            list.height = Starling.current.stage.stageHeight;

            addChild(list);
        }

        private function createButtonData():Array
        {
            return [
                {label:"popup", event:SHOW_POPUP},
                {label:"list", event:SHOW_LIST},
                {label:"HUD", event:SHOW_HUD},
                {label:"localization", event:SHOW_LOCALIZATION},
                {label:"tween", event:SHOW_TWEEN},
                {label:"external element", event:SHOW_EXTERNAL_ELEMENT},
                {label:"movie clip", event:SHOW_MOVIE_CLIP},
                {label:"layout", event:SHOW_LAYOUT},
                {label:"anchor layout", event:SHOW_ANCHOR_LAYOUT},
                {label:"container button", event:SHOW_CONTAINER_BUTTON},
                {label:"particle", event:SHOW_PARTICLE_BUTTON}
            ]
        }

        private function onListTrigger(event:Event):void
        {
            var list:List = event.target as List;
            var type:String = list.selectedItem.event;

            switch (type)
            {
                case SHOW_POPUP:
                    createConnectPopup();
                    break;
                case SHOW_LIST:
                    createMailPopup();
                    break;
                case SHOW_HUD:
                    createHUD();
                    break;
                case SHOW_LOCALIZATION:
                    createLocalizationTest();
                    break;
                case SHOW_TWEEN:
                    createTweenTest();
                    break;
                case SHOW_EXTERNAL_ELEMENT:
                    createExternalElement();
                    break;
                case SHOW_MOVIE_CLIP:
                    createMovieClipTest();
                    break;
                case SHOW_LAYOUT:
                    createLayoutTest();
                    break;
                case SHOW_ANCHOR_LAYOUT:
                    createAnchorLayoutTest();
                    break;
                case SHOW_CONTAINER_BUTTON:
                    createContainerButtonTest();
                    break;
                case SHOW_PARTICLE_BUTTON:
                    createParticleTest();
                    break;
            }

            list.selectedIndex = -1;
        }

        private function createConnectPopup():void
        {
            var popup:ConnectPopup = new ConnectPopup();
            PopUpManager.addPopUp(popup);
        }

        private function createMailPopup():void
        {
            var popup:MailPopup = new MailPopup();
            PopUpManager.addPopUp(popup);
        }

        private function createHUD():void
        {
            var hud:HUD = new HUD();
            addChild(hud);
        }

        private function createLocalizationTest():void
        {
            var test:LocalizationTest = new LocalizationTest();
            addChild(test);
        }

        private function createTweenTest():void
        {
            var test:TweenTest = new TweenTest();
            addChild(test);
        }

        private function createExternalElement():void
        {
            var test:ExternalElementTest = new ExternalElementTest();
            addChild(test);
        }

        private function createMovieClipTest():void
        {
            var test:MovieClipTest = new MovieClipTest();
            addChild(test);
        }

        private function createLayoutTest():void
        {
            var test:LayoutTest = new LayoutTest();
            addChild(test);
        }

        private function createAnchorLayoutTest():void
        {
            var test:AnchorLayoutTest = new AnchorLayoutTest();
            addChild(test);
        }

        private function createContainerButtonTest():void
        {
            var popup:ContainerButtonPopup = new ContainerButtonPopup();
            PopUpManager.addPopUp(popup);
        }

        private function createParticleTest():void
        {
            var test:ParticleTest = new ParticleTest();
            addChild(test);
        }
    }
}
