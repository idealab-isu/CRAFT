// Dimension-calibrated (target: 0.31 x 0.08 x 0.31 mm)
scale([0.840541, 0.518750, 3.790123])
{
// Shallow vented tray with rounded corners + wide outward flange + diamond side perforations
// Units: mm (very small part as requested)

// ---------------- Parameters ----------------
L = 0.31;   //[0.155:0.62:0.001]  // overall length (elongated axis)
W = 0.10;   //[0.05:0.20:0.001]   // overall width  (short axis)
H = 0.08;   //[0.04:0.16:0.001]   // overall height

corner_r = 0.02; //[0.01:0.05:0.001]
wall_t   = 0.006; //[0.003:0.012:0.001]
bottom_t = 0.010; //[0.004:0.020:0.001]

flange_w = 0.03;  //[0.01:0.06:0.001]  // outward lip width
flange_t = 0.004; //[0.002:0.010:0.001]

draft = 0.010; //[0.0:0.03:0.001] // outward draft amount from bottom to top (per side)

hole_w = 0.018; //[0.009:0.036:0.001] // diamond width
hole_h = 0.012; //[0.005:0.024:0.001] // diamond height
hole_pitch_x = 0.030; //[0.014:0.060:0.001] // along length
hole_pitch_z = 0.022; //[0.010:0.050:0.001] // along height

hole_margin_top = 0.012;    //[0.006:0.030:0.001]
hole_margin_bottom = 0.012; //[0.006:0.030:0.001]
hole_margin_corners = 0.020; //[0.010:0.050:0.001]

eps = 0.001;

// ---------------- Helpers ----------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_2d(x, y, r){
  r2 = clamp(r, 0, min(x,y)/2);
  offset(r=r2) square([x-2*r2, y-2*r2], center=true);
}

module diamond_2d(w,h){
  polygon(points=[[0,h/2],[w/2,0],[0,-h/2],[-w/2,0]]);
}

// Tray outer: rounded rectangle, drafted (top larger than bottom)
module outer_shell(){
  // bottom outer dims
  Lb = L - 2*draft;
  Wb = W - 2*draft;
  // keep valid
  Lb2 = max(Lb, 2*corner_r + 2*wall_t + 0.01);
  Wb2 = max(Wb, 2*corner_r + 2*wall_t + 0.01);

  hull(){
    translate([0,0,-H/2]) linear_extrude(height=eps, center=false)
      rounded_rect_2d(Lb2, Wb2, max(corner_r - draft, 0.001));
    translate([0,0, H/2]) linear_extrude(height=eps, center=false)
      rounded_rect_2d(L, W, corner_r);
  }
}

// Inner void: drafted, starts above bottom_t to keep solid bottom
module inner_void(){
  // inner top dims
  Lt = L - 2*wall_t;
  Wt = W - 2*wall_t;

  // inner bottom dims (smaller due to draft)
  Lb = (L - 2*draft) - 2*wall_t;
  Wb = (W - 2*draft) - 2*wall_t;

  // keep valid
  Lt2 = max(Lt, 0.02);
  Wt2 = max(Wt, 0.02);
  Lb2 = max(Lb, 0.02);
  Wb2 = max(Wb, 0.02);

  // inner corner radii
  rt = max(corner_r - wall_t, 0.001);
  rb = max(corner_r - wall_t - draft, 0.001);

  hull(){
    translate([0,0,-H/2 + bottom_t]) linear_extrude(height=eps, center=false)
      rounded_rect_2d(Lb2, Wb2, rb);
    translate([0,0, H/2 + eps]) linear_extrude(height=eps, center=false)
      rounded_rect_2d(Lt2, Wt2, rt);
  }
}

// Wide outward flange/lip around top perimeter
module top_flange(){
  translate([0,0, H/2 - flange_t/2])
  difference(){
    linear_extrude(height=flange_t, center=true)
      rounded_rect_2d(L + 2*flange_w, W + 2*flange_w, corner_r + flange_w);
    translate([0,0,0])
      linear_extrude(height=flange_t + 2*eps, center=true)
        rounded_rect_2d(L, W, corner_r);
  }
}

// Diamond hole cutter oriented to cut through a wall
module diamond_cutter_x(depth){
  rotate([0,90,0])
    linear_extrude(height=depth, center=true)
      diamond_2d(hole_w, hole_h);
}
module diamond_cutter_y(depth){
  rotate([90,0,0])
    linear_extrude(height=depth, center=true)
      diamond_2d(hole_w, hole_h);
}

// Perforation pattern on all four side walls (through-holes), leaving bottom solid
module side_perforations(){
  // z range for holes (avoid top flange and bottom)
  z0 = -H/2 + bottom_t + hole_margin_bottom + hole_h/2;
  z1 =  H/2 - flange_t - hole_margin_top - hole_h/2;
  zspan = max(z1 - z0, 0);

  // x/y ranges (avoid rounded corners)
  x0 = -L/2 + hole_margin_corners + hole_w/2;
  x1 =  L/2 - hole_margin_corners - hole_w/2;
  y0 = -W/2 + hole_margin_corners + hole_w/2;
  y1 =  W/2 - hole_margin_corners - hole_w/2;

  // counts
  nx = max(1, floor((x1 - x0)/hole_pitch_x) + 1);
  ny = max(1, floor((y1 - y0)/hole_pitch_x) + 1);
  nz = max(1, floor(zspan/hole_pitch_z) + 1);

  // wall mid-planes (approx; cutters are deep enough to pass through drafted walls)
  xwall = L/2 - wall_t/2;
  ywall = W/2 - wall_t/2;

  depth = wall_t + 2*draft + 4*eps;

  union(){
    // +X and -X walls (vary along Y and Z)
    for (iz = [0:nz-1]){
      z = z0 + iz*hole_pitch_z;
      // stagger every other row
      yshift = (iz % 2) * (hole_pitch_x/2);
      for (iy = [0:ny-1]){
        y = (y0 + iy*hole_pitch_x) + yshift;
        if (y >= y0 && y <= y1){
          translate([ xwall, y, z]) diamond_cutter_x(depth);
          translate([-xwall, y, z]) diamond_cutter_x(depth);
        }
      }
    }

    // +Y and -Y walls (vary along X and Z)
    for (iz = [0:nz-1]){
      z = z0 + iz*hole_pitch_z;
      xshift = (iz % 2) * (hole_pitch_x/2);
      for (ix = [0:nx-1]){
        x = (x0 + ix*hole_pitch_x) + xshift;
        if (x >= x0 && x <= x1){
          translate([x,  ywall, z]) diamond_cutter_y(depth);
          translate([x, -ywall, z]) diamond_cutter_y(depth);
        }
      }
    }
  }
}

// ---------------- Final model ----------------
module tray(){
  difference(){
    union(){
      difference(){
        outer_shell();
        inner_void();
      }
      top_flange();
    }
    side_perforations();
  }
}

color([0.85, 0.85, 0.8])
tray();
}
