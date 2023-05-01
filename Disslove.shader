Shader "Unlit/Disslove"
{
    Properties
    {
        _MainTex ( "Texture", 2D ) = "white" {}
	    _NoiseTex( "Noise", 2D ) = "white" {}
	    _ClipAmount( "ClipAmount", Range( 0, 1 ) ) = 0.2
	    [HDR]_LineColor( "LineColor", color ) = (1,1,1,1)
	    _LineWidth( "LineWidth", float ) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
	    Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
	    sampler2D _NoiseTex;
            float4 _MainTex_ST;

	    float _ClipAmount;
	    fixed4 _LineColor;
	    float _LineWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 noise = tex2D(_NoiseTex, i.uv).rgb;
		clip(noise.r - _ClipAmount);
		fixed minus = noise.r - _ClipAmount;
		fixed4 lineC = fixed4(0,0,0,0);
		float t = 0;
		float m = 1 / _LineWidth;
		if(minus < _LineWidth)
                {
			t = minus * m;
			lineC = _LineColor * t;				
		}

                fixed4 col = tex2D(_MainTex, i.uv);
		fixed4 c = lerp(col, lineC, t);

                return c;
            }
            ENDCG
        }
    }
}