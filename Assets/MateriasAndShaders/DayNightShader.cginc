#include "UnityCG.cginc"

struct vertexInput
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct vertexOutput
{
	float4 vertex : SV_POSITION;
	float2 uv : TEXCOORD0;
	float arrayIndex : TEXCOORD1;
};


float _SliceRange;
float _DarkFactor;

//skybox vertex shader
vertexOutput skyboxVert(vertexInput i)
{
	vertexOutput o;
	o.vertex = UnityObjectToClipPos(i.vertex);
	o.uv = i.uv;
	o.arrayIndex = _SliceRange;
	return o;
}
