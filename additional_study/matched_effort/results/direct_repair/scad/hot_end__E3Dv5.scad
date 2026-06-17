$fn = 96;

// Units: mm
// Simple stylized 3D-printer hot end for 1.75mm filament
// Total length: 70.0mm
// Barrel diameter: 3.7mm

total_len = 70.0;
barrel_d = 3.7;
filament_d = 1.75;

// Segment lengths (sum to total_len)
len_nozzle = 12.0;
len_block  = 12.0;
len_sink   = 18.0;
len_barrel = total_len - (len_nozzle + len_block + len_sink); // 28.0

// Feature sizes
nozzle_tip_d = 1.2;
nozzle_base_d = 7.0;

block_w = 16.0;
block_d = 16.0;

sink_outer_d = 12.0;
sink_fins = 8;
sink_fin_th = 1.2;

module hotend() {
  difference() {
    union() {
      // Nozzle (bottom)
      translate([0,0,0])
        cylinder(h=len_nozzle, d1=nozzle_tip_d, d2=nozzle_base_d);

      // Heater block
      translate([0,0,len_nozzle])
        cube([block_w, block_d, len_block], center=false);

      // Align block centered on axis
      // (cube is from (0,0,...) so shift it)
      // We'll shift the whole union later by translating block only:
    }
  }
}

module hotend_full() {
  difference() {
    union() {
      // Nozzle (bottom)
      cylinder(h=len_nozzle, d1=nozzle_tip_d, d2=nozzle_base_d);

      // Heater block centered on axis
      translate([-block_w/2, -block_d/2, len_nozzle])
        cube([block_w, block_d, len_block], center=false);

      // Heat sink (finned cylinder)
      translate([0,0,len_nozzle+len_block]) {
        // Core
        cylinder(h=len_sink, d=barrel_d + 2.0);

        // Fins
        for (i = [0:sink_fins-1]) {
          z0 = i*(len_sink/sink_fins);
          translate([0,0,z0])
            cylinder(h=sink_fin_th, d=sink_outer_d);
        }
      }

      // Barrel / heat break (top)
      translate([0,0,len_nozzle+len_block+len_sink])
        cylinder(h=len_barrel, d=barrel_d);

      // Small top collar
      translate([0,0,total_len-3.0])
        cylinder(h=3.0, d=6.0);
    }

    // Filament path through entire hotend
    translate([0,0,-0.5])
      cylinder(h=total_len+1.0, d=filament_d);

    // Heater cartridge hole (stylized) through block
    translate([0, 0, len_nozzle + len_block/2])
      rotate([0,90,0])
        cylinder(h=block_w+2.0, d=6.0, center=true);

    // Thermistor hole (stylized) through block
    translate([0, -block_d/4, len_nozzle + len_block/2])
      rotate([90,0,0])
        cylinder(h=block_d+2.0, d=3.0, center=true);
  }
}

hotend_full();