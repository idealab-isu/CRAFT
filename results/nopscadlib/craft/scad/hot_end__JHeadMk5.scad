$fn = 128;

// =====================
// Parameters (requested)
// =====================
total_length_mm = 51.2;              //[25.6:102.4:0.1]
barrel_diameter_mm = 4.75;           //[2.4:9.5:0.05]
filament_diameter_mm = 1.75;         //[1.0:3.0:0.05]

// Practical clearances
filament_clearance_mm = 0.20;        //[0.0:0.6:0.05]
overlap_mm = 0.60;                   //[0.2:2.0:0.1]

// =====================
// Hotend proportions
// =====================
nozzle_length_mm = 10.0;             //[5.0:20.0:0.5]
heater_block_length_mm = 12.0;       //[6.0:24.0:0.5]
barrel_length_mm = 30.0;             //[15.0:60.0:0.5]

// Heater block details
heater_block_width_mm = 16.0;        //[8.0:32.0:0.5]
heater_block_depth_mm = 16.0;        //[8.0:32.0:0.5]
heater_cartridge_d_mm = 6.0;         //[4.0:8.0:0.1]
heater_cartridge_inset_mm = 3.0;     //[1.0:6.0:0.1]
thermistor_d_mm = 3.0;               //[2.0:5.0:0.1]
thermistor_inset_mm = 2.5;           //[1.0:6.0:0.1]

// Nozzle geometry
nozzle_hex_flat_mm = 7.0;            //[5.0:10.0:0.1]
nozzle_hex_h_mm = 4.0;               //[2.0:8.0:0.1]
nozzle_cone_h_mm = nozzle_length_mm - nozzle_hex_h_mm;
nozzle_tip_d_mm = 1.0;               //[0.5:2.0:0.05]

// Heatsink geometry (recognizable fins)
mount_outer_diameter_mm = 16.0;      //[10.0:26.0:0.5]
core_od_mm = 10.0;                   //[8.0:16.0:0.5]
fin_od_mm = 22.0;                    //[14.0:30.0:0.5]
fin_count = 7;                       //[4:12]
fin_thickness_mm = 1.2;              //[0.6:2.0:0.1]
fin_gap_mm = 1.0;                    //[0.6:2.5:0.1]
mount_length_mm = 6.0;               //[3.0:12.0:0.2]

// =====================
// Derived
// =====================
barrel_r = barrel_diameter_mm/2;
filament_bore_d_mm = filament_diameter_mm + filament_clearance_mm;
filament_bore_r = filament_bore_d_mm/2;

// Heatsink length derived to hit exact total length
heatsink_length_mm = total_length_mm - (nozzle_length_mm + heater_block_length_mm + barrel_length_mm);
heatsink_length_mm = (heatsink_length_mm < (mount_length_mm + 0.01)) ? (mount_length_mm + 0.01) : heatsink_length_mm;

// Fin stack length (kept within heatsink length, leaving a small core section)
fin_stack_len_mm = fin_count*fin_thickness_mm + (fin_count-1)*fin_gap_mm;
fin_stack_len_mm = min(fin_stack_len_mm, heatsink_length_mm - mount_length_mm);
fin_stack_len_mm = (fin_stack_len_mm < fin_thickness_mm) ? fin_thickness_mm : fin_stack_len_mm;

// Z layout (centered assembly)
z_min = -total_length_mm/2;

z_nozzle_c = z_min + nozzle_length_mm/2;
z_block_c  = z_min + nozzle_length_mm + heater_block_length_mm/2;
z_barrel_c = z_min + nozzle_length_mm + heater_block_length_mm + barrel_length_mm/2;
z_sink_c   = z_min + nozzle_length_mm + heater_block_length_mm + barrel_length_mm + heatsink_length_mm/2;

// Segment boundaries (for formula-based placement)
z_nozzle_top = z_min + nozzle_length_mm;
z_block_top  = z_min + nozzle_length_mm + heater_block_length_mm;
z_barrel_top = z_min + nozzle_length_mm + heater_block_length_mm + barrel_length_mm;
z_sink_top   = z_min + total_length_mm;

// =====================
// Helpers
// =====================
module hex_prism(flat_mm, h_mm, center=true) {
    // Regular hex with given across-flats dimension
    // For a regular hex: across flats = 2 * apothem = sqrt(3) * R (circumradius)
    R = flat_mm / sqrt(3);
    cylinder(h=h_mm, r=R, $fn=6, center=center);
}

