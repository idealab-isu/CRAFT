// Dimension-calibrated (target: 0.04 x 0.04 x 0.01 mm)
scale([0.000900, 0.000900, 0.000500])
{
// Flat circular disk with thick outer rim, recessed inner face,
// five octagonal through-holes on a bolt circle, and a central square through-hole.

// ---------- Parameters (mm) ----------
thickness           = 10;     // overall plate thickness
outer_radius        = 20;     // outer disk radius
rim_radial_width    = 4;      // radial width of the thick rim (unrecessed ring)
recess_depth        = 3;      // depth of recessed inner face (from top surface)

bolt_circle_radius  = 11;     // radius of bolt circle for the 5 holes
oct_hole_flat_d     = 4;      // across-flats size of octagon hole
center_square_side  = 2;      // side length of central square through-hole

eps                 = 0.05;   // small overlap to ensure clean booleans
$fn                 = 180;    // smooth circle

// ---------- Derived ----------
inner_radius = outer_radius - rim_radial_width;

// Convert across-flats (2*apothem) to circumradius for regular octagon
// apothem a = R*cos(pi/8) => R = a / cos(pi/8)
oct_R = (oct_hole_flat_d/2) / cos(180/8);

// ---------- Helpers ----------
module octagon2d(R){
    polygon(points=[
        for (i=[0:7]) [ R*cos(i*45), R*sin(i*45) ]
    ]);
}

module oct_hole(){
    linear_extrude(height=thickness + 2*eps, center=true)
        octagon2d(oct_R);
}

module center_square_hole(){
    cube([center_square_side, center_square_side, thickness + 2*eps], center=true);
}

module bolt_circle_holes_5(){
    for (i=[0:4])
        rotate([0,0,i*360/5])
            translate([bolt_circle_radius, 0, 0])
                oct_hole();
}

// ---------- Main solid ----------
module hub_plate(){
    difference(){
        // Base disk
        cylinder(r=outer_radius, h=thickness, center=true);

        // Recessed inner face (remove material from the TOP only)
        // Leaves an outer rim of full thickness.
        translate([0,0, thickness/2 - recess_depth/2 + eps/2])
            cylinder(r=inner_radius, h=recess_depth + eps, center=true);

        // Through-holes
        bolt_circle_holes_5();
        center_square_hole();
    }
}

// ---------- Output ----------
hub_plate();
}
