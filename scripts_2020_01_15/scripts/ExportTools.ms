Global FunctionLib = (GetDir #scripts) + "\FunctionLib\ByteDanceFunctionLib.mse"
fileIn FunctionLib

Global ExpFiles,LastDisUnits,LastSysUnits
if LastDisUnits == undefined do LastDisUnits = 3
if LastSysUnits == undefined do LastSysUnits = 5
	
try DestroyDialog ExportTools catch()

rollout ExpFiles "导出文件列表" width:250 height:210
(
	MultiListBox ExpFiles_MLB items:#() pos:[12,5] width:226 height:12
)

rollout ExportTools "导出工具" width:300 height:350 --silenterrors:true
(
	button UnitsSet_Btn "单位设置" pos:[12,10] width:80 height:25 tooltip:"将Max单位设置为选择的单位设置"
	dropdownlist DisUnits_DL "" pos:[102,13] items:#("Millimeters","Centimeters","Meters","Kilometers") selection:LastDisUnits width:80 height:25 tooltip:"选择显示单位"
	dropdownlist SysUnits_DL "" pos:[192,13] items:#("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers") selection:LastSysUnits width:97 height:25 tooltip:"选择系统单位"
	
	groupBox FbxExport "导出Fbx文件" pos:[12,45] width:276 height:290
	button ExpFolder_Btn "指定导出文件夹" pos:[20,65] width:100 height:20 tooltip:"选择需批量导出的Max文件所在路径，右键点击打开文件夹"
	label ExpFolder_Lbl "显示导出文件所在文件夹路径" pos:[130,68] width:150 height:40
	button FbxFolder_Btn "指定Fbx文件夹" pos:[20,105] width:100 height:20 tooltip:"设定批量导出的FBX文件保存路径，右键点击打开文件夹"
	label FbxFolder_Lbl "显示导出的Fbx文件的保存路径" pos:[130,108] width:150 height:40
	checkbox AnimExp_CB "导出动作" pos:[22,135] width:60 height:35 checked:true
	checkbox SkinExp_CB "导出蒙皮"  pos:[90,135] width:60 height:35 checked:false
	checkbox MorphExp_CB "导出变形" pos:[160,135] width:60 height:35 checked:false
	checkbox MeshExp_CB "仅模型" pos:[230,135] width:50 height:35 checked:false
	button ExpBatch_Btn "批量导出Fbx文件" pos:[20,170] width:120 height:20 tooltip:"将Max文件批量导出为FBX文件，名称与源文件相同"
	button ExpOne_Btn "仅导出当前文件为Fbx" pos:[150,170] width:130 height:20 tooltip:"将当前打开的Max文件导出为FBX文件，保存位置和名称与源文件相同，右键点击打开所在文件夹"
	
	checkbox UnitCK_CB "单位检查" pos:[22,200] width:60 height:25 checked:true
	label Unit_Lbl "厘米,厘米" pos:[90,207] width:60 height:25
	
	checkbox BoneNumCK_CB "骨骼数检查" pos:[150,200] width:70 height:25 checked:true
	edittext BoneNum_ET "" text:"80" pos:[223,202] width:55 height:20
	
	checkbox SkinNumCK_CB "权重检查" pos:[22,230] width:60 height:25 checked:true
	edittext SkinNum_ET "" text:"4" pos:[90,232] width:55 height:20
	
	checkbox FaceNumCK_CB "面数检查" pos:[150,230] width:60 height:25 checked:true
	edittext FaceNum_ET "" text:"10000" pos:[223,232] width:55 height:20
	
	checkbox CharNameCK_CB "文件模型名检查" pos:[22,260] width:90 height:25 checked:true
	label CharNameCK_Lbl "编号_缩写大写(_Head或_Body)" pos:[120,267] width:155 height:20
	
	button CheckFolder_Btn "批量检查文件夹内文件规格" pos:[20,290] width:150 height:25 tooltip:"设定批量导出的FBX文件保存路径，右键点击打开文件夹"
	button CheckOpen_Btn "检查当前文件规格" pos:[180,290] width:100 height:25 tooltip:"设定批量导出的FBX文件保存路径，右键点击打开文件夹"
	
	
	Global ExpFolder=undefined,FbxFolder=undefined,ExpFilesArray=#()
	
	Fn UnitDisplay DisUnit SysUnit =
	(
		tempTest = Unit_Lbl.text
		tempTest = filterString tempTest ","
		case DisUnit of
		(
			1:
			(
				Unit_Lbl.text = "毫米," + tempTest[2]
			)
			2:
			(
				Unit_Lbl.text = "厘米," + tempTest[2]
			)
			3:
			(
				Unit_Lbl.text = "米," + tempTest[2]
			)
			4:
			(
				Unit_Lbl.text = "千米," + tempTest[2]
			)
		)
		tempTest = Unit_Lbl.text
		tempTest = filterString tempTest ","
		case SysUnit of
		(
			1:
			(
				Unit_Lbl.text = tempTest[1] + ",英寸"
			)
			2:
			(
				Unit_Lbl.text = tempTest[1] + ",英尺"
			)
			3:
			(
				Unit_Lbl.text = tempTest[1] + ",英里"
			)
			4:
			(
				Unit_Lbl.text = tempTest[1] + ",毫米"
			)
			5:
			(
				Unit_Lbl.text = tempTest[1] + ",厘米"
			)
			6:
			(
				Unit_Lbl.text = tempTest[1] + ",米"
			)
			7:
			(
				Unit_Lbl.text = tempTest[1] + ",千米"
			)
		)
	)

	on ExportTools close do
	(
		DestroyDialog ExpFiles
		LastDisUnits = DisUnits_DL.selection
		LastSysUnits = SysUnits_DL.selection 
		ExportTools = undefined
	)
	
	on ExportTools moved val do
	(
		SetDialogPos ExpFiles (val + [302,0])
	)
	
	on UnitsSet_Btn pressed do
	(
		SettingMaxUnits DisUnits_DL.selection SysUnits_DL.selection
	)
	
	on MeshExp_CB changed val do
	(
		if val do
		(
			AnimExp_CB.checked = false
			SkinExp_CB.checked = false
			MorphExp_CB.checked = false
		)
	)
	
	on AnimExp_CB changed val do
	(
		MeshExp_CB.checked = false
	)
	on SkinExp_CB changed val do
	(
		MeshExp_CB.checked = false
	)
	on MorphExp_CB changed val do
	(
		MeshExp_CB.checked = false
	)
	
	on DisUnits_DL selected val do
	(
		UnitDisplay val SysUnits_DL.selection
	)
	
	on SysUnits_DL selected val do
	(
		UnitDisplay DisUnits_DL.selection val
	)
	
	on ExpFolder_Btn pressed do
	(
		ExpFolder = getSavePath caption:"要导出的Max文件所在文件夹:" initialDir:"D:/"
		if (ExpFolder != undefined) then
		(
			ExpFolder_Lbl.text = ExpFolder
			ExpFilesArray = getMaxFiles ExpFolder
			if ExpFilesArray.count != 0 do
			(
				createdialog ExpFiles pos:(GetDialogPos (ExportTools) + [302,0]) width:250 height:210
				ExpFilesName = #()
				for i in ExpFilesArray do append ExpFilesName (getfilenamefile i)
				ExpFiles.ExpFiles_MLB.items = ExpFilesName
				ExpFiles.ExpFiles_MLB.selection = #{1..ExpFilesName.count}
			)			
		)
		else 
		(
			DestroyDialog ExpFiles
			ExpFolder_Lbl.text = "显示动画文件夹路径"
		)
	)
	
	on ExportTools open do
	(
		DisUnits_DL.selection = LastDisUnits
		SysUnits_DL.selection = LastSysUnits
		fileIn FunctionLib
		UnitDisplay LastDisUnits LastSysUnits
	)
	
	on ExpFolder_Btn rightclick do
	(		
		if ExpFolder != undefined do ShellLaunch ExpFolder ""
	)
	
	on FbxFolder_Btn pressed do
	(
		FbxFolder = getSavePath caption:"指定Fbx文件的保存路径:" initialDir:"D:/"
		if FbxFolder != undefined then ExportTools.FbxFolder_Lbl.text = FbxFolder
		else ExportTools.FbxFolder_Lbl.text = "显示保存文件夹路径:"
	)
	
	on FbxFolder_Btn rightclick do
	(		
		if FbxFolder != undefined do ShellLaunch FbxFolder ""
	)
	
	on ExpBatch_Btn pressed do
	(
		if ExpFilesArray.count != 0 then
		(
			if FbxFolder != undefined then
			(
				ExpSelected = ExpFiles.ExpFiles_MLB.selection as array
				BadFiles = #()	
				DisableSceneRedraw()
				for i in ExpSelected do
				(
					loadMaxFile ExpFilesArray[i] useFileUnits:true quiet:true
					BadBool = false
					if UnitCK_CB.checked do
					(
						BadUnitBool = CheckUnits DisUnits_DL.selected SysUnits_DL.selected
						if BadUnitBool == false do BadBool = true
					)
					if BoneNumCK_CB.checked do
					(
						BadBoneNumBool = CheckBoneNum (BoneNum_ET.text as integer)
						if BadBoneNumBool == false do BadBool = true
					)
					if SkinNumCK_CB.checked do
					(
						BadSkinNumBool = CheckSkinNum (SkinNum_ET.text as integer)
						if BadSkinNumBool == false do BadBool = true
					)
					if FaceNumCK_CB.checked do
					(
						BadFaceNumBool = CheckFaceNum (FaceNum_ET.text as integer)
						if BadFaceNumBool == false do BadBool = true
					)
					if CharNameCK_CB.checked do
					(
						BadCharNameBool = CheckCharFileName()
						if BadCharNameBool == false do BadBool = true
					)
					if BadBool then
					(
						append BadFiles i
					)					
					else 					
					(
						FbxFile = FbxFolder + "\\" + getfilenamefile ExpFilesArray[i] + ".fbx"
						ExpFbx FbxFile AnimExp_CB.checked SkinExp_CB.checked MorphExp_CB.checked
					)
				)
				EnableSceneRedraw()
				if BadFiles.count != 0 do
				(
					ExpFiles.ExpFiles_MLB.selection = BadFiles
					messagebox "右侧列表选中文件有问题，未进行导出！" title:"警告!"					
				)
			)
			else messagebox "未指定FBX的保存文件夹！" title:"保存路径未指定："
		)
		else messagebox "未指定需要导出的文件夹！" title:"导出文件夹为空："
	)
	
	on ExpOne_Btn pressed do
	(
		FbxFile = maxfilepath + getfilenamefile maxfilename + ".fbx"
		ExpFbx FbxFile AnimExp_CB.checked SkinExp_CB.checked MorphExp_CB.checked
	)
	
	on ExpOne_Btn rightclick do
	(		
		try ShellLaunch maxfilepath "" catch()
	)
	
	on CheckOpen_Btn pressed do
	(
		messageText = "本Max文件"
		if UnitCK_CB.checked do
		(
			BadUnitBool = CheckUnits DisUnits_DL.selected SysUnits_DL.selected
			if BadUnitBool == false do messageText += "<单位非规范>"
		)
		if BoneNumCK_CB.checked do
		(
			BadBoneNumBool = CheckBoneNum (BoneNum_ET.text as integer)
			if BadBoneNumBool == false do messageText += "<绑定骨骼数量过多>"
		)
		if SkinNumCK_CB.checked do
		(
			BadSkinNumBool = CheckSkinNum (SkinNum_ET.text as integer)
			if BadSkinNumBool == false do messageText += "<绑定权重影响数量过多>"
		)
		if FaceNumCK_CB.checked do
		(
			BadFaceNumBool = CheckFaceNum (FaceNum_ET.text as integer)
			if BadFaceNumBool == false do messageText += "<模型面数过多>"
		)
		if CharNameCK_CB.checked do
		(
			BadCharNameBool = CheckCharFileName()			
			if BadCharNameBool == false do messageText += "<角色文件或模型命名不规范>"
		)
		if messageText == "本Max文件" then messagebox (messageText + "没有问题") title:"恭喜!"			
		else messagebox (messageText + "--以上方面存在问题。") title:"警告!"
	)
	
	on CheckFolder_Btn pressed do
	(
		checkFolder = getSavePath caption:"要检查的Max文件所在文件夹:" initialDir:"D:/"
		if (checkFolder != undefined) then
		(
			checkFilesArray = getMaxFiles checkFolder
			if checkFilesArray.count != 0 do
			(
				BadUnitArray = #()
				BadBoneArray = #()
				BadSkinNumArray = #()
				BadFaceNumArray = #()
				BadCharNameArray = #()
				BadFileArray = #()
				DisableSceneRedraw()
				for i in checkFilesArray do
				(
					loadMaxFile i useFileUnits:true quiet:true
					tempBad = ""
					if UnitCK_CB.checked do
					(
						BadUnitBool = CheckUnits DisUnits_DL.selected SysUnits_DL.selected
						if BadUnitBool == false do
						(
							append BadUnitArray (getfilenamefile i)
							tempBad += "<单位非规范>"
						)
					)
					if BoneNumCK_CB.checked do
					(
						BadBoneNumBool = CheckBoneNum (BoneNum_ET.text as integer)
						if BadBoneNumBool == false do 
						(
							append BadBoneArray (getfilenamefile i)
							tempBad += "<绑定骨骼数量过多>"
						)	
					)
					if SkinNumCK_CB.checked do
					(
						BadSkinNumBool = CheckSkinNum (SkinNum_ET.text as integer)
						if BadSkinNumBool == false do 
						(
							append BadSkinNumArray (getfilenamefile i)
							tempBad += "<绑定权重影响数量过多>"
						)
					)
					if FaceNumCK_CB.checked do
					(
						BadFaceNumBool = CheckFaceNum (FaceNum_ET.text as integer)
						if BadFaceNumBool == false do 
						(
							append BadFaceNumArray (getfilenamefile i)
							tempBad += "<模型面数过多>"
						)
					)
					if CharNameCK_CB.checked do
					(
						BadCharNameBool = CheckCharFileName()
						if BadCharNameBool == false do 
						(
							append BadCharNameArray (getfilenamefile i)
							tempBad += "<文件或模型命名不规范>"
						)
					)
					if tempBad != "" do
					(
						append BadFileArray ((getfilenamefile i) + "  存在以下问题:----" + tempBad + "\n")
					)
				)
				EnableSceneRedraw()
				if BadFileArray.count != 0 then
				(
					checkFile = "d:\MaxScriptsInfo\CheckLog.bin"
					opfile = openFile checkFile mode:"wb"
					if BadUnitArray.count != 0 do
					(
						format ("--以下文件单位非规范: \n") to:opfile
						for i in BadUnitArray do
						(
							format (i + "\n") to:opfile
						)
						format ("\n\n") to:opfile
					)
					if BadBoneArray.count != 0 do
					(
						format ("--以下文件绑定骨骼数量过多: \n") to:opfile
						for i in BadBoneArray do
						(
							format (i + "\n") to:opfile
						)
						format ("\n\n") to:opfile
					)
					if BadSkinNumArray.count != 0 do
					(
						format ("--以下文件绑定权重影响数量过多: \n") to:opfile
						for i in BadSkinNumArray do
						(
							format (i + "\n") to:opfile
						)
						format ("\n\n") to:opfile
					)
					if BadFaceNumArray.count != 0 do
					(
						format ("--以下文件模型面数过多: \n") to:opfile
						for i in BadFaceNumArray do
						(
							format (i + "\n") to:opfile
						)
						format ("\n\n") to:opfile
					)
					if BadCharNameArray.count != 0 do
					(
						format ("--以下文件文件名或模型命名不规范: \n") to:opfile
						for i in BadCharNameArray do
						(
							format (i + "\n") to:opfile
						)
						format ("\n\n") to:opfile
					)			
					format ("\n\n\n\n") to:opfile
					format ("--以文件进行分类: \n") to:opfile
					for i in BadFileArray do format (i + "\n") to:opfile
					close opfile
					ShellLaunch checkFile ""
				)
				else messagebox "文件没有问题。" title:"恭喜！"
			)			
		)
	)
)
createdialog ExportTools 300 350
