package shaders;

import flixel.system.FlxAssets.FlxShader;

// basically same shit as haxeflixel demo
// but i made some changes to the variables
class MosaicShader
{
	public var shader(default, null):MosaicShaderData = new MosaicShaderData();
	
	public var strength(default, set):Float = 1;

	public function new() {}
	
	function set_strength(v:Float):Float
    {
        strength = v;
        shader.uBlocksize.value = [strength, strength];
        return v;
    }
}

/**
 * A classic mosaic effect, just like in the old days!
 *
 * Usage notes:
 * - The effect will be applied to the whole screen.
 * - Set the x/y-values on the 'uBlocksize' vector to the desired size (setting this to 0 will make the screen go black)
 */
class MosaicShaderData extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec2 uBlocksize;

		void main()
		{
			vec2 blocks = openfl_TextureSize / uBlocksize;
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new()
	{
		super();
	}
}
