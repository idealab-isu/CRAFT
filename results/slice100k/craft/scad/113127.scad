// Blocky C-shaped bracket/frame with stepped outer perimeter and inner step transitions
// Bounding box: 31.8 x 31.8 x 15.8 mm

// Parameters
bbox_x = 31.8;
bbox_y = 31.8;
bbox_z = 15.8;

frame_thk_z = bbox_z;

outer_step_depth = 2.0;
outer_step_margin = 3.0;

opening_x = 20.0;
opening_y = 20.0;

inner_step_depth = 1.5;
inner_step_width = 1.5;

c_gap_w = 8.0;

boss_w = 6.0;
boss_h = 6.0;
boss_z = bbox_z;
boss_inset = 0.0;

overlap = 0.6;

chamfer = 0.8;

nub_d = 2.0;
nub_h = 1.2;

relief_d = 3.0;
relief_depth = 1.0;

// Helpers
module box(sz, pos=[0,0,0]) { translate(pos) cube(sz, center=true); }
module cyl(r,h,pos=[0,0,0]) { translate(pos) cylinder(r=r, h=h, center=true, $fn=48); }

// Base solids
module outer_frame_plate() {
  box([bbox_x, bbox_y, frame_thk_z]);
}

// Outer stepped perimeter (a shallow "ring" on the top face)
module outer_perimeter_step_ring() {
  difference() {
    // slightly oversized in Z to avoid coplanar artifacts
    box([bbox_x, bbox_y, outer_step_depth + 2*overlap],
        [0,0, frame_thk_z/2 - outer_step_depth/2]);
    box([bbox_x - 2*outer_step_margin, bbox_y - 2*outer_step_margin, outer_step_depth + 4*overlap],
        [0,0, frame_thk_z/2 - outer_step_depth/2]);
  }
}

// Inner step transitions around the opening (a shallow ledge on the top face)
module inner_opening_step_ring() {
  difference() {
    box([opening_x + 2*inner_step_width, opening_y + 2*inner_step_width, inner_step_depth + 2*overlap],
        [0,0, frame_thk_z/2 - inner_step_depth/2]);
    box([opening_x, opening_y, inner_step_depth + 4*overlap],
        [0,0, frame_thk_z/2 - inner_step_depth/2]);
  }
}

// Boss pads at corners (reinforced pads)
module union_boss_pads() {
  union() {
    box([boss_w, boss_h, boss_z],
        [-bbox_x/2 + boss_w/2 + boss_inset,  bbox_y/2 - boss_h/2 - boss_inset, 0]);
    box([boss_w, boss_h, boss_z],
        [-bbox_x/2 + boss_w/2 + boss_inset, -bbox_y/2 + boss_h/2 + boss_inset, 0]);
    box([boss_w, boss_h, boss_z],
        [ bbox_x/2 - boss_w/2 - boss_inset,  bbox_y/2 - boss_h/2 - boss_inset, 0]);
    box([boss_w, boss_h, boss_z],
        [ bbox_x/2 - boss_w/2 - boss_inset, -bbox_y/2 + boss_h/2 + boss_inset, 0]);
  }
}

// Small alignment nubs (kept connected by placing on faces with slight overlap)
module union_alignment_nubs() {
  union() {
    cyl(nub_d/2, nub_h + 2*overlap,
        [-bbox_x/2 + outer_step_margin + nub_d/2, 0,  frame_thk_z/2 - nub_h/2]);
    cyl(nub_d/2, nub_h + 2*overlap,
        [-bbox_x/2 + outer_step_margin + nub_d/2, 0, -frame_thk_z/2 + nub_h/2]);
  }
}

// Subtractive features
module central_rectangular_opening() {
  box([opening_x, opening_y, frame_thk_z + 4*overlap]);
}

// C-gap that opens the inner opening to the outside on the +X side
module c_shape_side_gap() {
  // Ensure it reaches the outer boundary and overlaps slightly
  gap_len_x = (bbox_x/2 - opening_x/2) + c_gap_w + 2*overlap;
  box([gap_len_x, opening_y + 2*inner_step_width + 2*overlap, frame_thk_z + 4*overlap],
      [opening_x/2 + gap_len_x/2 - overlap, 0, 0]);
}

// Corner chamfers (small corner nips)
module chamfer_cut(pos) {
  translate(pos)
    rotate([0,0,45])
      cube([chamfer, chamfer, frame_thk_z + 4*overlap], center=true);
}

// Cosmetic reliefs on top face
module cosmetic_reliefs() {
  union() {
    cyl(relief_d/2, relief_depth + 2*overlap,
        [0,  bbox_y/2 - outer_step_margin - relief_d/2, frame_thk_z/2 - relief_depth/2]);
    cyl(relief_d/2, relief_depth + 2*overlap,
        [0, -bbox_y/2 + outer_step_margin + relief_d/2, frame_thk_z/2 - relief_depth/2]);
  }
}

// Build
module union_additive_features() {
  union() {
    outer_frame_plate();
    outer_perimeter_step_ring();
    inner_opening_step_ring();
    union_boss_pads();
    union_alignment_nubs();
  }
}

module final_part() {
  difference() {
    union_additive_features();

    // Main through opening + C-gap
    central_rectangular_opening();
    c_shape_side_gap();

    // Reliefs and chamfers
    cosmetic_reliefs();

    chamfer_cut([-bbox_x/2 + chamfer/2,  bbox_y/2 - chamfer/2, 0]);
    chamfer_cut([ bbox_x/2 - chamfer/2,  bbox_y/2 - chamfer/2, 0]);
    chamfer_cut([-bbox_x/2 + chamfer/2, -bbox_y/2 + chamfer/2, 0]);
    chamfer_cut([ bbox_x/2 - chamfer/2, -bbox_y/2 + chamfer/2, 0]);
  }
}

final_part();