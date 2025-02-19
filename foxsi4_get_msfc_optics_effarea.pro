FUNCTION foxsi4_get_msfc_optics_effarea, energy_arr=energy_arr, plot=plot, _extra=extra

  ; :Project:
  ;   FOXSI-4 sounding rocket simulation
  ;
  ; :description:
  ;    This function returns the effective area of the msfc high resolution optics
  ;    Since this is unknown we actually take the sum of the two inner shells of the 10-shell module (modeled values)
  ;
  ; :inputs:
  ;
  ; :outputs:
  ;   The function returns an structure containing the energy array and the effective area
  ;
  ; :keywords:
  ;   energy_arr: an array of energies at which the transmission and absorption are to be calculated
  ;   plot: set to do this analysis for the cmos sensor
  ;
  ; :call:
  ;   This function calls csv tables contained in a folder named optics_data
  ;
  ; :example:
  ;   energy_in = indgen(400)*0.1+1
  ;   area = foxsi4_get_msfc_optics_effarea(energy_arr=energy_in)
  ;
  ; :history:
  ;   2019/08/07, SMusset (UMN), initial release
  ;   2019/10/30, SMusset (UMN), change the effective area to be the sum of the two inner shells (instead of the 3 inner shells)
  ;   2020/09/16, SMusset (UoG), change doc
  ;   2020/10/06, SMusset (UoG), change path access + make it compatible with Mac and Unix
  ;   2022/05/11, Y.Zhang (UMN), update data file
  ;   2022/10/10, Y.Zhang (UMN), update effect area (now we use the innermost and the 3rd innermost shells) 
  ;   
  ; :to be done:
  ;   
  ;-

  DEFAULT, plot, 0

  ; find and read data file 
  ;-------------------------
  os=!VERSION.OS_FAMILY
  IF os EQ 'Windows' THEN sep_char='\' ELSE sep_char='/'
  mypath = routine_filepath()
  sep = strpos(mypath,sep_char,/reverse_search)
  path = strmid(mypath, 0, sep)
  file = path+'/optics_data/3Inner_EA_EPDL97_14AA.csv'  ;roughness 14\AA, using EPDL theoretical model
  ; file = path+'/optics_data/3Inner_EA_Windt_15AA.csv'  ;roughness 15\AA, using Windt model
  ; Note: above roughnesses correspond to the values that best fit lab data in the 10-15 keV energy range

  opt = read_csv(file)

  energy = opt.field2 ; in kev
 ; effarea = opt.field6 ; in cm2 ; this line was used when we used the sum of the three inner shells
 ; effarea = opt.field5 + opt.field4 ; in cm2 ; we now use only the two most inner shells only
 effarea = opt.field5 + opt.field3 ; in cm2 ; we now use the innermost and the 3rd innermost shells (S10 and S08) only

  selec1 = where(energy NE 0)

  energy = energy[selec1]
  effarea = effarea[selec1]

  IF keyword_set(energy_arr) THEN BEGIN
    interpol_data = interpol(effarea, energy, energy_arr)
    ; interpolate data on new energies
  ENDIF ELSE BEGIN
    energy_arr = energy
    interpol_data = effarea
  ENDELSE

  IF plot EQ 1 THEN BEGIN
    plot,energy_arr,interpol_data1,chars=3,xtitle='Energy (keV)',ytitle='Effective area (cm2)', thick=3, xth=2, yth=2, charth=2,title='High resolution optic module (Japan)', _extra=extra
    ;al_legend, ['optics radius '+strtrim(string(r),2)+' mm','optics height 200 mm'], chars=3, charth=2, /right, _extra=extra
  ENDIF

  result = create_struct("energy_keV", energy_arr, "eff_area_cm2", interpol_data)
  RETURN, result
END
