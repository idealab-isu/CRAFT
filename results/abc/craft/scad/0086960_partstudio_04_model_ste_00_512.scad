// Dimension-calibrated (target: 0.06 x 0.01 x 0.07 mm)
scale([1.040650, 0.601852, 0.650000])
{
// U-shaped bent strap with cylindrical end bosses and recessed hex sockets
// One connected solid, constant thickness in Z, elongated in X.

$fn = 96;

// ---------- Parameters (mm) ----------
bbox_x = 0.10;          // overall length (X)
bbox_y = 0.10;          // overall span (Y)
bbox_z = 0.001;         // very thin thickness (Z)

strap_thk_z = bbox_z;   // constant thickness
strap_w_y   = 0.012;    // strap width (in Y)

u_outer_len_x  = bbox_x;
u_outer_span_y = bbox_y;

// U geometry: open end at +X, closed bend at -X
leg_len_x = 0.030;          // length of each leg from open end toward bend
bend_radius_inner = 0.018;  // inner bend radius

// End bosses at the open ends (+X), centered on each leg centerline
boss_d_y   = 0.020;     // boss diameter
boss_len_x = 0.012;     // boss length along X

// Hex socket (female) recessed into each boss along the boss axis (X)
hex_af      = 0.010;    // across flats
hex_depth_x = 0.008;    // recess depth along X
hex_entry_chamfer_x = 0.0015;

overlap = 0.0015;       // ensure connectivity / clean booleans

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// across-flats -> circumradius for regular hex
function hex_R_from_af(af) = af / sqrt(3);

// 2D hex polygon (flat-to-flat = af), centered at origin
module hex2d(af){
  R = hex_R_from_af(af);
  polygon(points=[ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// ---------- Strap (2D in XY), then extrude in Z ----------
module u_strap_2d(){
  // Fit bend within span
  r_in  = clamp(bend_radius_inner, 0.001, (u_outer_span_y/2 - strap_w_y - 0.001));
  r_out = r_in + strap_w_y;

  x_open    =  u_outer_len_x/2;
  x_leg_end =  x_open - leg_len_x;     // where straight legs meet the bend
  x_c       =  x_leg_end;              // bend center x

  y_leg = u_outer_span_y/2 - strap_w_y/2;

  union(){
    // Top leg
    translate([x_leg_end - overlap, y_leg - strap_w_y/2])
      square([leg_len_x + overlap, strap_w_y], center=false);

    // Bottom leg
    translate([x_leg_end - overlap, -y_leg - strap_w_y/2])
      square([leg_len_x + overlap, strap_w_y], center=false);

    // Left-side U-bend: annular half-ring (left half)
    translate([x_c, 0])
      intersection(){
        difference(){
          circle(r=r_out);
          circle(r=r_in);
        }
        // keep only left half (x <= 0 in local coords)
        translate([-r_out - 2*overlap, -r_out - 2*overlap])
          square([r_out + 2*overlap, 2*r_out + 4*overlap], center=false);
      }
  }
}

module u_strap_3d(){
  linear_extrude(height=strap_thk_z, center=true)
    u_strap_2d();
}

// ---------- End bosses (cylinders along X) ----------
module end_boss_at(yc){
  x_open = u_outer_len_x/2;

  // Place boss so its OUTER face is at x_open, and it overlaps into the strap by `overlap`
  // Cylinder is centered, so outer face = x_boss_c + boss_len_x/2
  x_boss_c = x_open - boss_len_x/2 + overlap;

  translate([x_boss_c, yc, 0])
    rotate([0,90,0])
      cylinder(h=boss_len_x, r=boss_d_y/2, center=true);
}

module bosses(){
  y_leg = u_outer_span_y/2 - strap_w_y/2;
  union(){
    end_boss_at( y_leg);
    end_boss_at(-y_leg);
  }
}

// ---------- Hex sockets (subtract) ----------
module hex_socket_at(yc){
  x_open = u_outer_len_x/2;

  // Recessed hex prism:
  // Make the MOUTH exactly at x_open and extend inward by hex_depth_x.
  // Use center=false so placement is unambiguous and the opening is clearly visible.
  translate([x_open - hex_depth_x - overlap, yc, 0])
    rotate([0,90,0])
      linear_extrude(height=hex_depth_x + overlap, center=false)
        hex2d(hex_af);

  // Entry chamfer (slight countersink) at the mouth to read clearly in ortho views
  Rhex = hex_R_from_af(hex_af);
  translate([x_open - hex_entry_chamfer_x - overlap, yc, 0])
    rotate([0,90,0])
      cylinder(
        h  = hex_entry_chamfer_x + overlap,
        r1 = Rhex*1.30,   // larger at the mouth
        r2 = Rhex*1.02,   // transitions toward the hex pocket
        center=false
      );
}

module sockets(){
  y_leg = u_outer_span_y/2 - strap_w_y/2;
  union(){
    hex_socket_at( y_leg);
    hex_socket_at(-y_leg);
  }
}

// ---------- Final model ----------
difference(){
  union(){
    u_strap_3d();
    bosses();
  }
  sockets();
}
}
