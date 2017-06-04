Shader "Custom/TextMoveYAnimation" {
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

	float4 TransportInterval(float4 pos, uint vertexId) {

		float4 newPos = pos;
		uint geometoryId = vertexId / 4;
		uint textId = ((_TextCount - 1) - geometoryId);

		if (textId % 4 == 1)
			newPos.y += 30 * _CosTime.w * _NormalTime;
		else if (textId % 4 == 2)
			newPos.y -= 8 * _CosTime.z * _NormalTime;
		else if (textId % 4 == 3)
			newPos.y += 20 * _SinTime.z * _NormalTime;
		return newPos;
	}

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		float4 pos = IN.vertex;
		pos = TransportInterval(pos, IN.vertexId);

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
