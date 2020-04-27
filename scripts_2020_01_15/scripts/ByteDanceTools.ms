Global ByteDanceTools

rollout ByteDanceTools "Max工具_Bytedance FGame" width:100 height:135 silenterrors:true
(
	button CharacterTools_Btn "角色工具" pos:[15,10] width:70 height:30 tooltip:"打开角色工具面板"
	button SceneTools_Btn "场景工具" pos:[15,50] width:70 height:30 tooltip:"打开场景工具面板"	
	button ExportTools_Btn "导出工具" pos:[15,90] width:70 height:30 tooltip:"打开导出工具面板"	
	
	on CharacterTools_Btn pressed do
	(
		Toolpath = (GetDir #scripts) + "\CharacterTools.ms"
		fileIn Toolpath
		DestroyDialog ByteDanceTools
	)	
	
	on SceneTools_Btn pressed do
	(
		Toolpath = (GetDir #scripts) + "\SceneTools.ms"
		fileIn Toolpath
		DestroyDialog ByteDanceTools
	)	
	
	on ExportTools_Btn pressed do
	(
		Toolpath = (GetDir #scripts) + "\ExportTools.ms"
		fileIn Toolpath
		DestroyDialog ByteDanceTools
	)
)
createdialog ByteDanceTools 100 135