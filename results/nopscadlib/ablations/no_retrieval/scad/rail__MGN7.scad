// Miniature linear guide rail
// Target overall size: 100mm (L) x 7mm (W) x 5mm (H)

// ---------- Parameters ----------
rail_length = 100.0;          // mm
rail_width  = 7.0;            // mm
rail_height = 5.0;            // mm

mount_hole_diameter = 3.0;    // mm
mount_hole_count    = 4;      // count
end_margin          = 10.0;   // mm from each end to first/last hole

chamfer_size = 0.8;           // mm (end chamfer)
engrave_depth = 0.3;          // mm (shallow recess on top)

fillet_radius = 0.35;         // mm (Minkowski rounding radius)
overlap = 0.2;                // mm (boolean robustness)

// ---------- Helpers ----------
module rail_body_raw() {
    cube([rail_length, rail_width, rail_height], center=true);
}

module mount_hole_cyl(pos_x) {
    // Holes go through width (Y direction), centered in Z
    translate([pos_x, 0, 0])
        rotate([90, 0, 0])
            cylinder(h=rail_width + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=48);
}

module end_chamfer_wedge(pos_x, side=1) {
    // side = +1 for +X end, -1 for -X end
    // Place wedge so it intersects the end face and removes a small 45° chamfer.
    translate([pos_x, 0, 0])
        rotate([0, side*45, 0])
            cube([2*chamfer_size, rail_width + 2*overlap, rail_height + 2*overlap], center=true);
}

module engraved_markings_recess() {
    // Shallow recess on the top face (kept small so it doesn't break the solid)
    translate([0, 0, rail_height/2 - engrave_depth/2 + overlap/2])
        cube([rail_length*0.6, rail_width*0.6, engrave_depth + overlap], center=true);
}

module rounded_rail() {
    // Build the rail (with holes/chamfers/recess), then round edges.
    minkowski() {
        difference() {
            // Base rail with holes and chamfers
            difference() {
                difference() {
                    rail_body_raw();

                    // Evenly spaced holes between end margins
                    union() {
                        for (i = [0:mount_hole_count-1]) {
                            pos_x = -rail_length/2 + end_margin
                                    + i * ((rail_length - 2*end_margin) / (mount_hole_count - 1));
                            mount_hole_cyl(pos_x);
                        }
                    }
                }

                // End chamfers (both ends)
                union() {
                    end_chamfer_wedge( rail_length/2 - chamfer_size,  1);
                    end_chamfer_wedge(-rail_length/2 + chamfer_size, -1);
                }
            }

            // Top recess
            engraved_markings_recess();
        }

        // Rounding kernel
        sphere(r=fillet_radius, $fn=32);
    }
}

// ---------- Output ----------
color([0.75, 0.75, 0.77])
rounded_rail();