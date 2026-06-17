$fn=96;

// Units: mm
// Simple generic hot end model:
// - Total length: 51.2
// - Barrel diameter: 4.75
// - Filament path: 1.75 (through-hole)
// Includes a small heater block and a nozzle for visual completeness.

total_len = 51.2;
barrel_d  = 4.75;
filament_d = 1.75;

// Segment lengths (sum to total_len)
nozzle_len = 12.0;
block_len  = 10.0;
barrel_len = total_len - nozzle_len - block_len;

// Heater block dimensions
block_w = 16;
block_h = 16;

// Nozzle dimensions
nozzle_base_d = 7.0;
nozzle_tip_d  = 1.0;

// Filament path (slightly extended for clean subtraction)
hole_extra = 2;

module hotend() {
  difference() {
    union() {
      // Nozzle (bottom)
      translate([0,0,0])
        cylinder(h=nozzle_len, d1=nozzle_tip_d, d2=nozzle_base_d);

      // Heater block (middle)
      translate([-block_w/2, -block_h/2, nozzle_len])
        cube([block_w, block_h, block_len], center=false);

      // Barrel (top)
      translate([0,0,nozzle_len + block_len])
        cylinder(h=barrel_len, d=barrel_d);
    }

    // Filament through-hole
    translate([0,0,-hole_extra])
      cylinder(h=total_len + 2*hole_extra, d=filament_d);

    // Optional heater cartridge hole (visual)
    // 6mm cartridge through the block along X
    translate([0, 0, nozzle_len + block_len/2])
      rotate([0,90,0])
        cylinder(h=block_w + 2, d=6.0, center=true);

    // Optional thermistor hole (visual)
    translate([block_w/2 - 3.5, 0, nozzle_len + block_len/2])
      rotate([90,0,0])
        cylinder(h=block_h + 2, d=3.0, center=true);
  }
}

hotend();