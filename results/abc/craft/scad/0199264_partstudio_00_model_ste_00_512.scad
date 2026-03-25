// Dimension-calibrated (target: 0.10 x 0.01 x 0.12 mm)
scale([0.782022, 0.610476, 0.600000])
{
// Flat 6-armed radial plate with integrated rounded pads + diamond through-holes
// All geometry is built in 2D (XY) then extruded once to ensure a single connected planar solid.

$fn = 64;

// --- Parameters (mm) ---
bbox_X = 0.1;          // overall X target
bbox_Y = 0.0;          // planar (thickness handled by plate_thk)
bbox_Z = 0.1;          // overall Y target (kept symmetric)
plate_thk = 0.01;

hub_r = 0.012;

arm_len = 0.045;
arm_w_root = 0.01;
arm_w_tip  = 0.014;

pad_len = 0.03;
pad_w = 0.02;
pad_corner_r = 0.004;

hole_count_per_pad = 3;
hole_size = 0.004;
hole_pitch = 0.006;
hole_edge_margin = 0.004;
hole_rotation_deg = 45;

overlap = 0.001;

notch_r = 0.0015;
notch_depth = 0.001;

// --- Helpers ---
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_2d(w, h, r){
  r2 = clamp(r, 0, min(w,h)/2);
  hull(){
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module arm_2d(){
  // Arm extends from hub edge outward along +Y
  polygon(points=[
    [-arm_w_root/2, hub_r - overlap],
    [ arm_w_root/2, hub_r - overlap],
    [ arm_w_tip/2,  hub_r + arm_len + overlap],
    [-arm_w_tip/2,  hub_r + arm_len + overlap]
  ]);
}

module pad_2d(){
  // Pad centered at end of arm, integrated by union in 2D
  translate([0, hub_r + arm_len + pad_len/2 - overlap])
    rounded_rect_2d(pad_w, pad_len, pad_corner_r);
}

module hub_2d(){
  circle(r=hub_r);
}

module diamond_hole_2d(){
  rotate(hole_rotation_deg) square([hole_size, hole_size], center=true);
}

module notch_2d(){
  // Small circular notch near pad tip (subtracted)
  translate([0, hub_r + arm_len + pad_len - overlap - notch_depth])
    circle(r=notch_r);
}

// --- Build one arm (2D) ---
module arm_with_pad_2d(){
  union(){
    arm_2d();
    pad_2d();
  }
}

// --- Full plate outline (2D) ---
module spider_2d(){
  union(){
    hub_2d();
    for(i=[0:5])
      rotate(i*60) arm_with_pad_2d();
  }
}

// --- Holes (2D) ---
module holes_2d(){
  union(){
    for(i=[0:5]){
      rotate(i*60){
        // Place holes along pad length (Y direction), centered in pad width
        y0 = hub_r + arm_len + hole_edge_margin;
        for(j=[0:hole_count_per_pad-1]){
          translate([0, y0 + j*hole_pitch])
            diamond_hole_2d();
        }
      }
    }
  }
}

// --- Notches (2D) ---
module notches_2d(){
  union(){
    for(i=[0:5])
      rotate(i*60) notch_2d();
  }
}

// --- Final (single connected planar solid) ---
linear_extrude(height=plate_thk, center=true)
difference(){
  spider_2d();
  holes_2d();
  notches_2d();
}
}
