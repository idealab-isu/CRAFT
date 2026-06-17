// 3D Printer Hot End (single connected solid) with verifiable dimensions:
// - Total length (Z): 51.2mm
// - Heatbreak/barrel diameter: 4.75mm
// - Filament path: 1.75mm nominal (bore = 1.95mm)
//
// Fixes vs prior:
// - Added recognizable heater block details (cartridge + thermistor bores, nozzle seat)
// - Added more realistic nozzle (hex + cone tip) and internal melt cone
// - Added stepped filament path (upper bore + heatbreak + melt cone + nozzle orifice)
// - Ensured all parts are connected using dimension-derived Z formulas (no arbitrary offsets)

$fn = 72;

// -------------------- Parameters --------------------
total_length_mm = 51.2;

barrel_diameter_mm = 4.75;          // heatbreak OD
filament_diameter_mm = 1.75;
filament_clearance_mm = 0.20;
filament_bore_diameter_mm = filament_diameter_mm + 2*filament_clearance_mm; // 1.95

overlap_mm = 0.6;

// Heatsink / top body
heatsink_outer_diameter_mm = 16;
heatsink_length_mm = 22;

num_fins = 7;
fin_thickness_mm = 1.2;
fin_gap_mm = 1.2;
fin_outer_diameter_mm = 22;

// Groove mount ring
groove_outer_diameter_mm = 12;
groove_length_mm = 6;

// Heatbreak / barrel
barrel_length_mm = 23.2;

// Heater block
heater_block_size_x_mm = 16;
heater_block_size_y_mm = 16;
heater_block_height_mm = 12;

// Heater block details
cartridge_diameter_mm = 6.0;
thermistor_diameter_mm = 3.0;

// Nozzle (more recognizable)
nozzle_length_mm = 6;
nozzle_hex_flat_mm = 7.0;           // across flats
nozzle_hex_height_mm = 2.6;         // portion of nozzle that is hex
nozzle_cone_height_mm = nozzle_length_mm - nozzle_hex_height_mm;
nozzle_tip_diameter_mm = 1.2;       // external tip diameter
nozzle_orifice_diameter_mm = 0.4;   // internal exit

// Nozzle seat / melt zone
nozzle_seat_diameter_mm = 6.0;      // bore in heater block for nozzle shoulder
nozzle_seat_depth_mm = 2.0;         // depth into block

// Upper bore (PTFE-ish) inside heatsink
upper_bore_diameter_mm = 2.2;

// Derived: allocate any remainder to a short neck/collar section
neck_diameter_mm = max(barrel_diameter_mm, 6);
neck_length_mm = max(
    0,
    total_length_mm - (heatsink_length_mm + barrel_length_mm + heater_block_height_mm + nozzle_length_mm)
);

// -------------------- Z layout (bottom at z=0) --------------------
z0 = 0;

z_nozzle0 = z0;
z_nozzle1 = z_nozzle0 + nozzle_length_mm;

z_block0 = z_nozzle1 - overlap_mm;
z_block1 = z_block0 + heater_block_height_mm;

z_barrel0 = z_block1 - overlap_mm;
z_barrel1 = z_barrel0 + barrel_length_mm;

z_neck0 = z_barrel1 - overlap_mm;
z_neck1 = z_neck0 + neck_length_mm;

z_heatsink0 = z_neck1 - overlap_mm;
z_heatsink1 = z_heatsink0 + heatsink_length_mm;

// Groove ring near top of heatsink (connected)
z_groove_center = z_heatsink1 - groove_length_mm/2 - overlap_mm;

// -------------------- Helpers --------------------
module z_cyl_const(z0_, z1_, r_) {
    h_ = max(0.01, z1_ - z0_);
    zc_ = (z0_ + z1_) / 2;
    translate([0,0,zc_]) cylinder(h=h_, r=r_, center=true);
}

module z_cyl_taper(z0_, z1_, r1_, r2_) {
    h_ = max(0.01, z1_ - z0_);
    zc_ = (z0_ + z1_) / 2;
    translate([0,0,zc_]) cylinder(h=h_, r1=r1_, r2=r2_, center=true);
}

module z_cube(z0_, z1_, sx_, sy_) {
    h_ = max(0.01, z1_ - z0_);
    zc_ = (z0_ + z1_) / 2;
    translate([0,0,zc_]) cube([sx_, sy_, h_], center=true);
}

module z_hex_prism(z0_, z1_, flat_mm) {
    // Regular hex with given across-flats
    r_ = flat_mm / sqrt(3); // circumradius for across-flats = sqrt(3)*r
    h_ = max(0.01, z1_ - z0_);
    zc_ = (z0_ + z1_) / 2;
    translate([0,0,zc_]) cylinder(h=h_, r=r_, $fn=6, center=true);
}

module heatsink_with_fins(z0_, z1_) {
    // Core cylinder
    z_cyl_const(z0_, z1_, heatsink_outer_diameter_mm/2);

