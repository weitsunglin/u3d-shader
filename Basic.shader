// Shader的名稱
Shader "Custom/Basic"
{
    // 屬性
    Properties 
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }

    SubShader
    {
        Pass
        {   
            // 設定名稱、繪製狀態和標籤，可選項目
            // 在這個例子中，我們不需要進行更多設置

            // 開始撰寫Shader
            CGPROGRAM

            // 宣告vertex / fragment shader的名稱
            #pragma vertex vert
            #pragma fragment frag
            
            // 使用定義在Properties區塊的屬性
            // 注意：變數必須和區塊中的屬性以及變數名稱一致
            fixed4 _Color;
            
            // 頂點 Shader
            float4 vert( float4 v : POSITION ) : SV_POSITION 
            {
                return UnityObjectToClipPos( v );
            }
            
            // 片段 Shader
            fixed4 frag() : SV_TARGET 
            {
                return _Color;
            }

            ENDCG
        }
    }
    
    // 若以上兩種Shader皆無法運行，則使用這個最低階的Shader
    // 若「不留後路」，也可直接關閉該選項
    // `Fallback Off`
    Fallback "VertexLit"
}
