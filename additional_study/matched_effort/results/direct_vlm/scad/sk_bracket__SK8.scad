$fn = 96;

// Shaft support bracket for 8.0mm rod, 20.0mm tall

// Parameters
rod_d = 8.0;
rod_r = rod_d/2;

height   = 20.0;   // overall height (Z)
base_len = 40.0;   // X
base_w   = 20.0;   // Y
base_t   = 6.0;    // base thickness (Z)

wall_t = 6.0;      // material around bore (radial)
cap_t  = 6.0;      // material above bore to top

mount_hole_d = 5.0;
mount_hole_x_offset = 12.0; // from ends (X)
mount_hole_y_offset = 6.0;  // from front/back edges (Y)

slot_w = 2.0;      // clamp split width (Y)
eps = 0.2;

// Derived
upright_h = height - base_t;

// Bore center: ensure cap thickness above bore and enough material below
bore_center_z_raw = height - cap_t - (rod_r + wall_t);
bore_center_z_min = base_t + rod_r + wall_t;
bore_center_z = max(bore_center_z_raw, bore_center_z_min);

// Ensure bore stays within the part (avoid degenerate/blank results)
bore_center_z = min(bore_center_z, height - cap_t - rod_r);

// Outer radius of the clamp boss
boss_r = rod_r + wall_t;

// Clamp boss length along X (kept within base length)
boss_len = base_len - 2*wall_t;
boss_len = max(boss_len, base_len*0.6);

// Boss center X
boss_cx = base_len/2;

// Boss Z placement: center at bore_center_z
boss_cz = bore_center_z;

// Boss Y placement: centered
boss_cy = base_w/2;

module bracket() {
    difference() {
        union() {
            // Base
            cube([base_len, base_w, base_t], center=false);

            // Upright block (keeps overall envelope and guarantees connectivity)
            translate([0, 0, base_t])
                cube([base_len, base_w, upright_h], center=false);

            // Clamp boss (cylindrical saddle around the rod), connected to upright
            translate([boss_cx, boss_cy, boss_cz])
                rotate([0, 90, 0])
                    cylinder(h=boss_len, r=boss_r, center=true);

            // Side ribs (stiffeners), connected
            rib_t = 3.0;
            rib_h = max(0, upright_h * 0.75);
            translate([0, 0, base_t])
                cube([base_len, rib_t, rib_h], center=false);
            translate([0, base_w - rib_t, base_t])
                cube([base_len, rib_t, rib_h], center=false);
        }

        // Rod bore (through X) with slight clearance
        rod_clear = 0.2;
        translate([boss_cx, boss_cy, boss_cz])
            rotate([0, 90, 0])
                cylinder(h=base_len + 2, r=rod_r + rod_clear/2, center=true);

        // Clamp split slot (from top down past bore center), through X
        slot_z0 = boss_cz; // start at bore center
        slot_h  = height - slot_z0 + 1; // reach above top with margin
        translate([-1, boss_cy - slot_w/2, slot_z0])
            cube([base_len + 2, slot_w, slot_h], center=false);

        // Mounting holes (four holes), through base
        for (x = [mount_hole_x_offset, base_len - mount_hole_x_offset])
            for (y = [mount_hole_y_offset, base_w - mount_hole_y_offset])
                translate([x, y, -1])
                    cylinder(h=base_t + 2, d=mount_hole_d, center=false);

        // Lighten pocket under upright (keeps walls and preserves connectivity)
        pocket_margin_x = 5.0;
        pocket_margin_y = 4.0;
        pocket_z0 = base_t + 1.5;

        // Keep at least wall_t under the bore region
        pocket_z1 = min(boss_cz - boss_r - 1.0, height - 2.0);

        if (pocket_z1 > pocket_z0) {
            translate([pocket_margin_x, pocket_margin_y, pocket_z0])
                cube([base_len - 2*pocket_margin_x,
                      base_w   - 2*pocket_margin_y,
                      pocket_z1 - pocket_z0], center=false);
        }
    }
}

bracket();