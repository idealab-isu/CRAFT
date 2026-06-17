// Threaded heat-set insert (simplified geometry)
// Target: 25.0mm OD, 18.5mm long, for 10.0mm screws

outer_diameter = 25; //[12.5:50:0.1]
length = 18.5; //[9.25:37:0.1]
screw_diameter = 10; //[5:20:0.1]
thread_pitch = 1.5; //[0.75:3:0.05]  // (not modeled; kept for UI)
inner_clearance = 0.4; //[0.1:1:0.05]
end_chamfer_height = 2; //[1:4:0.1]
end_chamfer_angle_deg = 45; //[20:70:1] // (not used directly; height controls chamfer)
knurl_depth = 1; //[0.5:2:0.1]
knurl_pitch = 4; //[2:8:0.1] // (not used directly; count controls spacing)
knurl_rib_width = 2.5; //[1.5:5:0.1]
knurl_rib_height = 14; //[8:18:0.1]
knurl_count = 20; //[8:40:1]
overlap = 0.8; //[0.2:2:0.1]

$fn = 128;

module threaded_insert() {
  outer_r = outer_diameter/2;
  inner_r = (screw_diameter + inner_clearance)/2;

  // Keep chamfers valid and within length
  chamfer_h = min(end_chamfer_height, length/2 - 0.01);
  chamfer_h_safe = max(0.01, chamfer_h);

  // Knurl ribs stay within the straight section between chamfers
  straight_h = max(0.01, length - 2*chamfer_h_safe);
  rib_h = min(knurl_rib_height, straight_h);
  rib_h_safe = max(0.01, rib_h);

  // Center ribs in the straight section
  rib_z = 0;

  // Ensure ribs protrude outward but overlap into the body for connectivity
  // Inner face of rib at (outer_r - overlap), outer face at (outer_r - overlap + knurl_depth)
  rib_center_r = (outer_r - overlap) + knurl_depth/2;

  // Ensure the hole doesn't erase the entire part
  inner_r_safe = min(inner_r, outer_r - 0.5);

  color("Brass")
  difference() {
    union() {
      // Main body
      cylinder(r=outer_r, h=length, center=true);

      // End chamfers (slight overlap into main body to avoid coplanar artifacts)
      translate([0, 0,  length/2 - chamfer_h_safe/2 - overlap/2])
        cylinder(r1=outer_r, r2=max(0.01, outer_r - chamfer_h_safe),
                 h=chamfer_h_safe, center=true);

      translate([0, 0, -length/2 + chamfer_h_safe/2 + overlap/2])
        cylinder(r1=max(0.01, outer_r - chamfer_h_safe), r2=outer_r,
                 h=chamfer_h_safe, center=true);

      // Knurl ribs
      for (i = [0:knurl_count-1]) {
        rotate([0, 0, i*360/knurl_count])
          translate([rib_center_r, 0, rib_z])
            cube([knurl_depth, knurl_rib_width, rib_h_safe], center=true);
      }
    }

    // Through-hole for screw (thread not modeled)
    cylinder(r=inner_r_safe, h=length + 2*overlap, center=true);
  }
}

threaded_insert();