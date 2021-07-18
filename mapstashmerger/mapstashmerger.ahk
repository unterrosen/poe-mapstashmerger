; automerge remove-only map tabs in poe
;
; special thanks to demented at https://autohotkey.com/board/topic/80205-display-mouse-coordinates-and-copy-them-if-needed/
; for their mouse coordinate script
;
; prerequisites:
; autohotkey installed
; stash affinity set to 'maps' for target map tab
; map tabs set to same map series
; 1920 x 1080 display resolution (display and game)
; windowed fullscreen for poe
; empty inventory
;
; usage:
; start script and focus poe window
; open map tab to be emptied and open inventory (both shall be open)
; press ctrl F4 to run and ctrl F5 to stop
; don't touch anything until done
;


; map tier button coords
global tier_1 := [60, 185]
global tier_2 := [132, 183]
global tier_3 := [199, 183]
global tier_4 := [261, 185]
global tier_5 := [327, 187]
global tier_6 := [397, 187]
global tier_7 := [466, 184]
global tier_8 := [524, 192]
global tier_9 := [590, 181]
global tier_10 := [107, 254]
global tier_11 := [168, 252]
global tier_12 := [237, 252]
global tier_13 := [303, 253]
global tier_14 := [372, 248]
global tier_15 := [432, 250]
global tier_16 := [496, 256]
global tier_u := [569, 252]

global map_tier_buttons := [tier_1, tier_2, tier_3, tier_4, tier_5, tier_6, tier_7, tier_8, tier_9, tier_10, tier_11, tier_12, tier_13, tier_14, tier_15, tier_16, tier_u]

; stash map button coords (visible in map tab)
global map_1 := [111, 326]
global map_2 := [186, 326]
global map_3 := [259, 321]
global map_4 := [331, 323]
global map_5 := [400, 328]
global map_6 := [478, 323]
global map_7 := [546, 320]
global map_8 := [116, 403]
global map_9 := [190, 404]
global map_10 := [261, 404]
global map_11 := [330, 406]
global map_12 := [399, 407]
global map_13 := [478, 405]
global map_14 := [544, 403]
      
global map_buttons := [map_1, map_2, map_3, map_4, map_5, map_6, map_7, map_8, map_9, map_10, map_11, map_12, map_13, map_14]

; scroll buttons
global btn_stash_up := [607, 326]
global btn_stash_down := [607, 391]

global stash_map_1 := [69, 502] ; first map field in stash tab
global inventory_map_1 := [1295, 614] ; first field in inventory

global dist = 48 ; spacing between stash cells
global inv_dist = 52 ; inventory spacing

; rows/columns
global map_tab_height = 6
global map_tab_width = 12
global inv_height = 5
global inv_width = 12

global delay = 25 ; ms to sleep between clicks


Dump_Inventory()
{
	coords := [0, 0]

	i = 0
	Loop, %inv_height%
	{
		j = 0
		Loop, %inv_width%
		{
			coords[1] := inventory_map_1[1] + j * inv_dist ; arrays start at one
			coords[2] := inventory_map_1[2] + i * inv_dist
			MouseMove, coords[1], coords[2], 0
			Sleep, %delay%
			CtrlClick()
			Sleep, %delay%
			j := j + 1
		}
		i := i + 1
	}
}


Dump_Stash()
{
	coords := [0, 0]
	transferred_maps = 0

	For fock, tier in map_tier_buttons
	{
		MouseMove, tier[1], tier[2], 0
		Sleep, %delay%
		Click
		Sleep, %delay%
		Go_up()
		Go_up()

		Loop, 2
		{
			folders: ; goto <3
			For fak, map_folder in map_buttons
			{
				MouseMove, map_folder[1], map_folder[2], 0
				Sleep, %delay%
				Click

				found := FindColorInArea(map_folder, 0xe3912b, 16, 2.6) ; check if folder exists
				if (!found)
					continue folders

				Sleep, 400

				found := CheckMapWindow() ; check if there is contents in folder
				;MsgBox, % map_folder[1]
				if (!found)
					continue folders
				

				i = 0
				Loop, %map_tab_height%
				{
					j = 0

					coords[1] := stash_map_1[1] + j * dist
					coords[2] := stash_map_1[2] + i * dist
					MouseMove, coords[1], coords[2], 0

					;skip := CheckMapWindow()
					;if (skip)
					;	continue 1

					Sleep, 5

					Loop, %map_tab_width%
					{
						coords[1] := stash_map_1[1] + j * dist
						coords[2] := stash_map_1[2] + i * dist
						MouseMove, coords[1], coords[2], 0
						skip := FindColorInArea(coords, 0x000000, 1, 4)
						if (skip)
						{
							j := j + 1
							continue 1
						}
						Sleep, %delay%

						CtrlClick()
						Sleep, %delay%

						transferred_maps := transferred_maps + 1

						max_transfer := inv_height * inv_width
						if (transferred_maps >= max_transfer)
						{
							Dump_Inventory()
							transferred_maps = 0
						}
						j := j + 1
					}
					i := i + 1
				}
			}

			found := FindColorInArea([608, 392], 0xa6926b, 16, 4) ; check if down button is active
			if (!found)
				continue 2

			Go_Down()
		}
	}
}


Go_Down()
{
	MouseMove btn_stash_down[1], btn_stash_down[2], 0
	Sleep, %delay%
	Click,
	Sleep, %delay%
	Click
	Sleep, %delay%
}

Go_up()
{
	MouseMove, btn_stash_up[1], btn_stash_up[2], 0
	Sleep, %delay%
	Click
	Sleep, %delay%
	Click
	Sleep, %delay%
}

CtrlClick()
{
	SetKeydelay, 1
	Send, {Control down}
	Sleep, 5
	Click
	Send, {Control up}
}

FindColorInArea(center, color, deviation, radius)
{
	Sleep, 5
	foundx = 0
	foundy = 0
	d2 := dist / radius
	x1 := center[1] - d2
	x2 := center[1] + d2
	y1 := center[2] - d2
	y2 := center[2] + d2
	PixelSearch, foundx, foundy, x1, y1, x2, y2, color, deviation, Fast RGB
	;MsgBox, % ErrorLevel
	if (ErrorLevel)
		return false
	else
		return true
}

CheckMapWindow()
{
	window_center := [332, 611]
	MouseMove, window_center[1], window_center[2], 0
	red = 0x2b0505
	blue = 0x05051e
	Sleep, 5
	posx = 0
	posyy = 0
	x1 := 45
	x2 := 619
	y1 := 467
	y2 := 755

	PixelSearch, posx, posy, x1, y1, x2, y2, red, 5, Fast RGB
	foundr := ErrorLevel
	PixelSearch, posx, posy, x1, y1, x2, y2, blue, 5, Fast RGB
	foundb := ErrorLevel

	ret := !foundr or !foundb
	return ret ; return 1 when either was found, 0 otherwise
}


^F4::
WinActivate , A
Dump_Stash()
Dump_Inventory()
MsgBox, DONE

^F5::
Reload
