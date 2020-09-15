#include "UnityCG.cginc"

#if defined(RAIN)
float4x4 rotationMatrix90(float3 axis){
	float ocxy = axis.x * axis.y;
	float oczx = axis.z * axis.x;
	float ocyz = axis.y * axis.z;
	return float4x4(
        axis.x * axis.x, ocxy - axis.z, oczx + axis.y, 0.0,
        ocxy + axis.z, axis.y * axis.y, ocyz - axis.x, 0.0,
        oczx - axis.y, ocyz + axis.x, axis.z * axis.z, 0.0,
        0.0, 0.0, 0.0, 1.0
	);
}
#endif


struct vertexData
{
	float4 vertex : POSITION;
	float4 uv : TEXCOORD0;
	uint instanceID : SV_INSTANCEID;
};

struct geometryOutput
{
	UNITY_POSITION(pos);
	float4 uv : TEXCOORD0;
	UNITY_VERTEX_OUTPUT_STEREO
};

sampler2D _MainTex;

float _GridSize;
float _Amount;
sampler2D _NoiseTex;
float2 _CameraRange;
float _FallSpeed;
float _MaxTravelDistance;

float2 _FlutterFrequency;
float2 _FlutterSpeed;
float2 _FlutterMagnitude;

float4 _Color;
float4 _ColorVariation;
float2 _SizeRange;

float4x4 _WindRotationMatrix;

// VertexShader
vertexData vert(vertexData v)
{
	return v;
}

// Add Vertex
void AddVertex(inout TriangleStream<geometryOutput> stream, float3 vertex, float2 uv, float colorVariation, float opacity)
{
	geometryOutput o;

	UNITY_INITIALIZE_OUTPUT(geometryOutput, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	o.pos = UnityObjectToClipPos(vertex);
	o.uv.xy = uv;
	o.uv.z = opacity;
	o.uv.w = colorVariation;

	stream.Append(o);
}

// Create Quad
void CreateQuad(inout TriangleStream<geometryOutput> stream, float3 bottomMiddle, float3 topMiddle, float3 prepDir, float colorVariation, float opacity)
{
	AddVertex(stream, bottomMiddle - prepDir, float2(0,0), colorVariation, opacity);
	AddVertex(stream, bottomMiddle + prepDir, float2(1,0), colorVariation, opacity);
	AddVertex(stream, topMiddle - prepDir, float2(0,1), colorVariation, opacity);
	AddVertex(stream, topMiddle + prepDir, float2(1,1), colorVariation, opacity);
	stream.RestartStrip();
}

#if defined(RAIN)
[maxvertexcount(8)]	//rain draws 2 quads
#else
[maxvertexcount(4)]	//snow draws one quad with billboard technique
#endif

// GeometryShader
void geom(point vertexData IN[1], inout TriangleStream<geometryOutput> stream)
{
	vertexData v = IN[0];

	UNITY_SETUP_INSTANCE_ID(v);

	float3 pos = v.vertex.xyz;

	pos.xz *= _GridSize;
	
	float2 noise = float2(
        frac(tex2Dlod(_NoiseTex, float4(v.uv.xy , 0, 0)).r + (pos.x + pos.z)), 
        frac(tex2Dlod(_NoiseTex, float4(v.uv.yx * 2, 0, 0)).r + (pos.x * pos.z)));

	float vertexAmountThreshold = v.uv.z;
	vertexAmountThreshold *= noise.y;
	if(vertexAmountThreshold > _Amount)
	{
		return;
	}

	float3x3 windRotation = (float3x3)_WindRotationMatrix;
	float3 rotatedVertexOffset = mul(windRotation, pos) - pos;

	pos.y -= (_Time.y + 10000)*(_FallSpeed + (_FallSpeed * noise.y));
	float2 inside = pos.y * noise.yx * _FlutterFrequency + ((_FlutterFrequency + (_FlutterSpeed * noise)) * _Time.y);
	float2 flutter = float2(sin(inside.x), cos(inside.y)) * _FlutterMagnitude;
	pos.xz += flutter;
	pos.y = fmod(pos.y, _MaxTravelDistance) + noise.x;
	pos = mul(windRotation, pos);
	pos -= rotatedVertexOffset;
	pos.y += _GridSize * 0.5;

	float3 worldPos = pos + float3(unity_ObjectToWorld[0].w, unity_ObjectToWorld[1].w, unity_ObjectToWorld[2].w);

	float3 posToCamera = worldPos - _WorldSpaceCameraPos;
	float distanceToCamera = length(posToCamera);

	posToCamera /= distanceToCamera;

	float3 camForward = normalize(mul((float3x3)unity_CameraToWorld, float3(0,0,1)));

	if(dot(camForward, posToCamera) < 0.5)
	{
		return;
	}

	float opacity = 1.0;

	float cameraDistanceInterpolation = 1.0 - min(max(distanceToCamera- _CameraRange.x, 0)/(_CameraRange.y - _CameraRange.x),1);
	opacity *= cameraDistanceInterpolation;

	#define VERTEX_THRESHOLD_LEVELS 4
	float vertexAmountThresholdFade = min((_Amount - vertexAmountThreshold)*VERTEX_THRESHOLD_LEVELS, 1);
	opacity *= vertexAmountThresholdFade;
	if(opacity <= 0)
	{
		return;
	}

	float colorVariation = (sin(noise.x * (pos.x + pos.y * noise.y + pos.z + _Time.y * 2)) * 0.5 + 0.5) * _ColorVariation.a;
	float2 quadSize = lerp(_SizeRange.x, _SizeRange.y, noise.x);

#if defined(RAIN)
	quadSize.x *= 0.01;
	quadSize.y *= 0.5;
	float3 quadUpDirection = mul(windRotation, float3(0,1,0));
	float3 topMiddle = pos + quadUpDirection * quadSize.y;
	float3 rightDirection = float3(0.5 * quadSize.x, 0, 0);
#else
	float3 quadUpDirection = UNITY_MATRIX_IT_MV[1].xyz;
	float3 topMiddle = pos + quadUpDirection * quadSize.y;
	float3 rightDirection = UNITY_MATRIX_IT_MV[0].xyz * 0.5 * quadSize.x;
#endif
	CreateQuad(stream, pos, topMiddle, rightDirection, colorVariation, opacity);

#if defined(RAIN)
    rightDirection = mul((float3x3)rotationMatrix90(quadUpDirection), rightDirection);
    CreateQuad (stream, pos, topMiddle, rightDirection, colorVariation, opacity);
#endif
}

//Fragment Shader
float4 frag(geometryOutput i) : SV_Target
{
	float4 color = tex2D(_MainTex, i.uv.xy) * _Color;

	float colorVariationAmount = i.uv.w;
	float3 shiftedColor = lerp(color.rgb, _ColorVariation.rgb, colorVariationAmount);
	float maxBase = max(color.r, max(color.g, color.b));
	float newMaxBase = max(shiftedColor.r, max(shiftedColor.g, shiftedColor.b));
	color.rgb = saturate(shiftedColor.r * ((maxBase / newMaxBase) * 0.5 + 0.5));

	color.a *= i.uv.z;
	return color;
}