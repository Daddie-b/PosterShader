Shader "Custom/OperationShader"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1 ("Color 1", Color) = (1, 0, 0, 1)
        _Color2 ("Color 2", Color) = (0, 1, 0, 1)
        _Color3 ("Color 3", Color) = (0, 0, 1, 1)
        _BlurAmount ("Blur Amount", Range(0.0, 10.0)) = 1.0
        _EdgeThreshold ("Edge Threshold", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Texture sampler
            sampler2D _MainTexSampler;
            // Color parameters
            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            // Blur amount
            float _BlurAmount;
            // Edge threshold
            float _EdgeThreshold;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            // Vertex shader
            v2f vert (float4 vertex : POSITION, float2 uv : TEXCOORD0)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.uv = uv;
                return o;
            }

            // Pixel shader
            fixed4 frag (v2f i) : SV_Target
            {
                // Re-color the image
                fixed4 texel = tex2D(_MainTexSampler, i.uv);
                float brightness = dot(texel.rgb, float3(0.2126, 0.7152, 0.0722));
                fixed4 newColor;
                if (brightness < 0.33) {
                    newColor = _Color1;
                } else if (brightness < 0.67) {
                    newColor = _Color2;
                } else {
                    newColor = _Color3;
                }

                // Apply motion blur
                float4 blur = float4(0, 0, 0, 0);
                float2 velocity = float2(0, 0);
                float2 velocityX = float2(_BlurAmount / _ScreenParams.x, 0);
                float2 velocityY = float2(0, _BlurAmount / _ScreenParams.y);
                blur += tex2D(_MainTexSampler, i.uv - velocity * 0.5);
                blur += tex2D(_MainTexSampler, i.uv - velocity * 0.25);
                blur += tex2D(_MainTexSampler, i.uv);
                blur += tex2D(_MainTexSampler, i.uv + velocity * 0.25);
                blur += tex2D(_MainTexSampler, i.uv + velocity * 0.5);
                blur /= 5.0;

                // Apply edge detection
                float4 edges = texel;
                float4 left = tex2D(_MainTexSampler, i.uv - float2(1.0 / _ScreenParams.x, 0));
                float4 right = tex2D(_MainTexSampler, i.uv + float2(1.0 / _ScreenParams.x, 0));
                float4 top = tex2D(_MainTexSampler, i.uv - float2(0, 1.0 / _ScreenParams.y));
                float4 bottom = tex2D(_MainTexSampler, i.uv + float2(0, 1.0 / _ScreenParams.y));
                float4 tl = tex2D(_MainTexSampler, i.uv - float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y));
                float4 tr = tex2D(_MainTexSampler, i.uv + float2(1.0 / _ScreenParams.x, -1.0 / _ScreenParams.y));
                float4 bl = tex2D(_MainTexSampler, i.uv + float2(-1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y));
                float4 br = tex2D(_MainTexSampler, i.uv + float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y));
                            float4 gx = -1.0*left + 1.0*right - 1.0*tl + 1.0*tr - 1.0*bl + 1.0*br;
            float4 gy = -1.0*left - 1.0*right + 1.0*top + 1.0*bottom - 1.0*tl - 1.0*bl;
            
            float4 sobel = sqrt(gx*gx + gy*gy);
            
            // Apply threshold
            float threshold = 0.3;
            float4 edgeColor = sobel.r > threshold ? float4(1.0, 1.0, 1.0, 1.0) : float4(0.0, 0.0, 0.0, 1.0);
            
            // Apply edge color to output
            float4 outputColor = texel * (1.0 - edgeColor.a) + edgeColor;
            
            return outputColor;
        }
        ENDCG
    }
}

}