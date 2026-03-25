// Dimension-calibrated (target: 5.45 x 1.41 x 9.01 mm)
scale([1.008528, 0.632886, 0.818567])
{
// Small mounting clip/bracket (single connected solid)
// Target bounding box (approx): X=5.4, Y=1.4, Z=9.0
// Elongated along Z

$fn = 72;

// ---------------- Parameters ----------------
bbox_X = 5.40;   // X width
bbox_Y = 1.40;   // Y thickness
bbox_Z = 9.00;   // Z length

// Base plate
base_W = bbox_X;         // X
base_T = 0.70;           // Y
base_L = bbox_Z;         // Z
base_corner_R = 0.55;

// Central raised spine (continuous along most of base)
spine_W = 1.25;          // X
spine_H = 0.40;          // Y
spine_L = base_L * 0.82; // Z

// Cradle / hook (forward-projecting along +Z)
cradle_opening_W = 1.70; // X span of hook seat (between tips)
cradle_inner_R   = 0.75; // inner seat radius (rod/cable radius)
cradle_arm_thk   = 0.55; // arm thickness (radial thickness)
cradle_proj      = 2.05; // how far beyond base front edge the hook reaches (+Z)

// Nubs at hook tips
nub_D = 0.70;
nub_L = 0.55;

// Reliefs
void_depth = 0.30;
void_R = 0.55;

// Overlap for robust unions (small model: keep modest)
overlap = 0.20;

// ---------------- Helpers ----------------
module rounded_rect_prism(size=[10,1,10], r=1, center=true) {
  // size = [X,Y,Z]
  minkowski() {
    cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

// ---------------- Base ----------------
module base_plate() {
  rounded_rect_prism([base_W, base_T, base_L], r=base_corner_R, center=true);
}

module base_internal_relief_void() {
  // shallow underside relief, stays inside base
  translate([0, -base_T/2 + void_depth/2 + overlap/2, 0])
    rounded_rect_prism([base_W - 2*void_R, void_depth + overlap, base_L - 2*void_R], r=void_R, center=true);
}

// ---------------- Spine ----------------
module central_spine() {
  translate([0, base_T/2 + spine_H/2 - overlap/2, 0])
    rounded_rect_prism([spine_W, spine_H + overlap, spine_L], r=min(0.25, spine_W/2-0.01), center=true);
}

// ---------------- Cradle (U-shaped hook) ----------------
module cradle_hook_solid() {
  // U-shaped forward-projecting cradle: partial torus segment extruded along X.
  // Open toward +Y (up), and only forward-facing (toward +Z).
  arm_r = cradle_arm_thk/2;
  Rmid  = cradle_inner_R + arm_r;

  // Place hook so it is clearly in front of the base and connected via a web.
  // Ensure forward reach: outermost Z approx = base_L/2 + cradle_proj
  y0 = base_T/2 + spine_H - overlap/2;
  z0 = (base_L/2 + cradle_proj) - (Rmid + arm_r);  // center of arc

  translate([0, y0, z0])
  rotate([0,90,0])  // extrude along X
  intersection() {
    // Ring (tube) extruded across full width; later clipped to opening width.
    linear_extrude(height=base_W + 2*overlap, center=true, convexity=10)
      difference() {
        circle(r=Rmid + arm_r);
        circle(r=Rmid - arm_r);
      }

    // Keep only the lower half of the ring (so it opens upward toward +Y).
    // In this local frame, "up" is +Y of the 2D profile.
    translate([0, -(Rmid + arm_r)*0.60, 0])
      cube([base_W + 4*overlap, 2*(Rmid + arm_r) + 4*overlap, 2*(Rmid + arm_r) + 4*overlap], center=true);

    // Keep only the forward-facing portion (no wrap behind the base).
    // Local +Z corresponds to global +Z after the rotate.
    translate([0, 0, +(Rmid + arm_r)*0.35])
      cube([base_W + 4*overlap, 3*(Rmid + arm_r) + 4*overlap, 1.70*(Rmid + arm_r) + 4*overlap], center=true);

    // Limit hook to opening width in X (so it reads as a cradle, not a full-width ring).
    cube([cradle_opening_W + 2*overlap, 5*(Rmid + arm_r) + 4*overlap, 5*(Rmid + arm_r) + 4*overlap], center=true);
  }
}

module cradle_end_nubs() {
  // Nubs at the two hook tips (left/right in X), positioned to intersect the hook solid.
  arm_r = cradle_arm_thk/2;
  Rmid  = cradle_inner_R + arm_r;

  y0 = base_T/2 + spine_H - overlap/2;
  z0 = (base_L/2 + cradle_proj) - (Rmid + arm_r);

  // Put nubs at the forward/lower tip region of the kept arc.
  // Ensure they intersect the hook and remain within overall X.
  x_tip = cradle_opening_W/2;
  y_tip = y0 - 0.05;
  z_tip = z0 + (Rmid + arm_r) * 0.70;

  union() {
    translate([ x_tip, y_tip, z_tip])
      rotate([90,0,0]) cylinder(r=nub_D/2, h=nub_L, center=true);
    translate([-x_tip, y_tip, z_tip])
      rotate([90,0,0]) cylinder(r=nub_D/2, h=nub_L, center=true);
  }
}

module cradle_inner_relief_void() {
  // Hollow out the seat (cylindrical) to make a clear cradle for a rod/cable.
  arm_r = cradle_arm_thk/2;
  Rmid  = cradle_inner_R + arm_r;

  y0 = base_T/2 + spine_H - overlap/2;
  z0 = (base_L/2 + cradle_proj) - (Rmid + arm_r);

  translate([0, y0, z0])
    rotate([0,90,0])
      cylinder(r=cradle_inner_R, h=cradle_opening_W + 2*overlap, center=true);
}

module cradle_connection_web() {
  // Strong, obvious connection between spine/front of base and the hook.
  // Web overlaps both the spine and the hook base region.
  arm_r = cradle_arm_thk/2;
  Rmid  = cradle_inner_R + arm_r;

  // Hook center
  y_hook = base_T/2 + spine_H - overlap/2;
  z_hook = (base_L/2 + cradle_proj) - (Rmid + arm_r);

  // Start near the base front edge (slightly inside to guarantee overlap)
  z_base_front = base_L/2 - base_corner_R*0.40;

  // End slightly behind hook center so it intersects the hook body
  z_web_end = z_hook + (Rmid + arm_r)*0.05;

  web_L  = (z_web_end - z_base_front) + 2*overlap;
  web_Zc = (z_base_front + z_web_end)/2;

  // Web height: reaches up to hook centerline region
  web_H = spine_H + 0.35;

  translate([0, base_T/2 + web_H/2 - overlap/2, web_Zc])
    rounded_rect_prism([spine_W + 0.90, web_H + overlap, web_L], r=0.20, center=true);
}

// ---------------- Assembly ----------------
module complete_model() {
  difference() {
    union() {
      base_plate();
      central_spine();

      // Forward-projecting open cradle + nubs + connecting web
      cradle_hook_solid();
      cradle_end_nubs();
      cradle_connection_web();
    }

    // Voids
    base_internal_relief_void();
    cradle_inner_relief_void();
  }
}

complete_model();
}
