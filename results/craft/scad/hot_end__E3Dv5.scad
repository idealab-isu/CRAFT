// 3D printer hot end (stylized but recognizable) with required dimensions:
// - total length: 70.0mm
// - heatbreak/barrel diameter: 3.7mm
// - filament path: 1.75mm (with clearance)

$fn = 128;

// Parameters
total_length_mm = 70;                 // required
barrel_diameter_mm = 3.7;             // required (heatbreak OD)
filament_diameter_mm = 1.75;          // required
filament_bore_clearance_mm = 0.2;
filament_bore_diameter_mm = filament_diameter_mm + filament_bore_clearance_mm;
overlap_mm = 0.8;                     // small overlap to guarantee watertight unions

// Derived
barrel_r = barrel_diameter_mm/2;
bore_r   = filament_bore_diameter_mm/2;

// Segment lengths (sum exactly to total_length_mm)
heatsink_h  = 26;
heatbreak_h = 18;
heater_h    = 12;
nozzle_h    = total_length_mm - (heatsink_h + heatbreak_h + heater_h);

// Z extents (model spans [-total_length/2, +total_length/2])
z_top = total_length_mm/2;
z_bot = -total_length_mm/2;

// Segment centers (formula-based, contiguous)
z_heatsink_center  = z_top - heatsink_h/2;
z_heatbreak_center = z_top - heatsink_h - heatbreak_h/2;
z_heater_center    = z_top - heatsink_h - heatbreak_h - heater_h/2;
z_nozzle_center    = z_bot + nozzle_h/2;

// Heatsink geometry (recognizable fins + side clamp flats)
heatsink_core_d = 14;
fin_d = 22;
fin_th = 1.2;
fin_gap = 1.2;
num_fins = 9;

cap_h = 6;
cap_d = 12;

// Heater block geometry (with cartridge + thermistor bumps)
heater_w = 20;
heater_d = 16;

// Nozzle geometry
nozzle_hex_flat = 7;     // across flats (stylized)
nozzle_hex_h = 4;
nozzle_cone_h = nozzle_h - nozzle_hex_h;
nozzle_top_d = 8.5;
nozzle_tip_d = 1.2;

// Helpers
module hex_prism(af, h, center=true) {
  // Regular hex with across-flats = af
  r = af / sqrt(3); // circumradius
  cylinder(h=h, r=r, $fn=6, center=center);
}

module heatsink() {
  union() {
    // Core cylinder
    translate([0,0,z_heatsink_center])
      cylinder(h=heatsink_h, r=heatsink_core_d/2, center=true);

    // Fins distributed along upper portion of heatsink
    fin_stack_h = num_fins*fin_th + (num_fins-1)*fin_gap;
    fin_top_z = z_top - cap_h - 1.0; // leave room for cap; formula-based
    fin_start_z = fin_top_z - fin_th/2;
    for (i = [0:num_fins-1]) {
      zf = fin_start_z - i*(fin_th + fin_gap);
      translate([0,0,zf])
        cylinder(h=fin_th, r=fin_d/2, center=true);
    }

    // Top cap / mount
    translate([0,0,z_top - cap_h/2 + overlap_mm])
      cylinder(h=cap_h, r=cap_d/2, center=true);

    // Side clamp flats (gives recognizable silhouette in orthographic views)
    // Two opposing "ears" blended into the core so it isn't just a circle.
    flat_w = heatsink_core_d*0.85;
    flat_t = 4.0;
    flat_h = 10.0;
    z_flat = z_top - cap_h - flat_h/2 - 2.0;
    translate([0,0,z_flat])
      union() {
        translate([0, (heatsink_core_d/2) - flat_t/2 + 0.2, 0])
          cube([flat_w, flat_t, flat_h], center=true);
        translate([0, -(heatsink_core_d/2) + flat_t/2 - 0.2, 0])
          cube([flat_w, flat_t, flat_h], center=true);
      }
  }
}

module heatbreak() {
  // Required 3.7mm OD barrel, connected with overlaps
  translate([0,0,z_heatbreak_center])
    cylinder(h=heatbreak_h + 2*overlap_mm, r=barrel_r, center=true);
}

module heater_block() {
  // Main block centered on heatbreak axis
  translate([0,0,z_heater_center])
  union() {
    cube([heater_w, heater_d, heater_h + 2*overlap_mm], center=true);

    // Cartridge heater cylinder protrusion (side feature)
    cart_d = 6;
    cart_len = heater_w*0.75;
    // Place so it intersects the block (connected), along X axis
    translate([0, 0, 0])
      rotate([0,90,0])
        translate([0,0, (heater_w/2 - cart_len/2 + 0.6)]) // overlap into block
          cylinder(h=cart_len, r=cart_d/2, center=true);

    // Thermistor bump (smaller side feature)
    therm_d = 3;
    therm_len = heater_d*0.65;
    rotate([90,0,0])
      translate([0,0, (heater_d/2 - therm_len/2 + 0.6)]) // overlap into block
        cylinder(h=therm_len, r=therm_d/2, center=true);
  }
}

module nozzle() {
  // Hex + cone, connected to heater block via overlap
  union() {
    // Hex section at top of nozzle
    z_hex = z_bot + nozzle_cone_h + nozzle_hex_h/2;
    translate([0,0,z_hex])
      hex_prism(nozzle_hex_flat, nozzle_hex_h + 2*overlap_mm, center=true);

    // Cone section
    z_cone = z_bot + nozzle_cone_h/2;
    translate([0,0,z_cone])
      cylinder(h=nozzle_cone_h + 2*overlap_mm, r1=nozzle_top_d/2, r2=nozzle_tip_d/2, center=true);
  }
}

module hot_end() {
  difference() {
    union() {
      heatsink();
      heatbreak();
      heater_block();
      nozzle();

      // Small transition collar between heatsink and heatbreak (adds realism + ensures connection)
      collar_h = 3.0;
      collar_d = 8.0;
      z_collar = z_top - heatsink_h - collar_h/2;
      translate([0,0,z_collar])
        cylinder(h=collar_h + 2*overlap_mm, r=collar_d/2, center=true);
    }

    // Filament bore through entire assembly
    cylinder(h=total_length_mm + 6*overlap_mm, r=bore_r, center=true);
  }
}

hot_end();