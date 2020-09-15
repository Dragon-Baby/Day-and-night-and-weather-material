Shader "Unlit/DayNight"
{
    Properties
    {
        [NoScaleOffset]_FrontTex("Front[+Z] ", 2DArray) = ""{}
        [NoScaleOffset]_BackTex("Back[-Z] ", 2DArray) = ""{}
        [NoScaleOffset]_LeftTex("Left[+X] ", 2DArray) = ""{}
        [NoScaleOffset]_RightTex("Right[-X] ", 2DArray) = ""{}
        [NoScaleOffset]_UpTex("Up[+Y] ", 2DArray) = ""{}
        [NoScaleOffset]_DownTex("Down[-Y] ", 2DArray) = ""{}
        _SliceRange ("Slices", Range(0,6)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            //#pragma require 2darray
            #include "DayNightShader.cginc"
            half4 _FrontTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_FrontTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_FrontTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_FrontTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _FrontTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            #include "DayNightShader.cginc"
            half4 _BackTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_BackTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_BackTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_BackTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _BackTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            #include "DayNightShader.cginc"
            half4 _LeftTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_LeftTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_LeftTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_LeftTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _LeftTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            #include "DayNightShader.cginc"
            half4 _RightTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_RightTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_RightTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_RightTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _RightTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            #include "DayNightShader.cginc"
            half4 _UpTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_UpTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_UpTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_UpTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _UpTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex skyboxVert
            #pragma fragment frag
            #pragma target 2.0
            #include "DayNightShader.cginc"
            half4 _DownTex_HDR;
            UNITY_DECLARE_TEX2DARRAY(_DownTex);
            half4 frag(vertexOutput i):SV_Target
            {
                half4 previousTex = UNITY_SAMPLE_TEX2DARRAY(_DownTex, float3(i.uv, floor(i.arrayIndex)));
                float nextIndex = ceil(i.arrayIndex);
                if(nextIndex == 7.0f)
                {
                    nextIndex = 0.0f;
                }
                half4 nextTex = UNITY_SAMPLE_TEX2DARRAY(_DownTex, float3(i.uv, nextIndex));
                half4 texColor = half4(lerp(previousTex, nextTex, frac(i.arrayIndex)).xyz, 1.0);
                half3 col = DecodeHDR(texColor, _DownTex_HDR);
                return half4(col, 1.0);
            }
            ENDCG
        }
    }
}
