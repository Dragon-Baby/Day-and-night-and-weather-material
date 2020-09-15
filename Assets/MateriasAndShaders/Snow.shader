Shader "Unlit/Snow"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True"}
        Cull Front
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_instancing
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            #pragma target 4.0
            #include "Precipitation.cginc"
            ENDCG
        }
    }
}
