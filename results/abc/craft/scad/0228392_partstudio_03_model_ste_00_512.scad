// Dimension-calibrated (target: 0.02 x 0.86 x 0.05 mm)
scale([0.960000, 0.540000, 0.190000])
{
// Simple long, thin rectangular strip (mm)
// Target bounding box: 0.9 x 0.1 x 0.1

L = 0.9;   // length (X)
W = 0.1;   // width  (Y)
T = 0.1;   // thickness (Z)

// Ensure strictly positive dimensions to avoid empty renders
eps = 0.001;
L_ = (L > eps) ? L : eps;
W_ = (W > eps) ? W : eps;
T_ = (T > eps) ? T : eps;

color([0.85, 0.85, 0.8])
cube([L_, W_, T_], center=false);
}
