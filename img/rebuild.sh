#!/bin/bash
set -e

# This is a script to rebuild the output images of the website.
#
# Requisites:
#	1. folder "flat" where the output images go (mkdir -p flat)
#	2. folder "menthe" where "menthe" is mounted (sshfs menthe:/ menthe)
test -d menthe/home/facciolo/iarpa
test -d flat || mkdir -p flat

echo "everything seems OK"

# Copy all the input DSMs using flat names
DIR=menthe/home/facciolo/iarpa
DIR0=$DIR/all_pairs
DIR1=$DIR/all_pairs_site1
DIR2=$DIR/all_pairs_site2
DIR3=$DIR/all_pairs_site3

#explorer/Explorern.jpg
#master/MasterProvisional1nn.jpg
#master/MasterProvisional2nn.jpg
#master/MasterProvisional3nn.jpg
cp $DIR/training/ground-truth/Challenge1_Lidar.tif               flat/S0.tif
cp $DIR/MasterProvisional1.tif                                   flat/S1.tif
cp $DIR/MasterProvisional2.tif                                   flat/S2.tif
cp $DIR/MasterProvisional3.tif                                   flat/S3.tif

#explorer/fusion_heuristicNEW_N50_kmedianslow.jpg
#explorer/fusion_heuristicNEW_N50_med.jpg
#explorer/fusion_heuristicNEW_N700_med.jpg
cp $DIR0/fusion_heuristicNEW_N47/kmedianslow.tif                 flat/s0_fu_heNEW_N47_kmedianslow.tif
cp $DIR0/fusion_heuristicNEW_N47/med.tif                         flat/s0_fu_heNEW_N47_med.tif
cp $DIR0/fusion_heuristicNEW_N700/med.tif                        flat/s0_fu_heNEW_N700_med.tif

#explorer/fusion_heuristicNEW_NO_sixtuplet_N50_kmedianslow.jpg
#explorer/fusion_heuristicNEW_NO_sixtuplet_N50_med.jpg
#explorer/fusion_heuristicNEW_NO_sixtuplet_N700_med.jpg
cp $DIR0/fusion_heuristicNEW_NO_sixtuplet_N47/kmedianslow.tif    flat/s0_fu_heNEW_NO_six_N47_kmedianslow.tif
cp $DIR0/fusion_heuristicNEW_NO_sixtuplet_N47/med.tif            flat/s0_fu_heNEW_NO_six_N47_med.tif
cp $DIR0/fusion_heuristicNEW_NO_sixtuplet_N700/med.tif           flat/s0_fu_heNEW_NO_six_N700_med.tif

#explorer/fusion_optimal_order_NO_sixtuplet_N50_kmedianslow.jpg
#explorer/fusion_optimal_order_only_sixtuplet_N16_kmedianslow.jpg
cp $DIR0/fusion_optimal_order_NO_sixtuplet_N47/kmedianslow.tif   flat/s0_fu_op_or_NO_six_N47_kmedianslow.tif
cp $DIR0/fusion_optimal_order_only_sixtuplet_N16/kmedianslow.tif flat/s0_fu_op_or_on_six_N16_kmedianslow.tif

#master/all_pairs_site1_fusion_heuristicNEW_N50_kmedianslow_.jpg
#master/all_pairs_site2_fusion_heuristicNEW_N50_kmedianslow_.jpg
#master/all_pairs_site3_fusion_heuristicNEW_N50_kmedianslow_.jpg
#master/all_pairs_site1_fusion_heuristicNEW_N50_med_.jpg
#master/all_pairs_site2_fusion_heuristicNEW_N50_med_.jpg
#master/all_pairs_site3_fusion_heuristicNEW_N50_med_.jpg
cp $DIR1/fusion_heuristicNEW_N50/kmedianslow.tif                 flat/s1_fu_heNEW_N50_kmedianslow.tif
cp $DIR2/fusion_heuristicNEW_N50/kmedianslow.tif                 flat/s2_fu_heNEW_N50_kmedianslow.tif
cp $DIR3/fusion_heuristicNEW_N50/kmedianslow.tif                 flat/s3_fu_heNEW_N50_kmedianslow.tif
cp $DIR1/fusion_heuristicNEW_N50/med.tif                         flat/s1_fu_heNEW_N50_med.tif
cp $DIR2/fusion_heuristicNEW_N50/med.tif                         flat/s2_fu_heNEW_N50_med.tif
cp $DIR3/fusion_heuristicNEW_N50/med.tif                         flat/s3_fu_heNEW_N50_med.tif

# trim the ground truths so that they are easy to register
for i in 0 1 2 3; do
	autotrim flat/S$i.tif flat/S$i.tiff
done

# register each image to the corresponding ground truth
cd flat
for i in 0 1 2 3; do
	for f in s${i}_*.tif; do
		ncc_compute_shift S$i.tiff $f > $f.reg
		ncc_apply_shift $f `cat $f.reg` r$f
	done
done
cd -

#explorer/fusion_heuristicNEW_N50_kmedianslow_diff.jpg
#explorer/fusion_heuristicNEW_N50_med_diff.jpg
#explorer/fusion_heuristicNEW_N700_med_diff.jpg
#explorer/fusion_heuristicNEW_NO_sixtuplet_N50_kmedianslow_diff.jpg
#explorer/fusion_heuristicNEW_NO_sixtuplet_N50_med_diff.jpg
#explorer/fusion_heuristicNEW_NO_sixtuplet_N700_med_diff.jpg
#explorer/fusion_optimal_order_NO_sixtuplet_N50_kmedianslow_diff.jpg
#explorer/fusion_optimal_order_only_sixtuplet_N16_kmedianslow_diff.jpg
#master/all_pairs_site1_fusion_heuristicNEW_N50_kmedianslow__diff.jpg
#master/all_pairs_site1_fusion_heuristicNEW_N50_med__diff.jpg
#master/all_pairs_site2_fusion_heuristicNEW_N50_kmedianslow__diff.jpg
#master/all_pairs_site2_fusion_heuristicNEW_N50_med__diff.jpg
#master/all_pairs_site3_fusion_heuristicNEW_N50_kmedianslow__diff.jpg
#master/all_pairs_site3_fusion_heuristicNEW_N50_med__diff.jpg
# NOTE: differences are actually computed here
