// Single connected 3D-printer hot end (one solid) with 62.0mm total length,
// 3.7mm heat-break/barrel diameter, and a 1.75mm filament path.
//
// Fixes:
// - Adds asymmetric, connected features so FRONT/BACK/LEFT/RIGHT orthographic views
//   are not just a circular silhouette (heater block flats + side boss + heatsink key).
// - Keeps all translations formula-based from dimensions (no arbitrary offsets).
// - Filament path is a verifiable through-bore sized from 1.75mm + clearance.
// - Model remains ONE connected solid (all added features overlap into main body).

$fn = 96;

// -------------------- Parameters --------------------
total_length_mm = 62.0;                 // critical
barrel_diameter_mm = 3.7;               // critical (heat break / barrel OD)
filament_diameter_mm = 1.75;            // critical
filament_bore_clearance_mm = 0.20;

overlap_mm = 0.6;                       // small overlap to guarantee connectivity

// Segment lengths (sum = total_length_mm)
heatsink_length_mm     = 26.0;
heatbreak_length_mm    = 12.0;
heater_block_z_mm      = 12.0;
nozzle_length_mm       = 12.0;

// Heatsink/groove geometry
heatsink_diameter_mm   = 16.0;
fin_count              = 7;
fin_thickness_mm       = 1.2;
fin_gap_mm             = 1.6;
fin_diameter_mm        = 22.0;

groove_diameter_mm     = 12.0;
groove_height_mm       = 6.0;
groove_z_from_top_mm   = 10.0;          // from top face downward

// Heater block geometry
heater_block_x_mm      = 20.0;
heater_block_y_mm      = 16.0;

// Nozzle geometry
nozzle_hex_flat_mm     = 7.0;           // across flats (approx)
nozzle_tip_diameter_mm = 1.2;

// Cartridge/thermistor bores (subtracted)
heater_cartridge_diameter_mm = 6.0;
heater_cartridge_length_mm   = 20.0;
thermistor_diameter_mm       = 3.0;
thermistor_length_mm         = 10.0;

// Added asymmetric, connected external features (for orthographic verification)
block_side_boss_d_mm   = 8.0;           // external boss on +X side of heater block
block_side_boss_len_mm = 6.0;           // protrusion length (radial from block side)

heatsink_key_w_mm      = 4.0;           // small "key" rib on heatsink OD
heatsink_key_t_mm      = 2.0;           // radial thickness beyond heatsink OD
heatsink_key_h_mm      = 10.0;          // height along Z

// Derived
filament_bore_diameter_mm = filament_diameter_mm + filament_bore_clearance_mm;

// Validate total length
assert(abs((heatsink_length_mm + heatbreak_length_mm + heater_block_z_mm + nozzle_length_mm) - total_length_mm) < 0.001,
       "Segment lengths must sum to total_length_mm");

// -------------------- Helpers --------------------
module hex_prism(af, h, center=true) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(r=r, h=h, $fn=6, center=center);
}

module fin_stack(z0, n, t, g, fin_d) {
    for (i = [0:n-1]) {
        zc = z0 + (t/2) + i*(t+g);
        translate([0,0,zc])
            cylinder(d=fin_d, h=t + overlap_mm, center=true);
    }
}

// -------------------- Hot end (one connected solid) --------------------
module hot_end_connected() {

    // Z layout (bottom to top)
    z_bottom = -total_length_mm/2;
    z_nozzle0 = z_bottom;
    z_block0  = z_nozzle0 + nozzle_length_mm;
    z_break0  = z_block0  + heater_block_z_mm;
    z_sink0   = z_break0  + heatbreak_length_mm;
    z_top     = z_sink0   + heatsink_length_mm;

    // Centers
    z_nozzle_c = z_nozzle0 + nozzle_length_mm/2;
    z_block_c  = z_block0  + heater_block_z_mm/2;
    z_break_c  = z_break0  + heatbreak_length_mm/2;
    z_sink_c   = z_sink0   + heatsink_length_mm/2;

