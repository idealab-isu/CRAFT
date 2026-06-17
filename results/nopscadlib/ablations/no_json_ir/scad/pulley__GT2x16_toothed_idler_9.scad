// Timing pulley: 16 teeth, 9.75mm pitch diameter
// One connected solid; all placements are formula-based.

$fn = 180;

// ---------------- Parameters ----------------
tooth_count        = 16;
pitch_diameter     = 9.75;   // mm (pitch circle diameter)
bore_diameter      = 5;      // mm

hub_diameter       = 12;     // mm
hub_length         = 10;     // mm

pulley_width       = 6;      // mm (toothed section width)
flange_thickness   = 1.5;    // mm
flange_diameter    = pitch_diameter + 4; // mm

set_screw_diameter = 2;      // mm
set_screw_distance = 3;      // mm from center

// Tooth geometry (simplified but clearly countable)
tooth_height       = 1.10;   // mm radial height above pitch circle (more visible)
tooth_tip_arc_frac = 0.55;   // fraction of tooth angular pitch occupied by tooth tip
tooth_root_relief  = 0.55;   // mm relief below pitch circle between teeth (visible valleys)

// ---------------- Derived ----------------
pitch_r = pitch_diameter/2;
outer_r = pitch_r + tooth_height;
root_r  = max(pitch_r - tooth_root_relief, bore_diameter/2 + 1.0);

// Z layout (centered overall)
overlap_z = 0.25; // small overlap to guarantee watertight unions
z_tooth_center = 0;
z_hub_center   = -(pulley_width/2 + hub_length/2 - overlap_z);
z_flange_top   =  (pulley_width/2 + flange_thickness/2 - overlap_z);
z_flange_bot   = -(pulley_width/2 + flange_thickness/2 - overlap_z);

// ---------------- Modules ----------------
module tooth_ring() {
    // Root cylinder + outward teeth; teeth overlap into root cylinder for connectivity.
    overlap_r = 0.35;

    ang = 360/tooth_count;
    tooth_ang = ang * tooth_tip_arc_frac;

    // Tangential tooth width at pitch circle (use pitch_r so tooth count is visually clear)
    tooth_w = 2 * pitch_r * sin(tooth_ang/2);

    // Radial tooth length from root to outer
    tooth_len = (outer_r - root_r) + overlap_r;

    union() {
        // Root cylinder (valleys)
        cylinder(h=pulley_width, r=root_r, center=true);

        // Teeth
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*ang])
                translate([root_r + tooth_len/2 - overlap_r, 0, 0])
                    cube([tooth_len, tooth_w, pulley_width], center=true);
        }
    }
}

module pulley() {
    difference() {
        union() {
            // Toothed section
            tooth_ring();

            // Hub (overlaps into toothed section)
            translate([0,0,z_hub_center])
                cylinder(h=hub_length, d=hub_diameter, center=true);

            // Flanges (overlap into toothed section)
            translate([0,0,z_flange_top])
                cylinder(h=flange_thickness, d=flange_diameter, center=true);

            translate([0,0,z_flange_bot])
                cylinder(h=flange_thickness, d=flange_diameter, center=true);
        }

        // Bore through entire part
        total_h = hub_length + pulley_width + 2*flange_thickness + 2;
        cylinder(h=total_h, d=bore_diameter, center=true);

        // Set screw holes (radial, through hub region)
        for (a = [0,180]) {
            rotate([0,0,a])
                translate([set_screw_distance, 0, z_hub_center])
                    rotate([0,90,0])
                        cylinder(h=hub_diameter + 2, d=set_screw_diameter, center=true);
        }
    }
}

// ---------------- Render ----------------
pulley();