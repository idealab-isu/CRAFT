// T-slot nut for M3 screws, 6.0mm across flats, 3.0mm thick
// Fixed: ensure end blocks are physically connected to the main body (no gaps/floating)

// Parameters
screw_thread_diameter = 3.0;      // M3 nominal
nut_across_flats      = 6.0;      // hex AF
nut_thickness         = 3.0;      // overall thickness (Z)
nut_length            = 10.0;     // along slot (X)

clearance_allowance   = 0.2;      // hole clearance
chamfer_size          = 0.3;      // end chamfer (X)

// Structural overlap for guaranteed connectivity (1-2mm as required)
overlap               = 1.2;      // boolean overlap / intentional intersection

// Simple T-slot features (kept modest so it still fits typical slots)
wing_thickness_y      = 1.2;      // wing thickness (Y)
wing_height_z         = 1.2;      // wing height (Z) (must be <= nut_thickness)
t_slot_channel_lip_width = 2.0;   // relief width near wings (Y)

// Helpers
function hex_circumradius_from_af(af) = af / sqrt(3); // R such that across flats = af

module hex_prism(af, h, center=true) {
    cylinder(r=hex_circumradius_from_af(af), h=h, $fn=6, center=center);
}

module tslot_nut() {

    // Derived sizes to guarantee a single continuous solid along X
    // Main "bar" spans full nut_length; end blocks are attached by overlapping into the bar.
    bar_y = nut_across_flats - 0.2;
    bar_x = nut_length;

    end_block_x = max(2.5, nut_length * 0.28); // modest end blocks (keeps design intent)
    end_block_y = bar_y;
    end_block_z = nut_thickness;

    // Place end blocks so they intersect the bar by 'overlap' (no gaps)
    end_block_center_x = (bar_x/2 + end_block_x/2 - overlap);

    difference() {
        union() {
            // Main body: hex prism (gives visible 6mm across flats)
            hex_prism(nut_across_flats, nut_thickness, center=true);

            // Central sliding bar (continuous connector)
            cube([bar_x, bar_y, nut_thickness], center=true);

            // End blocks (left/right) - ATTACHED by overlapping into the central bar
            for (sx = [-1, 1]) {
                translate([sx * end_block_center_x, 0, 0])
                    cube([end_block_x, end_block_y, end_block_z], center=true);
            }

            // T-slot wings: connected to the body with overlap
            for (sy = [-1, 1]) {
                translate([0,
                           sy * (nut_across_flats/2 + wing_thickness_y/2 - overlap),
                           0])
                    cube([nut_length, wing_thickness_y, min(wing_height_z, nut_thickness)],
                         center=true);
            }
        }

        // End chamfers (lead-in) on the long block portion
        for (sx = [-1, 1]) {
            translate([sx * (nut_length/2 - chamfer_size/2 + overlap), 0, 0])
                rotate([0, 0, 45])
                    cube([chamfer_size,
                          nut_across_flats + 2*(wing_thickness_y) + 2*overlap,
                          nut_thickness + 2*overlap],
                         center=true);
        }

        // Undercut reliefs near wings (helps fit under slot lips)
        for (sy = [-1, 1]) {
            translate([0,
                       sy * (nut_across_flats/2 - t_slot_channel_lip_width/2 + overlap),
                       0])
                cube([nut_length - 2*chamfer_size,
                      t_slot_channel_lip_width,
                      nut_thickness + 2*overlap],
                     center=true);
        }

        // Through hole for M3 screw (clearance)
        cylinder(r=(screw_thread_diameter + clearance_allowance)/2,
                 h=nut_thickness + 2*overlap,
                 center=true,
                 $fn=48);
    }
}

tslot_nut();