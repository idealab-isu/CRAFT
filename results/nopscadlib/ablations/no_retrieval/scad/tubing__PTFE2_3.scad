// PTFE Tubing (single connected solid) - structurally fixed to be clearly recognizable

// --- Parameters (kept simple, but scaled to be visible in typical orthographic frames) ---
tube_length    = 120;  // was 1000; too long/thin -> looks like a line in ortho views
outer_diameter = 12;   // was 4; increase so side/front views show a real cylinder
inner_diameter = 8;    // was 2; keep a clear hollow bore
end_chamfer    = 1.0;

// Quality
$fn = 128;

// Helpers
outer_r = outer_diameter/2;
inner_r = inner_diameter/2;

// Robustness
eps = 0.05;          // small overlap to avoid coincident faces
wall_min = 0.6;      // ensure visible wall thickness
inner_r_safe = min(inner_r, max(outer_r - wall_min, 0.01));
ch = max(0, min(end_chamfer, outer_r - eps, tube_length/2 - eps));

// Main tube
module ptfe_tube() {
    difference() {
        // Outer body with chamfered ends (single connected solid)
        union() {
            // Main outer cylinder
            cylinder(h=tube_length, r=outer_r, center=true);

            // Chamfer sleeves (slight overlap for watertight union)
            if (ch > 0) {
                // Top chamfer
                translate([0, 0, tube_length/2 - ch/2 + eps/2])
                    cylinder(h=ch + eps, r1=outer_r, r2=max(outer_r - ch, eps), center=true);

                // Bottom chamfer
                translate([0, 0, -tube_length/2 + ch/2 - eps/2])
                    cylinder(h=ch + eps, r1=max(outer_r - ch, eps), r2=outer_r, center=true);
            }
        }

        // Through bore (longer to guarantee clean subtraction)
        cylinder(h=tube_length + 2*eps, r=inner_r_safe, center=true);
    }
}

// Final output
color([0.85, 0.85, 0.8])
ptfe_tube();