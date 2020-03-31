Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};
			
			v2f vert(a2v v) {
				v2f o;
				// Transform the vertex from object space to projection space
				//将顶点信息从模型空间转到齐次裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// Get ambient term
				//得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// Transform the normal from object space to world space
				//将物体的顶点法线坐标转化到世界坐标，并归一化
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// Get the light direction in world space
				//获取平行光的方向及强度信息，并归一化（可省略归一化）
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// Compute diffuse term
				//固有色=直射光的颜色和强度*漫反射颜色及强度*取[0.1] （点击*（世界坐标系下的顶点法线*直射光方向））
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
				//输出的颜色信息=环境色+漫反射颜色
				o.color = ambient + diffuse;
				//经数储存进o，做为片元阶段数据
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				////输出v2f，color为思维向量，需补足A信息
				return fixed4(i.color, 1.0);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
