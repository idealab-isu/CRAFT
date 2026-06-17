$fn = 128;

// =====================
// Requested dimensions
// =====================
total_len   = 66.0;   // overall length along X (so Front/Back/Left/Right show full length)
barrel_d    = 6.8;    // heatbreak/barrel diameter
filament_d  = 1.75;   // filament size

// =====================
// Proportions (simple, renderable)
// =====================
heatbreak_len     = 26.0;
heater_block_len  = 20.0;
nozzle_len        = total_len - heatbreak_len - heater_block_len;

heater_block_w = 16.0;   // Y
heater_block_h = 16.0;   // Z

nozzle_hex_h   = 6.0;
nozzle_hex_af  = 7.0;     // across flats
nozzle_tip_h   = max(0.1, nozzle_len - nozzle_hex_h);
nozzle_tip_d1  = 6.0;
nozzle_tip_d2  = 0.8;

// Filament path (through-hole)
filament_clear  = 0.15;
filament_hole_d = filament_d + filament_clear;

// Small overlap to guarantee watertight unions
ov = 0.25;

// Helper: hex prism by across-flats, axis along X
module hex_prism_x(af=7, h=6) {
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    rotate([0, 90, 0]) cylinder(h=h, r=R, $fn=6);
}

module hotend() {
    // Build centered on X so orthographic Front/Back/Left/Right show full length clearly
    x0 = -total_len/2;

    difference() {
        union() {
            // Heatbreak / barrel (axis along X)
            translate([x0, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=heatbreak_len + ov, d=barrel_d);

            // Heater block (connected to barrel with overlap)
            translate([x0 + heatbreak_len - ov, -heater_block_w/2, -heater_block_h/2])
                cube([heater_block_len + 2*ov, heater_block_w, heater_block_h]);

            // Nozzle hex (connected to block with overlap)
            translate([x0 + heatbreak_len + heater_block_len - ov, 0, 0])
                hex_prism_x(af=nozzle_hex_af, h=nozzle_hex_h + 2*ov);

            // Nozzle conical tip (connected to hex with overlap), axis along X
            translate([x0 + heatbreak_len + heater_block_len + nozzle_hex_h - ov, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=nozzle_tip_h + ov, d1=nozzle_tip_d1, d2=nozzle_tip_d2);
        }

        // Filament hole through entire hotend (axis along X, measurable)
        translate([x0 - 1, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=total_len + 2, d=filament_hole_d);

        // Heater cartridge hole (6mm) through block (Y direction)
        translate([x0 + heatbreak_len + heater_block_len/2, 0, 0])
            rotate([90, 0, 0])
                cylinder(h=heater_block_w + 2, d=6.0, center=true);

        // Thermistor hole (3mm) through block (Y direction), offset in Z and X
        translate([x0 + heatbreak_len + heater_block_len*0.35, 0, heater_block_h*0.25])
            rotate([90, 0, 0])
                cylinder(h=heater_block_w + 2, d=3.0, center=true);
    }
}

hotend();