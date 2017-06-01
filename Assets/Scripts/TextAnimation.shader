Shader "Custom/TextAnimation" {
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
	half _Hue, _Sat, _Val;
	int _TextCount;
	float _NormalTime;

	float4 TransportInterval(float4 pos, uint vertexId) {

		uint geometoryId = vertexId / 4; //ポリゴン番号（Textは左からポリゴンが作られる）
		uint textId = ((_TextCount - 1) - geometoryId); //右からのポリゴン番号:idは0から
		pos.x -= textId * 10 * _NormalTime; //左に行くほどXが離れる

		//番号によってY方向にアクセントつける
		if (textId % 4 == 1)
			pos.y += 30 * _CosTime.w * _NormalTime;
		else if (textId % 4 == 2)
			pos.y -= 8 * _CosTime.z * _NormalTime;
		else if (textId % 4 == 3)
			pos.y += 20 * _SinTime.z * _NormalTime;
		return pos;
	}

	float4 CalculateCenter(float s, float t, float4 pos1, float4 pos2, float4 pos3) {
		float4 pos = pos1 + (pos2 - pos1) * s + (pos3 - pos1) * t; // ３点の中間位置を求める
		return pos;
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
		//power算出
		float extraTime = _NormalTime;
		float power;
		float4 center;

		//拡大
		center = (In[0].pos - In[2].pos) * 0.5 + In[2].pos;//センター変更
		power = extraTime * 1.5;
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

		//歪み
		center = CalculateCenter(0.5, 0.5, In[0].pos, In[1].pos, In[2].pos);//センター変更:頂点シェーダから、ポリゴンに必要な頂点を求める

		if (primitiveId % 5 == 1)
			power *= 0.7 + abs(_CosTime.w) * 0.4;
		else if (primitiveId % 5 == 2)
			power *= 0.3 + abs(_CosTime.y) * 0.5;
		else if (primitiveId % 5 == 3)
			power *= 0.9 + abs(_SinTime.w) * 0.4;
		else if (primitiveId % 5 == 4)
			power *= 0.5 + abs(_CosTime.z) * 0.3;

		In[1].pos = (In[1].pos - center) * (power + 1) + center;


		//回転
		center = (In[0].pos - In[2].pos) * 0.5 + In[2].pos;//センター変更

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
	half3 shift = half3(_Hue * pos + pos * 100, _Sat, _Val); //HSV色空間

	return fixed4(shift_col(c, shift), c.a);
	}
		ENDCG
	}
	}
}
