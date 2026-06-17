$fn = 96;

// -------------------- Parameters --------------------
shaft_diameter = 8.0;
bore_clearance = 0.5;
bearing_bore_diameter = shaft_diameter + bore_clearance;

mounting_base_length = 55.0;   // X
mounting_base_width  = 42.0;   // Y
mounting_base_height = 10.0;   // Z

mounting_hole_diameter = 5.0;
mounting_hole_offset_x = 18.0; // from center, along X
mounting_hole_offset_y = 14.0; // from center, along Y

fillet_radius = 2.0;

// Housing (pillow block) proportions
housing_length = 36.0;                 // along X (bore axis)
housing_width  = 28.0;                 // along Y
saddle_outer_d = 26.0;                 // outer "arch" diameter
saddle_wall    = 4.0;                  // wall thickness around bore
saddle_inner_d = max(bearing_bore_diameter + 2*saddle_wall, bearing_bore_diameter + 6);

cap_height = 10.0;                     // top cap thickness above bore center
foot_overlap = 1.0;                    // overlap to ensure connectivity

// Split line / clamp slot
split_gap = 1.2;                        // visual split
clamp_bolt_d = 4.0;
clamp_bolt_head_d = 7.5;
clamp_bolt_head_h = 3.0;

// Derived placement: put base bottom at Z=0, and bore center above base
base_z0 = mounting_base_height/2;                 // base center Z
bore_center_z = mounting_base_height + saddle_outer_d/2 - saddle_wall; // typical pillow-block center height

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=1, center=true) {
    minkowski() {
        cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module base_solid() {
    translate([0,0,base_z0])
        rounded_box([mounting_base_length, mounting_base_width, mounting_base_height], r=fillet_radius, center=true);
}

module housing_solid() {
    union() {
        // Main arched body (cylinder along X)
        translate([0, 0, bore_center_z])
            rotate([0, 90, 0])
                cylinder(d=saddle_outer_d, h=housing_length, center=true);

        // Flat top cap (connected into arch)
        translate([0, 0, bore_center_z + saddle_outer_d/2 - cap_height/2 - foot_overlap])
            rounded_box([housing_length, housing_width, cap_height], r=2, center=true);

        // Side cheeks/feet to blend into base (ensure they reach base top and overlap)
        cheek_top_z = bore_center_z + saddle_outer_d/2 - 1;
        cheek_h = cheek_top_z - (mounting_base_height - foot_overlap);
        cheek_h = max(0.01, cheek_h);
        cheek_w = max(5, (mounting_base_width - housing_width) * 0.55);

        for (sy = [-1, 1]) {
            translate([0,
                       sy*(housing_width/2 + cheek_w/2 - foot_overlap),
                       (mounting_base_height - foot_overlap) + cheek_h/2])
                rounded_box([housing_length*0.95, cheek_w, cheek_h], r=2, center=true);
        }

        // Small center pedestal to guarantee connection between arch and base
        pedestal_h = (bore_center_z - saddle_outer_d/2) - (mounting_base_height - foot_overlap);
        pedestal_h = max(0.01, pedestal_h);
        translate([0, 0, (mounting_base_height - foot_overlap) + pedestal_h/2])
            rounded_box([housing_length*0.70, housing_width*0.70, pedestal_h], r=2, center=true);
    }
}

module pillow_block_bearing_unit() {
    difference() {
        union() {
            base_solid();
            housing_solid();
        }

        // Through bore for shaft (along X)
        translate([0, 0, bore_center_z])
            rotate([0, 90, 0])
                cylinder(d=bearing_bore_diameter, h=housing_length + 4, center=true);

        // Bearing insert seat cavity (shorter than housing length)
        translate([0, 0, bore_center_z])
            rotate([0, 90, 0])
                cylinder(d=saddle_inner_d, h=housing_length*0.72, center=true);

        // Split line (slot) across the top cap (along X)
        split_depth = saddle_outer_d*0.60;
        translate([0, 0, bore_center_z + saddle_outer_d/2 - split_depth/2 - 0.2])
            cube([housing_length + 4, split_gap, split_depth], center=true);

        // Clamp bolt holes (two) across the split (along Y), near ends in X
        bolt_x = housing_length*0.30;
        bolt_z = bore_center_z + saddle_outer_d/2 - cap_height*0.55;
        for (sx = [-1, 1]) {
            // Through hole along Y
            translate([sx*bolt_x, 0, bolt_z])
                rotate([90, 0, 0])
                    cylinder(d=clamp_bolt_d, h=housing_width + 12, center=true);

            // Counterbore for head on +Y side
            translate([sx*bolt_x, housing_width/2 - 1, bolt_z])
                rotate([90, 0, 0])
                    cylinder(d=clamp_bolt_head_d, h=clamp_bolt_head_h, center=true);
        }

        // Mounting holes through base (Z)
        for (x = [-mounting_hole_offset_x, mounting_hole_offset_x])
            for (y = [-mounting_hole_offset_y, mounting_hole_offset_y])
                translate([x, y, base_z0])
                    cylinder(d=mounting_hole_diameter, h=mounting_base_height + 4, center=true);
    }
}

// -------------------- Render --------------------
pillow_block_bearing_unit();