Shader "Custom/TextScaleAnimation(Legacy)" {
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
	_Color("Color", Color) = (1,1,1,1)
		_NormalTime("NormalizationTime", Float) = 0
		_TextCount("_TextCount", Int) = 1
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 1
	}

		SubShader
	{

		Cull Back
		Lighting Off
		AlphaToMask On

		Pass
	{
		CGPROGRAM
#pragma target 3.5
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile PIXELSNAP_ON
#include "UnityCG.cginc"

		struct appdata_t
	{
		float4 vertex   : POSITION;
		float4 color    : COLOR;
		float2 texcoord : TEXCOORD0;
		uint vertexId : SV_VertexID;
	};

	struct v2f
	{
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR;
		half2 texcoord  : TEXCOORD0;
	};

	fixed4 _Color;
	int _TextCount;
	float _NormalTime;

	float4 Scale(float4 pos, uint vertexId) {
		float power = _NormalTime * _NormalTime * (10 + abs(_CosTime.w) * 10);
		uint geoId = uint(vertexId / 4.0);//vertexId / 4; int割りできない 
		if (geoId % 2 == 1)
			power *= 0.4;

		float transX = power;
		float transY = power;
		if (vertexId % 4 == 0 || vertexId % 4 == 3)
		{
			transX *= -1;
		}
		if (vertexId % 4 == 2 || vertexId % 4 == 3)
		{
			transY *= -1;
		}

		float4 newPos = pos;
		newPos.x += transX;
		newPos.y += transY;
		return newPos;
	}

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		float4 pos = Scale(IN.vertex, IN.vertexId);
		OUT.pos = UnityObjectToClipPos(pos);
		OUT.texcoord = IN.texcoord;
		OUT.color = _Color;
		return OUT;
	}

	sampler2D _MainTex;

	fixed4 frag(v2f IN) : SV_Target
	{
		fixed4 c = tex2D(_MainTex, IN.texcoord);
	c.rgb = IN.color;
	c.rgb *= c.a;
	return c;
	}
		ENDCG
	}
	}
		Fallback "Custom/TextMoveAnimation(Legacy)"
}
