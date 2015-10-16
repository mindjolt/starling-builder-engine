/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package {
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
    }
}
