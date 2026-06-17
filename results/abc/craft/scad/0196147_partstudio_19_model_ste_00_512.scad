// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([0.000729, 0.000737, 0.001250])
{
// Hex nut-like ring with circular through-hole and slight top/bottom chamfers
// Units: mm

$fn = 96; // smooth circular bore

// Parameters (reasonable, non-zero defaults)
across_flats   = 9.5;
height         = 4.0;
bore_d         = 5.0;
chamfer_h      = 0.6;   // vertical height of chamfer band (each side)
chamfer_inset  = 0.5;   // radial inset of chamfer at outer perimeter
eps            = 0.02;

// Derived
outer_R = across_flats / sqrt(3); // circumradius for hex with given across-flats

module hex2d(R) {
    polygon(points=[
        [ R, 0],
        [ R/2,  R*sqrt(3)/2],
        [-R/2,  R*sqrt(3)/2],
        [-R, 0],
        [-R/2, -R*sqrt(3)/2],
        [ R/2, -R*sqrt(3)/2]
    ]);
}

module outer_with_chamfers() {
    // Build as 3 stacked frustums/prisms to create clear bevels
    union() {
        // Middle straight section
        translate([0,0,0])
            linear_extrude(height=max(height - 2*chamfer_h, eps), center=true)
                hex2d(outer_R);

        // Top chamfer band (tapers inward)
        translate([0,0, (height/2 - chamfer_h/2)])
            linear_extrude(height=chamfer_h, center=true, scale=(outer_R - chamfer_inset)/outer_R)
                hex2d(outer_R);

        // Bottom chamfer band (tapers inward)
        translate([0,0, -(height/2 - chamfer_h/2)])
            linear_extrude(height=chamfer_h, center=true, scale=(outer_R - chamfer_inset)/outer_R)
                hex2d(outer_R);
    }
}

difference() {
    outer_with_chamfers();

    // Circular through-hole (ensure it fully cuts through)
    cylinder(h=height + 2*eps, r=bore_d/2, center=true);

    // Optional slight inner bevels (kept subtle, still circular)
    // Top inner relief
    translate([0,0, (height/2 - chamfer_h/2)])
        cylinder(h=chamfer_h + eps, r1=bore_d/2, r2=bore_d/2 + chamfer_inset, center=true);

    // Bottom inner relief
    translate([0,0, -(height/2 - chamfer_h/2)])
        cylinder(h=chamfer_h + eps, r1=bore_d/2 + chamfer_inset, r2=bore_d/2, center=true);
}
}
