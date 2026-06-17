// Corrugated cardboard sheet (single connected solid)

// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 4;   //[2:8:0.1]

liner_T = 0.35; //[0.2:0.8:0.05]
core_T  = 3.3;  //[1.6:6.6:0.1]

corr_pitch = 8;  //[4:16:0.5]
corr_amp   = 1.65; //[0.8:3.3:0.05]

corner_R = 8; //[2:20:1]
overlap  = 0.25; //[0.1:1:0.05]

edge_crush_depth = 0.6; //[0.2:1.5:0.1]
edge_crush_band  = 6;   //[2:15:0.5]

texture_depth = 0.15; //[0.05:0.4:0.01]
texture_pitch = 12;   //[6:30:1]

// Derived / safety
eps = 0.01;
core_gap = max(0, sheet_T - 2*liner_T);
core_scale = (core_T <= 0) ? 1 : min(1, (core_gap + 2*overlap) / core_T);
core_T_eff = core_T * core_scale;

$fn = 48;

// ---------- Helpers ----------
module rounded_rect_2d(L, W, R){
  R2 = min(R, min(L, W)/2 - eps);
  hull() {
    translate([ L/2 - R2,  W/2 - R2]) circle(r=R2);
    translate([-L/2 + R2,  W/2 - R2]) circle(r=R2);
    translate([-L/2 + R2, -W/2 + R2]) circle(r=R2);
    translate([ L/2 - R2, -W/2 + R2]) circle(r=R2);
  }
}

module sheet_outline_3d(h){
  linear_extrude(height=h, center=true)
    rounded_rect_2d(sheet_L, sheet_W, corner_R);
}

module top_liner(){
  translate([0,0, sheet_T/2 - liner_T/2])
    sheet_outline_3d(liner_T);
}

module bottom_liner(){
  translate([0,0,-sheet_T/2 + liner_T/2])
    sheet_outline_3d(liner_T);
}

// Corrugated core: sinusoidal web extruded along X, repeated across Y
module corrugated_core(){
  // Place core between liners with slight overlap into liners for connectivity
  z0 = 0; // centered
  h_core = core_gap + 2*overlap;

  // 2D wave in Y-Z plane, then extrude along X
  module wave_strip(y_center){
    translate([0, y_center, z0])
      rotate([0,90,0])  // make extrusion axis = X
        linear_extrude(height=sheet_L + 2*overlap, center=true, convexity=10)
          polygon(points=
            let(
              n = max(24, ceil( (sheet_W / corr_pitch) * 24 )),
              y0 = -corr_pitch/2,
              y1 =  corr_pitch/2,
              dy = (y1 - y0)/n
            )
            concat(
              // top edge of strip follows sine
              [ for (i=[0:n]) [ y0 + i*dy,  (corr_amp*core_scale) * sin(360*(y0 + i*dy)/corr_pitch) + (h_core/2 - eps) ] ],
              // bottom edge returns back
              [ for (i=[n:-1:0]) [ y0 + i*dy, (corr_amp*core_scale) * sin(360*(y0 + i*dy)/corr_pitch) - (h_core/2 - eps) ] ]
            )
          );
  }

  // Repeat strips across width; overlap slightly to avoid gaps
  union(){
    for (y = [-sheet_W/2 : corr_pitch : sheet_W/2 + corr_pitch])
      wave_strip(y);
  }
}

// Surface texture ridges (subtle) on top liner only
module surface_texture(){
  zt = sheet_T/2 - texture_depth/2;
  intersection(){
    translate([0,0,zt])
      union(){
        for (y = [-sheet_W/2 : texture_pitch : sheet_W/2])
          translate([0,y,0])
            cube([sheet_L + 2*overlap, texture_pitch/3, texture_depth], center=true);
      }
    // clip to sheet outline
    translate([0,0,zt])
      sheet_outline_3d(texture_depth + 2*eps);
  }
}

// Edge crush: subtract shallow bands near edges on top surface
module edge_crush_cut(){
  zc = sheet_T/2 - edge_crush_depth/2;
  intersection(){
    translate([0,0,zc])
      union(){
        // X edges
        translate([ sheet_L/2 - edge_crush_band/2, 0, 0])
          cube([edge_crush_band, sheet_W + 2*overlap, edge_crush_depth], center=true);
        translate([-sheet_L/2 + edge_crush_band/2, 0, 0])
          cube([edge_crush_band, sheet_W + 2*overlap, edge_crush_depth], center=true);
        // Y edges
        translate([0, sheet_W/2 - edge_crush_band/2, 0])
          cube([sheet_L + 2*overlap, edge_crush_band, edge_crush_depth], center=true);
        translate([0,-sheet_W/2 + edge_crush_band/2, 0])
          cube([sheet_L + 2*overlap, edge_crush_band, edge_crush_depth], center=true);
      }
    // clip to sheet outline
    translate([0,0,zc])
      sheet_outline_3d(edge_crush_depth + 2*eps);
  }
}

// ---------- Final model (one connected solid) ----------
module complete_model(){
  difference(){
    union(){
      // Liners
      top_liner();
      bottom_liner();

      // Corrugated core (connected via overlap into liners)
      corrugated_core();

      // Subtle top texture (adds visible detail)
      surface_texture();
    }
    // Edge crush subtraction (still leaves connected solid)
    edge_crush_cut();
  }
}

complete_model();