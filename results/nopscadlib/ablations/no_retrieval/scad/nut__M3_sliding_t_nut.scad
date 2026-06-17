$fn = 64;

// ===== Target dimensions =====
thickness      = 3.0;   // overall thickness (Z)
across_flats   = 6.0;   // hex pocket across flats (driver/nut) (mm)
screw_diameter = 3.0;   // nominal screw size (M3 reference)
hole_diameter  = 3.2;   // M3 clearance hole (mm)

// ===== T-slot nut body (typical 2020/3030 style) =====
body_length   = 10.0;   // along slot (X)
t_head_width  = 5.8;    // undercut capture width (Y) - bottom "head"
t_neck_width  = 3.2;    // slot opening width (Y) - top "neck"
t_head_height = 1.6;    // bottom head height (Z)
t_neck_height = thickness - t_head_height;

// ===== Details =====
chamfer = 0.25;         // small edge chamfer
overlap = 0.20;         // boolean overlap

// Optional spring bump (keeps nut from sliding in slot)
spring_bump_height = 0.45;
spring_bump_radius = 0.90;

// Optional underside serrations (anti-rotation)
serration_count = 6;
serration_depth = 0.30;
serration_width = 0.60;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius from across-flats

module chamfered_block(size=[10,6,3], ch=0.25) {
    // Chamfer by subtracting 45° wedges on all 4 vertical edges
    difference() {
        cube(size, center=true);
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(size[0]/2 - ch/2), sy*(size[1]/2 - ch/2), 0])
                rotate([0,0,45])
                    cube([ch, ch, size[2] + 2*overlap], center=true);
        }
    }
}

module t_profile_body() {
    // One connected solid: neck sits on head (T-shape in YZ)
    union() {
        // Bottom head (captures under slot lips)
        translate([0, 0, -thickness/2 + t_head_height/2])
            chamfered_block([body_length, t_head_width, t_head_height], chamfer);

        // Top neck (fits slot opening)
        translate([0, 0,  thickness/2 - t_neck_height/2])
            chamfered_block([body_length, t_neck_width, t_neck_height], chamfer);
    }
}

module t_slot_nut() {
    difference() {
        union() {
            // Main T-slot nut body
            t_profile_body();

            // Spring bump on top face (connected with overlap)
            translate([0, 0, thickness/2 + spring_bump_height - spring_bump_radius - overlap])
                sphere(r=spring_bump_radius);
        }

        // Through hole for M3 clearance
        cylinder(d=hole_diameter,
                 h=thickness + 2*(spring_bump_height + spring_bump_radius + 2*overlap),
                 center=true);

        // Hex driver pocket on top face (6.0mm across flats)
        hex_depth = min(1.6, thickness - 0.6);
        translate([0, 0, thickness/2 - hex_depth/2 + overlap])
            cylinder(r=hex_R_from_AF(across_flats),
                     h=hex_depth + 2*overlap,
                     center=true, $fn=6);

        // Hole entry chamfers (top and bottom)
        chamfer_h = min(0.5, thickness/2);
        translate([0, 0,  thickness/2 - chamfer_h/2 + overlap])
            cylinder(d1=hole_diameter + 2*chamfer, d2=hole_diameter,
                     h=chamfer_h + 2*overlap, center=true);
        translate([0, 0, -thickness/2 + chamfer_h/2 - overlap])
            cylinder(d1=hole_diameter, d2=hole_diameter + 2*chamfer,
                     h=chamfer_h + 2*overlap, center=true);

        // Underside serrations on the head (bite into extrusion)
        for (i = [1:serration_count]) {
            x_pos = -body_length/2 + (body_length/(serration_count+1))*i;
            translate([x_pos, 0, -thickness/2 + serration_depth/2 - overlap])
                cube([serration_width, t_head_width*0.55, serration_depth + 2*overlap], center=true);
        }
    }
}

t_slot_nut();