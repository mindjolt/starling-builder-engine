/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
    import com.sgn.starlingbuilder.engine.IAssetMediator;
    import com.sgn.starlingbuilder.engine.IUIBuilder;
    import com.sgn.starlingbuilder.engine.UIBuilder;

    import feathers.controls.ButtonGroup;
    import feathers.core.PopUpManager;
    import feathers.data.ListCollection;
    import feathers.layout.HorizontalLayout;
    import feathers.layout.TiledRowsLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.filesystem.File;
    import flash.utils.describeType;

    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    public class UIBuilderDemo extends Sprite implements IAssetMediator
    {
        public static const linkers:Array = [TiledRowsLayout, HorizontalLayout];

        private var _assetManager:AssetManager;

        public static var uiBuilder:IUIBuilder;

        public function UIBuilderDemo()
        {
            if (uiBuilder == null)
            {
                uiBuilder = new UIBuilder(this);
            }

            new MetalWorksMobileTheme(false);

            parseLayouts(EmbeddedLayouts, ParsedLayouts);

            _assetManager = new AssetManager();
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

        public function getTexture(name:String):Texture
        {
            return _assetManager.getTexture(name);
        }

        public function getExternalData(name:String):Object
        {
            return null;
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
