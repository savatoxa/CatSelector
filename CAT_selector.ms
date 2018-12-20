global char_names = #()
global windowCATSelector
global tmp_selection = #()

--create list of characters 
for obj in helpers do
(
	if classof obj == CATParent then append char_names obj.name
)

-- create list of buttons names corresponding to selected CAT bones belonging to curr_char parent
function createSelectedCatBonesList = (
	global selected_cat_bones = #()
	for obj_from_scene in selection where (classOf obj_from_scene == CATBone or classOf obj_from_scene == HubObject or classOf obj_from_scene == IKTarget) do
	(
		if obj_from_scene.transform.controller.CATParent.name == curr_char then
		(
			for bone_from_list in buttons_bones_list do
			( 
				if obj_from_scene.transform.controller.Address == bone_from_list[2] then
				(						
					append selected_cat_bones bone_from_list[1]
					)
				)
			)
		)
	)

-- match FK and IK via button "Match IK and FK" in max motion panel, because there is no such method in LimdData controller
function MatchIkAndFk selection_ =
(
	for obj in selection_ do
	(
		max motion mode
		forceCompleteRedraw()
		local hwnd = windows.getChildHWND #max "Match IK and FK"
		if hwnd != undefined then 
			(
			animate on
			UIAccessor.SendMessage hwnd[1] 0x201 0 0 -- mouse down
			UIAccessor.SendMessage hwnd[1] 0x202 0 0 -- mouse up
			forceCompleteRedraw()
		)
	)
)

