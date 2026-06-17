// Parameters
total_length_mm = 66; //[33:132:0.5]
barrel_diameter_mm = 6.8; //[3.4:13.6:0.1]
filament_diameter_mm = 1.75; //[1.5:3:0.05]
filament_bore_diameter_mm = 2; //[1.8:3.5:0.05]
style = 0; //[0:2:1]
include_heater_block = 1; //[0:1:1]
include_nozzle = 1; //[0:1:1]
include_mounting_groove = 0; //[0:1:1]
eps_mm = 1; //[0.5:2:0.1]
top_stub_length_mm = 10; //[5:20:0.5]
heatsink_length_mm = 25; //[12:60:0.5]
heater_block_height_mm = 12; //[8:20:0.5]
heater_block_size_x_mm = 20; //[12:30:0.5]
heater_block_size_y_mm = 16; //[10:26:0.5]
nozzle_length_mm = 12; //[6:20:0.5]
nozzle_base_diameter_mm = 7; //[5:12:0.1]
nozzle_tip_diameter_mm = 1; //[0.4:2:0.05]
mount_groove_outer_diameter_mm = 12; //[8:24:0.5]
mount_groove_thickness_mm = 4; //[2:8:0.5]
mount_groove_z_from_top_mm = 6; //[2:15:0.5]
body_outer_diameter_mm = 16; //[10:30:0.5]

// Quality
$fn = 96;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Hot End - complete geometry (single connected solid with internal filament bore)
module hot_end() {

  // Derived lengths (ensure non-negative)
  mid_length_mm =
    clamp(
      total_length_mm
      - top_stub_length_mm
      - heatsink_length_mm
      - (include_heater_block ? heater_block_height_mm : 0)
      - (include_nozzle ? nozzle_length_mm : 0),
      0.1,
      total_length_mm
    );

  // Z layout from bottom (-total/2) to top (+total/2)
  z_bottom = -total_length_mm/2;

  z_nozzle_start = z_bottom;
  z_nozzle_end   = z_nozzle_start + (include_nozzle ? nozzle_length_mm : 0);

  z_block_start  = z_nozzle_end;
  z_block_end    = z_block_start + (include_heater_block ? heater_block_height_mm : 0);

  z_mid_start    = z_block_end;
  z_mid_end      = z_mid_start + mid_length_mm;

  z_sink_start   = z_mid_end;
  z_sink_end     = z_sink_start + heatsink_length_mm;

  z_top_start    = z_sink_end;
  z_top_end      = z_top_start + top_stub_length_mm;

  // Heatsink fin geometry (recognizable profile)
  fin_count = 8;
  fin_thickness = 1.2;
  fin_gap = (heatsink_length_mm - fin_count*fin_thickness) / (fin_count + 1);
  fin_gap_eff = fin_gap < 0.2 ? 0.2 : fin_gap;

  fin_outer_d = body_outer_diameter_mm;
  fin_root_d  = body_outer_diameter_mm * 0.78;

  // Heatbreak transition (taper) between heatsink root and barrel
  heatbreak_taper_h = 4;

  // Nozzle details
  nozzle_hex_h = 3.5;
  nozzle_hex_flat = nozzle_base_diameter_mm * 1.15; // across flats (approx)
  nozzle_thread_h = nozzle_length_mm - nozzle_hex_h;
  nozzle_thread_h_eff = nozzle_thread_h < 1 ? 1 : nozzle_thread_h;

  // Heater block details (cartridge + thermistor bores)
  cart_d = 6.2;
  cart_z = 0; // centered in block
  cart_y = heater_block_size_y_mm*0.25;

  therm_d = 3.2;
  therm_y = -heater_block_size_y_mm*0.25;
  therm_z = -heater_block_height_mm*0.15;

  // Mount groove (optional)
  groove_h = mount_groove_thickness_mm;
  groove_d = mount_groove_outer_diameter_mm;

