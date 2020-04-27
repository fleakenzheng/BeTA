Global FunctionLib = (GetDir #scripts) + "\FunctionLib\ByteDanceFunctionLib.mse"
fileIn FunctionLib

Global AnimFiles
try DestroyDialog CharacterTools catch()

rollout AnimFiles "动画文件列表" width:250 height:175
(
	MultiListBox AnimFiles_MLB items:#() pos:[12,5] width:226 height:12
)

rollout CharacterTools "角色工具" silenterrors:true
(
	groupBox CharactorScale "角色缩放" pos:[12,10] width:276 height:55
	edittext Scale_ET "" pos:[15,30] text:"1.0" fieldWidth:80 height:20
	button Scale_Btn "角色缩放" pos:[110,25] width:170 height:30 tooltip:"角色进行整体的体型缩放(可带绑定，动画，morpher)"
	timer CloseDialog_Tm interval:10 active:false
	
	groupBox MorpherSetting "Morpher设置" pos:[12,75] width:276 height:220
	button AddMorpherTarget_Btn "添加Morpher目标物体，并显示于下方列表" pos:[20,95] width:260 height:20 tooltip:"先选择全部MorphTarget模型"
	MultiListBox MorpherTarget_MLB items:#() pos:[20,125] width:210 height:6
	button TargetMoveUp_Btn "↑↑" pos:[240,130] width:40 height:30 tooltip:"将列表中选择的目标次序上调"
	button TargetMoveDown_Btn "↓↓" pos:[240,170] width:40 height:30 tooltip:"将列表中选择的目标次序下调"
	button AddSelMopherTarget_Btn "为选择的物体添加列表中选择的Morpher目标" pos:[20,215] width:260 height:30 tooltip:"选择需要添加MorphTarget的模型"
	button AddParaWire_Btn "添加表情参数控制器" pos:[20,255] width:130 height:30 tooltip:"选择需要添加表情控制器的模型"
	button MorphFixed_Btn "修复/生成Morph" pos:[160,255] width:120 height:30 tooltip:"先选择要修复的脸部模型，再加选带有正常MorphTarget的表情模型"
	
	groupBox AnimApplication "动画导出/套用" pos:[12,310] width:276 height:180
	button AnimFolder_Btn "指定动画文件夹" pos:[20,335] width:100 height:20 tooltip:"选择需批量导出动画的Max文件所在路径，右键点击打开文件夹" 
	label AnimFolder_Lbl "显示动画文件夹路径" pos:[130,338] width:150 height:40
	button SaveFolder_Btn "指定保存文件夹" pos:[20,375] width:100 height:20 tooltip:"设定批量套用动画后的Max文件保存路径，右键点击打开文件夹"
	label SaveFolder_Lbl "显示保存文件夹路径" pos:[130,378] width:150 height:40
	button BindPos_Btn "指定绑定文件" pos:[20,415] width:100 height:20 tooltip:"设定套用动画的蒙皮文件"
	label BindPos_Lbl "显示绑定文件名" pos:[130,418] width:150 height:40
	button AnimApply_Btn "动作套用蒙皮并导出Bip" pos:[20,455] width:150 height:20 tooltip:"开始批量动画导出/套用"
	checkbox OnlyBip_CB "仅导出动画文件" pos:[185,455] checked:false width:100 height:20 tooltip:"仅批量导出动画文件(bip & Xaf)，不进行蒙皮套用"
	
	groupBox SkinToolGroup	"蒙皮工具" pos:[12,505] width:276 height:115
	button SkinExp_Btn "保存蒙皮文件" pos:[20,525] width:120 height:20 tooltip:"保存该文件内选定的(不选为所有)带Skin修改器的蒙皮信息" 
	button SkinLoad_Btn "加载蒙皮文件" pos:[160,525] width:120 height:20 tooltip:"选择与Max文件匹配的蒙皮文件进行加载" 
	button ResetXForm_Btn "归一化模型" pos:[20,555] width:120 height:20 tooltip:"将Max文件中选择的模型(不选为全部模型)归一化"
	button ClearBone_Btn "清除多余骨骼" pos:[160,555] width:120 height:20 tooltip:"为选择的模型(不选为所有),清理零权重及不需要的骨骼"
	button ToBone_Btn "将其他类型骨骼转为Bone" pos:[20,585] width:150 height:20 tooltip:"双击父节点全选要转换的骨骼"
	edittext BoneWidth_ET "" pos:[180,585] text:"10" fieldWidth:40 height:20
	button BoneWidth_Btn "重置宽度" pos:[230,585] width:50 height:20 tooltip:"调整选择的Bone骨骼的宽度"
	
	Global AnimFolder=undefined,BindPosFile=undefined,AnimFilesArray=#(),SaveFolder=undefined	
	
	on Scale_Btn pressed do
	(
		sliderTime = animationrange.start
		multiple = Scale_ET.text as float
		bipedRootArray = SelectBipedRoot()		
		if bipedRootArray.count != 0 do
		(
			HeightFixedArray = #()
			for i in bipedRootArray do
			(
				append HeightFixedArray (multiple * i.transform.pos.z)
				i.controller.figureMode = true
			)
		)
		skinMeshArray = SelectSkinModel (Geometry as array)
		boneArray = SelectBone()
		IKArray = SelectIK()
		IKPointArray = SelectIKPoint()
		dummyArray = SelectDummy()
		
		--记录Morpher全部信息
		morpherModelArray = SelectMorpherModel()
		morpherTargetArray = SelectMorpherTarget morpherModelArray		
		norpherTargetNumArray = GetMorpherTargetNum morpherModelArray
		ParamWireArray = SaveMorpherParamWire morpherModelArray norpherTargetNumArray
		morpherArray = SelectMorpher morpherModelArray	
		
		SaveSkin_Fn skinMeshArray
		ModelScale_Fn skinMeshArray multiple	
		BipedScale_Fn bipedRootArray multiple
		BoneScale_Fn boneArray multiple		
		IKScale_Fn IKArray IKPointArray multiple		
		DummyScale_Fn dummyArray multiple		
		MorpherScale_Fn morpherTargetArray multiple
		
		--添加morpher修改器并还原线性控制
		newMorpherControllerArray = AddMorpherModifier  morpherArray
		LoadMorpherParamWire newMorpherControllerArray ParamWireArray
		
		CloseDialog_Tm.active = true
		if skinMeshArray.count != 0 do LoadSkin_Fn()
		CloseDialog_Tm.active = false
		if bipedRootArray.count != 0 do FootFixed bipedRootArray HeightFixedArray
	)
	
	on CloseDialog_Tm tick do
	(
		CloseLoadEnvDialog_Fn()
	)
	
	on AddMorpherTarget_Btn pressed do
	(
		MorpherTarget_MLB.items = #()
		morpherTarget = for i in selection where (classof i == Editable_Poly or classof i == Editable_Mesh or classof i == PolyMeshObject) collect i.name
		MorpherTarget_MLB.items = morpherTarget
		MorpherTarget_MLB.selection = #{1..morpherTarget.count}
	)
	
	on TargetMoveUp_Btn pressed do
	(
		targetSelectedArray = MorpherTarget_MLB.selection  as array
		targetList = MorpherTarget_MLB.items
		MultiListBoxMoveUp targetList targetSelectedArray
		MorpherTarget_MLB.items = targetList
		MorpherTarget_MLB.selection = targetSelectedArray
	)
	
	on TargetMoveDown_Btn pressed do
	(
		targetSelectedArray = MorpherTarget_MLB.selection  as array
		targetList = MorpherTarget_MLB.items
		MultiListBoxMoveDown targetList targetSelectedArray
		MorpherTarget_MLB.items = targetList
		MorpherTarget_MLB.selection = targetSelectedArray
	)
	
	on AddSelMopherTarget_Btn pressed do
	(
		selectionID = MorpherTarget_MLB.selection as array
		targetAddNameArray = #()
		for i in selectionID do
		(
			append targetAddNameArray MorpherTarget_MLB.items[i]
		)
		AddMorpherTargetList targetAddNameArray		
	)
	
	on AddParaWire_Btn pressed do
	(
		AddMorpherParaWire()
	)		
	
	on AnimFolder_Btn pressed do
	(
		AnimFolder = getSavePath caption:"动画文件所在文件夹:" initialDir:"D:/"
		if (AnimFolder != undefined) then
		(
			AnimFolder_Lbl.text = AnimFolder
			AnimFilesArray = getMaxFiles AnimFolder
			if AnimFilesArray.count != 0 do
			(
				createdialog AnimFiles 	pos:(GetDialogPos (CharacterTools) + [302,326]) width:250 height:175
				AnimFilesName = #()
				for i in AnimFilesArray do append AnimFilesName (getfilenamefile i)
				AnimFiles.AnimFiles_MLB.items = AnimFilesName
				AnimFiles.AnimFiles_MLB.selection = #{1..AnimFilesName.count}
			)			
		)
		else 
		(
			DestroyDialog AnimFiles
			AnimFolder_Lbl.text = "显示动画文件夹路径"
		)
	)
	
	on CharacterTools close do
	(
		DestroyDialog AnimFiles
		CharacterTools = undefined
	)
	
	on CharacterTools open do
	(
		fileIn FunctionLib
	)
	
	on CharacterTools moved val do
	(
		SetDialogPos AnimFiles (val + [302,326])
	)
	
	on BindPos_Btn pressed do
	(
		BindPosFile = getOpenFileName caption:"指定绑定文件：" filename:"*.max" types:"Bindpos File(*.max)|*.max"
		if BindPosFile != undefined then BindPos_Lbl.text = (getfilenamefile BindPosFile)
		else BindPos_Lbl.text = "显示绑定文件名"
	)
	
	on SaveFolder_Btn pressed do
	(
		SaveFolder = getSavePath caption:"指定文件保存路径:" initialDir:"D:/"
		if SaveFolder != undefined then SaveFolder_Lbl.text = SaveFolder
		else SaveFolder_Lbl.text = "显示保存文件夹路径:"
	)
	
	on AnimFolder_Btn rightclick do
	(
		if AnimFolder != undefined do
			ShellLaunch AnimFolder ""
	)
	
	on SaveFolder_Btn rightclick do
	(		
		if SaveFolder != undefined do ShellLaunch SaveFolder ""
	)
	
	on AnimApply_Btn pressed do
	(
		if AnimFilesArray.count != 0 then
		(
			if SaveFolder != undefined then
			(
				AnimSelected = AnimFiles.AnimFiles_MLB.selection as array
				AnimSelectedFilesArray = #()
				for i in AnimSelected do
				(
					append AnimSelectedFilesArray AnimFilesArray[i]
				)
				BipFileArray = #()
				XafFileArray = #()
				DisableSceneRedraw()
				for i in AnimSelectedFilesArray do
				(
					BipFolderCreate = makeDir (SaveFolder + "\Bip") all:true
					XafFolderCreate = makeDir (SaveFolder + "\\Xaf") all:true
					if (BipFolderCreate and XafFolderCreate) then
					(	
						loadMaxFile i useFileUnits:true quiet:true
						BipedFileName = (SaveFolder + "\Bip\\") + getfilenamefile i + ".bip"
						BipedRootArray = SelectBipedRoot()
						biped.saveBipFile BipedRootArray[1].controller BipedFileName #saveSubAnimControllers #saveMaxObjects
						append BipFileArray BipedFileName
						XafFileName = (SaveFolder + "\\Xaf\\") + getfilenamefile i + ".xaf"
						BoneArray = SelectBone()	
						SaveBoneAnim XafFileName BoneArray
						append XafFileArray XafFileName
					)
					else messagebox "请在指定的保存文件夹中手动创建Bip和Xaf文件夹！" title:"保存Bip文件夹创建失败："
				)
				if OnlyBip_CB.checked != true do
				(
					if BindPosFile != undefined then
					(
						loadMaxFile BindPosFile useFileUnits:true quiet:true
						holdMaxFile()
						for i=1 to BipFileArray.count do
						(
							--清理bip骨骼的IK Object
							fetchMaxFile quiet:true
							BipedRootArray = SelectBipedRoot()
							biped.loadBipFile BipedRootArray[1].controller BipFileArray[i] #noRedraw #loadMaxObjects #retargetHeight #retargetLimbSizes #scaleIKObjectSize #loadSubAnimControllers

							BoneArray = SelectBone()			
							LoadBoneAnim XafFileArray[i] BoneArray
								
							--AnimationRangeFit BipedRootArray[1]
							ViewportFit()							
							NewFileName = (SaveFolder + "\\") + getfilenamefile BipFileArray[i] + ".max"
							saveMaxFile NewFileName clearNeedSaveFlag:true useNewFile:false quiet:true
						)						
					)
					else messagebox "未指定BindPos文件！" title:"BindPos文件未指定："
				)
				EnableSceneRedraw()
			)
			else messagebox "未指定保存文件夹！" title:"保存路径未指定："
		)
		else messagebox "未指定动画文件夹！" title:"动画文件为空："
	)
	
	on SkinExp_Btn pressed do
	(
		SelArray = selection as array
		if SelArray.count == 0 do SelArray = Geometry as array
		SkinArray = SelectSkinModel SelArray
		if SkinArray.count != 0 do SaveSkin_Fn SkinArray
	)
	
	on SkinLoad_Btn pressed do
	(
		Skinfile = getOpenFileName caption:"指定绑定文件：" filename:"d:\MaxScriptsInfo\env\*.bin" filename:"*.bin" types:"Skin File(*.bin)|*.bin"
		CloseDialog_Tm.active = true
		if Skinfile != undefined do LoadSkinFile_Fn Skinfile
		CloseDialog_Tm.active = false		
	)
	
	on ResetXForm_Btn pressed do
	(
		SelArray = selection as array
		MeshArray = #()
		for i in SelArray do
		(
			if (classof i == Editable_Poly or classof i == Editable_mesh or classof i == PolyMeshObject) do append MeshArray i
		)
		if MeshArray.count == 0 then MeshArray = CollectMesh()
		if MeshArray.count == 0 then messagebox "场景不存在必要模型" title:"Error!"
		else
		(
			if (queryBox "自动归一化会清除模型全部修改器,确定进行自动归一化？" title:"注意！！！！！" beep:false) do
			(
				for i in MeshArray do	ResetXformMesh i
			)
		)
	)
	
	on ClearBone_Btn pressed do
	(
		SelArray = selection as array
		if SelArray.count == 0 do SelArray = Geometry as array
		SkinArray = SelectSkinModel SelArray
		if SkinArray.count != 0 do WeightOMesh = DeletOWeight SelArray
		if WeightOMesh != undefined do 
		(
			infor = "模型___ "
			for i in WeightOMesh do
			(
				infor += i + "___ "
			)
			infor += "存在权重为0的点。顶点已被自动选择。"
			messagebox infor title:"注意!!!!"
		)		
	)
	
	on MorphFixed_Btn pressed do
	(
		if selection.count == 2 do
		(
			Model = selection[1]
			Target = selection[2]
			if Target.modifiers[#Morpher] != undefined do
			(
				converttopoly Model
				MappingInfor = MappingArray Model Target
				vertsIDArray = VertexMapping Model Target MappingInfor
				FixedMorph_Fn Model Target vertsIDArray MappingInfor
			)
		)
	)
	
	on ToBone_Btn pressed do
	(
		DummyArray = selection as array
		boneWidth = BoneWidth_ET.text as float
		BoneArray = DummyToBone DummyArray boneWidth
		for i in BoneArray do
		(
			i.name = substring i.name 1 (i.name.count - 5)
		)
		delete DummyArray
	)
	
	on BoneWidth_Btn pressed do
	(
		boneWidth = BoneWidth_ET.text as float
		for i in selection do
		(
			try 
			(
				i.width = boneWidth
				i.height = boneWidth
			)			
			catch()
		)
	)
)
createdialog CharacterTools 300 630













