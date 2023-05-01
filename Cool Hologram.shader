Shader "Unlit/SpecialFX/Cool Hologram"
{
    Properties
    {

        //該著色器應用的物體的主要顏色/反照率。該紋理圖片被定義為2D紋理，默認值設為“白色”。
        _MainTex ( "Albedo Texture", 2D ) = "white" {  }

        //這是一種顏色，將用於對物體進行著色。默認值為白色，這意味著不會應用任何著色。
        _TintColor( "Tint Color", Color ) = ( 1,1,1,1 )

        //這定義了物體的透明度級別。默認值設為0.25，這意味著物體會有一定程度的透明度。
        _Transparency( "Transparency", Range( 0.0 , 0.5 ) ) = 0.25

        //這用於為物體定義剪裁閾值。物體中任何alpha值低於此閾值的部分將被剪裁，從而使其變為透明。默認值設為0.2。
        _CutoutThresh( "Cutout Threshold", Range( 0.0, 1.0 ) ) = 0.2

        //這定義物體與相機之間的距離。默認值設為1。
        _Distance( "Distance", Float ) = 1

        //這定義了用於在物體上創建全息效果的正弦波的振幅。默認值設為1。
        _Amplitude( "Amplitude", Float ) = 1

        //這定義了正弦波動畫的速度。默認值設為1。
        _Speed ( "Speed", Float ) = 1

        //這定義了應用於物體的全息效果的程度。默認值設為1，這意味著將應用完整的效果。
        _Amount("Amount", Range( 0.0, 1.0 )) = 1

    }

    //SubShader定義了一個特定渲染路徑的著色器代碼。
    SubShader
    {
        //這一行指定了Unity在渲染此物體時應使用的渲染隊列和渲染類型。"Transparent"類型是指物體具有透明部分。
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        // 這行程式碼定義了物體的LOD級別。LOD（Level of Detail）是一個技術，它允許在不同的距離和視野中渲染物體的不同級別的詳細信息。這行程式碼中的數字100表示該物體在所有距離和視野中都顯示相同的細節級別。
        LOD 100
        // 這行程式碼指示Unity在渲染此物體時不應寫入深度緩衝區。這是因為透明物體通常需要按深度順序繪製，而不是按照它們在場景中出現的順序繪製。
        ZWrite Off
        // 這行程式碼定義了用於混合紋理的方式。SrcAlpha表示紋理像素的alpha值被用作源因子，OneMinusSrcAlpha表示（1-紋理像素alpha值）被用作目標因子。這個混合方式通常用於透明物體。
        Blend SrcAlpha OneMinusSrcAlpha

        //SubShader中的第一個Pass被用來渲染物體的主要外觀，而其他Pass可以用於特殊效果，例如反射、陰影等。
        Pass
        {
            //CG語言是一種著色器語言，GPU的低級編程代碼，CG語言與OpenGL和Direct3D等圖形API緊密結合
            CGPROGRAM
            //它們告訴Unity這些函數是用作著色器程序的入口點。
            #pragma vertex vert
            #pragma fragment frag

            //將Unity的通用著色器庫文件包含到代碼中，以便在著色器中使用Unity的內建函數和變量

            #include "UnityCG.cginc"

            //包含了位置(vertex)和紋理座標(uv)等屬性
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            //包含了紋理座標(uv)和位置(vertex)等屬性
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            //紋理和紋理的平移縮放
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _TintColor; //表示顏色的調整
            float _Transparency; //表示透明度
            float _CutoutThresh; //表示用於剪裁的閾值
            
             //用於實現動畫效果的變量。
            float _Distance;
            float _Amplitude;
            float _Speed;
            float _Amount;

            //該函數實現了一個簡單的水平移動和正弦震動的動畫效果，並將紋理座標和位置傳遞給像素處理函數。
            v2f vert ( appdata v )
            {
                v2f o;
                //頂點的x座標應用正弦函數，對頂點的位置進行了變形，sin(x)，其中x是一個角度值。該函數會根據角度值的變化，返回對應的正弦值，可以用來描述一個周期性的波動
                v.vertex.x += sin( _Time.y * _Speed + v.vertex.y * _Amplitude ) * _Distance * _Amount;

                //將頂點的位置轉換成裝配後的坐標系下的位置
                o.vertex = UnityObjectToClipPos( v.vertex );

                //將UV坐標進行轉換，使其與_MainTex紋理的尺寸和位置相匹配
                o.uv = TRANSFORM_TEX( v.uv, _MainTex );

                return o; //最後返回包含變換後的頂點位置和UV坐標的結構體o。
            }

            //該函數根據紋理座標和其他變量計算像素顏色，並將顏色傳回渲染管線。

            fixed4 frag (v2f i) : SV_Target //返回四维浮点数 (RGBA) 的函数，它会将返回值写入到渲染管线的当前渲染目标中
            {
                
                //tex2D 函數來從 _MainTex 紋理中取樣出當前像素的顏色，再加上 _TintColor 作為顏色修飾
                fixed4 col = tex2D( _MainTex, i.uv ) + _TintColor;

                col.a = _Transparency; //設定透明度

                clip( col.r - _CutoutThresh );  //clip 函數根據 _CutoutThresh 參數過濾掉一些像素

                return col; //最後返回經過處理後的顏色
                
            }

            ENDCG //它的作用是標記著色器代碼的結束位置
        }
    }
}