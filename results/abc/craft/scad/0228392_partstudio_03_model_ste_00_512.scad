// Dimension-calibrated (target: 0.02 x 0.86 x 0.05 mm)
scale([0.960000, 0.540000, 19.000000])
{
// Long thin rectangular strip (mm)
// Target bounding box: 0.9 x 0.1 x 0.0 (Z is effectively zero in drawings)
// Use a tiny non-zero thickness so OpenSCAD renders a visible solid.

strip_L = 0.9;     // length (X)
strip_W = 0.1;     // width  (Y)
strip_T = 0.001;   // thickness (Z) - minimal but non-zero for rendering

color([0.85, 0.85, 0.8])
cube([strip_L, strip_W, strip_T], center=true);
}
