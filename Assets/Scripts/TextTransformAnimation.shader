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
		uint vertexId : SV_VertexID;
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

	float4 Rotate(float4 pos,uint vertexId) {

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

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		float4 pos = Rotate(IN.vertex, IN.vertexId);

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
}
