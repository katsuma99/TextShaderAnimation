Shader "Custom/TextColorAnimation" {
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Hue("Hue", Float) = 0
		_Sat("Saturation", Float) = 1
		_Val("Value", Float) = 1
		_NormalTime("NormalizationTime", Float) = 0
		_TextCount("_TextCount", Int) = 1
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 1
	}

		SubShader
	{
		Tags
	{
		"Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent"
		"PreviewType" = "Plane"
		"CanUseSpriteAtlas" = "True"
	}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog{ Mode Off }
		Blend One OneMinusSrcAlpha

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile DUMMY PIXELSNAP_ON
#include "UnityCG.cginc"

		struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR;
		half2 texcoord  : TEXCOORD0;
	};

	fixed4 _Color;
	half _Hue, _Sat, _Val;
	int _TextCount;
	float _NormalTime;

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		float4 pos = IN.vertex;
		OUT.pos = UnityObjectToClipPos(pos);
		OUT.texcoord = IN.texcoord;
		OUT.color = _Color;
		return OUT;
	}

	fixed3 shift_col(fixed3 RGB, half3 shift)
	{
		fixed3 RESULT = fixed3(RGB);
		float VSU = shift.z*shift.y*cos(shift.x*3.14159265 / 180);
		float VSW = shift.z*shift.y*sin(shift.x*3.14159265 / 180);

		RESULT.x = (.299*shift.z + .701*VSU + .168*VSW)*RGB.x
			+ (.587*shift.z - .587*VSU + .330*VSW)*RGB.y
			+ (.114*shift.z - .114*VSU - .497*VSW)*RGB.z;

		RESULT.y = (.299*shift.z - .299*VSU - .328*VSW)*RGB.x
			+ (.587*shift.z + .413*VSU + .035*VSW)*RGB.y
			+ (.114*shift.z - .114*VSU + .292*VSW)*RGB.z;

		RESULT.z = (.299*shift.z - .3*VSU + 1.25*VSW)*RGB.x
			+ (.587*shift.z - .588*VSU - 1.05*VSW)*RGB.y
			+ (.114*shift.z + .886*VSU - .203*VSW)*RGB.z;

		return (RESULT);
	}
	sampler2D _MainTex;

	fixed4 frag(v2f IN) : SV_Target
	{
		fixed4 c = tex2D(_MainTex, IN.texcoord);
		c.rgb = IN.color;
		c.rgb *= c.a;
		float pos = (IN.texcoord.x - 0.5) * 2; //-1^1
		half3 shift = half3(_Hue * _NormalTime * pos + pos * 100, _Sat, _Val); //HSV色空間
		return fixed4(shift_col(c, shift), c.a);
	}
		ENDCG
	}
	}
}
