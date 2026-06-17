$fn = 96;

// Target: centrifugal blower fan, 40.0mm x 40.0mm x 9.5mm (one connected solid)

// Overall envelope
footprint_x = 40.0;
footprint_y = 40.0;
overall_thickness = 9.5;

// Housing / walls
wall = 1.2;                 // casing wall thickness
base_t = 1.2;               // bottom plate thickness
top_t  = 1.2;               // top plate thickness
inner_h = overall_thickness - base_t - top_t;

// Volute / impeller region
impeller_diameter = 30.0;
impeller_thickness = 4.0;
hub_d = 10.0;

// Inlet / outlet
inlet_diameter = 20.0;
outlet_width = 12.0;        // tangential outlet width (X direction)
outlet_height = 6.0;        // outlet height (Y direction)
outlet_len = 10.0;          // outlet extension beyond housing

// Mounting
mounting_hole_diameter = 2.5;
mounting_hole_offset = 3.5;

// Small overlap to guarantee connectivity in unions/differences
eps = 0.25;

// Helpers
module rounded_square_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r=r2);
    }
}

module housing_outer() {
    // Square 40x40 body with slight corner radius
    linear_extrude(height=overall_thickness)
        rounded_square_2d(footprint_x, footprint_y, 3.0);
}

module outlet_outer() {
    // Tangential outlet duct attached to right side (positive X)
    // Centered in Z, centered in Y
    translate([
        footprint_x/2 - eps + (outlet_len + wall)/2,
        0,
        overall_thickness/2
    ])
        cube([outlet_len + wall, outlet_height + 2*wall, overall_thickness], center=true);
}

module internal_cavity() {
    // Main internal cavity: inset from outer walls, leaving base/top thickness
    translate([0, 0, base_t])
        linear_extrude(height=inner_h + eps)
            rounded_square_2d(footprint_x - 2*wall, footprint_y - 2*wall, 2.0);
}

module volute_cavity_2d() {
    // A simple "snail" cavity: impeller circle + expanding outer arc + tangential throat
    // Built as union of circles and a throat rectangle, then clipped to inner square.
    inner_w = footprint_x - 2*wall;
    inner_hh = footprint_y - 2*wall;

    // Impeller center slightly left to make room for outlet on right
    cx = -2.0;
    cy = 0.0;

    r_in = impeller_diameter/2 + 0.8;     // clearance around impeller
    r_out = r_in + 4.0;                   // volute expansion

    intersection() {
        union() {
            // Impeller chamber
            translate([cx, cy]) circle(r=r_in);

            // Volute expansion (outer arc)
            translate([cx, cy]) circle(r=r_out);

            // Throat leading to outlet (tangential on right)
            // Starts near outer arc and points to +X
            throat_x0 = cx + r_in + 1.0;
            throat_len = (inner_w/2 - throat_x0) + (outlet_len + wall) + 2.0;
            translate([throat_x0 + throat_len/2, 0])
                square([throat_len, outlet_height], center=true);
        }

        // Clip to inner housing footprint
        rounded_square_2d(inner_w, inner_hh, 2.0);
    }
}

module volute_cavity_3d() {
    // Carve volute cavity through the inner height
    translate([0, 0, base_t])
        linear_extrude(height=inner_h + eps)
            volute_cavity_2d();
}

module inlet_hole() {
    // Inlet opening on top cover (centered)
    translate([0, 0, overall_thickness - top_t - eps])
        cylinder(h=top_t + 2*eps, d=inlet_diameter, center=false);
}

module outlet_hole() {
    // Open the outlet duct through the side wall and into the duct
    // Carve a rectangular passage at mid-height of cavity
    translate([
        footprint_x/2 - eps + (outlet_len + wall)/2,
        0,
        base_t + inner_h/2
    ])
        cube([outlet_len + wall + 2*eps, outlet_height, inner_h + 2*eps], center=true);
}

module mounting_holes() {
    // Through-holes at corners
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            sx*(footprint_x/2 - mounting_hole_offset),
            sy*(footprint_y/2 - mounting_hole_offset),
            -eps
        ])
            cylinder(h=overall_thickness + 2*eps, d=mounting_hole_diameter, center=false);
    }
}

module impeller_detail() {
    // Simple internal impeller (as solid detail) attached to base so it is one connected solid.
    // It sits inside the cavity; not subtracted.
    z0 = base_t + 0.6; // slightly above base
    translate([0, 0, z0])
    union() {
        // Hub
        cylinder(h=impeller_thickness, d=hub_d, center=false);

        // Disk
        cylinder(h=impeller_thickness, d=impeller_diameter - 2.0, center=false);

        // Blades (radial array), overlapping into disk for connectivity
        blade_count = 10;
        blade_len = (impeller_diameter/2 - hub_d/2) - 1.0;
        blade_w = 2.0;
        overlap = 1.0;

        for (i = [0:blade_count-1]) {
            rotate([0, 0, i*360/blade_count + 12])
                translate([hub_d/2 + blade_len/2 - overlap, 0, 0])
                    cube([blade_len, blade_w, impeller_thickness], center=true);
        }
    }
}

module blower() {
    difference() {
        union() {
            // Outer shell + outlet duct (connected)
            union() {
                housing_outer();
                outlet_outer();
            }

            // Internal impeller detail (connected to base)
            impeller_detail();
        }

        // Carve internal cavity and volute
        internal_cavity();
        volute_cavity_3d();

        // Openings
        inlet_hole();
        outlet_hole();

        // Mounting holes
        mounting_holes();
    }
}

blower();