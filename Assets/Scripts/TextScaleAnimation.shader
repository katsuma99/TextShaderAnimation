Shader "Custom/TextScaleAnimation" {
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
#pragma target 4.0
#pragma vertex vert
#pragma geometry geo
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

	struct geomIn
	{
		float4 pos   : SV_POSITION;
		fixed4 color : COLOR;
		half2 texcoord  : TEXCOORD0;
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

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		float4 pos = IN.vertex; // Scale(IN.vertex, IN.vertexId);
		OUT.pos = UnityObjectToClipPos(pos);
		OUT.texcoord = IN.texcoord;
		OUT.color = _Color;
		return OUT;
	}

	[maxvertexcount(3)]
	void geo(triangle geomIn In[3], uint primitiveId : SV_PrimitiveID, inout TriangleStream<v2f> TriStream) {
		
		//拡大
		float4 center = (In[0].pos - In[2].pos) * 0.5 + In[2].pos;
		float power = _NormalTime * 1.5;
		int id = primitiveId % 10;
		if (id == 2 || id == 3)
			power *= 0.1 + abs(_CosTime.w) * 0.3;
		else if (id == 4 || id == 5)
			power *= 0.8 - abs(_SinTime.y) * 0.5;
		else if (id == 6 || id == 7)
			power *= 0.2 + abs(_SinTime.y) * 0.4;
		else if (id == 8 || id == 9)
			power *= 0.7 - abs(_CosTime.w) * 0.6;

		In[0].pos = (In[0].pos - center) * (power + 1) + center;
		In[1].pos = (In[1].pos - center) * (power + 1) + center;
		In[2].pos = (In[2].pos - center) * (power + 1) + center;

		TriStream.Append(In[0]);
		TriStream.Append(In[1]);
		TriStream.Append(In[2]);

		// 連続したトライアングルを終了
		TriStream.RestartStrip();
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
		Fallback "Custom/TextScaleAnimation(Legacy)"
}
