// Corrugated cardboard sheet (single connected solid) - FIXED: non-empty, real thickness, visible corrugation

$fn = 64;

// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4;   //[2:8:0.1]

liner_T = 0.4; //[0.2:1:0.05]

corrugation_pitch = 8;    //[4:16:0.5]
corrugation_amp   = 1.5;  //[0.5:3:0.1]
corrugation_wall_T = 0.6; //[0.3:1.2:0.05]

corner_R = 8; //[2:20:0.5]

edge_cut_L = 60;      //[20:120:1]
edge_cut_depth = 18;  //[6:60:1]
edge_cut_Z = 3.2;     //[1:6:0.1]
edge_cut_Z_offset = 0; //[-1:1:0.1]

fold_count = 2; //[0:4:1]
crease_W = 1.2; //[0.6:3:0.1]
crease_depth = 0.25; //[0.1:0.8:0.05]

grain_depth = 0.12; //[0.05:0.3:0.01]
grain_pitch = 10;   //[6:20:1]

overlap = 1; //[0.5:2:0.1]

// Robust epsilons
eps = 0.02;
minT = 0.2;

// Derived
sheet_T_eff = max(sheet_T, 2*liner_T + minT);
liner_T_eff = min(liner_T, sheet_T_eff/2 - minT/2);
core_T = max(minT, sheet_T_eff - 2*liner_T_eff);

core_z0 = -sheet_T_eff/2 + liner_T_eff;
core_z1 =  sheet_T_eff/2 - liner_T_eff;
core_zc = (core_z0 + core_z1)/2;

// Clamp corrugation amplitude so it fits inside core
amp_eff = min(corrugation_amp, max(0.05, core_T/2 - corrugation_wall_T/2 - eps));

// Base Shapes
module rounded_rect_prism(L, W, T, R) {
  R2 = min(R, min(L, W)/2 - eps);
  minkowski() {
    cube([max(eps, L-2*R2), max(eps, W-2*R2), max(eps, T)], center=true);
    cylinder(r=R2, h=eps, center=true);
  }
}

module sheet_solid() {
  rounded_rect_prism(sheet_L, sheet_W, sheet_T_eff, corner_R);
}

module liner_top() {
  translate([0, 0, sheet_T_eff/2 - liner_T_eff/2])
    rounded_rect_prism(sheet_L, sheet_W, liner_T_eff, corner_R);
}

module liner_bottom() {
  translate([0, 0, -sheet_T_eff/2 + liner_T_eff/2])
    rounded_rect_prism(sheet_L, sheet_W, liner_T_eff, corner_R);
}

// Corrugation: build a wavy "web" in XZ, then extrude along Y
module corrugation_web_2d(len, pitch, amp, wallT) {
  n = max(8, ceil(len / max(0.1, pitch)));
  step = len / n;

  pts = [ for (i=[0:n]) [
            -len/2 + i*step,
            amp * sin(360 * (-len/2 + i*step) / max(0.1, pitch))
         ] ];

  // Thickened path: offset a polyline (use offset on polygon made from the polyline)
  offset(delta=wallT/2, join_type="round")
    polygon(points=pts);
}

module corrugated_core() {
  // Extrude the web along Y, then clip to the core volume and rounded outline
  intersection() {
    // Web spans full width; centered in Z within core
    translate([0, 0, core_zc])
      rotate([90, 0, 0])  // linear_extrude along Z becomes along Y
        linear_extrude(height=max(eps, sheet_W - 2*overlap), center=true, convexity=10)
          corrugation_web_2d(max(eps, sheet_L - 2*overlap), corrugation_pitch, amp_eff, corrugation_wall_T);

    // Clip to the core volume (between liners) and rounded outline
    translate([0, 0, core_zc])
      rounded_rect_prism(sheet_L, sheet_W, core_T, corner_R);
  }
}

module edge_exposure_cutaway() {
  // Cut from one corner/edge; ensure it intersects the sheet
  translate([
      sheet_L/2 - edge_cut_L/2 + overlap*0.5,
     -sheet_W/2 + edge_cut_depth/2 - overlap*0.5,
      edge_cut_Z_offset
    ])
    cube([edge_cut_L, edge_cut_depth, edge_cut_Z], center=true);
}

module crease_line_at(xpos) {
  translate([xpos, 0, sheet_T_eff/2 - crease_depth/2 + overlap*0.2])
    cube([crease_W, sheet_W - 2*overlap, crease_depth], center=true);
}

module creases_union() {
  if (fold_count <= 0) {
    // none
  } else if (fold_count == 1) {
    crease_line_at(0);
  } else {
    for (k = [0:fold_count-1]) {
      x = (k - (fold_count-1)/2) * (sheet_L/(fold_count+1));
      crease_line_at(x);
    }
  }
}

module grain_grooves_union() {
  // shallow grooves on top liner area
  count = ceil(sheet_W / grain_pitch);
  for (i = [-count:count]) {
    translate([0, i*grain_pitch, sheet_T_eff/2 - grain_depth/2 + overlap*0.2])
      cube([sheet_L - 2*overlap, grain_pitch/3, grain_depth], center=true);
  }
}

module sheet_with_surface_details() {
  difference() {
    sheet_solid();
    edge_exposure_cutaway();
    creases_union();
    grain_grooves_union();
  }
}

// Final Output: ONE connected solid (liners overlap into sheet; core intersects liners)
module cardboard_sheet_complete() {
  union() {
    sheet_with_surface_details();

    // Overlap liners slightly into the core to guarantee connectivity
    translate([0, 0, -eps]) liner_top();
    translate([0, 0,  eps]) liner_bottom();

    // Core intersects liners by construction (core thickness spans between liners)
    corrugated_core();
  }
}

cardboard_sheet_complete();