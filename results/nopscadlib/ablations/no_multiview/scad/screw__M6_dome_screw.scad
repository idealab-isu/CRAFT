// Parameters
shaft_diameter_mm = 6; //[3:12:0.1]
head_diameter_mm  = 10.5; //[5.25:21:0.1]
head_height_mm    = 3.3; //[1.65:6.6:0.1]
length_mm         = 10; //[5:20:0.5]
dome_sphere_radius_mm = 7.5; //[4:15:0.1]
overlap_mm        = 1; //[0.5:2:0.1]

// Screw (single connected solid)
module screw() {
  union() {
    // Place head so its bottom is at z=0 and top at z=head_height_mm
    // This makes it easy to attach shaft below and any cap above.
    // Head (cylindrical portion)
    translate([0, 0, head_height_mm/2])
      cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true, $fn=64);

    // Dome (spherical cap) - intersects head by overlap_mm to avoid any gap
    intersection() {
      // Sphere positioned so it creates a dome over the head top
      translate([0, 0, head_height_mm - dome_sphere_radius_mm + overlap_mm])
        sphere(r=dome_sphere_radius_mm, $fn=64);

      // Limit dome to the head height region (slightly extended for robust overlap)
      translate([0, 0, head_height_mm/2])
        cube([head_diameter_mm*3, head_diameter_mm*3, head_height_mm + 2*overlap_mm], center=true);
    }

    // Shaft - attached to head bottom with overlap
    // Shaft spans from z = -length_mm to z = 0, but overlaps into head by overlap_mm
    translate([0, 0, -length_mm/2 + overlap_mm/2])
      cylinder(h=length_mm + overlap_mm, r=shaft_diameter_mm/2, center=true, $fn=64);

    // Top cylindrical segment (cap) - MUST be attached to head/dome (fix floating top part)
    // Sits above head top and overlaps downward into the head by overlap_mm
    top_cap_h = 2; // small segment as seen in top view
    translate([0, 0, head_height_mm + top_cap_h/2 - overlap_mm/2])
      cylinder(h=top_cap_h + overlap_mm, r=head_diameter_mm/2, center=true, $fn=64);

    // Bottom cylindrical segment - MUST be attached to shaft (fix floating bottom part)
    // Sits below shaft end and overlaps upward into the shaft by overlap_mm
    bottom_cap_h = 2; // small segment as seen in bottom view
    translate([0, 0, -length_mm - bottom_cap_h/2 + overlap_mm/2])
      cylinder(h=bottom_cap_h + overlap_mm, r=shaft_diameter_mm/2, center=true, $fn=64);
  }
}

screw();