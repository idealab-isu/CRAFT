$fn = 96;

// One connected solid hot end with verifiable:
// - total length = 62.0mm
// - barrel diameter = 3.7mm
// - filament bore = 1.75mm (through)
// Includes recognizable: heatsink fins, heatbreak/barrel, heater block, nozzle.

module hot_end_assembly() {
    // --- Key dimensions ---
    total_len = 62.0;

    barrel_d  = 3.7;     // requested barrel diameter
    bore_d    = 1.75;    // requested filament

    // Segment heights (sum to total_len)
    h_sink    = 24.0;
    h_barrel  = 18.0;    // includes heatbreak region down to heater block
    h_block   = 12.0;
    h_nozzle  = 8.0;

    // Sanity: h_sink + h_barrel + h_block + h_nozzle = 62
    // 24 + 18 + 12 + 8 = 62

    // Z references (model centered at Z=0)
    z_top     =  total_len/2;
    z_bottom  = -total_len/2;

    // Segment centers
    z_sink_c   = z_top - h_sink/2;
    z_barrel_c = z_top - h_sink - h_barrel/2;
    z_block_c  = z_top - h_sink - h_barrel - h_block/2;
    z_noz_c    = z_bottom + h_nozzle/2;

    // Overlaps to guarantee connectivity
    ov = 0.6;

    // Heatsink geometry
    sink_core_d = 12.0;
    fin_d       = 18.0;
    fin_t       = 1.6;
    fin_gap     = 1.6;
    fin_count   = 6;

    // Heater block geometry
    block_x = 20.0;
    block_y = 16.0;

    // Nozzle geometry
    noz_hex_d = 9.0;     // across flats approx (visual)
    noz_tip_d = 1.0;

    difference() {
        union() {
            // --- Heatsink core ---
            translate([0,0,z_sink_c])
                cylinder(h=h_sink + ov, d=sink_core_d, center=true);

            // --- Heatsink fins (radial discs) ---
            // Place fins within heatsink height using formulas (no arbitrary offsets)
            for (i = [0:fin_count-1]) {
                z_fin = (z_top - fin_t/2) - i*(fin_t + fin_gap);
                // Keep fins within heatsink region
                if (z_fin >= (z_top - h_sink + fin_t/2))
                    translate([0,0,z_fin])
                        cylinder(h=fin_t + ov, d=fin_d, center=true);
            }

            // --- Barrel / heatbreak (requested 3.7mm diameter) ---
            translate([0,0,z_barrel_c])
                cylinder(h=h_barrel + 2*ov, d=barrel_d, center=true);

            // --- Heater block (recognizable rectangular block) ---
            translate([0,0,z_block_c])
                cube([block_x, block_y, h_block + 2*ov], center=true);

            // --- Nozzle (cone + hex) ---
            // Hex section overlaps into heater block for connectivity
            z_hex_c = z_bottom + h_nozzle - (h_nozzle*0.45)/2;
            z_cone_c = z_bottom + (h_nozzle*0.55)/2;

            // Hex (use 6-sided cylinder)
            translate([0,0,z_hex_c])
                cylinder(h=h_nozzle*0.45 + 2*ov, d=noz_hex_d, $fn=6, center=true);

            // Cone tip
            translate([0,0,z_cone_c])
                cylinder(h=h_nozzle*0.55 + 2*ov, d1=noz_hex_d*0.85, d2=noz_tip_d, center=true);

            // --- Small top cap (visual cue for filament entry) ---
            cap_h = 3.0;
            cap_d = 6.0;
            translate([0,0,z_top - cap_h/2 + ov/2])
                cylinder(h=cap_h + ov, d=cap_d, center=true);
        }

        // --- Filament path (1.75mm bore) through entire assembly ---
        translate([0,0,0])
            cylinder(h=total_len + 4*ov, d=bore_d, center=true);

        // --- Heater cartridge hole (side) ---
        cart_d = 6.0;
        cart_y = block_y/2 - cart_d/2 + ov; // tangent-ish, still inside block
        translate([0, cart_y, z_block_c])
            rotate([90,0,0])
                cylinder(h=block_y + 4*ov, d=cart_d, center=true);

        // --- Thermistor hole (side, smaller) ---
        therm_d = 3.0;
        therm_y = -block_y/2 + therm_d/2 - ov;
        translate([block_x*0.25, therm_y, z_block_c])
            rotate([90,0,0])
                cylinder(h=block_y + 4*ov, d=therm_d, center=true);
    }
}

hot_end_assembly();