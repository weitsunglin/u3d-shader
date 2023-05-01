Shader "Unlit/waifaguangVertex" 
{
    // 屬性
    Properties
    {
        _MainTex(" Texture(RGB) ", 2D ) = "blue" {}  // 2D 貼圖屬性，默認顯示為一個藍色的貼圖（"blue"）。

        _Color( "Color", Color ) = ( 0, 0, 0, 1 )    //可以用來附加到貼圖上，調整貼圖的顏色。

        _AtmoColor("Atmosphere Color", Color) = (0, 0.4, 1.0, 1)    //光暈顏色

        _Size("Size", Float) = 0.1 //光暈範圍

        _OutLightPow("Falloff",Float) = 5 //光暈平方參數

        _OutLightStrength("Transparency", Float) = 15 //光暈強度

		_Input1( "Input 1", float ) = 0.0
		_Input2( "Input 2", float ) = 0.0
		_Input3( "Input 3", float ) = 0.0
    }

    SubShader
    {
        Pass //通道1 用於給物體貼圖、填色
        {
            Name "PlaneBase"

            Tags{ "LightMode" = "Always" }

            Cull Back //剔除背面，只顯示正面

            CGPROGRAM

			//聲明頂點着色器函數爲vert
			#pragma vertex vert

			//聲明片段着色器函數爲frag
			#pragma fragment frag

			#include "UnityCG.cginc"

            //函數可能用到的參數
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float4 _Color;
            uniform float4 _AtmoColor;
            uniform float _Size;
            uniform float _OutLightPow;
            uniform float _OutLightStrength;

			float _Input1;
			float _Input2;
			float _Input3;

            //頂點着色器的輸出
            struct vertexOutput
            {
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 worldvertpos:TEXCOORD1;
                float2 texcoord:TEXCOORD2;
            };

            //頂點着色器函數
            vertexOutput vert( appdata_base v )
            {
                vertexOutput o;

				//頂點動畫，//頂點動畫，每帧渲染时，对每个顶点的位置进行动态修改，从而实现一些有趣的效果。
                // sin 和 cos 函數來對每個頂點的位置進行變化，從而使得表面看起來像是在動態變化
				v.vertex.xyz += v.normal * ( sin (( v.vertex.x + _Time * _Input3 ) * _Input2 ) + cos(( v.vertex.z + _Time * _Input3 ) * _Input2 )) * _Input1;

                // 頂點位置
                o.pos = UnityObjectToClipPos( v.vertex );

                // 法線
                o.normal = v.normal;

                // 世界座標頂點位置
                o.worldvertpos = mul( unity_ObjectToWorld, v.vertex ).xyz;

                // 紋理
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            //片段着色器函數
            float4 frag(vertexOutput i) : COLOR
            {   
                float4 color = tex2D(_MainTex, i.texcoord);
                
                // 紋理貼圖疊加顏色
                return color*_Color;
            }

            ENDCG
        }

        //通道2： 用於生成模型外部的光暈
        Pass
        {
            Name "AtmosphereBase"
            Tags{ "LightMode" = "Always" }
            Cull Front //剔除正面。这意味着只有反面会被渲染
            Blend SrcAlpha One

            CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            uniform float4 _Color;
            uniform float4 _AtmoColor;
            uniform float _Size;
            uniform float _OutLightPow;
            uniform float _OutLightStrength;
			
			float _Input1;
			float _Input2;
			float _Input3;

            struct vertexOutput
            {
                float4 pos:SV_POSITION;
                float3 normal:TEXCOORD0;
                float3 worldvertpos:TEXCOORD1;
            };

            vertexOutput vert( appdata_base v )
            {
                vertexOutput o;

				v.vertex.xyz += v.normal * ( sin(( v.vertex.x + _Time * _Input3 ) * _Input2 )+ cos(( v.vertex.z + _Time * _Input3 ) * _Input2 ) ) * _Input1;

				 //頂點位置以法線方向向外延伸

                v.vertex.xyz += v.normal*_Size;

                o.pos = UnityObjectToClipPos( v.vertex );

                o.normal = v.normal;

                o.worldvertpos = mul( unity_ObjectToWorld, v.vertex );

                return o;
            }

            float4 frag(vertexOutput i):COLOR
            {
                i.normal = normalize(i.normal); ///計算頂點的法向量

                //視角法線
                float3 viewdir = normalize(i.worldvertpos.xyz - _WorldSpaceCameraPos.xyz); 

                float4 color = _AtmoColor;

                //視角法線與模型法線點積形成中間指爲1向四周逐漸衰減爲0的點積值，賦給透明通道，形成光暈效果
                color.a = pow(saturate(dot(viewdir, i.normal)), _OutLightPow);

                color.a *= _OutLightStrength*dot( viewdir, i.normal ); //原本透明度的值再乘上一個計算出來的光照強度值。

                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}