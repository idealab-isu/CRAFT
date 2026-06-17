$fn = 64;

// 15x15mm aluminium extrusion profile, 100mm long (simplified 4x T-slot style)
size   = 15.0;   // outer width/height (mm)
length = 100.0;  // extrusion length (mm)

// Profile parameters (kept proportional and printable)
wall      = 1.5;  // outer wall thickness
slot_w    = 3.0;  // slot opening width at the surface
slot_d    = 4.0;  // slot depth from surface inward
core_size = 6.0;  // central solid core (keeps model one connected solid)
web_t     = 1.2;  // connecting web thickness from core to outer wall

eps = 0.02;

module extrusion_profile_2d() {
    // Build solid as: (outer ring + core + webs) minus (slot cuts)
    difference() {
        union() {
            // Outer ring (square tube)
            difference() {
                square([size, size], center=true);
                square([size - 2*wall, size - 2*wall], center=true);
            }

            // Central core
            square([core_size, core_size], center=true);

            // Four webs connecting core to the inner wall (ensures one connected solid)
            // Web length reaches to the inner wall plane at y = (size/2 - wall)
            web_len = (size/2 - wall) - core_size/2;
            for (a = [0:90:270]) {
                rotate(a)
                    translate([0, core_size/2 + web_len/2, 0])
                        square([web_t, web_len + 2*eps], center=true); // +eps ensures overlap
            }
        }

        // Four slot openings cut from each face inward
        for (a = [0:90:270]) {
            rotate(a)
                translate([0, size/2 - slot_d/2 + eps, 0])
                    square([slot_w, slot_d + 2*eps], center=true);
        }
    }
}

linear_extrude(height=length, center=false, convexity=10)
    extrusion_profile_2d();