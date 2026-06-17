// Dimension-calibrated (target: 0.05 x 0.07 x 0.07 mm)
scale([0.700180, 0.700180, 0.510131])
{
// Short solid cylindrical puck/drum with slightly rounded edges and subtle faceting
// Bounding box: 0.1 x 0.1 x 0.1 mm (X=Y=D, Z=H)

D = 0.1;                 // diameter (mm)
H = 0.1;                 // height   (mm)
R = D/2;

facet_count = 48;        // subtle faceting (higher = more cylindrical)
fillet_r = 0.006;        // edge rounding radius (mm)
eps = 0.0005;            // small overlap for robust union

$fn = facet_count;

// Keep fillet within feasible range
fr = min(fillet_r, R - 1e-6, H/2 - 1e-6);

// Main puck with rounded edges via Minkowski (flat, parallel end faces; no flanges)
minkowski() {
  cylinder(r=R - fr, h=H - 2*fr, center=true);
  sphere(r=fr, $fn=max(24, facet_count));
}
}
