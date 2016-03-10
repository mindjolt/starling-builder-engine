/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo {
    import feathers.controls.ButtonGroup;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.layout.AnchorLayout;
    import feathers.layout.FlowLayout;
    import feathers.layout.HorizontalLayout;
    import feathers.layout.TiledRowsLayout;
    import feathers.layout.VerticalLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.utils.describeType;

    import starling.display.Sprite;
    import starling.filters.BlurFilter;
    import starling.utils.AssetManager;

    import starlingbuilder.engine.IUIBuilder;
    import starlingbuilder.engine.UIBuilder;
    import starlingbuilder.engine.localization.DefaultLocalization;
    import starlingbuilder.engine.localization.ILocalization;
    import starlingbuilder.engine.tween.DefaultTweenBuilder;

    public class UIBuilderDemo extends Sprite
    {
        public static const linkers:Array = [AnchorLayout, FlowLayout, HorizontalLayout, VerticalLayout, TiledRowsLayout, BlurFilter];

        private var _assetManager:AssetManager;
        private var _assetMediator:starlingbuilder.demo.AssetMediator;

        public static var uiBuilder:IUIBuilder;
        public static var localization:ILocalization;

        public function UIBuilderDemo()
        {
            _assetManager = new AssetManager();
            _assetMediator = new starlingbuilder.demo.AssetMediator(_assetManager);

            localization = new DefaultLocalization(JSON.parse(new EmbeddedAssets.strings), "en_US");
            uiBuilder = new UIBuilder(_assetMediator, false, null, localization, new DefaultTweenBuilder());

            new MetalWorksMobileTheme(false);

            parseLayouts(starlingbuilder.demo.EmbeddedLayouts, ParsedLayouts);

            _assetManager.enqueue(EmbeddedAssets);
            //_assetManager.enqueue(File.applicationDirectory.resolvePath("textures"));
            _assetManager.loadQueue(function(ratio:Number):void{
                if (ratio == 1)
                {
                    createButtons();
                }
            });
        }

        private function createButtons():void
        {
            var group:ButtonGroup = new ButtonGroup();
            group.dataProvider = new ListCollection(createButtonData());
            addChild(group);
        }

        private function createButtonData():Array
        {
            return [
                {label:"connect popup", triggered:createConnectPopup},
                {label:"mail popup", triggered:createMailPopup},
                {label:"HUD", triggered:createHUD},
                {label:"localization", triggered:createLocalizationTest},
                {label:"tween", triggered:createTweenTest},
                {label:"external layout", triggered:createExternalElement},
                {label:"movie clip", triggered:createMovieClipTest},
                {label:"layout", triggered:createLayoutTest},
                {label:"anchor layout", triggered:createAnchorLayoutTest}
            ]
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

        private function parseLayouts(fromCls:Class, toCls:Class):void
        {
            var name:String;
            var description:XML = describeType(fromCls);
            var constants:XMLList = description..constant;
            for each(var constant:XML in constants)
            {
                name = constant.@name;
                toCls[name] = JSON.parse(new fromCls[name]());
            }
        }
    }
}
