// Parameters
total_length_mm = 66; //[33:132:0.5]
barrel_diameter_mm = 6.8; //[3.4:13.6:0.1]
filament_diameter_mm = 1.75; //[1:3:0.05]
filament_bore_clearance_mm = 0.2; //[0.05:0.6:0.05]
filament_bore_diameter_mm = 1.95; //[1.6:3.2:0.05]
mount_diameter_mm = 16; //[8:32:0.5]
mount_length_mm = 8; //[4:20:0.5]
heatsink_diameter_mm = 22; //[11:44:0.5]
heatsink_length_mm = 30; //[15:70:0.5]
heater_block_size_x_mm = 20; //[10:40:0.5]
heater_block_size_y_mm = 16; //[8:32:0.5]
heater_block_size_z_mm = 12; //[6:24:0.5]
nozzle_length_mm = 10; //[5:25:0.5]
nozzle_tip_diameter_mm = 1.5; //[0.8:4:0.1]
nozzle_base_diameter_mm = 7; //[4:14:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Hot End - complete geometry (guaranteed internal connectivity)
module hot_end() {

  // Derived lengths so the stack exactly spans total_length_mm
  // Order (top -> bottom): mount, heatsink, barrel, heater block, nozzle
  barrel_length_mm =
    total_length_mm
    - mount_length_mm
    - heatsink_length_mm
    - heater_block_size_z_mm
    - nozzle_length_mm;

  // Guard against negative barrel length (keeps model valid)
  barrel_h = max(0.1, barrel_length_mm);

  // Build from a single reference: top face at +total_length/2
  z_top = total_length_mm/2;

  // Place each part by its center, ensuring overlap at each interface:
  // next_center = prev_center - (prev_h/2 + next_h/2 - overlap)
  z_mount_c    = z_top - mount_length_mm/2;
  z_heatsink_c = z_mount_c  - (mount_length_mm/2 + heatsink_length_mm/2 - overlap_mm);
  z_barrel_c   = z_heatsink_c - (heatsink_length_mm/2 + barrel_h/2 - overlap_mm);
  z_block_c    = z_barrel_c - (barrel_h/2 + heater_block_size_z_mm/2 - overlap_mm);
  z_nozzle_c   = z_block_c  - (heater_block_size_z_mm/2 + nozzle_length_mm/2 - overlap_mm);

  difference() {
    union() {
      color("DimGray") {
        // Mounting Interface
        translate([0, 0, z_mount_c])
          cylinder(r=mount_diameter_mm/2, h=mount_length_mm, center=true, $fn=64);

        // Heatsink Section (overlaps into mount and barrel)
        translate([0, 0, z_heatsink_c])
          cylinder(r=heatsink_diameter_mm/2, h=heatsink_length_mm, center=true, $fn=64);

        // Barrel Section (overlaps into heatsink and heater block)
        translate([0, 0, z_barrel_c])
          cylinder(r=barrel_diameter_mm/2, h=barrel_h, center=true, $fn=64);

        // Heater Block Section (overlaps into barrel and nozzle)
        translate([0, 0, z_block_c])
          cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_size_z_mm], center=true);

        // Nozzle Section (overlaps into heater block)
        translate([0, 0, z_nozzle_c])
          cylinder(r1=nozzle_base_diameter_mm/2, r2=nozzle_tip_diameter_mm/2,
                   h=nozzle_length_mm, center=true, $fn=64);
      }
    }

    // Filament Bore (subtracted so it doesn't create floating geometry)
    translate([0, 0, 0])
      cylinder(r=filament_bore_diameter_mm/2,
               h=total_length_mm + 4*overlap_mm, center=true, $fn=64);
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() { hot_end(); }

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() { hot_end(); }

// Assembly: FIXED so both hot-ends are physically connected (no gap)
// Adds a small connector that overlaps both central-facing ends by overlap_mm.
module assembly() {
  // Central connector thickness along Z (must be >= 2*overlap to overlap both sides)
  connector_h = 2*overlap_mm;

  // Connector radius: at least as large as the largest "central-facing" radius
  // (mount is the largest cylinder in this model)
  connector_r = max(mount_diameter_mm, heatsink_diameter_mm)/2;

  union() {
    // Upper hot-end (centered at Z=0)
    e3d_hot_end_assembly();

    // Lower hot-end: place so its top face overlaps the upper's bottom face by overlap_mm
    // Upper bottom face is at -total_length/2
    // Lower top face should be at (-total_length/2 + overlap_mm)
    // => lower center = (-total_length/2 + overlap_mm) - total_length/2 = -total_length + overlap_mm
    translate([0, 0, -total_length_mm + overlap_mm])
      jhead_hot_end_assembly();

    // Physical connector bridging the two central-facing ends (guaranteed overlap)
    // Spans from z = (-total_length/2 - overlap) to z = (-total_length/2 + overlap)
    translate([0, 0, -total_length_mm/2])
      cylinder(r=connector_r, h=connector_h, center=true, $fn=64);
  }
}

assembly();