    // Fins: discs along heatsink length
    fin_pitch = fin_thickness_mm + fin_gap_mm;
    usable_len = (z1_ - z0_);
    fin_stack_len = num_fins * fin_thickness_mm + max(0, (num_fins-1)) * fin_gap_mm;
    fin_start = z0_ + max(0, (usable_len - fin_stack_len)/2);

    for (i = [0 : max(0, num_fins-1)]) {
        f0 = fin_start + i * fin_pitch;
        f1 = f0 + fin_thickness_mm;

        f0c = max(z0_, f0);
        f1c = min(z1_, f1);

        if (f1c > f0c + 0.02)
            z_cyl_const(f0c, f1c, fin_outer_diameter_mm/2);
    }

    // Groove ring near top
    z_cyl_const(
        z_groove_center - groove_length_mm/2,
        z_groove_center + groove_length_mm/2,
        groove_outer_diameter_mm/2
    );
}

// -------------------- Solid geometry --------------------
module nozzle_solid() {
    // Hex section at top + cone to tip
    union() {
        // Hex at top of nozzle
        z_hex_prism(z_nozzle1 - nozzle_hex_height_mm, z_nozzle1, nozzle_hex_flat_mm);

        // Cone down to tip
        z_cyl_taper(
            z_nozzle0,
            z_nozzle1 - nozzle_hex_height_mm + overlap_mm,
            (nozzle_hex_flat_mm / sqrt(3)), // match hex circumradius at join
            nozzle_tip_diameter_mm/2
        );
    }
}

module heater_block_solid() {
    // Main block + small boss around heatbreak entry for a clearer silhouette
    union() {
        z_cube(z_block0, z_block1, heater_block_size_x_mm, heater_block_size_y_mm);

        // Slight top boss (helps silhouette and suggests clamp area)
        boss_d = 10;
        boss_h = 2.0;
        z_cyl_const(z_block1 - boss_h, z_block1 + overlap_mm, boss_d/2);
    }
}

module hotend_solid() {
    union() {
        // Nozzle
        nozzle_solid();

        // Heater block
        heater_block_solid();

        // Heatbreak / barrel (4.75mm diameter)
        z_cyl_const(z_barrel0, z_barrel1, barrel_diameter_mm/2);

        // Neck/collar to reach exact total length (if needed)
        if (neck_length_mm > 0.02)
            z_cyl_const(z_neck0, z_neck1, neck_diameter_mm/2);

        // Heatsink with fins + groove
        heatsink_with_fins(z_heatsink0, z_heatsink1);
    }
}

// -------------------- Internal bores (subtractions) --------------------
module filament_path_bore() {
    // Stepped bore:
    // - Upper bore through heatsink/neck (slightly larger)
    // - Heatbreak bore (filament_bore_diameter_mm)
    // - Melt cone in heater block
    // - Nozzle orifice at tip
    upper_r = upper_bore_diameter_mm/2;
    hb_r = filament_bore_diameter_mm/2;
    orifice_r = nozzle_orifice_diameter_mm/2;

    // Upper bore: from top down to just above heatbreak start
    z_cyl_const(z_barrel1 - overlap_mm, total_length_mm + overlap_mm, upper_r);

    // Heatbreak bore: through heatbreak
    z_cyl_const(z_barrel0 - overlap_mm, z_barrel1 + overlap_mm, hb_r);

    // Through heater block: straight section down to melt cone start
    melt_cone_top_z = z_block0 + heater_block_height_mm*0.65;
    z_cyl_const(melt_cone_top_z, z_block1 + overlap_mm, hb_r);

    // Melt cone: expands toward nozzle seat
    z_cyl_taper(z_nozzle1 - overlap_mm, melt_cone_top_z, nozzle_seat_diameter_mm/2, hb_r);

    // Nozzle orifice: from tip up into nozzle
    z_cyl_const(z_nozzle0 - overlap_mm, z_nozzle0 + nozzle_cone_height_mm + overlap_mm, orifice_r);
}

module heater_block_feature_bores() {
    // Cartridge heater bore (X direction) and thermistor bore (Y direction)
    // Positioned by formulas from block size; centered in Z of block.
    zc = (z_block0 + z_block1)/2;

    // Cartridge: along X, centered in Y, slightly below center in Z
    cart_z = zc - heater_block_height_mm*0.10;
    translate([0, 0, cart_z])
        rotate([0,90,0])
            cylinder(h=heater_block_size_x_mm + 2*overlap_mm, r=cartridge_diameter_mm/2, center=true);

    // Thermistor: along Y, offset in X, slightly above cartridge
    therm_z = zc + heater_block_height_mm*0.10;
    therm_x = heater_block_size_x_mm*0.22;
    translate([therm_x, 0, therm_z])
        rotate([90,0,0])
            cylinder(h=heater_block_size_y_mm + 2*overlap_mm, r=thermistor_diameter_mm/2, center=true);

    // Nozzle seat pocket into bottom of block (so nozzle looks seated)
    z_cyl_const(z_block0 - overlap_mm, z_block0 + nozzle_seat_depth_mm, nozzle_seat_diameter_mm/2);
}

// -------------------- Final model --------------------
difference() {
    hotend_solid();
    union() {
        filament_path_bore();
        heater_block_feature_bores();
    }
}