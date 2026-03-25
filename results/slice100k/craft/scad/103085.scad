// Connected L/C bracket with clear end-plate slope and through hex hole
// Bounding box target: 55.44 x 31.55 x 37.52 mm (X x Y x Z)

$fn = 96;

// Bounding box
bbox_L = 55.44;
bbox_W = 31.55;
bbox_H = 37.52;

// Main members
beam_L = bbox_L;
beam_W = bbox_W;
beam_H = 10;

end_plate_t = 6;
end_plate_H = bbox_H;

leg_t = 6;
leg_H = 18;

// Hex hole (through beam thickness, along Z)
hex_AF = 10;
hex_axis_angle_deg = 0;
hex_center_x_from_left = 27.72;
hex_center_y_from_front = 15.775;
hex_clearance = 0.2;

// End-plate slope (top chamfer)
slope_drop = 8;
slope_run  = 12;

// Small edge chamfers on beam (optional)
beam_edge_chamfer = 1;

// Small cylindrical reliefs at junctions
relief_r = 2;
relief_depth = 1.5;

overlap = 0.5;

// Helpers
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for pointy-top hex when AF is across flats

module horizontal_beam() {
  translate([0, 0, -bbox_H/2 + beam_H/2])
    cube([beam_L, beam_W, beam_H], center=true);
}

module tall_vertical_end_plate() {
  translate([-beam_L/2 + end_plate_t/2, 0, -bbox_H/2 + end_plate_H/2])
    cube([end_plate_t, beam_W, end_plate_H], center=true);
}

module short_vertical_support_leg() {
  translate([beam_L/2 - leg_t/2, 0, -bbox_H/2 + leg_H/2])
    cube([leg_t, beam_W, leg_H], center=true);
}

module hex_hole_prism() {
  af = hex_AF + hex_clearance;
  R  = hex_R_from_AF(af);

  // Centered in XY, extruded through beam thickness in Z
  translate([
      -beam_L/2 + hex_center_x_from_left,
      -beam_W/2 + hex_center_y_from_front,
      -bbox_H/2 + beam_H/2
    ])
    rotate([0, 0, hex_axis_angle_deg])
      linear_extrude(height=beam_H + 2*overlap, center=true)
        polygon(points=[
          [ R, 0],
          [ R/2,  af/2],
          [-R/2,  af/2],
          [-R, 0],
          [-R/2, -af/2],
          [ R/2, -af/2]
        ]);
}

module slope_cut_wedge() {
  // Cut a wedge from the TOP of the tall end plate to create a visible sloped face.
  // Slope runs along +X (from left edge toward beam), dropping in Z by slope_drop over slope_run.
  ang = atan(slope_drop / slope_run);

  x_left = -beam_L/2;
  x_right = x_left + end_plate_t;
  z_top = -bbox_H/2 + end_plate_H;

  // Use a large cutter rotated about Y; positioned so it intersects the plate top.
  // Make it wide in Y and tall in Z to guarantee a clean cut.
  translate([x_right - slope_run/2, 0, z_top - slope_drop/2])
    rotate([0, -ang, 0])
      cube([slope_run + 4*overlap, beam_W + 4*overlap, slope_drop + end_plate_H + 4*overlap], center=true);
}

module beam_chamfer_wedge_top_front() {
  if (beam_edge_chamfer > 0)
    translate([0, beam_W/2 - beam_edge_chamfer/2, -bbox_H/2 + beam_H - beam_edge_chamfer/2])
      rotate([45, 0, 0])
        cube([beam_L + 4*overlap, beam_edge_chamfer, beam_edge_chamfer], center=true);
}

module beam_chamfer_wedge_top_back() {
  if (beam_edge_chamfer > 0)
    translate([0, -beam_W/2 + beam_edge_chamfer/2, -bbox_H/2 + beam_H - beam_edge_chamfer/2])
      rotate([-45, 0, 0])
        cube([beam_L + 4*overlap, beam_edge_chamfer, beam_edge_chamfer], center=true);
}

module alignment_relief_left() {
  // Relief at left plate/beam junction (cuts into beam near plate)
  translate([-beam_L/2 + end_plate_t + relief_depth/2, 0, -bbox_H/2 + beam_H/2])
    rotate([0, 90, 0])
      cylinder(r=relief_r, h=relief_depth + 2*overlap, center=true);
}

module alignment_relief_right() {
  // Relief at right leg/beam junction (cuts into beam near leg)
  translate([beam_L/2 - leg_t - relief_depth/2, 0, -bbox_H/2 + beam_H/2])
    rotate([0, 90, 0])
      cylinder(r=relief_r, h=relief_depth + 2*overlap, center=true);
}

module final_bracket() {
  difference() {
    union() {
      horizontal_beam();
      tall_vertical_end_plate();
      short_vertical_support_leg();
    }

    // Cuts
    slope_cut_wedge();
    beam_chamfer_wedge_top_front();
    beam_chamfer_wedge_top_back();
    alignment_relief_left();
    alignment_relief_right();
    hex_hole_prism();
  }
}

color("Silver") final_bracket();