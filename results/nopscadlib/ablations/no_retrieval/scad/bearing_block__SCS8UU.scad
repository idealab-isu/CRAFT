$fn = 96;

// =====================
// Parameters
// =====================
block_L = 34.0; //[17.0:68.0:0.5]
block_W = 30.0; //[15.0:60.0:0.5]
block_H = 20.0; //[10.0:40.0:0.5]

shaft_d = 6.0; //[3.0:12.0:0.1]
bore_clearance = 0.2; //[0.0:0.6:0.05]

mount_hole_d = 4.2; //[2.5:8.0:0.1]
mount_hole_spacing_L = 24.0; //[12.0:48.0:0.5]
mount_hole_spacing_W = 18.0; //[10.0:40.0:0.5]
counterbore_d = 8.0; //[6.0:14.0:0.25]
counterbore_depth = 3.0; //[1.5:8.0:0.25]

edge_chamfer = 1.0; //[0.5:3.0:0.25]

grease_port_d = 2.0; //[1.0:4.0:0.1]
grease_port_angle_deg = 45.0; //[15.0:75.0:1.0]

bore_retention_wall_thickness = 2.0; //[1.0:4.0:0.25]
retention_ring_height = 2.0; //[1.0:5.0:0.25]

bearing_insert_seat_d = 12.0; //[8.0:20.0:0.25]
bearing_insert_seat_depth = 6.0; //[3.0:12.0:0.25]

// Use a real overlap for robust boolean connectivity
overlap = 1.5; //[0.5:2.0:0.25]

// =====================
// Derived
// =====================
bore_r = (shaft_d + bore_clearance)/2;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep holes inside the block
safe_spacing_L = clamp(mount_hole_spacing_L, 0, block_L - mount_hole_d - 2*edge_chamfer);
safe_spacing_W = clamp(mount_hole_spacing_W, 0, block_W - mount_hole_d - 2*edge_chamfer);

// =====================
// Base Shapes
// =====================
module block_body() {
  cube([block_L, block_W, block_H], center=true);
}

// Through bore along X (shaft axis) -> visible from +/-X faces
module shaft_bore() {
  rotate([0, 90, 0])
    cylinder(h=block_L + 2*overlap, r=bore_r, center=true);
}

// Larger seat at BOTH ends of the bore (visible bearing features on +/-X faces)
module bearing_insert_seat_end(sign=1) {
  // Place the seat so it starts at the end face and goes inward.
  // Center position along X after rotate([0,90,0]) is Z in local coords.
  rotate([0, 90, 0])
    translate([0, 0, sign*(block_L/2 - bearing_insert_seat_depth/2 + overlap/2)])
      cylinder(h=bearing_insert_seat_depth + overlap, r=bearing_insert_seat_d/2, center=true);
}

module bearing_insert_seats() {
  bearing_insert_seat_end(+1);
  bearing_insert_seat_end(-1);
}

// Mount holes: 4 holes through Z (top to bottom)
module mount_holes() {
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*safe_spacing_L/2, sy*safe_spacing_W/2, 0])
      cylinder(h=block_H + 2*overlap, r=mount_hole_d/2, center=true);
}

module counterbores() {
  // Counterbores from the TOP face only
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*safe_spacing_L/2, sy*safe_spacing_W/2,
               block_H/2 - counterbore_depth/2 + overlap/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
}

// Grease port: angled hole from top face into the bore region
module grease_port() {
  // Start slightly inside the top face to guarantee intersection
  translate([0, 0, block_H/2 - overlap/2])
    rotate([0, grease_port_angle_deg, 0])
      cylinder(h=block_L + block_H + 4*overlap, r=grease_port_d/2, center=false);
}

// Retention rings: add material collars at both ends around the bore (connected to body)
module retention_ring_end(sign=1) {
  // Center the ring so it overlaps the end face by overlap/2 for a solid union
  rotate([0, 90, 0])
    translate([0, 0, sign*(block_L/2 - retention_ring_height/2 + overlap/2)])
      difference() {
        cylinder(h=retention_ring_height + overlap, r=bore_r + bore_retention_wall_thickness, center=true);
        cylinder(h=retention_ring_height + 3*overlap, r=bore_r, center=true);
      }
}

module retention_rings() {
  retention_ring_end(+1);
  retention_ring_end(-1);
}

// Corner chamfers (cut)
module chamfer_cuts() {
  for (sx = [-1, 1], sy = [-1, 1])
    translate([sx*(block_L/2 - edge_chamfer), sy*(block_W/2 - edge_chamfer), 0])
      rotate([0, 0, 45])
        cube([edge_chamfer*2, edge_chamfer*2, block_H + 2*overlap], center=true);
}

// =====================
// Final model (ONE connected solid)
// Recognizable linear bearing block: main block + end collars + clear 6mm through-bore
// =====================
difference() {
  union() {
    block_body();
    retention_rings();
  }

  // Cuts
  shaft_bore();              // key feature: 6mm shaft through-bore along X
  bearing_insert_seats();    // visible end pockets to read as bearing block
  mount_holes();
  counterbores();
  grease_port();
  chamfer_cuts();
}