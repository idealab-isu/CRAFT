// T-slot nut for 4.0mm screws, 6.0mm across flats, 3.25mm thick
// One connected solid: true T-slot profile + internal hex socket + M4 clearance/tap hole.

screw_diameter = 4.0;                 //[2.0:8.0:0.1]
hole_style_clearance = 1;             //[0:1:1] 0=tap drill-ish, 1=clearance
tolerance = 0.15;                     //[0.05:0.4:0.01]
across_flats = 6.0;                   //[3.0:12.0:0.1]
thickness = 3.25;                     //[1.6:6.5:0.05]

body_length = 12.0;                   //[6.0:24.0:0.5]
t_slot_major_width = 8.0;             //[4.0:16.0:0.5]
t_slot_minor_width = 6.0;             //[3.0:12.0:0.5]

t_slot_lip_thickness = 1.2;           //[0.6:2.4:0.1]
chamfer_size = 0.3;                   //[0.1:1.0:0.05]
overlap = 0.8;                        //[0.5:2.0:0.1]

// Hex socket depth (internal hex recess), must be <= thickness
hex_socket_depth = 2.2;               //[0.8:3.25:0.05]
// Small extra clearance for the hex socket so 6.0 AF is functional after printing
hex_socket_clear = 0.10;              //[0.0:0.3:0.01]

$fn = 96;

function hex_R_from_AF(af) = af/(2*cos(30)); // circumradius for $fn=6 cylinder

module tslot_nut() {
    // Derived dimensions (keep valid)
    head_h = min(thickness, t_slot_lip_thickness);
    stem_h = max(0, thickness - head_h);

    head_w = max(t_slot_major_width, t_slot_minor_width);
    stem_w = min(t_slot_minor_width, head_w);

    // Hole sizing (clearance vs tap-ish)
    hole_d_clear = screw_diameter + tolerance;
    hole_d_tap   = max(0.1, screw_diameter - tolerance);
    hole_d = hole_d_tap*(1-hole_style_clearance) + hole_d_clear*hole_style_clearance;

    // Hex socket sizing
    hex_af = across_flats + hex_socket_clear;
    hex_r  = hex_R_from_AF(hex_af);
    sock_h = min(hex_socket_depth, thickness);

    difference() {
        // Solid: T-profile prism (this is the actual T-slot nut body)
        union() {
            // Head (wider) at top
            translate([0, 0, thickness/2 - head_h/2])
                cube([body_length, head_w, head_h], center=true);

            // Stem (narrower) below head
            if (stem_h > 0)
                translate([0, 0, -thickness/2 + stem_h/2])
                    cube([body_length, stem_w, stem_h], center=true);
        }

        // Through hole for M4
        cylinder(d=hole_d, h=thickness + 2*overlap, center=true, $fn=64);

        // Lead-in chamfers (top and bottom)
        translate([0, 0, thickness/2 - chamfer_size/2])
            cylinder(d1=hole_d + 2*chamfer_size, d2=hole_d,
                     h=chamfer_size + overlap, center=true, $fn=64);

        translate([0, 0, -thickness/2 + chamfer_size/2])
            cylinder(d1=hole_d, d2=hole_d + 2*chamfer_size,
                     h=chamfer_size + overlap, center=true, $fn=64);

        // Internal hex socket (6.0mm across flats) recessed from the top face
        // Positioned by formula so it is fully within thickness and connected.
        translate([0, 0, thickness/2 - sock_h/2])
            cylinder(r=hex_r, h=sock_h + overlap, center=true, $fn=6);
    }
}

tslot_nut();