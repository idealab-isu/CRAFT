// Pillow block bearing unit (simplified) for 8mm shaft
// Base: 55 x 42 mm
$fn = 120;

// Parameters
shaft_diameter = 8.0;

base_length = 55.0;
base_width  = 42.0;
base_thickness = 6.0;

mounting_hole_diameter = 5.0;
mounting_hole_offset_x = 18.0;   // from center
mounting_hole_offset_y = 13.0;   // from center

// Housing / saddle
saddle_length = 34.0;            // along X
saddle_width  = 26.0;            // along Y
saddle_height = 18.0;            // above base top

bearing_outer_d = 22.0;          // visual bearing seat OD
seat_clearance  = 0.4;           // clearance for bearing seat
bore_clearance  = 0.3;           // clearance for shaft bore

// Connectivity overlap (use 1-2mm as requested)
overlap = 1.2;

// Helpers
module rounded_block(size=[10,10,10], r=2) {
    minkowski() {
        cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=true);
        sphere(r=r);
    }
}

module base_plate() {
    translate([0,0,base_thickness/2])
        cube([base_length, base_width, base_thickness], center=true);
}

// Corner "bolt/fastener" bosses (the floating white/orange circles in the screenshots)
// These are SOLID bosses that are UNIONed to the base and overlap into it.
module corner_fastener_bosses() {
    boss_d = 10.0;                 // visual boss diameter
    boss_h = 3.0;                  // height above base top
    boss_r = boss_d/2;

    // Place bosses at the same XY as mounting holes, but ensure they are fully attached:
    // Bottom of boss is slightly BELOW base top by 'overlap' so it intersects the base.
    z0 = base_thickness - overlap; // boss bottom
    translate([0,0,z0])
        for (x = [-mounting_hole_offset_x, mounting_hole_offset_x])
            for (y = [-mounting_hole_offset_y, mounting_hole_offset_y])
                translate([x, y, 0])
                    cylinder(h=boss_h + overlap, d=boss_d, center=false);
}

module saddle_body() {
    union() {
        // Main block (rounded edges) - overlap into base
        translate([0,0, base_thickness + saddle_height/2 - overlap/2])
            rounded_block([saddle_length, saddle_width, saddle_height], r=3);

        // Arched top (half-cylinder along X)
        cap_r = saddle_width/2;
        cap_len = saddle_length;

        z_top_block = base_thickness + saddle_height;
        translate([0,0, z_top_block - cap_r + overlap])
            rotate([0,90,0])
                difference() {
                    cylinder(h=cap_len, r=cap_r, center=true);
                    translate([0, -cap_r, 0])
                        cube([2*cap_r + 2, 2*cap_r + 2, cap_len + 2], center=true);
                }

        // Small feet/ribs to visually connect housing to base (and strengthen)
        rib_w = 6;
        rib_l = saddle_length - 6;
        rib_h = 6;
        for (sy = [-1, 1]) {
            translate([0, sy*(saddle_width/2 - rib_w/2), base_thickness + rib_h/2 - overlap/2])
                rounded_block([rib_l, rib_w, rib_h], r=1.5);
        }
    }
}

module mounting_holes() {
    // Through holes (also cut through bosses)
    for (x = [-mounting_hole_offset_x, mounting_hole_offset_x])
        for (y = [-mounting_hole_offset_y, mounting_hole_offset_y])
            translate([x, y, -0.5])
                cylinder(h=base_thickness + saddle_height + 30, d=mounting_hole_diameter, center=false);
}

module bearing_seat_and_bore_cuts() {
    axis_z = base_thickness + saddle_height*0.55;

    // Through shaft bore
    translate([0,0,axis_z])
        rotate([0,90,0])
            cylinder(h=base_length + 20, d=shaft_diameter + bore_clearance, center=true);

    // Bearing seat (counterbore)
    seat_len = saddle_length - 8;
    translate([0,0,axis_z])
        rotate([0,90,0])
            cylinder(h=seat_len, d=bearing_outer_d + seat_clearance, center=true);

    // Split-line / top opening notch
    notch_w = saddle_width * 0.55;
    notch_h = 3.0;
    notch_l = saddle_length - 10;
    translate([0,0, axis_z + (bearing_outer_d/2) - notch_h/2])
        cube([notch_l, notch_w, notch_h], center=true);
}

module pillow_block_bearing_unit() {
    difference() {
        union() {
            // Single connected solid: base + bosses + saddle
            base_plate();
            corner_fastener_bosses(); // FIX: add/attach the four corner fastener features
            saddle_body();
        }
        mounting_holes();
        bearing_seat_and_bore_cuts();
    }
}

// Render
pillow_block_bearing_unit();