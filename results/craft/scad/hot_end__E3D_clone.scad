// Parameters
total_length_mm = 66; //[33:132:0.5]
barrel_diameter_mm = 6.8; //[3.4:13.6:0.1]
filament_diameter_mm = 1.75; //[1.5:3:0.05]
filament_bore_diameter_mm = 1.9; //[1.6:3.4:0.05]
overlap_mm = 1; //[0.5:2:0.1]

heatsink_length_mm = 30; //[15:60:0.5]
heatsink_outer_diameter_mm = 22; //[11:44:0.5]
fin_count = 7; //[3:14:1]
fin_thickness_mm = 1.6; //[0.8:3.2:0.1]
fin_gap_mm = 2.2; //[1:5:0.1]

heatbreak_length_mm = 12; //[6:24:0.5]

heater_block_length_x_mm = 20; //[10:40:0.5]
heater_block_width_y_mm = 16; //[8:32:0.5]
heater_block_height_z_mm = 12; //[6:24:0.5]

nozzle_length_mm = 12; //[6:24:0.5]
nozzle_tip_diameter_mm = 1.2; //[0.6:3:0.1]
nozzle_base_diameter_mm = 7; //[3.5:14:0.1]

groove_outer_diameter_mm = 12; //[6:24:0.5]
groove_inner_diameter_mm = 8; //[4:16:0.5]
groove_height_mm = 6; //[3:12:0.5]

bore_extra_length_mm = 4; //[2:10:0.5]

// Added: small circular cap/washer above nozzle tip (must be attached)
nozzle_washer_thickness_mm = 1.2; //[0.8:2.5:0.1]
nozzle_washer_diameter_mm  = 6.0; //[3:10:0.1]
nozzle_washer_overlap_mm   = 1.0; //[0.5:2:0.1]

$fn = 96;

// ---- Derived layout (Z axis is hotend axis; model spans z=[0..total_length_mm]) ----
// Build from bottom up with exact total length and guaranteed connectivity.
nozzle_z0 = 0;
nozzle_z1 = nozzle_z0 + nozzle_length_mm;

block_z0 = nozzle_z1;
block_z1 = block_z0 + heater_block_height_z_mm;

heatbreak_z0 = block_z1;
heatbreak_z1 = heatbreak_z0 + heatbreak_length_mm;

groove_z0 = heatbreak_z1;
groove_z1 = groove_z0 + groove_height_mm;

heatsink_z0 = groove_z1;
heatsink_z1 = total_length_mm;

// If heatsink length parameter doesn't match remaining length, force it to fit total_length_mm.
heatsink_len_actual = heatsink_z1 - heatsink_z0;

// ---- Modules ----
module heatsink_with_fins(z0, z1) {
    len = z1 - z0;

    // Slightly smaller core so fins read clearly in side views
    core_r = heatsink_outer_diameter_mm/2 - max(0.8, fin_thickness_mm*0.35);
    fin_r  = heatsink_outer_diameter_mm/2;

    // Core
    translate([0,0,(z0+z1)/2])
        cylinder(r=core_r, h=len, center=true);

    // Fins: thin discs, spaced along length
    fin_pitch = fin_thickness_mm + fin_gap_mm;

    // Center fins within available length
    usable = len - fin_thickness_mm;
    n = min(fin_count, max(1, floor(usable / fin_pitch) + 1));
    start_z = z0 + fin_thickness_mm/2 + (len - (n*fin_thickness_mm + (n-1)*fin_gap_mm))/2;

    for (i = [0:n-1]) {
        zc = start_z + i*fin_pitch;
        translate([0,0,zc])
            cylinder(r=fin_r, h=fin_thickness_mm, center=true);
    }
}

module groove_mount(z0, z1) {
    // Groove mount: outer ring with a necked section (visual groove)
    len = z1 - z0;
    neck_h = min(len*0.45, len - 0.8);
    neck_h = max(neck_h, 1.2);
    neck_z0 = z0 + (len - neck_h)/2;
    neck_z1 = neck_z0 + neck_h;

    union() {
        // Main outer
        translate([0,0,(z0+z1)/2])
            cylinder(r=groove_outer_diameter_mm/2, h=len, center=true);

        // Necked section (smaller OD) to create recognizable groove-mount step
        translate([0,0,(neck_z0+neck_z1)/2])
            cylinder(r=groove_inner_diameter_mm/2, h=neck_h, center=true);
    }
}

module heatbreak(z0, z1) {
    // Heatbreak: slender barrel diameter
    translate([0,0,(z0+z1)/2])
        cylinder(r=barrel_diameter_mm/2, h=(z1-z0), center=true);
}

module heater_block(z0, z1) {
    // Add a small top boss to visually connect to heatbreak and read as typical assembly
    len = z1 - z0;
    boss_d = max(barrel_diameter_mm + 2.0, 8.0);
    boss_h = min(3.0, len*0.35);

    union() {
        translate([0,0,(z0+z1)/2])
            cube([heater_block_length_x_mm, heater_block_width_y_mm, len], center=true);

        // Boss on top face (centered)
        translate([0,0,z1 - boss_h/2])
            cylinder(r=boss_d/2, h=boss_h, center=true);
    }
}

module nozzle(z0, z1) {
    // Nozzle: hex-like base + conical tip + attached washer/cap at the very tip
    len = z1 - z0;
    hex_h = min(4.0, len*0.45);
    cone_h = len - hex_h;

    // Washer is placed at the very bottom and overlaps into the cone by nozzle_washer_overlap_mm
    washer_h = nozzle_washer_thickness_mm;
    washer_r = nozzle_washer_diameter_mm/2;

    // Ensure overlap is not larger than washer thickness
    washer_overlap = min(nozzle_washer_overlap_mm, washer_h*0.9);

    union() {
        // Hex base at top of nozzle
        translate([0,0,z1 - hex_h/2])
            cylinder(r=nozzle_base_diameter_mm/2, h=hex_h, center=true, $fn=6);

        // Cone down to tip
        translate([0,0,z0 + cone_h/2])
            cylinder(r1=nozzle_tip_diameter_mm/2, r2=nozzle_base_diameter_mm/2, h=cone_h, center=true);

        // Attached small circular cap/washer at nozzle tip (NO FLOATING / NO GAP)
        // Bottom at z0, top at z0+washer_h, but pushed up slightly so it intersects the cone.
        translate([0,0, z0 + washer_h/2 + washer_overlap])
            cylinder(r=washer_r, h=washer_h, center=true);
    }
}

module hot_end_solid() {
    union() {
        // Nozzle at bottom (includes attached washer/cap)
        nozzle(nozzle_z0, nozzle_z1);

        // Heater block above nozzle; overlap into nozzle for connectivity
        heater_block(block_z0 - overlap_mm, block_z1);

        // Heatbreak above block; overlap into block
        heatbreak(heatbreak_z0 - overlap_mm, heatbreak_z1);

        // Groove mount above heatbreak; overlap into heatbreak
        groove_mount(groove_z0 - overlap_mm, groove_z1);

        // Heatsink above groove; overlap into groove
        heatsink_with_fins(heatsink_z0 - overlap_mm, heatsink_z1);
    }
}

module filament_bore() {
    // Through-bore along entire hotend, slightly extended
    translate([0,0,total_length_mm/2])
        cylinder(r=filament_bore_diameter_mm/2, h=total_length_mm + bore_extra_length_mm, center=true);
}

// ---- Final assembly: one connected solid with internal filament path ----
difference() {
    hot_end_solid();
    filament_bore();
}