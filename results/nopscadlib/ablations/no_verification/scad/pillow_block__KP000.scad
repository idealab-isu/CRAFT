$fn = 96;

// -------------------- Parameters --------------------
shaft_diameter_mm = 10;                 //[5:20:0.5]
shaft_bore_clearance_mm = 0.2;          //[0.05:0.6:0.05]

base_length_mm = 67;                    //[34:134:1]
base_width_mm  = 53;                    //[27:106:1]
base_thickness_mm = 12;                 //[6:24:1]

overall_height_mm = 36;                 //[18:72:1]

housing_outer_diameter_mm = 34;         //[20:60:1]
housing_length_mm = 53;                 //[30:90:1]

mounting_hole_diameter_mm = 11;         //[6:16:0.5]
mounting_hole_clearance_mm = 0.5;       //[0.1:1.5:0.1]
mounting_hole_center_spacing_mm = 50;   //[30:90:1]

bearing_insert_id_mm = 10;              //[5:20:0.5]
bearing_insert_od_mm = 30;              //[18:50:1]
bearing_insert_width_mm = 16;           //[8:30:1]
bearing_seat_clearance_mm = 0.2;        //[0.05:0.6:0.05]

// Pillow-block styling (simple KP-like pedestal + feet)
foot_end_margin_mm = 6;                 // margin from base ends to start of pedestal
foot_side_margin_mm = 6;                // margin from base sides to start of pedestal
pedestal_height_mm = 14;                // height above base top up to housing tangent region
fillet_r_mm = 6;                        // rounded transitions (hull-based)
transition_overlap_mm = 1;              //[0.5:2:0.1]

// -------------------- Derived --------------------
base_z0 = 0;
base_z1 = base_thickness_mm;

housing_r = housing_outer_diameter_mm/2;
housing_y_len = housing_length_mm;

shaft_r = (shaft_diameter_mm + shaft_bore_clearance_mm)/2;
seat_r  = (bearing_insert_od_mm + bearing_seat_clearance_mm)/2;

// Place housing so overall height matches: top of housing at overall_height
housing_center_z_mm = overall_height_mm - housing_r;

// Pedestal footprint (kept within base)
pedestal_len_x = max(10, base_length_mm - 2*foot_end_margin_mm);
pedestal_w_y   = max(10, base_width_mm  - 2*foot_side_margin_mm);

// Pedestal top Z (below housing center so it blends into housing)
pedestal_top_z = base_z1 + pedestal_height_mm;

// Ensure pedestal reaches into housing a bit for connectivity
pedestal_to_housing_overlap_z = max(transition_overlap_mm, 1);

// -------------------- Helpers --------------------
module rounded_block(size=[10,10,10], r=2, center=false) {
    // Minkowski is robust but heavier; keep r modest.
    // If r <= 0, fall back to cube.
    if (r <= 0)
        cube(size, center=center);
    else
        minkowski() {
            cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
            sphere(r=r);
        }
}

module kp_body_solid() {
    union() {
        // Base with softened edges
        translate([0,0, base_thickness_mm/2])
            rounded_block([base_length_mm, base_width_mm, base_thickness_mm], r=min(fillet_r_mm, base_thickness_mm/2-0.01), center=true);

        // Pedestal (raised "pillow" feet area)
        // Use hull between a lower wide block and an upper narrower block to mimic KP pedestal.
        hull() {
            // Lower pedestal block (on base top)
            translate([0,0, base_z1 + (pedestal_top_z-base_z1)*0.35/2])
                rounded_block([pedestal_len_x, pedestal_w_y, (pedestal_top_z-base_z1)*0.35],
                              r=min(fillet_r_mm, (pedestal_top_z-base_z1)*0.35/2-0.01), center=true);

            // Upper pedestal block (closer to housing)
            upper_h = (pedestal_top_z-base_z1)*0.65 + pedestal_to_housing_overlap_z;
            translate([0,0, base_z1 + (pedestal_top_z-base_z1)*0.35 + upper_h/2])
                rounded_block([pedestal_len_x*0.72, pedestal_w_y*0.72, upper_h],
                              r=min(fillet_r_mm, upper_h/2-0.01), center=true);
        }

        // Main housing cylinder (axis along Y)
        translate([0,0,housing_center_z_mm])
            rotate([90,0,0])
                cylinder(r=housing_r, h=housing_y_len, center=true);

        // Blend pedestal into housing with a hull "saddle" so it's one connected solid
        hull() {
            // A small block at pedestal top
            blend_h = max(2, fillet_r_mm);
            translate([0,0, pedestal_top_z - blend_h/2 + pedestal_to_housing_overlap_z])
                rounded_block([housing_outer_diameter_mm*0.9, pedestal_w_y*0.65, blend_h],
                              r=min(fillet_r_mm, blend_h/2-0.01), center=true);

            // A thin slice of the housing near its bottom tangent
            translate([0,0, (housing_center_z_mm - housing_r) + blend_h/2])
                rotate([90,0,0])
                    cylinder(r=housing_r*0.98, h=pedestal_w_y*0.65, center=true);
        }
    }
}

module kp_cutouts() {
    // Mounting holes (through base)
    hole_r = (mounting_hole_diameter_mm + mounting_hole_clearance_mm)/2;
    hole_h = base_thickness_mm + 2*transition_overlap_mm;

    for (sx = [-1, 1]) {
        translate([sx*mounting_hole_center_spacing_mm/2, 0, base_thickness_mm/2])
            cylinder(r=hole_r, h=hole_h, center=true);
    }

    // Shaft bore (through housing along Y)
    translate([0,0,housing_center_z_mm])
        rotate([90,0,0])
            cylinder(r=shaft_r, h=housing_y_len + 2*transition_overlap_mm, center=true);

    // Bearing seat counterbore (centered in housing)
    translate([0,0,housing_center_z_mm])
        rotate([90,0,0])
            cylinder(r=seat_r, h=bearing_insert_width_mm, center=true);
}

// -------------------- Final Assembly --------------------
difference() {
    kp_body_solid();
    kp_cutouts();
}