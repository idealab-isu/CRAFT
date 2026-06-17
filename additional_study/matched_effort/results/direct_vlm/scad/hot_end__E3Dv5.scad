$fn = 128;

// Units: mm
// Stylized 3D-printer hot end for 1.75mm filament
// Total length: 70.0mm
// Barrel diameter: 3.7mm

filament_d = 1.75;
barrel_d   = 3.7;
total_len  = 70.0;

module hotend() {

    // Segment lengths (sum to total_len)
    L_nozzle = 12.0;
    L_block  = 10.0;
    L_sink   = 18.0;
    L_barrel = total_len - (L_nozzle + L_block + L_sink); // 30.0

    // Nozzle diameters
    d_nozzle_tip  = 1.0;
    d_nozzle_base = 7.0;

    // Heater block
    block_w = 16.0;
    block_d = 16.0;
    block_h = L_block;

    // Heatsink
    sink_core_d = 8.0;
    sink_fin_d  = 16.0;
    fin_th      = 1.2;
    fin_gap     = 1.2;
    fin_count   = 7;
    top_cap_h   = 2.0;
    top_cap_d   = 12.0;

    // Filament path (slightly larger than filament)
    bore_d = filament_d + 0.25;

    // Small overlap to guarantee watertight unions
    ov = 0.3;

    // Z references
    z_nozzle0 = 0;
    z_block0  = z_nozzle0 + L_nozzle;
    z_barrel0 = z_block0  + L_block;
    z_sink0   = z_barrel0 + L_barrel;

    difference() {
        union() {
            // Nozzle (bottom)
            cylinder(h=L_nozzle + ov, d1=d_nozzle_tip, d2=d_nozzle_base);

            // Heater block (centered on axis)
            translate([-block_w/2, -block_d/2, z_block0 - ov])
                cube([block_w, block_d, block_h + 2*ov], center=false);

            // Heatbreak / barrel (runs through block and up to heatsink)
            translate([0,0,z_block0 - ov])
                cylinder(h=L_block + L_barrel + 2*ov, d=barrel_d);

            // Heatsink (top), connected to barrel with overlap
            translate([0,0,z_sink0 - ov])
            union() {
                // Core
                cylinder(h=L_sink + 2*ov, d=sink_core_d);

                // Fins
                for (i = [0:fin_count-1]) {
                    zf = i*(fin_th + fin_gap);
                    if (zf + fin_th <= L_sink)
                        translate([0,0,zf])
                            cylinder(h=fin_th, d=sink_fin_d);
                }

                // Top cap
                translate([0,0,L_sink - top_cap_h])
                    cylinder(h=top_cap_h + ov, d=top_cap_d);
            }
        }

        // Filament bore through entire hotend
        translate([0,0,-1])
            cylinder(h=total_len + 2, d=bore_d);

        // Heater cartridge hole (side through block) - centered in block height
        translate([0,0,z_block0 + block_h/2])
            rotate([0,90,0])
                cylinder(h=block_w + 2, d=6.0, center=true);

        // Thermistor hole (smaller, offset in Y), also through block
        translate([0, block_d*0.28, z_block0 + block_h/2])
            rotate([0,90,0])
                cylinder(h=block_w + 2, d=3.0, center=true);
    }
}

rotate([90,0,0]) hotend();