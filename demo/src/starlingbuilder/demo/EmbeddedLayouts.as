/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo {
    public class EmbeddedLayouts
    {
        [Embed(source="layouts/connect_popup.json", mimeType="application/octet-stream")]
        public static const connect_popup:Class;

        [Embed(source="layouts/mail_popup.json", mimeType="application/octet-stream")]
        public static const mail_popup:Class;

        [Embed(source="layouts/mail_item.json", mimeType="application/octet-stream")]
        public static const mail_item:Class;

        [Embed(source="layouts/hud.json", mimeType="application/octet-stream")]
        public static const hud:Class;

        [Embed(source="layouts/localization_test.json", mimeType="application/octet-stream")]
        public static const localization_test:Class;

        [Embed(source="layouts/tween_test.json", mimeType="application/octet-stream")]
        public static const tween_test:Class;

        [Embed(source="layouts/external_element_test.json", mimeType="application/octet-stream")]
        public static const external_element_test:Class;

        [Embed(source="layouts/movieclip_test.json", mimeType="application/octet-stream")]
        public static const movieclip_test:Class;

        [Embed(source="layouts/layout_test.json", mimeType="application/octet-stream")]
        public static const layout_test:Class;

        [Embed(source="layouts/anchorlayout_test.json", mimeType="application/octet-stream")]
        public static const anchorlayout_test:Class;

        [Embed(source="layouts/containerbutton_test.json", mimeType="application/octet-stream")]
        public static const containerbutton_test:Class;
    }
}
