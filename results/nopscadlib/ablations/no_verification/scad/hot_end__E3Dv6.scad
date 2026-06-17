$fn = 96;

// Target specs
total_length_mm = 62.0;                 // overall hotend length
barrel_diameter_mm = 3.7;               // heatbreak/barrel OD
filament_diameter_mm = 1.75;
filament_clearance_mm = 0.20;
filament_bore_diameter_mm = filament_diameter_mm + 2*filament_clearance_mm;

// Heatsink (top)
heatsink_length_mm = 26.0;
heatsink_diameter_mm = 22.0;
fin_count = 7;
fin_thickness_mm = 1.2;
fin_gap_mm = (heatsink_length_mm - fin_count*fin_thickness_mm) / (fin_count-1);
fin_diameter_mm = heatsink_diameter_mm;
core_diameter_mm = 12.0;

// Heatbreak (barrel)
heatbreak_length_mm = 12.0;

// Heater block (middle)
heater_block_size_x_mm = 16.0;
heater_block_size_y_mm = 16.0;
heater_block_height_mm = 12.0;

// Nozzle (bottom)
nozzle_length_mm = 12.0;
nozzle_hex_height_mm = 6.0;
nozzle_hex_flat_mm = 7.0;               // across flats
nozzle_tip_length_mm = nozzle_length_mm - nozzle_hex_height_mm;
nozzle_tip_d1_mm = 6.0;                 // tip base diameter
nozzle_tip_d2_mm = 1.0;                 // tip end diameter (visual)

// Connectivity overlap
overlap_mm = 0.6;

// Derived: enforce exact total length by adjusting heatbreak length if needed
computed_total = heatsink_length_mm + heatbreak_length_mm + heater_block_height_mm + nozzle_length_mm;
heatbreak_length_adj = heatbreak_length_mm + (total_length_mm - computed_total);

// Z layout (top at z=0, bottom at z=-total_length_mm)
z_top = 0;
z_heatsink_bot = z_top - heatsink_length_mm;
z_heatbreak_bot = z_heatsink_bot - heatbreak_length_adj;
z_block_bot = z_heatbreak_bot - heater_block_height_mm;
z_nozzle_bot = z_block_bot - nozzle_length_mm;

// Helpers
module hex_prism(af, h, center=false) {
    // Regular hex with given across-flats (af)
    r = af / sqrt(3); // circumradius
    cylinder(r=r, h=h, $fn=6, center=center);
}

module heatsink() {
    // Finned cylinder with a central core; all connected
    union() {
        // Core
        translate([0,0, z_top - heatsink_length_mm/2])
            cylinder(d=core_diameter_mm, h=heatsink_length_mm, center=true);

        // Fins
        for (i = [0:fin_count-1]) {
            z_fin_center = z_top - (fin_thickness_mm/2 + i*(fin_thickness_mm + fin_gap_mm));
            translate([0,0, z_fin_center])
                cylinder(d=fin_diameter_mm, h=fin_thickness_mm, center=true);
        }

        // Small top collar to suggest mounting area (still connected)
        collar_h = 3.0;
        collar_d = 16.0;
        translate([0,0, z_top - collar_h/2 + overlap_mm/2])
            cylinder(d=collar_d, h=collar_h + overlap_mm, center=true);
    }
}

module heatbreak() {
    // Thin barrel connecting heatsink to heater block
    translate([0,0, (z_heatsink_bot + z_heatbreak_bot)/2])
        cylinder(d=barrel_diameter_mm, h=(z_heatsink_bot - z_heatbreak_bot) + overlap_mm, center=true);
}

module heater_block() {
    // Block centered in its Z span; overlaps heatbreak and nozzle slightly
    zc = (z_heatbreak_bot + z_block_bot)/2;
    translate([0,0, zc])
        cube([heater_block_size_x_mm, heater_block_size_y_mm, (z_heatbreak_bot - z_block_bot) + overlap_mm], center=true);
}

module nozzle() {
    // Hex + conical tip; overlaps into heater block
    union() {
        // Hex section (top of nozzle)
        z_hex_top = z_block_bot + overlap_mm;
        z_hex_bot = z_hex_top - nozzle_hex_height_mm;
        translate([0,0, (z_hex_top + z_hex_bot)/2])
            hex_prism(nozzle_hex_flat_mm, nozzle_hex_height_mm + overlap_mm, center=true);

        // Conical tip
        z_tip_top = z_hex_bot;
        z_tip_bot = z_nozzle_bot;
        translate([0,0, (z_tip_top + z_tip_bot)/2])
            cylinder(d1=nozzle_tip_d1_mm, d2=nozzle_tip_d2_mm, h=(z_tip_top - z_tip_bot), center=true);
    }
}

module filament_bore() {
    // Through-bore for 1.75mm filament with clearance
    // Extend slightly beyond ends to guarantee clean subtraction
    extra = 2.0;
    translate([0,0, -total_length_mm/2])
        cylinder(d=filament_bore_diameter_mm, h=total_length_mm + 2*extra, center=true);
}

module hotend() {
    difference() {
        union() {
            heatsink();
            heatbreak();
            heater_block();
            nozzle();
        }
        filament_bore();
    }
}

// Single connected solid hotend
hotend();