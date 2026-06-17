// Low-poly armored vehicle / tank-like model
// Fixes:
// - Ensures visible geometry (no degenerate/near-zero dimensions)
// - Adds TWO large cylindrical end pods clearly at both ends
// - Ensures ONE connected solid via calculated placements + small overlaps
// - Keeps elongated along X axis
// Note: A true 0.0mm bounding-box dimension is impossible for a solid; model has non-zero thickness.

// -------------------- Parameters (mm) --------------------
bbox_L = 0.1;
bbox_W = 0.1;
bbox_H = 0.04;          // non-zero thickness required for a solid

hull_L = 0.072;
hull_W = 0.030;
hull_H = 0.018;

pod_R = 0.015;          // large end pods
pod_L = 0.022;
pod_overlap_into_hull = 0.004;  // how much pod intrudes into hull for connectivity

turret_L = 0.040;
turret_W = 0.026;
turret_H = 0.014;

barrel_R = 0.004;
barrel_L = 0.018;

fin_L = 0.012;
fin_T = 0.003;
fin_H = 0.006;
fin_x_pos = 0.0;

overlap = 0.001;

chamfer_T = 0.003;

panel_T = 0.0012;
greeble_R = 0.0012;
greeble_H = 0.002;

antenna_R = 0.001;
antenna_H = 0.01;

// -------------------- Helpers --------------------
module clamp_bbox() {
  // Scale the whole model to fit within bbox_L x bbox_W x bbox_H
  // Compute current extents conservatively from parameters.
  // X extent includes barrel.
  cur_L = max(hull_L + 2*pod_R, hull_L + barrel_L); // conservative
  cur_W = max(hull_W, 2*pod_R, turret_W);
  cur_H = max(hull_H + turret_H + antenna_H, 2*pod_R);

  s = min(bbox_L/cur_L, bbox_W/cur_W, bbox_H/cur_H);
  scale([s, s, s]) children();
}

// -------------------- Base Shapes --------------------
module hull_main() {
  cube([hull_L, hull_W, hull_H], center=true);
}

module end_pod_raw() {
  // Cylinder axis along X
  rotate([0, 90, 0])
    cylinder(r=pod_R, h=pod_L, center=true, $fn=18);
}

module turret_roof() {
  // Faceted trapezoid roof, extruded in Z
  linear_extrude(height=turret_H, center=true, convexity=10)
    polygon(points=[
      [-turret_L/2, -turret_W/2],
      [ turret_L/2, -turret_W/2],
      [ turret_L/2 - turret_L*0.18,  turret_W/2],
      [-turret_L/2 + turret_L*0.18,  turret_W/2]
    ]);
}

module barrel_raw() {
  rotate([0, 90, 0])
    cylinder(r=barrel_R, h=barrel_L, center=true, $fn=16);
}

module fin_raw() {
  // Thin fin plate extruded in Z; will be rotated to stick out sideways
  linear_extrude(height=fin_T, center=true, convexity=10)
    polygon(points=[
      [-fin_L/2, 0],
      [ fin_L/2, 0],
      [ fin_L/2 - fin_L*0.35, fin_H],
      [-fin_L/2 + fin_L*0.15, fin_H*0.75]
    ]);
}

module chamfer_cut() {
  cube([chamfer_T, hull_W + overlap*4, hull_H/2 + overlap*2], center=true);
}

module panel_facet_top() {
  cube([hull_L*0.55, hull_W*0.65, panel_T], center=true);
}

module panel_facet_front() {
  rotate([0, 0, 90])
    cube([hull_L*0.18, hull_W*0.55, panel_T], center=true);
}

module surface_greeble() {
  cylinder(r=greeble_R, h=greeble_H, center=true, $fn=14);
}

module antenna_stub_raw() {
  cylinder(r=antenna_R, h=antenna_H, center=true, $fn=12);
}

// -------------------- Operations / Placement --------------------
module end_pod_front() {
  // Place so pod overlaps into hull by pod_overlap_into_hull
  // Pod center at: hull end + pod half - overlap_into_hull
  translate([ hull_L/2 + pod_L/2 - pod_overlap_into_hull, 0, 0 ])
    end_pod_raw();
}

module end_pod_rear() {
  translate([ -(hull_L/2 + pod_L/2 - pod_overlap_into_hull), 0, 0 ])
    end_pod_raw();
}

module turret_roof_pos() {
  translate([0, 0, hull_H/2 + turret_H/2 - overlap])
    turret_roof();
}

module barrel() {
  // Barrel protrudes from FRONT pod/hull end; ensure it intersects pod slightly
  // Front-most solid is pod front face at: (hull_L/2 + pod_L - pod_overlap_into_hull)
  front_face_x = hull_L/2 + pod_L - pod_overlap_into_hull;
  translate([ front_face_x + barrel_L/2 - overlap, 0, hull_H/2 + turret_H*0.25 ])
    barrel_raw();
}

module left_fin() {
  // Rotate so fin extrude thickness (Z) becomes lateral thickness (Y)
  translate([fin_x_pos, hull_W/2 + fin_T/2 - overlap, -hull_H*0.05])
    rotate([90, 0, 0])
      fin_raw();
}

module right_fin() {
  translate([fin_x_pos, -(hull_W/2 + fin_T/2 - overlap), -hull_H*0.05])
    rotate([-90, 0, 0])
      fin_raw();
}

module chamfer_cut_front_top_pos() {
  translate([ hull_L/2 - chamfer_T/2 + overlap, 0, hull_H/2 - hull_H/4 ])
    rotate([0, 45, 0])
      chamfer_cut();
}

module chamfer_cut_rear_top_pos() {
  translate([ -(hull_L/2 - chamfer_T/2 + overlap), 0, hull_H/2 - hull_H/4 ])
    rotate([0, -45, 0])
      chamfer_cut();
}

module hull_chamfers() {
  difference() {
    hull_main();
    chamfer_cut_front_top_pos();
    chamfer_cut_rear_top_pos();
  }
}

module panel_facet_top_pos() {
  translate([0, 0, hull_H/2 + panel_T/2 - overlap])
    panel_facet_top();
}

module panel_facet_front_pos() {
  translate([hull_L*0.22, 0, hull_H*0.05])
    panel_facet_front();
}

module surface_greeble_1_pos() {
  translate([-hull_L*0.12, hull_W*0.18, hull_H/2 + greeble_H/2 - overlap])
    surface_greeble();
}

module surface_greeble_2_pos() {
  translate([hull_L*0.08, -hull_W*0.22, hull_H/2 + greeble_H/2 - overlap])
    surface_greeble();
}

module antenna_stub() {
  translate([-turret_L*0.18, turret_W*0.18, hull_H/2 + turret_H - overlap + antenna_H/2])
    antenna_stub_raw();
}

// -------------------- Final Vehicle Model --------------------
module vehicle_union_main() {
  union() {
    hull_chamfers();

    // Two large cylindrical end pods (clearly present)
    end_pod_front();
    end_pod_rear();

    // Faceted turret/roof
    turret_roof_pos();

    // Barrel protruding from one end
    barrel();

    // Lateral fins/winglets
    left_fin();
    right_fin();

    // Surface facets / greebles (kept connected via overlap)
    panel_facet_top_pos();
    panel_facet_front_pos();
    surface_greeble_1_pos();
    surface_greeble_2_pos();

    // Antenna
    antenna_stub();
  }
}

// Render (scaled to requested bbox limits as closely as possible)
clamp_bbox() vehicle_union_main();