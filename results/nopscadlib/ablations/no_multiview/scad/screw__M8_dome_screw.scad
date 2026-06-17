// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
length_under_head_mm = 10; //[5:20:0.1]
head_diameter_mm = 14; //[7:28:0.1]
head_height_mm = 4.4; //[2.2:8.8:0.1]
thread_representation_scale = 0.98; //[0.9:1:0.005]
overlap_mm = 1; //[0.5:2:0.1]

// Screw (single connected solid)
module screw() {
  shaft_r = shaft_diameter_mm/2;
  head_r  = head_diameter_mm/2;

  // Coordinate convention:
  // underside of head at z=0
  // shaft extends downward to z=-length_under_head_mm
  union() {
    color("DimGray")
    union() {

      // Shaft (main) - top of shaft overlaps into head by overlap_mm
      // z range: [-length_under_head_mm, +overlap_mm]
      translate([0, 0, (-length_under_head_mm + overlap_mm)/2])
        cylinder(h=length_under_head_mm + overlap_mm, r=shaft_r, center=true, $fn=64);

      // Thread representation (slightly smaller) - same z range so it is attached too
      translate([0, 0, (-length_under_head_mm + overlap_mm)/2])
        cylinder(h=length_under_head_mm + overlap_mm, r=shaft_r*thread_representation_scale, center=true, $fn=64);

      // Dome head as spherical cap:
      // Build cap spanning z=[-overlap_mm, head_height_mm] so it intersects the shaft
      // Sphere center at z=head_r - overlap_mm gives cap bottom at z=-overlap_mm
      translate([0, 0, head_r - overlap_mm])
        intersection() {
          sphere(r=head_r, $fn=96);
          // Clip to exact cap height with overlap into shaft
          translate([0, 0, (head_height_mm - overlap_mm)/2])
            cube([head_diameter_mm*2, head_diameter_mm*2, head_height_mm + overlap_mm], center=true);
        }

      // Neck/bridge to guarantee robust connection (extra overlap at the interface)
      // z range: [-overlap_mm, +overlap_mm]
      translate([0, 0, 0])
        cylinder(h=overlap_mm*2, r=shaft_r, center=true, $fn=64);
    }
  }
}

// Assembly
union() {
  screw();
}