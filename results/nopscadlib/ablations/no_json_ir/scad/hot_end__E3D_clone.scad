$fn = 128;

// =====================
// Target dimensions
// =====================
hot_end_length      = 66.0;   // total Z length (tip to top)
barrel_diameter     = 6.8;    // heatbreak/barrel OD
filament_diameter   = 1.75;   // filament path

// Small overlap to guarantee one connected solid
ov = 0.6;

// =====================
// Proportions (typical hotend-like)
// =====================
// Z stack: nozzle + heater block + heatbreak + heatsink = hot_end_length
nozzle_length       = 12.0;
heater_block_h      = 10.0;
heat_break_length   = 22.0;
heatsink_length     = hot_end_length - (nozzle_length + heater_block_h + heat_break_length);

// Heater block (rectangular, centered on axis)
heater_block_size   = [20.0, 16.0, heater_block_h];

// Nozzle geometry
nozzle_tip_d        = 1.0;
nozzle_hex_d        = 7.0;     // hex-ish shoulder diameter approximation
nozzle_hex_h        = 4.0;
nozzle_cone_h       = nozzle_length - nozzle_hex_h;

// Heatbreak
heatbreak_d         = barrel_diameter;

// Heatsink geometry (fins + top mount)
heatsink_core_d     = barrel_diameter + 4.0;   // core under fins
heatsink_fin_d      = barrel_diameter + 14.0;  // fin OD
fin_thickness       = 1.2;
fin_count           = 8;
fin_gap             = (heatsink_length - fin_count*fin_thickness) / (fin_count + 1);
fin_gap             = (fin_gap < 0.6) ? 0.6 : fin_gap;

// Top mount (short larger cylinder)
top_mount_h         = 8.0;
top_mount_d         = barrel_diameter + 10.0;

// =====================
// Z references (all derived)
// =====================
z_nozzle0   = 0;
z_block0    = z_nozzle0 + nozzle_length - ov;
z_break0    = z_nozzle0 + nozzle_length + heater_block_h - ov;
z_sink0     = z_nozzle0 + nozzle_length + heater_block_h + heat_break_length - ov;
z_top       = hot_end_length;

// =====================
// Modules
// =====================
module nozzle() {
    union() {
        // Cone (tip at z=0)
        cylinder(h=nozzle_cone_h, d1=nozzle_hex_d, d2=nozzle_tip_d, center=false);

        // "Hex" shoulder (approximated as cylinder) at top of nozzle
        translate([0,0,nozzle_cone_h - ov])
            cylinder(h=nozzle_hex_h + ov, d=nozzle_hex_d, center=false);

        // Small flange to visually separate from heater block (still connected)
        translate([0,0,nozzle_length - 1.2 - ov])
            cylinder(h=1.2 + ov, d=nozzle_hex_d + 2.0, center=false);
    }
}

module heater_block() {
    // Center the block on the hotend axis (typical)
    translate([-heater_block_size[0]/2, -heater_block_size[1]/2, z_block0])
        cube([heater_block_size[0], heater_block_size[1], heater_block_size[2] + ov], center=false);
}

module heat_break() {
    translate([0,0,z_break0])
        cylinder(h=heat_break_length + ov, d=heatbreak_d, center=false);
}

module heatsink() {
    union() {
        // Core
        translate([0,0,z_sink0])
            cylinder(h=heatsink_length + ov, d=heatsink_core_d, center=false);

        // Fins (discs) along heatsink length
        for (i = [0:fin_count-1]) {
            zf = z_sink0 + fin_gap*(i+1) + fin_thickness*i;
            translate([0,0,zf])
                cylinder(h=fin_thickness, d=heatsink_fin_d, center=false);
        }

        // Top mount (connects to heatsink core)
        // Place it at the very top, overlapping slightly into heatsink
        translate([0,0,z_top - top_mount_h])
            cylinder(h=top_mount_h, d=top_mount_d, center=false);

        // Small top lip
        translate([0,0,z_top - 1.2])
            cylinder(h=1.2, d=top_mount_d + 2.0, center=false);
    }
}

module hot_end_solid() {
    union() {
        nozzle();
        heater_block();
        heat_break();
        heatsink();
    }
}

module filament_bore() {
    // Through-bore for 1.75mm filament, extended for clean subtraction
    translate([0,0,-1])
        cylinder(h=hot_end_length + 2, d=filament_diameter, center=false);
}

// =====================
// Final model (one connected solid)
// =====================
difference() {
    hot_end_solid();
    filament_bore();
}