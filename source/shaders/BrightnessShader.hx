package shaders;

import flixel.system.FlxAssets.FlxShader;

class BrightnessShader
{
	public var shader(default, null):BrightnessShaderData = new BrightnessShaderData();
	public var value(default, set):Float = 0;
	public function new() {}
	function set_value(v:Float):Float
	{
		value = v;
		shader.brightness.value = [value];
		return v;
	}
}

class BrightnessShaderData extends FlxShader
{
	@:glFragmentSource('
	#pragma header
	uniform float brightness;
	void main() {
		vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
		if(color.a == 0) {
			gl_FragColor = vec4(0, 0, 0, 0);
		} else {
			float daR = color.r + ((1 - color.r) * brightness);
			float daG = color.g + ((1 - color.g) * brightness);
			float daB = color.b + ((1 - color.b) * brightness);
			gl_FragColor = vec4(daR, daG, daB, color.a);
		}
	}')
	public function new() {
		super();
	}
}