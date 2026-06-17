// HT 90 cap (pipe end cap) - connected solid with socket, end wall, lead-in chamfer, and outer bead

$fn = 160;

// Parameters
nominal_D = 90; //[45:180:1]
outer_D = 96; //[48:192:1]
inner_D = 90.5; //[45.25:181:0.1]
wall_t = 3; //[1.5:6:0.1]
cap_total_L = 60; //[30:120:1]
socket_depth = 45; //[22.5:90:1]
end_thickness = 4; //[2:8:0.1]
chamfer_L = 2; //[1:6:0.1]
chamfer_angle = 30; //[15:60:1]  // kept for UI; geometry uses chamfer_L
bead_radial = 1.5; //[0.75:3:0.1]
bead_axial = 3; //[1.5:8:0.1]
fillet_r = 0.8; //[0.4:2:0.1]
overlap = 1; //[0.5:2:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Derived
outer_r = outer_D/2;
inner_r = inner_D/2;

// Ensure valid geometry
socket_depth_eff = min(socket_depth, cap_total_L - end_thickness);
socket_depth_eff = max(socket_depth_eff, chamfer_L + 0.5);

// Z references (centered model)
z_top =  cap_total_L/2;
z_bot = -cap_total_L/2;

// Main solid: outer body + bead (connected)
module outer_solid() {
    union() {
        // Outer cylindrical body
        cylinder(h=cap_total_L, r=outer_r, center=true);

        // External rim bead near open end (overlaps into body by 'overlap')
        translate([0,0, z_top - bead_axial/2 - overlap/2])
            cylinder(h=bead_axial + overlap, r=outer_r + bead_radial, center=true);
    }
}

// Inner void: socket bore + lead-in chamfer (open end only)
module inner_void() {
    union() {
        // Main socket bore (stops before closed end)
        translate([0,0, z_top - socket_depth_eff/2])
            cylinder(h=socket_depth_eff + eps, r=inner_r, center=true);

        // Lead-in chamfer at mouth (slightly larger at the opening)
        translate([0,0, z_top - chamfer_L/2])
            cylinder(h=chamfer_L + eps, r1=inner_r + chamfer_L, r2=inner_r, center=true);
    }
}

// Final cap with approximate fillets (kept small to avoid washing out features)
module ht_cap() {
    minkowski() {
        difference() {
            outer_solid();
            inner_void();
        }
        sphere(r=fillet_r, $fn=64);
    }
}

color([0.85, 0.85, 0.8])
ht_cap();