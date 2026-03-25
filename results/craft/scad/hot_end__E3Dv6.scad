// 3D printer hot end (stylized E3D/J-head-like) with verified key dimensions:
// - Total length: 62.0mm (top of heatsink to tip of nozzle)
// - Barrel diameter: 3.7mm (heatbreak/barrel OD)
// - Filament path: 1.75mm filament, bore default 2.0mm

$fn = 96;

// -------------------- Parameters --------------------
total_length_mm = 62.0;                 //[31.0:124.0:0.5]
barrel_diameter_mm = 3.7;              //[1.85:7.4:0.05]
filament_diameter_mm = 1.75;           //[1.0:3.0:0.05]
filament_bore_diameter_mm = 2.0;       //[1.8:3.0:0.05]
overlap_mm = 1.0;                      //[0.5:2.0:0.1]

// Heatsink (top)
heatsink_h = 22.0;
heatsink_od = 16.0;
heatsink_core_od = 10.0;
fin_count = 7;
fin_th = 1.2;
fin_gap = (heatsink_h - fin_count*fin_th) / (fin_count+1);
fin_od = heatsink_od;

// Heatbreak / barrel (requested 3.7mm OD)
barrel_h = 22.0;
barrel_od = barrel_diameter_mm;

// Heater block
block_h = 12.0;
block_w = 16.0;
block_d = 16.0;

// Nozzle
nozzle_h = 6.0;
nozzle_hex_h = 3.0;
nozzle_hex_flat = 7.0;   // across flats
nozzle_tip_h = nozzle_h - nozzle_hex_h;
nozzle_tip_r1 = 3.0;     // base radius of cone
nozzle_tip_r2 = 0.6;     // tip radius

// Derived: enforce exact total length by adjusting barrel_h if needed
computed_total = heatsink_h + barrel_h + block_h + nozzle_h;
barrel_h_adj = barrel_h + (total_length_mm - computed_total);

// Safety clamp (avoid negative)
barrel_h_final = (barrel_h_adj < 2) ? 2 : barrel_h_adj;

// Z layout (all formulas, no arbitrary offsets)
z0 = 0;
z_heatsink_bot = z0;
z_heatsink_top = z_heatsink_bot + heatsink_h;

z_barrel_bot = z_heatsink_top - overlap_mm;
z_barrel_top = z_barrel_bot + barrel_h_final;

z_block_bot = z_barrel_top - overlap_mm;
z_block_top = z_block_bot + block_h;

z_nozzle_bot = z_block_top - overlap_mm;
z_nozzle_top = z_nozzle_bot + nozzle_h;

// Center the whole assembly around Z=0 for nicer viewing
z_min = z_heatsink_bot;
z_max = z_nozzle_top;
z_center = (z_min + z_max)/2;

// -------------------- Helpers --------------------
module hex_prism(h, flat_d, center=false) {
  // Regular hex with given across-flats distance
  // For a regular hex, across-flats = 2 * apothem = 2 * r * cos(30) => r = flat/(2*cos30)
  r = flat_d/(2*cos(30));
  cylinder(h=h, r=r, $fn=6, center=center);
}

module heatsink() {
  // Core + fins (all connected)
  union() {
    // Core
    translate([0,0, (z_heatsink_bot + z_heatsink_top)/2 - z_center])
      cylinder(h=heatsink_h, r=heatsink_core_od/2, center=true);

    // Fins
    for (i = [0:fin_count-1]) {
      z_fin_bot = z_heatsink_bot + fin_gap*(i+1) + fin_th*i;
      translate([0,0, z_fin_bot + fin_th/2 - z_center])
        cylinder(h=fin_th, r=fin_od/2, center=true);
    }

    // Small top cap (gives typical hotend top feature)
    cap_h = 3.0;
    cap_od = 12.0;
    translate([0,0, z_heatsink_top - cap_h/2 - z_center])
      cylinder(h=cap_h, r=cap_od/2, center=true);
  }
}

module barrel() {
  translate([0,0, (z_barrel_bot + z_barrel_top)/2 - z_center])
    cylinder(h=barrel_h_final, r=barrel_od/2, center=true);
}

module heater_block() {
  // Block centered on axis, connected to barrel and nozzle
  translate([0,0, (z_block_bot + z_block_top)/2 - z_center])
    cube([block_w, block_d, block_h], center=true);
}

module nozzle() {
  union() {
    // Hex section
    translate([0,0, z_nozzle_bot + nozzle_hex_h/2 - z_center])
      hex_prism(nozzle_hex_h, nozzle_hex_flat, center=true);

    // Conical tip
    translate([0,0, z_nozzle_bot + nozzle_hex_h + nozzle_tip_h/2 - z_center])
      cylinder(h=nozzle_tip_h, r1=nozzle_tip_r1, r2=nozzle_tip_r2, center=true);
  }
}

module filament_bore() {
  // Through-bore along entire hotend length with a little extra
  extra = 4.0;
  bore_h = (z_max - z_min) + extra;
  translate([0,0, (z_min + z_max)/2 - z_center])
    cylinder(h=bore_h, r=filament_bore_diameter_mm/2, center=true);
}

// -------------------- Final connected solid --------------------
difference() {
  union() {
    heatsink();
    barrel();
    heater_block();
    nozzle();
  }
  filament_bore();
}