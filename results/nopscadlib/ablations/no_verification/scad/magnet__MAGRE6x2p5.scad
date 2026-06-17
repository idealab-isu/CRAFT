// Radial encoder magnet (single connected solid)

$fn = 128;

// Parameters
outer_diameter_mm = 10; //[5:20:1]
height_mm = 3;          //[1.5:6:0.5]
inner_diameter_mm = 0;  //[0:10:0.5]  // Set to 0 for solid disk (no bore)
bore_clearance_mm = 0.2; //[0:0.6:0.05]
bore_extra_height_mm = 1; //[0.5:3:0.5]

// Derived / safety
outer_r = max(outer_diameter_mm/2, 0.01);
h       = max(height_mm, 0.01);

// Bore (only if requested)
bore_r = max((inner_diameter_mm + bore_clearance_mm)/2, 0);

// Keep at least this wall thickness if a bore is enabled
min_wall_mm = 0.25;
bore_r_safe = min(bore_r, max(outer_r - min_wall_mm, 0));
do_bore = (inner_diameter_mm > 0) && (bore_r_safe > 0);

// Magnet - complete geometry (always one connected solid)
module magnet() {
  color([0.72, 0.45, 0.2])
  difference() {
    cylinder(r=outer_r, h=h, center=true);

    if (do_bore)
      cylinder(r=bore_r_safe, h=h + 2*bore_extra_height_mm, center=true);
  }
}

magnet();