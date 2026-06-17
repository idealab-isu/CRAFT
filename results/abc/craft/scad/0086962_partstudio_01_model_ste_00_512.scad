// Dimension-calibrated (target: 0.02 x 0.01 x 0.02 mm)
scale([0.000278, 0.000278, 0.000208])
{
// Spur-gear-like wheel with external teeth and central hex through-bore
// Single connected solid, constant thickness, flat parallel faces

$fn = 128;

// -------------------- Parameters (mm) --------------------
thickness = 24;                 // make clearly elongated along Z (constant thickness)
tooth_count = 12;

root_diam  = 60;                // diameter of main circular body (tooth roots)
outer_diam = 72;                // diameter at tooth tips

tooth_radial = (outer_diam - root_diam)/2;   // radial tooth height
tooth_width_tangential = 10;                 // tooth width (tangential)

hex_flat_to_flat = 20;          // hex bore size (across flats)
hex_clearance = 0.25;           // clearance on flats

eps = 0.2;                      // small overlap to ensure watertight unions/differences

// -------------------- Helpers --------------------
function hex_R_from_flat(flat) = flat / sqrt(3); // circumradius for a hex with given flat-to-flat

module hex2d(flat) {
    R = hex_R_from_flat(flat);
    polygon(points=[ for (k=[0:5]) [ R*cos(60*k), R*sin(60*k) ] ]);
}

// -------------------- Geometry --------------------
module gear_body_disc() {
    cylinder(h=thickness, r=root_diam/2, center=true);
}

module tooth_3d() {
    // X = radial length, Y = tangential width, Z = thickness
    cube([tooth_radial + 2*eps, tooth_width_tangential, thickness], center=true);
}

module external_teeth_array() {
    // Teeth protrude outward; inner edge overlaps into the hub by eps
    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([root_diam/2 + tooth_radial/2 - eps, 0, 0])
                tooth_3d();
    }
}

module gear_plus_teeth() {
    union() {
        gear_body_disc();
        external_teeth_array();
    }
}

module central_hex_through_bore() {
    // Through-bore along Z; slightly taller to guarantee clean subtraction
    linear_extrude(height=thickness + 2*eps, center=true)
        hex2d(hex_flat_to_flat + hex_clearance);
}

difference() {
    gear_plus_teeth();
    central_hex_through_bore();
}
}