-- move Ik target to palm for each object of current parent in selection, if these object supports this functionality.
function moveIKTargetToPalm char_parent selection_ currFrame = (
		try
		(
		for obj in selection_ do
			if (obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[0].IKTargetValues") then 
				(
				-- because IKTarget doesn't support move IKTarget to palm method, we do this via palm.
				animate on
				((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]").transform.controller.LimbData.MoveIKTargetToEndOfLimb(currFrame)
				)
			else if (obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[1].IKTargetValues") then
				(
				-- because IKTarget doesn't support move IKTarget to palm method, we do this via palm.
				((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]").transform.controller.LimbData.MoveIKTargetToEndOfLimb(currFrame)
				)
			else
				(
				--for nodes that supports move IKTarget to palm method
				animate on
				obj.transform.controller.LimbData.MoveIKTargetToEndOfLimb(currFrame)
				)
		)
		catch ()
	)

--set IKFK_ratio to arg for each object of current parent in selection, if these object supports this functionality.
function set_IKFK_ratio char_parent selection_ arg = (
	try
		(
		for obj in selection_ do
			(
			if  (obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[0].IKTargetValues") then 
				(
				-- because IKTarget doesn't support layerIKFKRatio method, we do this via palm.					
				animate on
				((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]").transform.controller.LimbData.layerIKFKRatio = arg
				)
			else if (obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[1].IKTargetValues") then
				(
				-- because IKTarget doesn't support layerIKFKRatio method, we do this via palm.
				animate on
				((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]").transform.controller.LimbData.layerIKFKRatio = arg
				)
			else
				(
				-- for nodes that supports layerIKFKRatio method
				animate on
				obj.transform.controller.LimbData.layerIKFKRatio = arg
				)
			)
		)
		catch()
	)

-- this func returns IKFK_ratio of limb of current character in format "n.m"
function get_IKFK char_parent node_name = (
	try
	(
		if (getNodeByName char_parent).GetBoneByAddress node_name != undefined then
			(
			substring ((((getNodeByName char_parent).GetBoneByAddress node_name).transform.controller.LimbData.layerIKFKRatio) as string) 1 3
			)
		)
		catch ("")
	)

function selectAllChilds list = (
	for obj in list do 
	(
		append tmp_selection obj
		if obj.children != undefined do 
		(
			selectAllChilds obj.children
			)
		)
	)
	
-- select node of current chracter
function select_node char_parent node_name = (
	if char_names.count != 0 then
		(
		if (getNodeByName char_parent).GetBoneByAddress node_name != undefined then
			(
				if keyboard.controlpressed == true then
				(
				-- add this node to selection if control pressed
				selectmore ((getNodeByName char_parent).GetBoneByAddress node_name)
				)
				else if keyboard.altpressed == true then
				(
				-- delete this node from selection if alt pressed
					deselect ((getNodeByName char_parent).GetBoneByAddress node_name)
				)
				else if keyboard.shiftpressed == true then
				(
				--select all children of selected objects 
					selectmore ((getNodeByName char_parent).GetBoneByAddress node_name)
					tmp_selection = #()
					selectAllChilds selection
					selectmore tmp_selection
					for obj in selection where (classOf obj == CATBone) do
						(
						-- because IKTargets are not children of CAT limbs, we select them separately.
							try 
							(
								if obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm" then
									selectmore ((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[1].IKTargetValues")
								if obj[3].Address == "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm" then
									selectmore ((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Spine[0].Hub.Limb[0].IKTargetValues")
								if obj[3].Address == "SceneRootNode.Hub.Limb[1].Palm" then
									selectmore ((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Limb[1].Platform")
								if obj[3].Address == "SceneRootNode.Hub.Limb[0].Palm" then
									selectmore ((getNodeByName char_parent).GetBoneByAddress "SceneRootNode.Hub.Limb[0].Platform")
							) catch()
						)
				)
				else
				(
				-- select only this node
				select ((getNodeByName char_parent).GetBoneByAddress node_name)
				)
			)
		)
	)

-- function that extents hidden selected objects
function ExtentSelected selection_ = (
	if selection_.count != 0 then
		(	
		selectedObjects = (for obj in selection_ collect obj)
		tmpSphere = Sphere()
		tmpSphere.pos = selection_.center
		tmpSphere.radius = length(selection_.max - selection_.min)/2
		select tmpSphere
		max zoomext sel
		delete tmpSphere
		select selectedObjects
		)
	)
	
callbacks.addScript #selectionSetChanged "switchButtons()" id:#selectionCallbackID
	
rollout windowCATSelector "CAT_selector" width:200 height: 625
(
	dropdownList char_list "Select character" pos:[25,355] width:150 height:40 items: char_names
	global curr_char = char_names[1]
	-- define variables for CAT addresses of bones that represented in UI skeleton
	global head_name = "SceneRootNode.Hub.Spine[0].Hub.Spine[0].Hub"
	global ribcage_name = "SceneRootNode.Hub.Spine[0].Hub"
	global pelvis_name = "SceneRootNode.Hub"
	global RThigh_name = "SceneRootNode.Hub.Limb[1].LimbBone[0].BoneSeg[0]"
	global LThigh_name = "SceneRootNode.Hub.Limb[0].LimbBone[0].BoneSeg[0]"
	global RCalf_name = "SceneRootNode.Hub.Limb[1].LimbBone[1].BoneSeg[0]"
	global LCalf_name = "SceneRootNode.Hub.Limb[0].LimbBone[1].BoneSeg[0]"
	global LCollarbone_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].CollarBone"
	global RCollarbone_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].CollarBone"
	global LUpperarm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[0].BoneSeg[0]"
	global RUpperarm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[0].BoneSeg[0]"
	global LForearm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].LimbBone[1].BoneSeg[0]"
	global RForearm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].LimbBone[1].BoneSeg[0]"
	global LPalm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm"
	global RPalm_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm"
	global LFoot_name = "SceneRootNode.Hub.Limb[0].Palm"
	global RFoot_name = "SceneRootNode.Hub.Limb[1].Palm"
	global LFootDigit11_name = "SceneRootNode.Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]"
	global RFootDigit11_name = "SceneRootNode.Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]"
	global LPlatform_name = "SceneRootNode.Hub.Limb[0].Platform"
	global RPlatform_name = "SceneRootNode.Hub.Limb[1].Platform"
	global LIKTarget_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].IKTargetValues"
	global RIKTarget_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].IKTargetValues"
	global Spine1_name = "SceneRootNode.Hub.Spine[0].SpineLink[0]"
	global Spine2_name = "SceneRootNode.Hub.Spine[0].SpineLink[1]"
	global Spine3_name = "SceneRootNode.Hub.Spine[0].SpineLink[2]"
	global Neck1_name = "SceneRootNode.Hub.Spine[0].Hub.Spine[0].SpineLink[0]"
	global RDigit11_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[0]"
	global RDigit12_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[1]"
	global Rdigit13_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[0].DigitSegParams[2]"
	global LDigit11_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[0]"
	global LDigit12_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[1]"
	global LDigit13_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[0].DigitSegParams[2]"
	global RDigit21_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[0]"
	global RDigit22_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[1]"
	global RDigit23_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[1].DigitSegParams[2]"
	global RDigit31_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[0]"
	global RDigit32_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[1]"
	global RDigit33_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[2].DigitSegParams[2]"
	global RDigit41_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[0]"
	global RDigit42_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[1]"
	global RDigit43_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[3].DigitSegParams[2]"
	global RDigit51_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[0]"
	global RDigit52_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[1]"
	global RDigit53_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[1].Palm.Digit[4].DigitSegParams[2]"
	global LDigit21_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[0]"
	global LDigit22_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[1]"
	global LDigit23_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[1].DigitSegParams[2]"
	global LDigit31_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[0]"
	global LDigit32_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[1]"
	global LDigit33_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[2].DigitSegParams[2]"
	global LDigit41_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[0]"
	global LDigit42_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[1]"
	global LDigit43_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[3].DigitSegParams[2]"
	global LDigit51_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[0]"
	global LDigit52_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[1]"
	global LDigit53_name = "SceneRootNode.Hub.Spine[0].Hub.Limb[0].Palm.Digit[4].DigitSegParams[2]"

	--define initial text for IKFKRatio text labels
	local lbl_LThigh_text_ = get_IKFK curr_char LThigh_name
	local lbl_RThigh_text_ = get_IKFK curr_char RThigh_name
	local lbl_LUpperarm_text_ = get_IKFK curr_char LUpperarm_name
	local lbl_RUpperarm_text_ = get_IKFK curr_char RUpperarm_name
	
	-- define UI sceleton: create buttons corresponding to CAT skeleton
	checkButton btn_head "" pos:[85,20] width:30 height:40 images:#(getdir #maxroot+"UI\Icons\csl_head.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_ribcage "" pos:[65,78] width:70 height:25 images:#(getdir #maxroot+"UI\Icons\csl_ribcage.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_pelvis "" pos:[70,156] width:60 height:20 images:#(getdir #maxroot+"UI\Icons\csl_pelvis.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RThigh "" pos:[70,180] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_RThigh.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LThigh "" pos:[110,180] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_LThigh.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RCalf "" pos:[70,245] width:20 height:65 images:#(getdir #maxroot+"UI\Icons\csl_RCalf.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LCalf "" pos:[110,245] width:20 height:65 images:#(getdir #maxroot+"UI\Icons\csl_LCalf.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LCollarbone "" pos:[120,60] width:50 height:15 images:#(getdir #maxroot+"UI\Icons\csl_LCollarbone.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RCollarbone "" pos:[30,60] width:50 height:15 images:#(getdir #maxroot+"UI\Icons\csl_RCollarbone.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LUpperarm "" pos:[150,80] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_Lupperarm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RUpperarm "" pos:[30,80] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_Rupperarm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LForearm "" pos:[150,145] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_LForearm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RForearm "" pos:[30,145] width:20 height:60 images:#(getdir #maxroot+"UI\Icons\csl_RForearm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LPalm "" pos:[150,210] width:20 height:25 images:#(getdir #maxroot+"UI\Icons\csl_LPalm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RPalm "" pos:[30,210] width:20 height:25 images:#(getdir #maxroot+"UI\Icons\csl_RPalm.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LFoot "" pos:[110,315] width:30 height:20 images:#(getdir #maxroot+"UI\Icons\csl_LFoot.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RFoot "" pos:[60,315] width:30 height:20 images:#(getdir #maxroot+"UI\Icons\csl_RFoot.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LFootDigit11 "" pos:[145,315] width:20 height:20 images:#(getdir #maxroot+"UI\Icons\csl_LFootDigit11.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RFootDigit11 "" pos:[35,315] width:20 height:20 images:#(getdir #maxroot+"UI\Icons\csl_RFootDigit11.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LPlatform "" pos:[110,340] width:55 height:10 images:#(getdir #maxroot+"UI\Icons\csl_LPlatform.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RPlatform "" pos:[35,340] width:55 height:10 images:#(getdir #maxroot+"UI\Icons\csl_RPlatform.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RIKTarget "" pos:[25,240] width:30 height:10 images:#(getdir #maxroot+"UI\Icons\csl_RIKTarget.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LIKTarget "" pos:[145,240] width:30 height:10 images:#(getdir #maxroot+"UI\Icons\csl_LIKTarget.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_Spine1 "" pos:[85,139] width:30 height:15 images:#(getdir #maxroot+"UI\Icons\csl_Spine1.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_Spine2 "" pos:[85,122] width:30 height:15 images:#(getdir #maxroot+"UI\Icons\csl_Spine2.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_Spine3 "" pos:[85,105] width:30 height:15 images:#(getdir #maxroot+"UI\Icons\csl_Spine3.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_Neck1 "" pos:[90,63] width:20 height:12 images:#(getdir #maxroot+"UI\Icons\csl_Neck1.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LPalm_fingers "L Palm" pos:[125,510] width:60 height:20 images:#(getdir #maxroot+"UI\Icons\csl_LPalm_fingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RPalm_fingers "R Palm" pos:[15,510] width:60 height:20 images:#(getdir #maxroot+"UI\Icons\csl_RPalm_fingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit11 "" pos:[80,520] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit12 "" pos:[80,545] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit13 "" pos:[80,570] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit11 "" pos:[105,520] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit12 "" pos:[105,545] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit13 "" pos:[105,570] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit21 "" pos:[60,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit22 "" pos:[60,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit23 "" pos:[60,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit31 "" pos:[42,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit32 "" pos:[42,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit33 "" pos:[42,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit41 "" pos:[24,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit42 "" pos:[24,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit43 "" pos:[24,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit51 "" pos:[6,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit52 "" pos:[6,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_RDigit53 "" pos:[6,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_RFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit21 "" pos:[125,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit22 "" pos:[125,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit23 "" pos:[125,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit31 "" pos:[143,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit32 "" pos:[143,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit33 "" pos:[143,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit41 "" pos:[161,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit42 "" pos:[161,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit43 "" pos:[161,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit51 "" pos:[179,535] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit52 "" pos:[179,560] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	checkButton btn_LDigit53 "" pos:[179,585] width:15 height:20 images: #(getdir #maxroot+"UI\Icons\csl_LFingers.bmp", undefined, 2, 1, 2, 1, 1)
	-- create buttons for IKFK methods	
	button btn_moveIKTargetToPalm "Move IKTarget to Palm" pos:[25,400] width:150 height:20
	button btn_IKFK_0 "IK/KF=0" pos:[25,425] width:70 height:20
	button btn_IKFK_1 "FK/FK=1" pos:[105,425] width:70 height:20
	button btn_MatchIKandFK "Match IK and FK" pos:[25,475] width:150 height:20
	button btn_IK_all "IK Limb" pos:[25,450] width:70 height:20
	button btn_FK_all "FK Limb" pos:[105,450] width:70 height:20
	button btn_extSel "ExtSel" pos:[135,15] width:50 height:30
	--create lables for displaying IKFKRatio when scene time changes
	label lbl_LThigh lbl_LThigh_text_ pos:[140,295] width:30 height:15
	label lbl_RThigh lbl_RThigh_text_ pos:[40,295] width:30 height:15
	label lbl_LUpperarm lbl_LUpperarm_text_ pos:[150,255] width:20 height:15
	label lbl_RUpperarm lbl_RUpperarm_text_ pos:[30,255] width:20 height:15
	
	global buttons_bones_list = #(#("btn_head", head_name), #("btn_ribcage", ribcage_name), #("btn_pelvis", pelvis_name), #("btn_RThigh", RThigh_name), 
						#("btn_LThigh", LThigh_name), #("btn_RCalf", RCalf_name), #("btn_LCalf", LCalf_name), #("btn_LCollarbone", LCollarbone_name),
						#("btn_RCollarbone", RCollarbone_name), #("btn_LUpperarm", LUpperarm_name), #("btn_RUpperarm", RUpperarm_name), 
						#("btn_LForearm", LForearm_name), #("btn_RForearm", RForearm_name), #("btn_LPalm", LPalm_name), #("btn_RPalm", RPalm_name),
						#("btn_LFoot", LFoot_name), #("btn_RFoot", RFoot_name), #("btn_LFootDigit11", LFootDigit11_name), #("btn_RFootDigit11", RFootDigit11_name),
						#("btn_LPlatform", LPlatform_name), #("btn_RPlatform", RPlatform_name), #("btn_RIKTarget", RIKTarget_name), #("btn_LIKTarget", LIKTarget_name),
						#("btn_Spine1", Spine1_name), #("btn_Spine2", Spine2_name), #("btn_Spine3", Spine3_name), #("btn_Neck1", Neck1_name), 
						#("btn_LPalm_fingers", LPalm_name), #("btn_RPalm_fingers", RPalm_name), #("btn_RDigit11", RDigit11_name), #("btn_RDigit12", RDigit12_name),
						#("btn_RDigit13", RDigit13_name), #("btn_LDigit11", LDigit11_name), #("btn_LDigit12", LDigit12_name), #("btn_LDigit13", LDigit13_name), 
						#("btn_RDigit21", RDigit21_name), #("btn_RDigit22", RDigit22_name), #("btn_RDigit23", RDigit23_name), #("btn_RDigit31", RDigit31_name),
						#("btn_RDigit32", RDigit32_name), #("btn_RDigit33", RDigit33_name), #("btn_RDigit41", RDigit41_name), #("btn_RDigit42", RDigit42_name), 
						#("btn_RDigit43", RDigit43_name), #("btn_RDigit51", RDigit51_name), #("btn_RDigit52", RDigit52_name), #("btn_RDigit53", RDigit53_name),
						#("btn_LDigit21", LDigit21_name), #("btn_LDigit22", LDigit22_name), #("btn_LDigit23", LDigit23_name ), #("btn_LDigit31", LDigit31_name),
						#("btn_LDigit32", LDigit32_name), #("btn_LDigit33", LDigit33_name), #("btn_LDigit41", LDigit41_name), #("btn_LDigit42", LDigit42_name),
						#("btn_LDigit43", LDigit43_name), #("btn_LDigit51", LDigit51_name), #("btn_LDigit52", LDigit52_name), #("btn_LDigit53", LDigit53_name))

	
	-- functions that get IKFKRatio from 4 limbs for their lables
		function lbl_LThigh_text = (
			lbl_LThigh.text = get_IKFK curr_char LThigh_name
			)

		function lbl_RThigh_text = (
			lbl_RThigh.text = get_IKFK curr_char RThigh_name
			)
			
		function lbl_LUpperarm_text = (
			lbl_LUpperarm.text = get_IKFK curr_char LUpperarm_name
			)
		
		function lbl_RUpperarm_text = (
			lbl_RUpperarm.text = get_IKFK curr_char RUpperarm_name
			)
	-- this 4 functions grouped in one
	function tcb_limbs_function = (
		try (
			lbl_LThigh_text()
			lbl_RThigh_text()
			lbl_LUpperarm_text()
			lbl_RUpperarm_text()
			) catch()
		)
	
	-- define time callback for upper function, now every time timeslider changes this function will be xecuted
	on windowCATSelector open do
	(
	--switchButtons()
	tcb_limbs = registerTimeCallback tcb_limbs_function
	)
	-- delete callbacks
	on windowCATSelector close do 
	(
		unregisterTimeCallback tcb_limbs
		callbacks.removeScripts #selectionSetChanged id:#selectionCallbackID
	)
	
	-- select character from chracters list, and call tcb_limb_function to refresh IKFKRatio lables 
	on char_list selected i do
	(
		curr_char = char_list.items[i]
		switchButtons()
		tcb_limbs_function()
	)
	
	-- select bones when press associated with them buttons
	on btn_head changed state do (select_node curr_char head_name)
	on btn_ribcage changed state do (select_node curr_char ribcage_name)
	on btn_pelvis changed state do (select_node curr_char pelvis_name)
	on btn_RThigh changed state do (select_node curr_char RThigh_name)
	on btn_LThigh changed state do (select_node curr_char LThigh_name)
	on btn_RCalf changed state do (select_node curr_char RCalf_name)
	on btn_LCalf changed state do (select_node curr_char LCalf_name)
	on btn_LCollarbone changed state do (select_node curr_char LCollarbone_name)
	on btn_RCollarbone changed state do (select_node curr_char RCollarbone_name)
	on btn_LUpperarm changed state do (select_node curr_char LUpperarm_name)
	on btn_RUpperarm changed state do (select_node curr_char RUpperarm_name)
	on btn_LForearm changed state do (select_node curr_char LForearm_name)
	on btn_RForearm changed state do (select_node curr_char RForearm_name)
	on btn_LPalm changed state do (select_node curr_char LPalm_name)
	on btn_RPalm changed state do (select_node curr_char RPalm_name)
	on btn_LFoot changed state do (select_node curr_char LFoot_name)
	on btn_RFoot changed state do (select_node curr_char RFoot_name)
	on btn_LFootDigit11 changed state do (select_node curr_char LFootDigit11_name)
	on btn_RFootDigit11 changed state do (select_node curr_char RFootDigit11_name)
	on btn_LPlatform changed state do (select_node curr_char LPlatform_name)
	on btn_RPlatform changed state do (select_node curr_char RPlatform_name)
	on btn_RIKTarget changed state do (select_node curr_char RIKTarget_name)
	on btn_LIKTarget changed state do (select_node curr_char LIKTarget_name)
	on btn_Spine1 changed state do (select_node curr_char Spine1_name)
	on btn_Spine2 changed state do (select_node curr_char Spine2_name)
	on btn_Spine3 changed state do (select_node curr_char Spine3_name)
	on btn_Neck1 changed state do (select_node curr_char Neck1_name)
	on btn_LPalm_fingers changed state do (select_node curr_char LPalm_name)
	on btn_RPalm_fingers changed state do (select_node curr_char RPalm_name)
	on btn_RDigit11 changed state do (select_node curr_char RDigit11_name)
	on btn_RDigit12 changed state do (select_node curr_char RDigit12_name)
	on btn_RDigit13 changed state do (select_node curr_char RDigit13_name)
	on btn_LDigit11 changed state do (select_node curr_char LDigit11_name)
	on btn_LDigit12 changed state do (select_node curr_char LDigit12_name)
	on btn_LDigit13 changed state do (select_node curr_char LDigit13_name)
	on btn_RDigit21 changed state do (select_node curr_char RDigit21_name)
	on btn_RDigit22 changed state do (select_node curr_char RDigit22_name)
	on btn_RDigit23 changed state do (select_node curr_char RDigit23_name)
	on btn_RDigit31 changed state do (select_node curr_char RDigit31_name)
	on btn_RDigit32 changed state do (select_node curr_char RDigit32_name)
	on btn_RDigit33 changed state do (select_node curr_char RDigit33_name)
	on btn_RDigit41 changed state do (select_node curr_char RDigit41_name)
	on btn_RDigit42 changed state do (select_node curr_char RDigit42_name)
	on btn_RDigit43 changed state do (select_node curr_char RDigit43_name)
	on btn_RDigit51 changed state do (select_node curr_char RDigit51_name)
	on btn_RDigit52 changed state do (select_node curr_char RDigit52_name)
	on btn_RDigit53 changed state do (select_node curr_char RDigit53_name)
	on btn_LDigit21 changed state do (select_node curr_char LDigit21_name)
	on btn_LDigit22 changed state do (select_node curr_char LDigit22_name)
	on btn_LDigit23 changed state do (select_node curr_char LDigit23_name)
	on btn_LDigit31 changed state do (select_node curr_char LDigit31_name)
	on btn_LDigit32 changed state do (select_node curr_char LDigit32_name)
	on btn_LDigit33 changed state do (select_node curr_char LDigit33_name)
	on btn_LDigit41 changed state do (select_node curr_char LDigit41_name)
	on btn_LDigit42 changed state do (select_node curr_char LDigit42_name)
	on btn_LDigit43 changed state do (select_node curr_char LDigit43_name)
	on btn_LDigit51 changed state do (select_node curr_char LDigit51_name)
	on btn_LDigit52 changed state do (select_node curr_char LDigit52_name)
	on btn_LDigit53 changed state do (select_node curr_char LDigit53_name)

	-- call functions corresponding to their buttons
	on btn_extSel pressed do
	(
		ExtentSelected selection
	)
	
	on btn_MatchIKandFK pressed do
	(
		MatchIkAndFk selection
	)
		on btn_IKFK_0 pressed do
	(  
		set_IKFK_ratio curr_char selection 0
		tcb_limbs_function()
	)
	on btn_IKFK_1 pressed do
	(
		set_IKFK_ratio curr_char selection 1
		tcb_limbs_function()
	)
		on btn_moveIKTargetToPalm pressed do
	(	
		moveIKTargetToPalm curr_char selection sliderTime
	)
	on btn_IK_all pressed do
	(
		MatchIkAndFk selection
		moveIKTargetToPalm curr_char selection sliderTime
		set_IKFK_ratio curr_char selection 0
		tcb_limbs_function()
		)
	on btn_FK_all pressed do
	(
		MatchIkAndFk selection
		moveIKTargetToPalm curr_char selection sliderTime
		set_IKFK_ratio curr_char selection 1
		tcb_limbs_function()
		)		
		
)

if char_names.count  == 0 then messagebox "No CAT objects in scene, Add CATParent and relaunch"
createDialog windowCATSelector

_win1_controls = windowCATSelector.controls

-- switch on buttons corresponding to selected CAT bones of curr_char parent
function switchButtons = (
	createSelectedCatBonesList()
	--switch of all buttons from windowCATSelector controls list that have CheckButtonControl type.
	for control_ in _win1_controls do
	(
		parsed_control_ = filterString (control_ as string) ":"
		if parsed_control_[1] == "CheckButtonControl" then 
		(
			control_.state = false
			)
		)
	-- switch on buttons in windowCATSelector controls list which are represented in selected_cat_bones list
 	for control_ in _win1_controls do 
	(
		parsed_control_ = filterString (control_ as string) ":"
		for bone_ in selected_cat_bones do 
		(
			if parsed_control_[2] == bone_ then control_.state = true
			)
		) 
	)
