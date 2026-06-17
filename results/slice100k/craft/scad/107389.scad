// Parameters
bbox_X = 5.45; //[2.725:10.9:0.01]
bbox_Y = 1.41; //[0.705:2.82:0.01]
bbox_Z = 9.01; //[4.505:18.02:0.01]
base_L = 9.01; //[4.505:18.02:0.01]
base_W = 5.45; //[2.725:10.9:0.01]
base_T = 0.55; //[0.275:1.1:0.01]
base_R = 0.7; //[0.35:1.4:0.01]
spine_L = 8.2; //[4.1:16.4:0.01]
spine_W = 1.1; //[0.55:2.2:0.01]
spine_H = 0.35; //[0.175:0.7:0.01]
spine_offset_Z = 0.0; //[-1.0:1.0:0.01]
cradle_proj = 1.41; //[0.705:2.82:0.01]
cradle_thk = 0.55; //[0.275:1.1:0.01]
cradle_span_W = 3.2; //[1.6:6.4:0.01]
cradle_center_from_end = 1.6; //[0.8:3.2:0.01]
cradle_seat_R = 0.75; //[0.375:1.5:0.01]
nub_D = 0.7; //[0.35:1.4:0.01]
nub_L = 0.55; //[0.275:1.1:0.01]
nub_clearance = 0.2; //[0.1:0.4:0.01]
overlap = 0.6; //[0.2:1.2:0.01]
fillet_r = 0.12; //[0.05:0.25:0.01]
draft_scale_x = 0.985; //[0.95:1.0:0.001]
draft_scale_z = 0.99; //[0.95:1.0:0.001]
texture_amp = 0.06; //[0.0:0.12:0.01]

// Base corner cylinder
module base_corner_cyl() {
  translate([base_W/2 - base_R, 0, base_L/2 - base_R])
    rotate([90, 0, 0])
      cylinder(r=base_R, h=base_T, center=true);
}

// Base plate core box
module base_plate_core_box() {
  translate([0, 0, 0])
    cube([base_W - 2*base_R, base_T, base_L - 2*base_R], center=true);
}

// Central spine
module central_spine() {
  union() {
    translate([0, base_T/2 + spine_H/2 - overlap, spine_offset_Z])
      cube([spine_W, spine_H, spine_L], center=true);
    translate([0, base_T/2 + spine_H/2 - overlap, spine_offset_Z + spine_L/2 - spine_W/2])
      cylinder(r1=spine_W/2, r2=0, h=spine_W, center=true);
    translate([0, base_T/2 + spine_H/2 - overlap, spine_offset_Z - spine_L/2 + spine_W/2])
      rotate([0, 180, 0])
        cylinder(r1=spine_W/2, r2=0, h=spine_W, center=true);
  }
}

// U-shaped cradle arm
module u_cradle_arm() {
  union() {
    translate([0, base_T/2 + cradle_thk/2 - overlap, base_L/2 - cradle_center_from_end])
      rotate([0, 90, 0])
        rotate_extrude()
          translate([cradle_span_W/2 - cradle_thk/2, 0, 0])
            circle(r=cradle_thk/2);
    translate([-(cradle_span_W/2 - nub_D/2), base_T/2 + nub_L/2 - overlap, base_L/2 - cradle_center_from_end])
      rotate([90, 0, 0])
        cylinder(r=nub_D/2, h=nub_L, center=true);
    translate([cradle_span_W/2 - nub_D/2, base_T/2 + nub_L/2 - overlap, base_L/2 - cradle_center_from_end])
      rotate([90, 0, 0])
        cylinder(r=nub_D/2, h=nub_L, center=true);
  }
}

// Cradle inner seat cylinder
module cradle_inner_seat_cyl() {
  translate([0, base_T/2 + cradle_thk/2 - overlap, base_L/2 - cradle_center_from_end])
    rotate([0, 0, 90])
      cylinder(r=cradle_seat_R, h=cradle_span_W + 2*overlap, center=true);
}

// Base corner rounding
module base_corner_rounding() {
  union() {
    base_corner_cyl();
    mirror([1, 0, 0]) base_corner_cyl();
    mirror([0, 0, 1]) base_corner_cyl();
    mirror([1, 0, 0]) mirror([0, 0, 1]) base_corner_cyl();
  }
}

// Base plate hull
module base_plate_hull() {
  hull() {
    base_plate_core_box();
    base_corner_rounding();
  }
}

// Clip raw union
module clip_raw_union() {
  union() {
    base_plate_hull();
    central_spine();
    u_cradle_arm();
  }
}

// Final assembly with operations
module final_assembly() {
  difference() {
    clip_raw_union();
    cradle_inner_seat_cyl();
  }
}

// Apply draft angles
module draft_angles() {
  scale([draft_scale_x, 1, draft_scale_z])
    final_assembly();
}

// Apply micro texture
module micro_texture() {
  minkowski() {
    draft_angles();
    sphere(r=texture_amp, center=true);
  }
}

// Apply fillets to all edges
module fillets_all_edges() {
  minkowski() {
    micro_texture();
    sphere(r=fillet_r, center=true);
  }
}

// Render final output
fillets_all_edges();