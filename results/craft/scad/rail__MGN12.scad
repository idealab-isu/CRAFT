// Miniature linear guide rail (MGN12-style) — 12mm W x 8mm H x 100mm L
// One connected solid; all placements derived from dimensions.

$fn = 64;

// Parameters
rail_width_mm  = 12.0;   //[6.0:24.0:0.1]
rail_height_mm = 8.0;    //[4.0:16.0:0.1]
rail_length_mm = 100.0;  //[50.0:200.0:1]

mounting_hole_diameter_mm = 3.0;      //[1.5:6.0:0.1]
mounting_hole_count = 4;              //[2:8:1]
mounting_hole_end_offset_mm = 10.0;   //[5.0:20.0:0.1]
hole_clearance_extra_mm = 0.2;        //[0.0:0.6:0.05]

countersink_diameter_mm = 6.0;        //[4.0:8.0:0.1]
countersink_depth_mm = 2.0;           //[1.0:4.0:0.1]

raceway_groove_radius_mm = 1.2;       //[0.6:2.0:0.05]
raceway_groove_depth_mm  = 0.9;       //[0.3:1.5:0.05]

center_relief_width_mm = 4.0;         //[2.0:8.0:0.1]
center_relief_depth_mm = 0.6;         //[0.2:1.5:0.05]

chamfer_mm = 0.5;                     //[0.2:2.0:0.1]
op_overlap_mm = 1.0;                  //[0.5:2.0:0.1]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rail_profile_solid() {
    // IMPORTANT: length must be along X (100mm), width along Y (12mm), height along Z (8mm)
    cube([rail_length_mm, rail_width_mm, rail_height_mm], center=true);
}

module rail() {
    // Derived/validated dimensions
    hole_r = (mounting_hole_diameter_mm + hole_clearance_extra_mm)/2;

    cs_d = clamp(countersink_diameter_mm, mounting_hole_diameter_mm + 0.5, rail_width_mm - 1.0);
    cs_r = cs_d/2;
    cs_h = clamp(countersink_depth_mm, 0.5, rail_height_mm - 1.0);

    // Hole spacing computed from length and end offsets (no arbitrary spacing)
    hole_span = rail_length_mm - 2*mounting_hole_end_offset_mm;
    hole_step = (mounting_hole_count > 1) ? (hole_span/(mounting_hole_count-1)) : 0;

    // Raceway groove placement (near side faces, slightly below top)
    groove_r = clamp(raceway_groove_radius_mm, 0.3, rail_height_mm/2 - 0.6);
    groove_depth = clamp(raceway_groove_depth_mm, 0.1, rail_width_mm/2 - groove_r - 0.4);
    groove_y = rail_width_mm/2 - groove_r - groove_depth; // pushes groove into side face (±Y)
    groove_z = rail_height_mm/2 - groove_r - 0.8;         // near top

    // Center relief on top face
    relief_w = clamp(center_relief_width_mm, 1.0, rail_width_mm - 2*(chamfer_mm + 0.6));
    relief_d = clamp(center_relief_depth_mm, 0.1, rail_height_mm/2 - 0.6);

    color("DimGray")
    difference() {
        // Main solid
        rail_profile_solid();

        // Through mounting holes + countersinks (from top), holes along X
        for (i = [0:mounting_hole_count-1]) {
            x_i = -rail_length_mm/2 + mounting_hole_end_offset_mm + i*hole_step;

            // Through hole (Z axis)
            translate([x_i, 0, 0])
                cylinder(h=rail_height_mm + 2*op_overlap_mm, r=hole_r, center=true);

            // Countersink (conical) from top face
            translate([x_i, 0, rail_height_mm/2 - cs_h/2 + op_overlap_mm*0.01])
                cylinder(h=cs_h + op_overlap_mm*0.02, r1=cs_r, r2=hole_r, center=true);
        }

        // Raceway grooves (two longitudinal half-round cuts) along X
        for (sy = [-1, 1]) {
            translate([0, sy*groove_y, groove_z])
                rotate([0, 90, 0]) // align cylinder axis with X
                    cylinder(h=rail_length_mm + 2*op_overlap_mm, r=groove_r, center=true);
        }

        // Top center relief channel (shallow rectangular pocket) along X
        translate([0, 0, rail_height_mm/2 - relief_d/2 + op_overlap_mm*0.01])
            cube([rail_length_mm + 2*op_overlap_mm, relief_w, relief_d + op_overlap_mm*0.02], center=true);

        // Chamfers: subtract wedges along 4 long edges (keeps one connected solid)
        // Long edges are along X; chamfer the four X-parallel edges at (±Y, ±Z)
        for (sy = [-1, 1], sz = [-1, 1]) {
            translate([0, sy*(rail_width_mm/2 - chamfer_mm), sz*(rail_height_mm/2 - chamfer_mm)])
                rotate([0, 0, sy*sz*45])
                    cube([rail_length_mm + 2*op_overlap_mm, 2*chamfer_mm, 2*chamfer_mm], center=true);
        }
    }
}

// Assembly
rail();