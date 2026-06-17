// HT 160 end cap (one connected solid, manifold-safe)

$fn = 160;

// Parameters (mm)
pipe_outer_diameter = 160;     // OD of pipe
cap_wall_thickness  = 5;       // radial wall thickness of cap body
cap_length          = 50;      // total cap length (open end to closed end)
socket_depth        = 30;      // insertion depth (open end to internal stop)
rim_extra_diameter  = 10;      // outer rim adds to OD (total)
rim_height          = 6;       // axial height of rim/flange at open end
clearance           = 0.6;     // fit clearance over pipe OD
overlap             = 0.2;     // small overlap to ensure robust boolean ops

// Derived diameters
pipe_od   = pipe_outer_diameter;
socket_id = pipe_od + clearance;

cap_od = socket_id + 2*cap_wall_thickness;   // ensures minimum wall thickness even with clearance
rim_od = cap_od + rim_extra_diameter;

// Axial layout (Z=0 at open end, Z=cap_length at closed end)
z_open = 0;
z_end  = cap_length;

// Internal stop face (cavity ends here)
z_stop = socket_depth;

// Safety clamp to avoid negative/zero heights (prevents "blank" geometry)
z_stop_eff = min(max(z_stop, cap_wall_thickness + 1), cap_length - cap_wall_thickness);

module ht_160_cap() {
    difference() {
        // OUTER SOLID: body + rim (connected with overlap)
        union() {
            // Main body
            cylinder(h=cap_length, d=cap_od);

            // Rim/flange at open end
            translate([0, 0, z_open])
                cylinder(h=rim_height + overlap, d=rim_od);
        }

        // INNER VOID: socket cavity from open end to stop face
        translate([0, 0, z_open - overlap])
            cylinder(h=z_stop_eff - z_open + 2*overlap, d=socket_id);

        // Rim underside relief: remove material under rim so it becomes a flange ring
        // Keep a small axial land so rim remains connected to body.
        land_h = max(1, cap_wall_thickness);
        relief_h = max(0, rim_height - land_h);

        if (relief_h > 0)
            translate([0, 0, z_open - overlap])
                cylinder(h=relief_h + 2*overlap, d=cap_od);
    }
}

ht_160_cap();