module heatsink(zc, h) {
    // One connected heatsink: core cylinder + fin discs + top mount cylinder
    // All Z positions are computed from h and fin stack length.
    core_r = core_od_mm/2;
    fin_r  = fin_od_mm/2;
    mount_r = mount_outer_diameter_mm/2;

    // Place fin stack at lower portion of heatsink, mount at top.
    z_bottom = zc - h/2;
    z_mount_c = z_bottom + (h - mount_length_mm/2);
    z_fin_stack_c = z_bottom + fin_stack_len_mm/2;

    union() {
        // Core cylinder spanning full heatsink length (ensures connectivity)
        translate([0,0,zc])
            cylinder(h=h, r=core_r, center=true);

        // Fin discs along Z (connected to core)
        for (i = [0:fin_count-1]) {
            z_i = (z_fin_stack_c - fin_stack_len_mm/2)
                  + fin_thickness_mm/2
                  + i*(fin_thickness_mm + fin_gap_mm);

            // Only place fins that fit within fin stack length
            if (z_i <= (z_fin_stack_c + fin_stack_len_mm/2 + 1e-6))
                translate([0,0,z_i])
                    cylinder(h=fin_thickness_mm, r=fin_r, center=true);
        }

        // Top mount cylinder (connected via core overlap)
        translate([0,0, z_mount_c - overlap_mm/2])
            cylinder(h=mount_length_mm + overlap_mm, r=mount_r, center=true);
    }
}

module hot_end_solid() {
    union() {
        // -----------------
        // Nozzle (hex + cone)
        // -----------------
        // Hex section at top of nozzle (touches heater block)
        z_noz_hex_c = z_min + (nozzle_length_mm - nozzle_hex_h_mm/2);
        translate([0,0,z_noz_hex_c])
            hex_prism(nozzle_hex_flat_mm, nozzle_hex_h_mm + overlap_mm, center=true);

        // Cone section below hex
        z_noz_cone_c = z_min + nozzle_cone_h_mm/2;
        translate([0,0,z_noz_cone_c])
            cylinder(h=nozzle_cone_h_mm + overlap_mm,
                     r1=nozzle_hex_flat_mm/2,  // approximate at junction
                     r2=nozzle_tip_d_mm/2,
                     center=true);

        // -----------------
        // Heater block (with cartridge + thermistor bumps)
        // -----------------
        translate([0,0,z_block_c])
            cube([heater_block_width_mm, heater_block_depth_mm, heater_block_length_mm], center=true);

        // Heater cartridge protrusion (cyl) on +X side, aligned through block depth (Y axis)
        // Centered in Z within block.
        cart_len = heater_block_depth_mm - 2*heater_cartridge_inset_mm;
        cart_y_c = 0;
        cart_x_c = heater_block_width_mm/2 + heater_cartridge_d_mm/2 - overlap_mm;
        translate([cart_x_c, cart_y_c, z_block_c])
            rotate([90,0,0])
                cylinder(h=cart_len, r=heater_cartridge_d_mm/2, center=true);

        // Thermistor protrusion (smaller cyl) on -X side, also through depth
        therm_len = heater_block_depth_mm - 2*thermistor_inset_mm;
        therm_x_c = -(heater_block_width_mm/2 + thermistor_d_mm/2 - overlap_mm);
        translate([therm_x_c, 0, z_block_c])
            rotate([90,0,0])
                cylinder(h=therm_len, r=thermistor_d_mm/2, center=true);

        // -----------------
        // Heatbreak / barrel (requested 4.75mm diameter)
        // -----------------
        translate([0,0,z_barrel_c])
            cylinder(h=barrel_length_mm + overlap_mm, r=barrel_r, center=true);

        // Transition collar from barrel to heatsink core (guarantees connectivity)
        collar_h = 2.0;
        collar_zc = z_block_top + barrel_length_mm + collar_h/2 - overlap_mm/2; // at barrel top
        translate([0,0,collar_zc])
            cylinder(h=collar_h + overlap_mm,
                     r1=core_od_mm/2,
                     r2=barrel_r,
                     center=true);

        // -----------------
        // Heatsink with fins + mount (recognizable)
        // -----------------
        heatsink(z_sink_c, heatsink_length_mm);
    }
}

module filament_bore() {
    // Through-hole for filament path (1.75mm + clearance)
    // Extend beyond ends for clean subtraction.
    cylinder(h=total_length_mm + 4, r=filament_bore_r, center=true);
}

difference() {
    hot_end_solid();
    filament_bore();
}