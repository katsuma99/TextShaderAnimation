Shader "Custom/TextRotateAnimation" {
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
		OUT.pos = UnityObjectToClipPos(IN.vertex);
		OUT.texcoord = IN.texcoord;
		OUT.color = _Color;
		return OUT;
	}

	float4 CalculateCenter(float s, float t, float4 pos1, float4 pos2, float4 pos3) {
		float4 pos = pos1 + (pos2 - pos1) * s + (pos3 - pos1) * t; // ３点の中間位置を求める
		return pos;
	}

	float4 Rotate(float4 pos, uint vertexId) {

		//画面の中心から回転する(変形しているみたいになる)GeometryShaderじゃないとポリゴンの中心わからない
		float Deg2Rad = 0.0174532924;
		int id = vertexId % 8;

		//最大角度(場所によって変える)
		float power = _NormalTime * 50;
		if (id == 0 || id == 1)
			power *= 0.3 + abs(_CosTime.z) * 0.8;
		else if (id == 2 || id == 3)
			power *= 0.2 + abs(_CosTime.z) * 0.1;
		else if (id == 6 || id == 7)
			power *= 0.3 + abs(_SinTime.w) * 0.2;
		float rad = power * Deg2Rad;

		//角度算出
		float4 newPos = pos;
		newPos.x = pos.x * cos(rad) - pos.y * sin(rad);
		newPos.y = pos.x * sin(rad) + pos.y * cos(rad);
		return newPos;
	}

	[maxvertexcount(3)]
	void geo(triangle geomIn In[3], uint primitiveId : SV_PrimitiveID, inout TriangleStream<v2f> TriStream) {

		//回転
		float4 center = (In[0].pos - In[2].pos) * 0.5 + In[2].pos;

		In[0].pos -= center;
		In[1].pos -= center;
		In[2].pos -= center;

		In[0].pos = Rotate(In[0].pos, primitiveId);
		In[1].pos = Rotate(In[1].pos, primitiveId);
		In[2].pos = Rotate(In[2].pos, primitiveId);

		In[0].pos += center;
		In[1].pos += center;
		In[2].pos += center;

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
		Fallback "Custom/TextColorAnimation"
}
