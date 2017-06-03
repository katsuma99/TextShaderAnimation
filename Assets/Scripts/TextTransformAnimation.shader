Shader "Custom/TextTransformAnimation" {
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
#pragma multi_compile DUMMY PIXELSNAP_ON
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

		struct geomIn
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
			OUT.pos = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;
			OUT.color = _Color;
			return OUT;
		}

		float4 CalculateCenter(float s, float t, float4 pos1, float4 pos2, float4 pos3) {
			float4 pos = pos1 + (pos2 - pos1) * s + (pos3 - pos1) * t; // ３点の中間位置を求める
			return pos;
		}

		[maxvertexcount(3)]
		void geo(triangle geomIn In[3], uint primitiveId : SV_PrimitiveID, inout TriangleStream<v2f> TriStream) {

			//歪み
			float4 center = CalculateCenter(0.5, 0.5, In[0].pos, In[1].pos, In[2].pos);//センター変更:頂点シェーダから、ポリゴンに必要な頂点を求める

			float power = _NormalTime * 2.0;
			if (primitiveId % 5 == 1)
				power *= 0.7 + abs(_CosTime.w) * 0.4;
			else if (primitiveId % 5 == 2)
				power *= 0.3 + abs(_CosTime.y) * 0.5;
			else if (primitiveId % 5 == 3)
				power *= 0.9 + abs(_SinTime.w) * 0.4;
			else if (primitiveId % 5 == 4)
				power *= 0.5 + abs(_CosTime.z) * 0.3;

			In[1].pos = (In[1].pos - center) * (power + 1) + center;

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
	Fallback "Custom/TextTransformAnimation(Legacy)"
}
