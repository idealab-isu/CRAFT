// 3D Printer Hot End (stylized) - ONE connected solid
// Targets:
// - Total length: 51.2mm
// - Barrel (heatbreak) diameter: 4.75mm
// - Filament path: 1.75mm (bore set by filament_bore_diameter_mm)

$fn = 96;

// Parameters
total_length_mm = 51.2;                 //[25.6:102.4:0.1]
barrel_diameter_mm = 4.75;              //[2.4:9.5:0.05]
filament_diameter_mm = 1.75;            //[1.0:3.0:0.05]
filament_clearance_mm = 0.2;            //[0.0:0.6:0.05]
filament_bore_diameter_mm = 1.95;       //[1.2:3.5:0.05]

// Small overlap to guarantee watertight unions/differences
overlap = 0.25;

// --- Derived / fixed feature sizes (stylized E3D-like) ---
barrel_r = barrel_diameter_mm/2;

// Segment lengths (sum to total_length_mm)
heatsink_h = 22.0;
heatbreak_h = 12.0;                     // includes the 4.75mm barrel section
heaterblock_h = 12.0;
nozzle_h = total_length_mm - (heatsink_h + heatbreak_h + heaterblock_h); // remainder

// Ensure nozzle_h is non-negative for given total length
nozzle_h_safe = (nozzle_h < 3) ? 3 : nozzle_h;

// Rebalance if nozzle_h was clamped
extra = nozzle_h_safe - nozzle_h;
heatsink_h_adj = heatsink_h - extra;    // keep total length exact
heatsink_h_final = (heatsink_h_adj < 10) ? 10 : heatsink_h_adj;

// Recompute to keep exact total length if heatsink got clamped
extra2 = (heatsink_h_adj < 10) ? (10 - heatsink_h_adj) : 0;
heaterblock_h_final = heaterblock_h - extra2;
heaterblock_h_final2 = (heaterblock_h_final < 8) ? 8 : heaterblock_h_final;

// Final recompute nozzle to keep exact total length
nozzle_h_final = total_length_mm - (heatsink_h_final + heatbreak_h + heaterblock_h_final2);

// Feature diameters
heatsink_od = 22.0;
heatsink_core_od = 12.0;
fin_count = 7;
fin_th = 1.2;
fin_gap = (heatsink_h_final - fin_count*fin_th) / (fin_count-1);
fin_gap_final = (fin_gap < 0.6) ? 0.6 : fin_gap;

heaterblock_xy = 16.0;
heaterblock_z = heaterblock_h_final2;

nozzle_hex_flat = 7.0;                  // across flats (stylized)
nozzle_tip_d = 1.2;
nozzle_top_d = 6.0;

// Positions along Z (centered assembly)
z0 = -total_length_mm/2;
z_heatsink0 = z0;
z_heatbreak0 = z_heatsink0 + heatsink_h_final;
z_block0 = z_heatbreak0 + heatbreak_h;
z_nozzle0 = z_block0 + heaterblock_z;

// Helpers
module hex_prism(af=7, h=5, center=false) {
    // across flats -> circumradius
    r = af / (2*cos(180/6));
    cylinder(r=r, h=h, center=center, $fn=6);
}

module heatsink() {
    // Core + fins (all connected)
    union() {
        // Core cylinder
        translate([0,0, z_heatsink0 + heatsink_h_final/2])
            cylinder(d=heatsink_core_od, h=heatsink_h_final, center=true);

        // Fins
        for (i = [0:fin_count-1]) {
            z_fin = z_heatsink0 + i*(fin_th + fin_gap_final) + fin_th/2;
            translate([0,0,z_fin])
                cylinder(d=heatsink_od, h=fin_th, center=true);
        }

        // Top cap / mount stub (keeps it hotend-like)
        top_cap_h = 3.0;
        translate([0,0, z_heatsink0 + heatsink_h_final - top_cap_h/2 + overlap/2])
            cylinder(d=heatsink_core_od+2, h=top_cap_h+overlap, center=true);
    }
}

module heatbreak_barrel() {
    // 4.75mm barrel diameter section (requested)
    translate([0,0, z_heatbreak0 + heatbreak_h/2])
        cylinder(d=barrel_diameter_mm, h=heatbreak_h + overlap, center=true);
}

module heater_block() {
    // Block centered on its segment; includes a small neck overlap to ensure connection
    translate([0,0, z_block0 + heaterblock_z/2])
        cube([heaterblock_xy, heaterblock_xy, heaterblock_z + overlap], center=true);
}

module nozzle() {
    // Stylized nozzle: hex + conical tip, connected to heater block
    union() {
        hex_h = min(4.0, nozzle_h_final*0.55);
        cone_h = nozzle_h_final - hex_h;

        // Hex portion (top of nozzle)
        translate([0,0, z_nozzle0 + hex_h/2 - overlap/2])
            hex_prism(af=nozzle_hex_flat, h=hex_h + overlap, center=true);

        // Cone to tip
        translate([0,0, z_nozzle0 + hex_h + cone_h/2])
            cylinder(d1=nozzle_top_d, d2=nozzle_tip_d, h=cone_h + overlap, center=true);
    }
}

module filament_bore() {
    // Through-bore for 1.75mm filament (with clearance)
    // Use filament_bore_diameter_mm parameter; ensure it is >= filament_diameter_mm + clearance
    bore_d = max(filament_bore_diameter_mm, filament_diameter_mm + filament_clearance_mm);
    translate([0,0,0])
        cylinder(d=bore_d, h=total_length_mm + 2*overlap, center=true);
}

module hotend_solid() {
    // ONE connected solid assembly
    union() {
        heatsink();
        heatbreak_barrel();
        heater_block();
        nozzle();

        // Small internal "neck" overlap between heatsink core and heatbreak (guarantees union)
        neck_h = 1.2;
        translate([0,0, z_heatbreak0 - neck_h/2 + overlap/2])
            cylinder(d=heatsink_core_od, h=neck_h + overlap, center=true);

        // Small overlap between heatbreak and heater block (guarantees union)
        bridge_h = 1.2;
        translate([0,0, z_block0 - bridge_h/2 + overlap/2])
            cylinder(d=barrel_diameter_mm + 1.0, h=bridge_h + overlap, center=true);

        // Small overlap between heater block and nozzle (guarantees union)
        bridge2_h = 1.2;
        translate([0,0, z_nozzle0 - bridge2_h/2 + overlap/2])
            cylinder(d=nozzle_top_d, h=bridge2_h + overlap, center=true);
    }
}

difference() {
    hotend_solid();
    filament_bore();
}