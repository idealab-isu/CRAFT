// Dimension-calibrated (target: 0.01 x 0.00 x 0.01 mm)
scale([0.000520, 0.000500, 0.000385])
{
// Hex nut-like ring with circular through-hole and slight edge chamfers
// (single connected solid; no floating parts)

$fn = 96;

// --- Parameters (mm) ---
outer_flat_to_flat = 10;     // across flats
thickness          = 4;      // overall thickness (elongated along Z)
hole_d             = 5;      // circular through-hole diameter
edge_chamfer       = 0.4;    // chamfer height on top and bottom edges
overlap            = 0.05;   // boolean robustness

// --- Derived ---
outer_R = outer_flat_to_flat / sqrt(3); // circumradius for hex with given flat-to-flat
inner_R = max(outer_R - edge_chamfer, 0.01);
mid_h   = max(thickness - 2*edge_chamfer, 0.01);

// 2D hex helper
module hex2d(R){
    polygon(points=[
        [ R, 0],
        [ R/2,  R*0.866025403784],
        [-R/2,  R*0.866025403784],
        [-R, 0],
        [-R/2, -R*0.866025403784],
        [ R/2, -R*0.866025403784]
    ]);
}

// Outer body with slight chamfer via hull of three extrusions
module outer_body(){
    hull(){
        // bottom "cap"
        translate([0,0,-thickness/2])
            linear_extrude(height=overlap, center=false) hex2d(outer_R);

        // middle inset
        translate([0,0,-mid_h/2])
            linear_extrude(height=mid_h, center=true) hex2d(inner_R);

        // top "cap"
        translate([0,0, thickness/2 - overlap])
            linear_extrude(height=overlap, center=false) hex2d(outer_R);
    }
}

// Circular through-hole (true circle, not polygonal)
module through_hole(){
    cylinder(d=hole_d, h=thickness + 2*overlap, center=true, $fn=128);
}

// Final solid
difference(){
    outer_body();
    through_hole();
}
}
