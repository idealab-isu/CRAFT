// Parameters
thread_size = 4; //[2:8:1]          // nominal major diameter (mm)
length_mm = 8; //[4:20:1]
hob_point_mm = 0; //[0:3:0.5]       // 0 = flat end, >0 = cone point height
drive_hex_af = 2; //[1.3:3:0.1]
socket_depth = 2.5; //[1.5:5:0.1]
thread_pitch = 0.7; //[0.5:1.25:0.05]
thread_depth = 0.15; //[0.05:0.3:0.01]
overlap = 0.8; //[0.5:2:0.1]
eps = 0.05; //[0.01:0.2:0.01]

// Quality
$fn = 96;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Hex socket (AF = across flats)
module hex_socket(af, h) {
  r = af/(2*cos(30));
  linear_extrude(height=h, center=true)
    polygon(points=[
      [ r, 0],
      [ r*cos(60),  r*sin(60)],
      [-r*cos(60),  r*sin(60)],
      [-r, 0],
      [-r*cos(60), -r*sin(60)],
      [ r*cos(60), -r*sin(60)]
    ]);
}

// Simple external thread approximation using helical twist of a triangular ridge
module external_thread(d_major, pitch, depth, len) {
  r_major = d_major/2;
  r_root  = r_major - depth;

  turns = len / pitch;
  slices = max(ceil(turns * 50), 120);

  linear_extrude(height=len, twist=turns*360, slices=slices, center=true, convexity=10)
    translate([r_root, 0, 0])
      polygon(points=[
        [0, -pitch*0.35],
        [depth, 0],
        [0,  pitch*0.35]
      ]);
}

// Screw module (M4 grub / set screw)
module screw() {
  d = thread_size;
  L = length_mm;

  // Keep socket within length
  sock_d = clamp(socket_depth, 0.8, L - 0.8);

  // End style: flat if 0, pointed if >0
  point_h = clamp(hob_point_mm, 0, L/2);

  // Small chamfer at the drive end to make the top view/side views read correctly
  chamfer_h = clamp(0.35, 0.2, L/6);

  // Main body length excluding point and chamfer
  body_L = L - point_h - chamfer_h;

  // Z layout (centered overall)
  z_body    = -L/2 + point_h + body_L/2;
  z_chamfer = -L/2 + point_h + body_L + chamfer_h/2;
  z_point   = -L/2 + point_h/2;

  color("DimGray")
  difference() {
    union() {
      // Root cylinder (minor diameter)
      translate([0, 0, z_body])
        cylinder(d=d - 2*thread_depth, h=body_L + overlap, center=true);

      // Helical thread ridge
      translate([0, 0, z_body])
        external_thread(d_major=d, pitch=thread_pitch, depth=thread_depth, len=body_L + overlap);

      // Drive-end chamfer (slight taper)
      translate([0, 0, z_chamfer])
        cylinder(d1=d - 2*thread_depth, d2=d - 2*thread_depth - 0.5, h=chamfer_h + overlap, center=true);

      // Bottom end: flat with small chamfer ring, or pointed cone
      if (point_h > 0) {
        translate([0, 0, z_point + overlap/2])
          cylinder(d1=d - 2*thread_depth, d2=0.2, h=point_h + overlap, center=true);
      } else {
        // Small bottom chamfer to show end detail in orthographic views
        bottom_ch = clamp(0.35, 0.2, L/6);
        z_bottom_ch = -L/2 + bottom_ch/2;
        translate([0, 0, z_bottom_ch])
          cylinder(d1=d - 2*thread_depth - 0.5, d2=d - 2*thread_depth, h=bottom_ch + overlap, center=true);
      }
    }

    // Hex socket cut into the top face (headless grub screw)
    // Place so the socket opens at the top end (z = +L/2)
    translate([0, 0, L/2 - sock_d/2 + eps])
      hex_socket(drive_hex_af, sock_d + 2*eps);
  }
}

// Assembly
module assembly() {
  screw();
}

assembly();