  // Build as one connected solid: union of outer shapes, then subtract filament bore + block holes
  difference() {
    union() {

      // Top stub (smooth cylinder)
      translate([0,0,(z_top_start+z_top_end)/2])
        cylinder(d=body_outer_diameter_mm*0.92, h=(z_top_end-z_top_start), center=true);

      // Heatsink core (root cylinder)
      translate([0,0,(z_sink_start+z_sink_end)/2])
        cylinder(d=fin_root_d, h=(z_sink_end-z_sink_start), center=true);

      // Heatsink fins (radial discs) - connected by core
      for (i = [0:fin_count-1]) {
        z_fin_center =
          z_sink_start
          + fin_gap_eff*(i+1)
          + fin_thickness*i
          + fin_thickness/2;

        translate([0,0,z_fin_center])
          cylinder(d=fin_outer_d, h=fin_thickness, center=true);
      }

      // Heatbreak taper down to barrel diameter (ensures visible transition)
      translate([0,0,z_mid_end - heatbreak_taper_h/2])
        cylinder(d1=fin_root_d, d2=barrel_diameter_mm, h=heatbreak_taper_h, center=true);

      // Barrel / heatbreak straight section (critical diameter 6.8mm)
      translate([0,0,(z_mid_start+z_mid_end)/2])
        cylinder(d=barrel_diameter_mm, h=(z_mid_end-z_mid_start) + 0.2, center=true);

      // Heater block (with slight overlap into barrel/nozzle)
      if (include_heater_block) {
        translate([0,0,(z_block_start+z_block_end)/2])
          cube([heater_block_size_x_mm, heater_block_size_y_mm, (z_block_end-z_block_start) + 0.2], center=true);
      }

      // Nozzle (threaded cylinder + hex + conical tip)
      if (include_nozzle) {
        // Threaded section (cylinder)
        translate([0,0,z_nozzle_start + nozzle_thread_h_eff/2])
          cylinder(d=nozzle_base_diameter_mm*0.95, h=nozzle_thread_h_eff + 0.2, center=true);

        // Hex section (6-sided prism)
        translate([0,0,z_nozzle_start + nozzle_thread_h_eff + nozzle_hex_h/2])
          cylinder(h=nozzle_hex_h + 0.2, d=nozzle_hex_flat, $fn=6, center=true);

        // Conical tip
        tip_h = nozzle_length_mm*0.45;
        tip_h_eff = tip_h < 2 ? 2 : tip_h;
        translate([0,0,z_nozzle_end - tip_h_eff/2])
          cylinder(d1=nozzle_base_diameter_mm*0.55, d2=nozzle_tip_diameter_mm, h=tip_h_eff, center=true);
      }

      // Optional mounting groove ring (connected to heatsink/top)
      if (include_mounting_groove) {
        // Place groove measured down from top end
        z_groove_center = (total_length_mm/2) - mount_groove_z_from_top_mm;
        translate([0,0,z_groove_center])
          cylinder(d=groove_d, h=groove_h, center=true);
      }
    }

    // Filament bore (1.75mm filament path -> use filament_bore_diameter_mm)
    translate([0,0,0])
      cylinder(d=filament_bore_diameter_mm, h=total_length_mm + 2*eps_mm, center=true);

    // Heater block cartridge + thermistor holes (do not break connectivity; they are subtractions)
    if (include_heater_block) {
      z_block_center = (z_block_start+z_block_end)/2;

      // Cartridge hole along X
      translate([0, cart_y, z_block_center + cart_z])
        rotate([0,90,0])
          cylinder(d=cart_d, h=heater_block_size_x_mm + 2*eps_mm, center=true);

      // Thermistor hole along X
      translate([0, therm_y, z_block_center + therm_z])
        rotate([0,90,0])
          cylinder(d=therm_d, h=heater_block_size_x_mm + 2*eps_mm, center=true);
    }
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() { hot_end(); }

// E3D Hot End - complete geometry
module e3d_hot_end() { hot_end(); }

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() { hot_end(); }

// Jhead Hot End - complete geometry
module jhead_hot_end() { hot_end(); }

// Final Assembly
module assembly() { e3d_hot_end_assembly(); }

assembly();