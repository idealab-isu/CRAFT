// Parameters
thread_nominal_diameter = 5; //[2.5:10:0.1]
across_flats = 9.2; //[4.6:18.4:0.1]
thickness = 4; //[2:8:0.1]
bore_type = 0; //[0:1:1]
thread_pitch = 0.8; //[0.4:1.6:0.05]
clearance_diameter_if_unthreaded = 5.5; //[4.5:7:0.1]
chamfer_size = 0.3; //[0.1:1:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_outer_diameter = 10; //[6:20:0.1]
washer_thickness = 1; //[0.5:3:0.1]

// Derived
hex_r = across_flats/(2*cos(30));
bore_r = ((1-bore_type)*thread_nominal_diameter + bore_type*clearance_diameter_if_unthreaded)/2;

// Nut and Washer - complete geometry (single connected solid)
module nut_and_washer() {
  color("DimGray")
  difference() {
    // UNION of all solids to guarantee connectivity (with intentional overlap)
    union() {
      // Hex Nut Body
      cylinder(r=hex_r, h=thickness, center=true, $fn=6);

      // Top thin plate/sheet (attached with overlap into nut body)
      // Plate thickness uses chamfer_size; overlaps into nut by `overlap`
      translate([0, 0, thickness/2 + chamfer_size/2 - overlap])
        cylinder(r=hex_r + overlap, h=chamfer_size, center=true, $fn=6);

      // Bottom thin plate/sheet (attached with overlap into nut body)
      translate([0, 0, -thickness/2 - chamfer_size/2 + overlap])
        cylinder(r=hex_r + overlap, h=chamfer_size, center=true, $fn=6);

      // Washer (attached to bottom plate/nut with overlap)
      // Top of washer intersects bottom plate by `overlap`
      translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
    }

    // Central Bore (cuts through everything: nut + plates + washer)
    cylinder(r=bore_r, h=thickness + 2*chamfer_size + washer_thickness + 4*overlap, center=true);

    // Washer bore (redundant but harmless; kept explicit)
    translate([0, 0, -thickness/2 - washer_thickness/2 + overlap])
      cylinder(r=bore_r, h=washer_thickness + 2*overlap, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();