// Linear bearing block for 9.0mm shaft
// Block size: 50.0mm x 44.0mm x 30.0mm
// One connected solid, render-safe booleans

$fn = 64;

// Parameters
block_L = 50.0; //[25.0:100.0:1.0]
block_W = 44.0; //[22.0:88.0:1.0]
block_H = 30.0; //[15.0:60.0:1.0]

shaft_d = 9.0; //[4.0:20.0:0.1]
bore_clearance = 0.2; //[0.0:1.0:0.05]
bore_d = shaft_d + bore_clearance; //[4.0:25.0:0.1]

// Bore runs along LENGTH (X), centered in width, at mid-height
bore_axis_height = block_H/2; //[7.0:30.0:0.5]

mount_hole_d = 5.0; //[3.0:10.0:0.1]
mount_hole_edge_offset_L = 8.0; //[4.0:20.0:0.5]
mount_hole_edge_offset_W = 7.0; //[3.0:20.0:0.5]

counterbore_d = 9.0; //[6.0:16.0:0.1]
counterbore_depth = 4.0; //[1.0:10.0:0.5]

chamfer_size = 0.8; //[0.0:3.0:0.1]

// Robust boolean overlap (keep 1-2mm as requested)
overlap = 1.2; //[0.5:2.0:0.1]

grease_port_d = 3.0; //[1.5:6.0:0.1]
grease_port_x = block_L/2 - 12.0; //[6.0:25.0:0.5]

set_screw_d = 4.0; //[2.0:8.0:0.1]
set_screw_x_from_end = 12.0; //[6.0:25.0:0.5]

// Bearing housing pocket (makes it recognizable as a bearing block, not just a plate)
bearing_pocket_d = 18.0; //[12.0:30.0:0.5]
bearing_pocket_depth = 12.0; //[6.0:25.0:0.5]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Bore axis Z (height) clamped inside block
bore_axis_z = clamp(
  (-block_H/2) + bore_axis_height,
  (-block_H/2) + bore_d/2 + 0.5,
  ( block_H/2) - bore_d/2 - 0.5
);

// Base body with simple corner chamfers only (fast & robust)
module body_chamfered() {
  difference() {
    cube([block_L, block_W, block_H], center=true);

    if (chamfer_size > 0) {
      // Corner chamfers: subtract small rotated cubes at all 8 corners
      for (sx=[-1,1], sy=[-1,1], sz=[-1,1]) {
        translate([sx*(block_L/2), sy*(block_W/2), sz*(block_H/2)])
          rotate([45,45,0])
            cube([2*chamfer_size, 2*chamfer_size, 2*chamfer_size], center=true);
      }
    }
  }
}

module shaft_bore() {
  // Through-hole along X so it is visible in LEFT/RIGHT views as a large circle
  translate([0, 0, bore_axis_z])
    rotate([0, 90, 0])
      cylinder(h=block_L + 2*overlap, r=bore_d/2, center=true);
}

module bore_lead_in(xpos) {
  // Conical lead-in at each end face (X = +/- block_L/2)
  // Ensure it actually intersects the end face by overlapping past it.
  lead_h = max(0.1, chamfer_size + 2*overlap);
  translate([xpos, 0, bore_axis_z])
    rotate([0, 90, 0])
      cylinder(h=lead_h,
               r1=(bore_d/2) + chamfer_size,
               r2=bore_d/2,
               center=true);
}

module bearing_pocket_top() {
  // A shallow cylindrical pocket from the TOP face down toward the bore.
  // This makes the part read as a "bearing block" (housing) rather than a flat plate.
  // Pocket is centered over the shaft bore.
  pocket_r = max(bore_d/2 + 1.0, bearing_pocket_d/2);

  // Keep pocket within the block and ensure it intersects the bore region.
  // Depth is clamped so it doesn't cut through the bottom.
  depth = clamp(bearing_pocket_depth, 1.0, block_H - 2.0);

  // Place pocket so its top slightly exceeds the top face (avoid coplanar artifacts)
  zc = (block_H/2) - (depth/2) + overlap/2;

  translate([0, 0, zc])
    cylinder(h=depth + overlap, r=pocket_r, center=true);
}

module mount_hole(x, y) {
  // Vertical mounting holes (Z)
  translate([x, y, 0])
    cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);
}

module counterbore(x, y) {
  // Counterbore from top face; overlap slightly above top to avoid coplanar artifacts
  translate([x, y, (block_H/2) - (counterbore_depth/2) + overlap/2])
    cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

module mounting_holes_and_counterbores() {
  for (sx=[-1,1], sy=[-1,1]) {
    x = sx*(block_L/2 - mount_hole_edge_offset_L);
    y = sy*(block_W/2 - mount_hole_edge_offset_W);
    mount_hole(x,y);
    counterbore(x,y);
  }
}

module grease_port() {
  // Vertical port from top down to intersect the shaft bore
  // Make sure it reaches into the bore by a small overlap.
  port_top_z    = (block_H/2) + overlap;
  port_bottom_z = (bore_axis_z + bore_d/2) - overlap;
  port_h = max(0.1, port_top_z - port_bottom_z);

  gx = clamp(grease_port_x,
             -block_L/2 + grease_port_d/2 + 1,
              block_L/2 - grease_port_d/2 - 1);

  translate([gx, 0, (port_top_z + port_bottom_z)/2])
    cylinder(h=port_h, r=grease_port_d/2, center=true);
}

module retention_set_screw_hole() {
  // Cross hole along Y that intersects the bore (typical retention/set screw)
  // Position measured from +X end face.
  x = (block_L/2) - set_screw_x_from_end;
  translate([x, 0, bore_axis_z])
    rotate([90, 0, 0])
      cylinder(h=block_W + 2*overlap, r=set_screw_d/2, center=true);
}

// Final solid (single connected object)
difference() {
  // Main block
  body_chamfered();

  // Essential bearing feature: 9mm shaft bore through the block
  shaft_bore();

  // Visible bearing housing feature: top pocket around the bore
  bearing_pocket_top();

  // Lead-ins at both ends of the shaft bore (kept simple)
  if (chamfer_size > 0) {
    // Center the lead-in volumes on the end faces so they definitely cut the ends
    bore_lead_in( (block_L/2) - (chamfer_size/2));
    bore_lead_in((-block_L/2) + (chamfer_size/2));
  }

  // Mounting features
  mounting_holes_and_counterbores();

  // Simple lubrication/grease port and retention screw
  grease_port();
  retention_set_screw_hole();
}