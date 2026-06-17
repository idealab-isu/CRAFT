// Threaded heat-set insert (visual model)
// Target: 3.0mm OD, 4.6mm long, for M3 screws

screw_nominal_diameter = 3; //[1.5:6:0.1]
outer_diameter = 3; //[1.5:6:0.1]
length = 4.6; //[2.3:9.2:0.1]
tolerance_outer_diameter = 0; //[-0.2:0.2:0.01]
tolerance_length = 0; //[-0.3:0.3:0.01]
chamfer_length = 0.3; //[0.1:1:0.05]
chamfer_angle_deg = 45; //[20:70:1]
inner_thread_clearance_diameter = 3.2; //[2.6:4:0.05]
rib_count = 12; //[6:24:1]
rib_radial_height = 0.25; //[0.1:0.6:0.05]
rib_tangential_width = 0.5; //[0.2:1.2:0.05]
rib_axial_margin = 0.4; //[0.2:1.2:0.05]
overlap = 0.8; //[0.2:2:0.1]
eps = 0.05; //[0.01:0.2:0.01]

module threaded_insert() {
  od = outer_diameter + tolerance_outer_diameter;
  h  = length + tolerance_length;

  od_r = max(od/2, 0.2);
  h2   = max(h/2, 0.2);

  // Ensure a real wall thickness so the model is visible/solid even if clearance >= OD
  min_wall = 0.25; // mm
  bore_r_req = max(inner_thread_clearance_diameter/2, 0.01);
  bore_r = min(bore_r_req, max(od_r - min_wall, 0.01));

  // Ribs: keep within OD and ensure they overlap into the body
  rib_h = max(rib_radial_height, 0);
  rib_w = max(rib_tangential_width, 0.05);
  rib_len = max(h - 2*rib_axial_margin, 0.2);

  // Place ribs so their outer face is at od_r, and they overlap inward by "overlap"
  rib_center_r = od_r - rib_h/2 - max(overlap, 0);

  // Chamfer
  cham_h = min(max(chamfer_length, 0), h/2);
  cham_r2 = max(od_r - cham_h, 0.01);

  color([0.8, 0.6, 0.2])
  difference() {
    union() {
      // Main body
      cylinder(r=od_r, h=h, center=true, $fn=96);

      // Lead-in chamfers (both ends), connected by construction
      if (cham_h > 0) {
        translate([0, 0,  h2 - cham_h/2])
          cylinder(r1=od_r, r2=cham_r2, h=cham_h, center=true, $fn=96);
        translate([0, 0, -h2 + cham_h/2])
          cylinder(r1=cham_r2, r2=od_r, h=cham_h, center=true, $fn=96);
      }

      // Outer ribs/knurls (connected)
      if (rib_h > 0) {
        for (i = [0:rib_count-1]) {
          rotate([0, 0, i * 360 / rib_count])
            translate([rib_center_r, 0, 0])
              cube([rib_h + 2*eps, rib_w, rib_len], center=true);
        }
      }
    }

    // Internal clearance hole (represents threaded bore)
    cylinder(r=bore_r, h=h + 2*eps, center=true, $fn=96);
  }
}

threaded_insert();