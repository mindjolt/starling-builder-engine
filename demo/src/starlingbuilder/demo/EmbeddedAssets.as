/**
 *  Starling Builder
 *  Copyright 2015 SGN Inc. All Rights Reserved.
 *
 *  This program is free software. You can redistribute and/or modify it in
 *  accordance with the terms of the accompanying license agreement.
 */
package starlingbuilder.demo
{
    public class EmbeddedAssets
    {
        //textures
        [Embed(source="../../../assets/textures/ui.png")]
        public static const ui:Class;

        [Embed(source="../../../assets/textures/ui.xml", mimeType="application/octet-stream")]
        public static const ui_xml:Class;


        //fonts
        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size18_ColorFFFFFF_StrokeA8364B.png")]
        public static const GrilledCheeseBTN_Size18_ColorFFFFFF_StrokeA8364B:Class;

        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size18_ColorFFFFFF_StrokeA8364B.fnt", mimeType="application/octet-stream")]
        public static const GrilledCheeseBTN_Size18_ColorFFFFFF_StrokeA8364B_fnt:Class;

        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size36_ColorFFFFFF.png")]
        public static const GrilledCheeseBTN_Size36_ColorFFFFFF:Class;

        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size36_ColorFFFFFF.fnt", mimeType="application/octet-stream")]
        public static const GrilledCheeseBTN_Size36_ColorFFFFFF_fnt:Class;

        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size36_ColorFFFFFF_StrokeA8364B.png")]
        public static const GrilledCheeseBTN_Size36_ColorFFFFFF_StrokeA8364B:Class;

        [Embed(source="../../../assets/textures/fonts/GrilledCheeseBTN_Size36_ColorFFFFFF_StrokeA8364B.fnt", mimeType="application/octet-stream")]
        public static const GrilledCheeseBTN_Size36_ColorFFFFFF_StrokeA8364B_fnt:Class;

        [Embed(source="../../../assets/textures/fonts/LobsterTwoRegular_Size54_ColorFFFFFF_StrokeAF384E_DropShadow560D1B.png")]
        public static const LobsterTwoRegular_Size54_ColorFFFFFF_StrokeAF384E_DropShadow560D1B:Class;

        [Embed(source="../../../assets/textures/fonts/LobsterTwoRegular_Size54_ColorFFFFFF_StrokeAF384E_DropShadow560D1B.fnt", mimeType="application/octet-stream")]
        public static const LobsterTwoRegular_Size54_ColorFFFFFF_StrokeAF384E_DropShadow560D1B_fnt:Class;


        //localization strings
        [Embed(source="../../../assets/strings.json", mimeType="application/octet-stream")]
        public static const strings:Class;
    }
}
