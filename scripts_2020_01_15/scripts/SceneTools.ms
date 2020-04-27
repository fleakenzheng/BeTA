Global FunctionLib = (GetDir #scripts) + "\FunctionLib\ByteDanceFunctionLib.mse"
fileIn FunctionLib

try DestroyDialog SceneTools catch()

rollout SceneTools "场景工具" width:300 height:250 --silenterrors:true
(
	groupBox VertexColorGB "顶点色设置" pos:[12,10] width:276 height:230
	
	checkbox ShowVC_CB "显示顶点颜色" pos:[30,30] width:100 height:20 tooltip:"勾选，显示顶点颜色，以下所有操作针对顶点颜色进行操作"
	checkbox ShowVA_CB "显示顶点Alpha" pos:[180,30] width:100 height:20 tooltip:"勾选，显示顶点Alpha颜色，以下除了颜色空间转换外的其他操作也改为针对Alpha进行操作"
	button Gamma2Linear_Btn "颜色空间Gamma转线性" pos:[17,55] width:125 height:30 tooltip:"将选定的模型顶点(不选顶点为模型全部顶点,不选模型为全部模型全部顶点)顶点色变暗"
	button Linear2Gamma_Btn "颜色空间线性转Gamma" pos:[157,55] width:125 height:30 tooltip:"将选定模型顶点(不选顶点为模型全部顶点,不选模型为全部模型全部顶点)顶点色变亮"
	
	colorpicker VertexColor_CP "" pos:[17,90] color:[255,255,255] alpha:false fieldWidth:48 height:30 title:"拾取顶点色"
	button SelectVertex_Btn "选择同色顶点" pos:[85,90] width:80 height:30 tooltip:"选择单个模型与色板同色的所有顶点"
	button SetVC_Btn "色板赋予顶点色" pos:[182,90] width:100 height:30 tooltip:"将选定模型顶点(不选顶点为模型全部顶点,不选模型为全部模型全部顶点)顶点色变为色板颜色"
	
	colorpicker VCStart_CP "起始" pos:[20,125] color:[255,255,255] alpha:false fieldWidth:48 height:30 title:"设置过渡起始色"
	colorpicker VCEnd_CP "结束" pos:[100,125] color:[0,0,0] alpha:false fieldWidth:48 height:30 title:"设置过渡结束色"
	dropdownlist GradePower_DD "" pos:[183,130] items:#("线性","平方","平方根") selection:1 width:98 height:30 tooltip:"颜色过渡类型"
	button SetVCGrade_Btn "设置过渡顶点色" pos:[17,160] width:100 height:30 tooltip:"将模型选择的顶点进行指定颜色的过渡"
	radiobuttons Axial_RB "轴向:"	pos:[130,160] labels:#("X","Y","Z") default:1 columns:3 tooltip:"过渡轴向" 
	dropdownlist GradeSetType_DD "" pos:[223,165] items:#("替换","平均") selection:1 width:57 height:30 tooltip:"顶点过渡设置类型_替换或者与原颜色平均(可设置多方向多颜色过渡)"
	button SetVCGradeR_Btn "设置径向过渡色" pos:[17,200] width:100 height:30 tooltip:"将模型选择的顶点进行指定颜色的过渡，右键点击拾取中心点位置，并在后方显示。最后项输入距离。"
	edittext CenterX_ET "" pos:[115,205] fieldWidth:40 height:18
	edittext CenterY_ET "" pos:[155,205] fieldWidth:40 height:18
	edittext CenterZ_ET "" pos:[195,205] fieldWidth:40 height:18
	edittext Range_ET "" pos:[235,205] fieldWidth:40 height:18
	
	on ShowVC_CB changed state do
	(
		if state then
		(
			MeshArray = GetGeometry()
			for i in MeshArray do
			(
				i.showVertexColors = on
				if ShowVA_CB.checked then
					i.vertexColorType = 2
				else 
					i.vertexColorType = 0
			)
		)
		else
		(
			MeshArray = GetGeometry()
			for i in MeshArray do
			(
				i.showVertexColors = off
				if ShowVA_CB.checked then
					i.vertexColorType = 2
				else 
					i.vertexColorType = 0
			)
		)
	)
	
	on SceneTools open do
	(
		fileIn FunctionLib
	)
	
	on SceneTools close do
	(
		SceneTools = undefined
	)
	
	on ShowVA_CB changed state do
	(
		if state then
		(
			MeshArray = GetGeometry()
			for i in MeshArray do
			(
				i.vertexColorType = 2
				i.showVertexColors = off
				if ShowVC_CB.checked do i.showVertexColors = on
			)
		)
		else
		(
			MeshArray = GetGeometry()
			for i in MeshArray do
			(
				i.vertexColorType = 0
				i.showVertexColors = off
				if ShowVC_CB.checked do i.showVertexColors = on
			)
		)
	)
	
	on Gamma2Linear_Btn pressed do
	(
		MeshArray = #()
		MeshArray = GetGeometry()
		if selection.count == 1 then
		(
			converttopoly $
			VertexArray = $.selectedVerts
			if VertexArray.count == 0 then
			(
				for i in $.verts do
				(
					select i
					VCPre = $.GetVertexColor #VertexColor
					VCPro = Gamma2Linear VCPre
					$.SetVertexColor VCPro #VertexColor
					deselect i
				)
			)
			else
			(
				VertexArray = (VertexArray as bitarray) as array
				for i in VertexArray do
				(
					$.EditablePoly.SetSelection #Vertex #{i}
					VCPre = $.GetVertexColor #VertexColor
					VCPro = Gamma2Linear VCPre
					$.SetVertexColor VCPro #VertexColor
				)
				$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
			)
		)
		else
		(
			for i in MeshArray do
			(
				converttopoly i
				VertexArray = i.selectedVerts
				for j in i.verts do
				(
					select j
					VCPre = i.GetVertexColor #VertexColor
					VCPro = Gamma2Linear VCPre
					i.SetVertexColor VCPro #VertexColor
					deselect j
				)
			)
		)
	)
	
	on Linear2Gamma_Btn pressed do
	(
		MeshArray = #()
		MeshArray = GetGeometry()
		if selection.count == 1 then
		(
			converttopoly $
			VertexArray = $.selectedVerts
			if VertexArray.count == 0 then
			(
				for i in $.verts do
				(
					select i
					VCPre = $.GetVertexColor #VertexColor
					VCPro = Linear2Gamma VCPre
					$.SetVertexColor VCPro #VertexColor
					deselect i
				)
			)
			else
			(
				VertexArray = (VertexArray as bitarray) as array
				for i in VertexArray do
				(
					$.EditablePoly.SetSelection #Vertex #{i}
					VCPre = $.GetVertexColor #VertexColor
					VCPro = Linear2Gamma VCPre
					$.SetVertexColor VCPro #VertexColor
				)
				$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
			)
		)
		else
		(
			for i in MeshArray do
			(
				converttopoly i
				VertexArray = i.selectedVerts
				for j in i.verts do
				(
					select j
					VCPre = i.GetVertexColor #VertexColor
					VCPro = Linear2Gamma VCPre
					i.SetVertexColor VCPro #VertexColor
					deselect j
				)
			)
		)
	)
	
	on SelectVertex_Btn pressed do
	(
		MeshArray = #()
		MeshArray = GetGeometry()
		if MeshArray.count != 1 then
			messagebox "选择一个有效模型" title:"Error"
		else
		(
			converttopoly $
			VertexArray = #()
			for i in $.verts do
			(
				select i
				if ShowVA_CB.checked then
				(
					VCPre = $.GetVertexColor #Alpha
					if abs(VCPre.r - (VertexColor_CP.color).r) <= 3 do append VertexArray i.index
				)
				else
				(
					VCPre = $.GetVertexColor #VertexColor
					if VCPre == VertexColor_CP.color do append VertexArray i.index
				)					
				deselect i
			)
			$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
		)
	)
	
	on SetVC_Btn pressed do
	(
		MeshArray = #()
		MeshArray = GetGeometry()
		if selection.count == 1 then
		(
			converttopoly $
			VertexArray = $.selectedVerts
			if VertexArray.count == 0 then
			(
				for i in $.verts do
				(
					select i
					if ShowVA_CB.checked then
					(
						NewVC = VertexColor_CP.color
						NewVC.g = NewVC.r
						NewVC.b = NewVC.r
						$.SetVertexColor NewVC #Alpha
					)							
					else $.SetVertexColor VertexColor_CP.color #VertexColor
					deselect i
				)
			)
			else
			(
				VertexArray = (VertexArray as bitarray) as array
				for i in VertexArray do
				(
					$.EditablePoly.SetSelection #Vertex #{i}					
					if ShowVA_CB.checked then
					(
						NewVC = VertexColor_CP.color
						NewVC.g = NewVC.r
						NewVC.b = NewVC.r
						$.SetVertexColor NewVC #Alpha
					)							
					else $.SetVertexColor VertexColor_CP.color #VertexColor
				)
				$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
			)
		)
		else
		(
			for i in MeshArray do
			(
				converttopoly i
				VertexArray = i.selectedVerts
				for j in i.verts do
				(
					select j
					if ShowVA_CB.checked then
					(
						NewVC = VertexColor_CP.color
						NewVC.g = NewVC.r
						NewVC.b = NewVC.r
						i.SetVertexColor NewVC #Alpha
					)							
					else i.SetVertexColor VertexColor_CP.color #VertexColor
					deselect j
				)
			)
		)
	)
	
	on SetVCGrade_Btn pressed do
	(
		GradeScale = ComputerVCGradeScale SceneTools.Axial_RB.state
		if GradeScale.count != 0 do
		(			
			ColorS = SceneTools.VCStart_CP.color
			ColorE = SceneTools.VCEnd_CP.color
			converttopoly $	
			VertexArray = $.selectedVerts
			VertexArray = (VertexArray as bitarray) as array
			for i = 1 to VertexArray.count do
			(
				$.EditablePoly.SetSelection #Vertex #{VertexArray[i]}
				TempScale = GradeScale[i]
				if SceneTools.GradePower_DD.selection == 2 do TempScale *= TempScale
				if SceneTools.GradePower_DD.selection == 3 do TempScale = sqrt TempScale
				NewVC = LerpColor ColorS ColorE TempScale
				if SceneTools.GradeSetType_DD.selection == 2 do
				(
					if ShowVA_CB.checked then VCPre = $.GetVertexColor #VertexColor
					else VCPre = $.GetVertexColor #Alpha
					NewVC = LerpColor NewVC VCPre 0.5
				)
				if ShowVA_CB.checked then
				(
					NewVC.g = NewVC.r
					NewVC.b = NewVC.r
					$.SetVertexColor NewVC #Alpha
				)
				else $.SetVertexColor NewVC #VertexColor
			)
			$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
		)
	)	
	
	on SetVCGradeR_Btn pressed do
	(
		GradeScalePow = ComputerVCGradeRScalePow (CenterX_ET.text as integer) (CenterY_ET.text as integer) (CenterZ_ET.text as integer) (Range_ET.text as integer)
		if GradeScalePow.count != 0 do
		(			
			ColorS = VCStart_CP.color
			ColorE = VCEnd_CP.color
			converttopoly $	
			VertexArray = $.selectedVerts
			VertexArray = (VertexArray as bitarray) as array
			for i = 1 to VertexArray.count do
			(
				$.EditablePoly.SetSelection #Vertex #{VertexArray[i]}
				TempScale = GradeScalePow[i]
				if SceneTools.GradePower_DD.selection == 1 do TempScale = sqrt TempScale
				if SceneTools.GradePower_DD.selection == 3 do TempScale = sqrt (sqrt TempScale)
				NewVC = LerpColor ColorS ColorE TempScale
				if SceneTools.GradeSetType_DD.selection == 2 do
				(
					VCPre = $.GetVertexColor #VertexColor
					NewVC = LerpColor NewVC VCPre 0.5
				)				
				if ShowVA_CB.checked then
				(
					NewVC.g = NewVC.r
					NewVC.b = NewVC.r
					$.SetVertexColor NewVC #Alpha
				)
				else $.SetVertexColor NewVC #VertexColor
			)
			$.EditablePoly.SetSelection #Vertex (VertexArray as bitarray)
		)
	)
	
	on SetVCGradeR_Btn rightclick do
	(
		VertexArray = $.selectedVerts
		if VertexArray.count == 1 then
		(
			CenterX_ET.text = VertexArray[1].pos.x as string
			CenterY_ET.text = VertexArray[1].pos.y as string
			CenterZ_ET.text = VertexArray[1].pos.z as string
		)
		else messagebox "先选择中心点。" title:"Error!"
	)
)
createdialog SceneTools 300 250