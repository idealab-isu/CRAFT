// Dome head screw (single connected solid)
// Target: 6.0mm thread diameter, 10.5mm head diameter, 3.3mm head height, 10mm length under head

$fn = 96;

// Parameters
thread_diameter_mm      = 6.0;
length_under_head_mm    = 10.0;

head_diameter_mm        = 10.5;
head_height_mm          = 3.3;

thread_pitch_mm         = 1.0;   // visual thread pitch
thread_depth_mm         = 0.35;  // radial depth of thread (visual)

tip_chamfer_height_mm   = 0.8;
underhead_fillet_height_mm = 0.6;

hex_socket_af_mm        = 4.0;
hex_socket_depth_mm     = 2.5;

overlap_mm              = 0.2;

// Derived
r_major = thread_diameter_mm/2;
r_minor = r_major - thread_depth_mm;

z_underhead = 0;                         // underside of head at z=0
z_tip       = -length_under_head_mm;     // tip at z=-L
z_head_top  = head_height_mm;

// --- Helpers ---
module hex_prism(af, h, center=false) {
  // across-flats -> circumradius
  r = af/(2*cos(30));
  cylinder(h=h, r=r, $fn=6, center=center);
}

module dome_head_solid() {
  // Build a dome-like head by revolving a 2D profile.
  // Profile is constrained to: diameter=head_diameter_mm at z=0, height=head_height_mm.
  r_head = head_diameter_mm/2;

  // Choose a circle that passes through (r_head,0) and (0,head_height_mm)
  // Center at (0, c) with radius R = r_head, where c = (head_height^2 - r_head^2)/(2*head_height)
  c = (head_height_mm*head_height_mm - r_head*r_head) / (2*head_height_mm);

  rotate_extrude(convexity=10)
    intersection() {
      // Circle arc region
      translate([0, c]) circle(r=r_head);
      // Keep only within the head bounding box
      polygon(points=[
        [0, 0],
        [r_head, 0],
        [r_head, head_height_mm],
        [0, head_height_mm]
      ]);
    }
}

module threaded_shaft_visual() {
  // Base minor cylinder
  translate([0,0,(z_underhead+z_tip)/2])
    cylinder(h=length_under_head_mm, r=r_minor, center=true);

  // Helical thread (visual approximation)
  // Use linear_extrude with twist to create a continuous ridge.
  turns = length_under_head_mm / thread_pitch_mm;
  slices = max(ceil(turns*40), 80);

  translate([0,0,z_tip])
    linear_extrude(height=length_under_head_mm, twist=turns*360, slices=slices, convexity=10)
      translate([r_minor, 0, 0])
        circle(r=thread_depth_mm, $fn=24);

  // Tip chamfer (cone) at the end
  translate([0,0,z_tip + tip_chamfer_height_mm/2])
    cylinder(h=tip_chamfer_height_mm, r1=r_major, r2=0, center=true);
}

module underhead_fillet() {
  // Small taper from head diameter down to thread major diameter
  translate([0,0,underhead_fillet_height_mm/2 - overlap_mm])
    cylinder(h=underhead_fillet_height_mm + 2*overlap_mm,
             r1=head_diameter_mm/2,
             r2=r_major,
             center=true);
}

module screw() {
  difference() {
    union() {
      // Head (underside at z=0)
      translate([0,0,0]) dome_head_solid();

      // Underhead fillet (overlaps into head and shaft)
      underhead_fillet();

      // Threaded shaft (connected at z=0)
      threaded_shaft_visual();
    }

    // Hex socket cut into head from top
    translate([0,0,z_head_top - hex_socket_depth_mm/2 + overlap_mm])
      hex_prism(hex_socket_af_mm, hex_socket_depth_mm + 2*overlap_mm, center=true);
  }
}

screw();