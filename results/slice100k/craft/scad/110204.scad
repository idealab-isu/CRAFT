// Spool / guide roller body with double-conical waist and axial through-bore
// Bounding box target: 10 x 7 x 10 mm (X x Y x Z) => OD_max ~10, L_total ~7

$fn = 128;

// Parameters (mm)
OD_max     = 10.0;   // overall max diameter (X,Y)
L_total    = 7.0;    // overall length (Z)
bore_D     = 3.0;    // through-bore diameter

flange_thk = 2.0;    // thickness of each outer flange
waist_D_min = 5.0;   // minimum diameter at mid-plane (hourglass waist)

overlap = 0.05;      // small overlap to ensure watertight unions/differences

// Derived
waist_len = L_total - 2*flange_thk;                 // axial length between flanges
waist_len = (waist_len < 0.01) ? 0.01 : waist_len;  // guard

module spool_outer() {
    // Build as a single rotate_extrude profile to guarantee the hourglass silhouette
    rotate_extrude(convexity=10)
        polygon(points=[
            // axis line (keeps profile closed)
            [0, -L_total/2],
            [0,  L_total/2],

            // outer surface, from +Z end back to -Z end
            [OD_max/2,  L_total/2],                          // outer face (flat disc)
            [OD_max/2,  L_total/2 - flange_thk],             // inner face of right flange
            [waist_D_min/2, 0],                              // taper to waist at mid-plane
            [OD_max/2, -(L_total/2 - flange_thk)],           // inner face of left flange
            [OD_max/2, -L_total/2]                           // outer face (flat disc)
        ]);
}

module axial_bore() {
    cylinder(d=bore_D, h=L_total + 2*overlap, center=true);
}

difference() {
    spool_outer();
    axial_bore();
}