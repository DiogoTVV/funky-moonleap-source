package meta.data;

import flixel.FlxG;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

/*
*	just flixel-demos colorblindness filters but in a class
*/
class ColorBlindFilterManager
{
	public static var filters:Array<BitmapFilter> = [];

	public static function reload()
	{
		var curFilter:String = SaveData.trueSettings.get('Colorblind Filter');

		// no filter :[
		var r:Array<Float> = [1,0,0];
		var g:Array<Float> = [0,1,0];
		var b:Array<Float> = [0,0,1];

        //trace(curFilter);
        switch(curFilter)
        {
            case "protanopia":
                r = [0.567, 0.433, 0];
                g = [0.558, 0.442, 0];
                b = [0,     0.242, 0.758];
            case "protanomaly":
                r = [0.817, 0.183, 0];
                g = [0.333, 0.667, 0];
                b = [0,     0.125, 0.875];
            case "deuteranopia":
                r = [0.625, 0.375, 0];
                g = [0.7,   0.3,   0];
                b = [0,     0,     1.0];
            case "deuteranomaly":
                r = [0.8,   0.2,   0];
                g = [0.258, 0.742, 0];
                b = [0,     0.142, 0.858];
            case "tritanopia":
                r = [0.95, 0.05,  0];
                g = [0,    0.433, 0.567];
                b = [0,    0.475, 0.525];
            case "tritanomaly":
                r = [0.967, 0.033, 0];
                g = [0,     0.733, 0.267];
                b = [0,     0.183, 0.817];
            case "achromatopsia":
                r = [0.299, 0.587, 0.114];
                g = [0.299, 0.587, 0.114];
                b = [0.299, 0.587, 0.114];
            case "achromatomaly":
                r = [0.618, 0.320, 0.062];
                g = [0.163, 0.775, 0.062];
                b = [0.163, 0.320, 0.516];
        }

		var matrix:Array<Float> = [
		    r[0], r[1], r[2], 0, 0,
		    g[0], g[1], g[2], 0, 0,
		    b[0], b[1], b[2], 0, 0,
		       0,    0,    0, 1, 0,
		];

		filters = [];
		filters.push(new ColorMatrixFilter(matrix));
		FlxG.game.filtersEnabled = true;
		FlxG.game.setFilters(filters);
	}
}