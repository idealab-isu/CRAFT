// Threaded heat-set insert (simplified) — 15mm OD, 12mm long, for 6mm screws

// Parameters
outer_diameter = 15; //[7.5:30:0.1]
length = 12; //[6:24:0.1]
screw_diameter = 6; //[3:12:0.1]
inner_thread_clearance = 0.4; //[0.1:1:0.05]

lead_in_chamfer_height = 1; //[0.5:2:0.1]
installation_end_chamfer_height = 0.5; //[0.2:1.5:0.1]

retention_rib_count = 24; //[8:60:1]
retention_rib_depth = 0.6; //[0.2:1.5:0.05]
retention_rib_width = 1.2; //[0.5:3:0.05]
retention_rib_z_margin = 0.5; //[0.2:2:0.1]

overlap = 0.8; //[0.2:2:0.1]
$fn = 96;

// Threaded Insert - complete geometry
module threaded_insert() {
  outer_r = outer_diameter/2;
  inner_r = (screw_diameter + inner_thread_clearance)/2;

  // Keep ribs fully within the insert length so everything is one connected solid
  rib_len = max(0.01, length - 2*retention_rib_z_margin);

  // Place ribs so they overlap into the body by "overlap" (prevents floating / non-manifold)
  rib_center_r = outer_r + retention_rib_depth/2 - overlap;

  // Chamfer radial reduction (simple, stable)
  lead_reduction = min(lead_in_chamfer_height, outer_r - 0.01);
  inst_reduction = min(installation_end_chamfer_height, outer_r - 0.01);

  color([0.8, 0.6, 0.2])  // Brass-like
  difference() {
    union() {
      // Main body
      cylinder(r=outer_r, h=length, center=true);

      // Retention ribs (knurl-like)
      for (i = [0:retention_rib_count-1]) {
        rotate([0, 0, i*360/retention_rib_count])
          translate([rib_center_r, 0, 0])
            cube([retention_rib_depth + 2*overlap, retention_rib_width, rib_len], center=true);
      }
    }

    // Lead-in chamfer (subtract)
    translate([0, 0, -length/2 + lead_in_chamfer_height/2])
      cylinder(r1=outer_r, r2=outer_r - lead_reduction, h=lead_in_chamfer_height, center=true);

    // Installation end chamfer (subtract)
    translate([0, 0,  length/2 - installation_end_chamfer_height/2])
      cylinder(r1=outer_r - inst_reduction, r2=outer_r, h=installation_end_chamfer_height, center=true);

    // Internal clearance hole
    cylinder(r=inner_r, h=length + 2*overlap, center=true);
  }
}

threaded_insert();