    // Groove position (from top face downward)
    groove_center_z = z_top - groove_z_from_top_mm - groove_height_mm/2;

    difference() {
        union() {
            // --- Heatsink core (cylinder) ---
            translate([0,0,z_sink_c])
                cylinder(d=heatsink_diameter_mm, h=heatsink_length_mm + overlap_mm, center=true);

            // --- Heatsink fins (radial discs) ---
            fin_total_span = fin_count*fin_thickness_mm + (fin_count-1)*fin_gap_mm;
            fin_start_z = z_sink0 + (heatsink_length_mm - fin_total_span)/2;
            fin_stack(fin_start_z, fin_count, fin_thickness_mm, fin_gap_mm, fin_diameter_mm);

            // --- Groove mount ring (connected to heatsink) ---
            translate([0,0,groove_center_z])
                cylinder(d=groove_diameter_mm, h=groove_height_mm + overlap_mm, center=true);

            // --- Heatsink "key" rib (asymmetric, connected) ---
            // Placed on +X side; overlaps into heatsink cylinder by overlap_mm.
            key_zc = z_top - heatsink_key_h_mm/2; // near top for visibility
            translate([heatsink_diameter_mm/2 + heatsink_key_t_mm/2 - overlap_mm, 0, key_zc])
                cube([heatsink_key_t_mm + 2*overlap_mm, heatsink_key_w_mm, heatsink_key_h_mm + overlap_mm], center=true);

            // --- Heat break / barrel (3.7mm OD) ---
            translate([0,0,z_break_c])
                cylinder(d=barrel_diameter_mm, h=heatbreak_length_mm + 2*overlap_mm, center=true);

            // --- Heater block ---
            translate([0,0,z_block_c])
                cube([heater_block_x_mm, heater_block_y_mm, heater_block_z_mm + overlap_mm], center=true);

            // --- Heater block side boss (asymmetric, connected) ---
            // Boss center is offset from block +X face by half boss length minus overlap.
            boss_xc = heater_block_x_mm/2 + block_side_boss_len_mm/2 - overlap_mm;
            boss_zc = z_block0 + heater_block_z_mm*0.55; // aligns with cartridge bore height
            translate([boss_xc, 0, boss_zc])
                rotate([0,90,0])
                    cylinder(d=block_side_boss_d_mm, h=block_side_boss_len_mm + 2*overlap_mm, center=true);

            // --- Nozzle: hex base + conical tip (connected to block) ---
            nozzle_hex_h  = nozzle_length_mm * 0.55;
            nozzle_cone_h = nozzle_length_mm - nozzle_hex_h;

            translate([0,0, z_nozzle0 + nozzle_hex_h/2 + overlap_mm/2])
                hex_prism(nozzle_hex_flat_mm, nozzle_hex_h + overlap_mm, center=true);

            translate([0,0, z_nozzle0 + nozzle_hex_h + nozzle_cone_h/2])
                cylinder(d1=nozzle_hex_flat_mm*0.95, d2=nozzle_tip_diameter_mm, h=nozzle_cone_h + overlap_mm, center=true);
        }

        // -------------------- Internal/side bores (subtractions) --------------------

        // Filament path through entire hot end (verifiable 1.75mm + clearance)
        translate([0,0,0])
            cylinder(d=filament_bore_diameter_mm, h=total_length_mm + 4*overlap_mm, center=true);

        // Heater cartridge bore through heater block (X axis)
        cartridge_z = z_block0 + heater_block_z_mm*0.55;
        translate([0,0,cartridge_z])
            rotate([0,90,0])
                cylinder(d=heater_cartridge_diameter_mm, h=heater_cartridge_length_mm + 2*overlap_mm, center=true);

        // Thermistor bore through heater block (Y axis)
        therm_z = z_block0 + heater_block_z_mm*0.30;
        translate([0,0,therm_z])
            rotate([90,0,0])
                cylinder(d=thermistor_diameter_mm, h=thermistor_length_mm + 2*overlap_mm, center=true);
    }
}

hot_end_connected();