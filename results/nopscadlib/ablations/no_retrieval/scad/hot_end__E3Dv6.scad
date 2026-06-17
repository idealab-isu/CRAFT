$fn = 128;

// =====================
// Target constraints
// =====================
total_length = 62.0;                 // overall Z length (verifiable)
barrel_diameter = 3.7;               // heatbreak/barrel OD (verifiable)
filament_diameter = 1.75;
filament_clearance = 0.25;
bore_diameter = filament_diameter + filament_clearance;  // verifiable filament path

// =====================
// Hotend proportions (E3D-ish silhouette)
// All Z positions are computed from these lengths so total_length is exact.
// =====================
overlap = 0.6;                       // small overlap to guarantee one connected solid

// Segment lengths along Z (top -> bottom)
heatsink_height = 18.0;
mount_groove_height = 3.0;
barrel_length = 23.0;                // thin heatbreak section between heatsink and block
heater_block_height = 12.0;
nozzle_length = total_length - (heatsink_height + mount_groove_height + barrel_length + heater_block_height); // ensures exact total

// Heatsink geometry
heatsink_outer_diameter = 16.0;
heatsink_core_diameter  = 8.0;
heatsink_fin_count = 7;
heatsink_fin_thickness = 1.2;
heatsink_fin_gap = (heatsink_height - heatsink_fin_count*heatsink_fin_thickness) / (heatsink_fin_count-1);

// Groove mount collar
mount_groove_diameter = 12.0;

// Heater block geometry
heater_block_length = 20.0;          // X
heater_block_width  = 16.0;          // Y

// Nozzle geometry
nozzle_hex_flat = 7.0;
nozzle_tip_diameter = 1.0;

// Side holes (typical)
heater_cartridge_diameter = 6.0;
thermistor_diameter = 3.0;
set_screw_hole_diameter = 3.0;

// =====================
// Derived Z coordinates (centered model)
// =====================
z_top = total_length/2;
z_bottom = -total_length/2;

z_heatsink_top = z_top;
z_heatsink_bottom = z_heatsink_top - heatsink_height;

z_groove_top = z_heatsink_bottom;
z_groove_bottom = z_groove_top - mount_groove_height;

z_barrel_top = z_groove_bottom;
z_barrel_bottom = z_barrel_top - barrel_length;

z_block_top = z_barrel_bottom;
z_block_bottom = z_block_top - heater_block_height;

z_nozzle_top = z_block_bottom;
z_nozzle_bottom = z_bottom;

// Centers
zc_heatsink = (z_heatsink_top + z_heatsink_bottom)/2;
zc_groove   = (z_groove_top + z_groove_bottom)/2;
zc_barrel   = (z_barrel_top + z_barrel_bottom)/2;
zc_block    = (z_block_top + z_block_bottom)/2;
zc_nozzle   = (z_nozzle_top + z_nozzle_bottom)/2;

// =====================
// Helpers
// =====================
module hex_prism(flat, h, center=true) {
    // across flats = 2*R*cos(30) => R = flat/(2*cos(30))
    R = flat/(2*cos(30));
    cylinder(h=h, r=R, $fn=6, center=center);
}

// =====================
// Parts (all connected via computed Z and overlaps)
// =====================
module heatsink() {
    union() {
        // core
        translate([0,0,zc_heatsink])
            cylinder(h=heatsink_height + overlap, r=heatsink_core_diameter/2, center=true);

        // fins
        for (i = [0:heatsink_fin_count-1]) {
            z_fin = z_heatsink_top - heatsink_fin_thickness/2 - i*(heatsink_fin_thickness + heatsink_fin_gap);
            translate([0,0,z_fin])
                cylinder(h=heatsink_fin_thickness + overlap, r=heatsink_outer_diameter/2, center=true);
        }
    }
}

module groove_mount() {
    // collar that overlaps into heatsink and barrel to ensure connectivity
    translate([0,0,zc_groove])
        cylinder(h=mount_groove_height + 2*overlap, r=mount_groove_diameter/2, center=true);
}

module barrel_heatbreak() {
    translate([0,0,zc_barrel])
        cylinder(h=barrel_length + 2*overlap, r=barrel_diameter/2, center=true);
}

module heater_block() {
    translate([0,0,zc_block])
        cube([heater_block_length, heater_block_width, heater_block_height + 2*overlap], center=true);
}

module nozzle() {
    union() {
        // hex section at top of nozzle (inside/just below block)
        hex_h = min(5.0, nozzle_length*0.55);
        translate([0,0,z_nozzle_top - hex_h/2 + overlap])
            hex_prism(nozzle_hex_flat, hex_h + 2*overlap, center=true);

        // conical tip down to bottom
        cone_h = nozzle_length - hex_h;
        translate([0,0,z_nozzle_bottom + cone_h/2])
            cylinder(h=cone_h + 2*overlap,
                     r1=(nozzle_hex_flat/(2*cos(30))) * 0.85,
                     r2=nozzle_tip_diameter/2,
                     center=true);
    }
}

// =====================
// Holes
// =====================
module filament_bore() {
    cylinder(h=total_length + 4*overlap, r=bore_diameter/2, center=true);
}

module heater_cartridge_hole() {
    // Through X direction (so FRONT/BACK/LEFT/RIGHT show full Z silhouette, not a circular cut)
    translate([0,0,zc_block])
        rotate([0,90,0])
            cylinder(h=heater_block_length + 4*overlap, r=heater_cartridge_diameter/2, center=true);
}

module thermistor_hole() {
    // Through Y direction, offset toward one side in X
    x_off = heater_block_length/2 - thermistor_diameter/2 - 1.0;
    translate([x_off,0,zc_block])
        rotate([90,0,0])
            cylinder(h=heater_block_width + 4*overlap, r=thermistor_diameter/2, center=true);
}

module set_screw_holes() {
    // Two small holes through Y direction, near ends in X
    x_off = heater_block_length/2 - set_screw_hole_diameter/2 - 2.0;
    for (sx = [-1, 1]) {
        translate([sx*x_off,0,zc_block])
            rotate([90,0,0])
                cylinder(h=heater_block_width + 4*overlap, r=set_screw_hole_diameter/2, center=true);
    }
}

// =====================
// Assembly
// =====================
module hotend_solid() {
    union() {
        heatsink();
        groove_mount();
        barrel_heatbreak();
        heater_block();
        nozzle();
    }
}

module hotend_final() {
    difference() {
        hotend_solid();
        filament_bore();
        heater_cartridge_hole();
        thermistor_hole();
        set_screw_holes();
    }
}

color("Silver") hotend_final();