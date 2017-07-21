
# makefile for creating the visualizations
# INPUT:  the ground truth files S{0,1,2,3}.tiff
#         the raw unregistered dsm $(NAMES).tif
#         the desired ranges for each site Z{0,1,2,3}.range
# OUTPUT: png visualization of registered dsm
#         png visualization of diff with respect to GT
#         colorbars for everyfile
#
# Needed binaries and scripts:
# plambda, palette, ncc_apply_shift, ncc_compute_shift, autotrim, convert,
# simpois, blur, qauto, downsa, elevate, ijmesh, gdalcopyproj.py

# base names
NAMES          = $(shell cat TARGETS.mk)
NORMALIZED_GTS = Z0.tif Z1.tif Z2.tif Z3.tif

# deduced filenames
DSMS_INPUT     = $(addsuffix .tif,  $(NAMES))      # input dsm
DSMS_REG       = $(addprefix r,     $(DSMS_INPUT)) # registered dsm
DSMS_DIFF      = $(addprefix diff_, $(DSMS_REG))   # signed error wrt. GT
PNG_GTS        = $(NORMALIZED_GTS:%.tif=%.png)     # png of GT
PNG_REG        = $(DSMS_REG:%.tif=%.png)           # png of registered dsm
PNG_DIFF       = $(DSMS_DIFF:%.tif=%.png)          # png of signed errors
RANGES_GTS     = $(NORMALIZED_GTS:%.tif=%.range)   # view range of GT (input)
RANGES_REG     = $(DSMS_REG:%.tif=%.range)         # view range of dsms (computed)

# aggregated collections of files
TIFS     = $(DSMS_REG) $(NORMALIZED_GTS)
PSH_PNGS = $(addprefix psh_,$(PNG_GTS) $(PNG_REG))
P0_PNGS  = $(PNG_GTS) $(PNG_REG)
P1_PNGS  = $(PSH_PNGS) $(PNG_DIFF) $(P0_PNGS)
P2_PNGS  = $(addprefix p2_,$(P1_PNGS))
P3_PNGS  = $(addprefix p3_,$(P1_PNGS))
PNGS     = $(P1_PNGS) $(P2_PNGS) $(P3_PNGS)
JPGS     = $(PNGS:%.png=%.jpg)

RGB_PLY  = $(TIFS:%.tif=c_%.ply)
GEO_PLY  = $(TIFS:%.tif=g_%.ply)
PLYS     = $(RGB_PLY) $(GEO_PLY)

# default target
default: $(JPGS) $(PLYS)

# ground truths: change -9999 to NAN and trim
Z%.tif: S%.tif
	plambda $^ "x -1000 < nan x if" | autotrim - $@

# render ground truths using the requested range
Z%.png: Z%.tif Z%.range
	palette `cat Z$*.range` dem $< -l legend_$@ $@

# render registered files using the corresponding range
rs%.png: rs%.tif rs%.range
	palette `cat rs$*.range` dem $< -l legend_$@ $@

# compute the shadowmap of a dsm (as a png)
sh_%.png: %.tif
	simpois -i $^|plambda - 'x,l -1 *'|blur c 1|plambda - 0\ fmin|qauto - $@

# combine a shadowmap with a colormap
psh_%.png: %.png sh_%.png
	plambda $^ "255 - +" -o $@

# render error images using a centered palette
diff_rs0%.png:Z0.tif rs0%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs1%.png:Z1.tif rs1%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs2%.png:Z2.tif rs2%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs3%.png:Z3.tif rs3%.tif;plambda $^ rot\ -|palette -20 20 nice - $@ -l l_$@

# register each file to the corresponding ground truth
# note: the registered files keep their original size, not the target size
# (is this a bug?)
rs0%.tif: Z0.tif s0%.tif ;ncc_apply_shift s0$*.tif `ncc_compute_shift $^`|plambda Z0.tif - "" -o $@
rs1%.tif: Z1.tif s1%.tif ;ncc_apply_shift s1$*.tif `ncc_compute_shift $^`|plambda Z1.tif - "" -o $@
rs2%.tif: Z2.tif s2%.tif ;ncc_apply_shift s2$*.tif `ncc_compute_shift $^`|plambda Z2.tif - "" -o $@
rs3%.tif: Z3.tif s3%.tif ;ncc_apply_shift s3$*.tif `ncc_compute_shift $^`|plambda Z3.tif - "" -o $@

# build the range for each DSM by copying that of the GT
rs0%.range: Z0.range ; cp Z0.range $@
rs1%.range: Z1.range ; cp Z1.range $@
rs2%.range: Z2.range ; cp Z2.range $@
rs3%.range: Z3.range ; cp Z3.range $@

# convert png to jpg
%.jpg: %.png ; convert $^ $@

# zoom pngs out by factors 2 and 3
p2_%.png: %.png ; downsa v 2 $^ $@
p3_%.png: %.png ; downsa v 3 $^ $@

# create colored ply from dsm and colors
c_%.ply: %.tif psh_%.png
	plambda $*.tif "3 * " | ijmesh psh_$*.png - > $@

# create georefenced ply from dsm
g_%.ply: %.tif
	cp $*.tif geo_$*.tif
	gdalcopyproj.py S`echo $^|tr -c -d [:digit:]|cut -c1`.tif geo_$^
	elevate geo_$^ -p $@ > /dev/null
#	rm geo_$^

clean:
	$(RM) $(PNGS) $(TIFS) $(JPGS) $(RANGES_REG) $(PLYS) geo_*.tif legend_*.png l_*png

.PRECIOUS: $(TIFS) $(PNGS) # preserve intermediate files
.PHONY: default clean
