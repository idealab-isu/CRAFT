// U-shaped retaining/mounting clip with rounded back, open front channel,
// opposing side through-holes near top, and small lips at open edge.
// Bounding box target: ~22.1 x 24.3 x 79.0 mm (X x Y x Z)

$fn = 96;

// ---------------- Parameters ----------------
bbox_X = 22.15;
bbox_Y = 24.3;
bbox_Z = 79;

wall_t = 2.2;
channel_W = 14;
channel_D = 14.5;

open_gap_W = 12;

hole_d = 4;
hole_center_from_top = 14;
hole_axis_offset_from_center = 0;   // along Y

tab_len = 3;     // lip protrusion into opening (toward -Y)
tab_drop = 2;    // lip height (Z)

fillet_R_internal = 2.5;
outer_round_r = 0.9;

overlap = 1.2;   // ensure solid connections / robust booleans

// ---------------- Derived ----------------
outer_r = bbox_X/2;
inner_r = max(0.01, outer_r - wall_t);

inner_W = min(channel_W, bbox_X - 2*wall_t);
inner_D = min(channel_D, bbox_Y - 2*wall_t);

// Place rounded back so overall Y fits bbox_Y
back_cy    = -bbox_Y/2 + outer_r;
back_cy_in = back_cy + wall_t;

// Inner void rectangle center so its back aligns with inner back cylinder
inner_cy = back_cy_in + inner_D/2;

// Hole Z position (near upper region)
hole_z = bbox_Z/2 - hole_center_from_top;

// ---------------- Helpers ----------------
module rounded_rect_2d(w, h, r){
  r2 = min(r, min(w,h)/2);
  hull(){
    translate([ w/2-r2,  h/2-r2]) circle(r=r2);
    translate([-w/2+r2,  h/2-r2]) circle(r=r2);
    translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    translate([-w/2+r2, -h/2+r2]) circle(r=r2);
  }
}

// Outer solid: rounded-back silhouette (rect + half-cylinder), clipped to bbox
module outer_solid(){
  intersection(){
    union(){
      cube([bbox_X, bbox_Y, bbox_Z], center=true);
      translate([0, back_cy, 0])
        cylinder(r=outer_r, h=bbox_Z + 2*overlap, center=true);
    }
    cube([bbox_X, bbox_Y, bbox_Z], center=true);
  }
}

// Inner void with generous fillets (2D minkowski then extrude)
module inner_void(){
  // Shrink base profile before Minkowski so final cavity stays within intended size
  base_W = max(0.01, inner_W - 2*fillet_R_internal);
  base_D = max(0.01, inner_D - 2*fillet_R_internal);
  base_r = max(0.01, inner_r - fillet_R_internal);

  linear_extrude(height=bbox_Z - 2*wall_t + 2*overlap, center=true, convexity=10)
    minkowski(){
      union(){
        translate([0, inner_cy])
          square([base_W, base_D], center=true);
        translate([0, back_cy_in])
          circle(r=base_r);
      }
      circle(r=fillet_R_internal);
    }
}

// Open front cut: remove material at +Y side to create U opening.
// Ensure it fully opens the mouth while preserving the rounded back.
module open_front_cut(){
  // Back-most Y of inner back cylinder = back_cy_in - inner_r
  y_back_limit = back_cy_in - inner_r;

  // Cut from just behind that limit to the front face
  y0 = y_back_limit - overlap;
  y1 = bbox_Y/2 + overlap;

  cut_len_y = (y1 - y0);
  cut_cy_y  = (y0 + y1)/2;

  translate([0, cut_cy_y, 0])
    cube([open_gap_W, cut_len_y, bbox_Z + 4*overlap], center=true);
}

// TRUE through-holes: one aligned cylinder passing through both side walls (along X)
module side_through_hole(){
  translate([0, hole_axis_offset_from_center, hole_z])
    rotate([0,90,0])
      cylinder(d=hole_d, h=bbox_X + 4*overlap, center=true);
}

// Small lips/tabs at open edge (front, +Y), one on each side of opening.
// Positioned to overlap into the side walls and top region for a single solid.
module end_tabs(){
  side_w = (bbox_X - open_gap_W)/2;

  // Place tabs so their front face is flush with bbox front, and they extend inward by tab_len.
  tab_center_y = bbox_Y/2 - tab_len/2 + overlap/2;

  // Place near the top opening edge
  tab_center_z = bbox_Z/2 - tab_drop/2 + overlap/2;

  for (sx = [-1, 1]){
    translate([
      sx*(open_gap_W/2 + side_w/2 - overlap/2),
      tab_center_y,
      tab_center_z
    ])
      cube([side_w + overlap, tab_len + overlap, tab_drop + overlap], center=true);
  }
}

// Subtle outer rounding skin (kept inside bbox)
module outer_rounding_skin(){
  intersection(){
    linear_extrude(height=bbox_Z, center=true, convexity=10)
      rounded_rect_2d(bbox_X, bbox_Y, outer_round_r);
    cube([bbox_X, bbox_Y, bbox_Z], center=true);
  }
}

// ---------------- Final ----------------
module clip(){
  difference(){
    union(){
      // Main shell with rounded back and generous internal fillets
      difference(){
        outer_solid();
        inner_void();
      }

      // Lips at the open edge (connected with overlap)
      end_tabs();

      // Subtle outer rounding
      outer_rounding_skin();
    }

    // Open the front (U opening)
    open_front_cut();

    // Aligned opposing side through-holes near top (single pass-through)
    side_through_hole();
  }
}

clip();