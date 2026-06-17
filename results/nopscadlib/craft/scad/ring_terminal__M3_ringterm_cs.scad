// Ring terminal (connected solid, smooth hole, detailed neck/barrel transition)

// Parameters
outer_diameter_od = 10; //[5:20:0.5]
inner_diameter_id = 5; //[2.5:10:0.5]
thickness_t = 1; //[0.5:2:0.1]
width_w = 6; //[3:12:0.5]
overall_length_l = 20; //[10:40:1]
crimp_length = 0; //[0:30:1]
bend_angle_deg = 45; //[0:90:1]
transition_length = 1; //[0.5:3:0.1]
wire_hole_diameter = 0; //[0:8:0.5]
overlap_eps = 1; //[0.5:2:0.1]
cut_slot_width = 0.8; //[0.4:2:0.1]
cut_slot_extra = 2; //[1:6:0.5]

$fn = 128;

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

module ring_terminal_assembly() {
    // Derived dimensions (ensure valid)
    od = max(outer_diameter_od, inner_diameter_id + 2*thickness_t + 0.2);
    id = min(inner_diameter_id, od - 2*thickness_t - 0.2);
    t  = thickness_t;
    w  = width_w;

    ring_r_out = od/2;
    ring_r_in  = id/2;

    // Tongue length from ring tangent to end
    tongue_len = max(overall_length_l - ring_r_out, w*0.8);

    // Neck/transition sizing (adds detail vs a simple block)
    neck_len = max(transition_length, t*1.5);
    neck_w   = clamp(w*0.75, t*2.0, w);
    neck_h   = clamp(w*0.55, t*2.0, w);

    // Barrel sizing
    barrel_len = max(crimp_length, 0);
    barrel_r_out = w/2;
    barrel_r_in  = max(barrel_r_out - t, t*0.6);

    // Coordinate system:
    // Ring center at origin. Tongue extends in -Y direction.
    // Plate centered at z=0 (thickness along Z).
    z0 = 0;

    // Key Y positions
    y_ring_center = 0;
    y_ring_tangent = -ring_r_out;                 // where tongue meets ring
    y_tongue_end = y_ring_tangent - tongue_len;   // far end of tongue

    // Place tongue so its top edge touches ring tangent with overlap
    y_tongue_center = (y_ring_tangent - tongue_len/2) - overlap_eps/2;

    // Neck sits at the tongue start (near ring), centered slightly into tongue
    y_neck_center = y_ring_tangent - neck_len/2 + overlap_eps/2;

    // Barrel sits after neck, further down the tongue
    y_barrel_center = y_ring_tangent - neck_len - barrel_len/2 + overlap_eps/2;

    // Build as one connected solid, then subtract holes/slots
    difference() {
        union() {
            // Ring (washer)
            difference() {
                cylinder(r=ring_r_out, h=t, center=true);
                cylinder(r=ring_r_in,  h=t + 2*overlap_eps, center=true);
            }

            // Tongue plate (flat)
            translate([0, y_tongue_center, z0])
                cube([w, tongue_len + overlap_eps, t], center=true);

            // Detailed neck/transition: hull between tongue and barrel profile
            // This creates a smoother, more realistic transition than a simple block.
            hull() {
                // Near ring: slightly narrower and lower neck block
                translate([0, y_neck_center + neck_len*0.15, z0 + (neck_h - t)/2])
                    cube([neck_w, neck_len*0.7 + overlap_eps, neck_h], center=true);

                // Toward barrel: approach barrel diameter
                translate([0, y_neck_center - neck_len*0.35, z0 + (w - t)/2])
                    cube([w, neck_len*0.7 + overlap_eps, w], center=true);
            }

            // Crimp barrel shell (optional)
            if (barrel_len > 0) {
                // Outer barrel
                translate([0, y_barrel_center, z0 + (w - t)/2])
                    rotate([90, 0, 0])
                        cylinder(r=barrel_r_out, h=barrel_len + overlap_eps, center=true);

                // Blend from neck to barrel with a short hull (adds detail)
                hull() {
                    translate([0, y_ring_tangent - neck_len + overlap_eps/2, z0 + (w - t)/2])
                        cube([w, overlap_eps, w], center=true);
                    translate([0, y_ring_tangent - neck_len - min(barrel_len, w*0.6)/2 + overlap_eps/2, z0 + (w - t)/2])
                        rotate([90, 0, 0])
                            cylinder(r=barrel_r_out, h=min(barrel_len, w*0.6) + overlap_eps, center=true);
                }
            }
        }

        // Optional wire hole in tongue end (through thickness)
        if (wire_hole_diameter > 0) {
            translate([0, y_tongue_end + w*0.6, z0])
                cylinder(r=wire_hole_diameter/2, h=t + 2*overlap_eps, center=true);
        }

        // Crimp barrel inner void + seam slot (optional)
        if (barrel_len > 0) {
            // Inner void
            translate([0, y_barrel_center, z0 + (w - t)/2])
                rotate([90, 0, 0])
                    cylinder(r=barrel_r_in, h=barrel_len + 2*overlap_eps, center=true);

            // Slot cut along barrel length (connects to inner void)
            slot_len = barrel_len + neck_len + cut_slot_extra;
            translate([0,
                       (y_ring_tangent - neck_len) - slot_len/2 + overlap_eps/2,
                       z0 + (w - t)/2])
                cube([cut_slot_width, slot_len, w + 2*overlap_eps], center=true);
        }
    }
}

ring_terminal_assembly();