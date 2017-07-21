
# makefile for creating the visualizations
# INPUT:  the ground truth files S{0,1,2,3}.tiff
#         the raw unregistered dsm $(NAMES).tif
#         the desired ranges for each site Z{0,1,2,3}.range
# OUTPUT: png visualization of registered dsm
#         png visualization of diff with respect to GT
#         colorbars for everyfile
#
# Needed binaries:
# plambda, palette, ncc_apply_shift, ncc_compute_shift, autotrim

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
RANGES_GTS     = $(NORMALIZED_GTS:%.tif=%.range)   # view range of GT
RANGES_REG     = $(DSMS_REG:%.tif=%.range)         # view range of dsms

# default target
default: $(PNG_GTS) $(PNG_REG) $(PNG_DIFF)

# ground truths: change -9999 to NAN and trim
Z%.tif: S%.tif
	plambda $^ "x -1000 < nan x if" | autotrim - $@

# render ground truths using the requested range
Z%.png: Z%.tif Z%.range
	palette `cat Z$*.range` dem $< -l legend_$@ $@

# render registered files using the corresponding range
rs%.png: rs%.tif rs%.range
	palette `cat rs$*.range` dem $< -l legend_$@ $@

# render error images using a centered palette
diff_rs0%.png:Z0.tif rs0%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs1%.png:Z1.tif rs1%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs2%.png:Z2.tif rs2%.tif;plambda $^ rot\ -|palette -10 10 nice - $@ -l l_$@
diff_rs3%.png:Z3.tif rs3%.tif;plambda $^ rot\ -|palette -20 20 nice - $@ -l l_$@

# register each file to the corresponding ground truth
rs0%.tif: Z0.tif s0%.tif ;./ncc_apply_shift s0$*.tif `./ncc_compute_shift $^` $@
rs1%.tif: Z1.tif s1%.tif ;./ncc_apply_shift s1$*.tif `./ncc_compute_shift $^` $@
rs2%.tif: Z2.tif s2%.tif ;./ncc_apply_shift s2$*.tif `./ncc_compute_shift $^` $@
rs3%.tif: Z3.tif s3%.tif ;./ncc_apply_shift s3$*.tif `./ncc_compute_shift $^` $@

# build the range for each DSM by copying that of the GT
rs0%.range: Z0.range ; cp Z0.range $@
rs1%.range: Z1.range ; cp Z1.range $@
rs2%.range: Z2.range ; cp Z2.range $@
rs3%.range: Z3.range ; cp Z3.range $@

TIFS = $(DSMS_REG) $(NORMALIZED_GTS)
PNGS = $(PNG_REG) $(PNG_GTS) $(PNG_DIFF)
clean:
	$(RM) $(PNGS) $(TIFS) legend_*.png

.SECONDARY: $(NORMALIZED_GTS) $(DSMS_REG) $(DSMS_DIFF)
.PHONY: default clean
