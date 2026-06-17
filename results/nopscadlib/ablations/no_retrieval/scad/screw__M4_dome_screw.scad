// Dome head screw: 4.0mm shank dia, 7.6mm head dia, 2.2mm head height, 10mm length under head
// One connected solid, smooth cylindrical shank, visible helical threads.

$fn = 128;

// Parameters
shank_d = 4.0;                 //[2.0:8.0:0.1]
length_under_head = 10.0;      //[5.0:20.0:0.5]
head_d = 7.6;                  //[4.0:15.2:0.1]
head_h = 2.2;                  //[1.1:4.4:0.1]

thread_pitch = 0.7;            //[0.35:1.4:0.05]
thread_length = 8.0;           //[4.0:16.0:0.5]
thread_depth = 0.25;           //[0.1:0.6:0.05]

tip_chamfer_h = 0.6;           //[0.3:1.2:0.05]
underhead_fillet_r = 0.4;      //[0.2:0.8:0.05]

drive_recess_enable = 0;       //[0:1:1]
drive_recess_d = 3.0;          //[1.5:5.0:0.1]
drive_recess_h = 1.2;          //[0.6:2.4:0.1]

overlap = 0.05;

// Derived
shank_r = shank_d/2;
head_r  = head_d/2;

// Coordinate convention:
// z=0 at underside of head (bearing surface).
// Shank extends to z = -length_under_head.
// Head extends to z = +head_h.

module dome_head() {
  // Spherical cap that exactly meets:
  // - base circle radius = head_r at z=0
  // - apex at z=head_h
  // Sphere radius R = (a^2 + h^2)/(2h), center at z = h - R
  a = head_r;
  h = head_h;
  R = (a*a + h*h)/(2*h);
  zc = h - R;

  intersection() {
    translate([0,0,zc]) sphere(r=R);
    // clip to [0..head_h]
    translate([0,0,h/2]) cylinder(h=h + overlap*2, r=head_r + 1, center=true);
  }
}

module underhead_fillet() {
  // Small torus-like fillet between shank and underside of head
  // Positioned so it blends at z=0 and touches shank radius.
  rotate_extrude(convexity=10)
    translate([shank_r + underhead_fillet_r, 0, 0])
      circle(r=underhead_fillet_r, $fn=96);
}

module shank_core() {
  // Smooth core cylinder (minor diameter) for threading
  // Core radius reduced by thread_depth so threads add back to nominal shank_d.
  core_r = max(0.01, shank_r - thread_depth);
  translate([0,0,-length_under_head/2])
    cylinder(h=length_under_head, r=core_r, center=true);
}

module tip_chamfer() {
  // Conical tip on the core (keeps overall length under head correct)
  core_r = max(0.01, shank_r - thread_depth);
  translate([0,0,-length_under_head + tip_chamfer_h/2])
    cylinder(h=tip_chamfer_h + overlap*2, r1=core_r, r2=0, center=true);
}

module helical_thread() {
  // Simple external thread as a helical triangular ridge
  // Built by twisting a small triangular profile around the core.
  core_r = max(0.01, shank_r - thread_depth);
  turns = thread_length / thread_pitch;

  // Thread profile (2D) in X-Y plane, then linear_extrude with twist along Z.
  // Triangle spans from core_r to shank_r (core_r + thread_depth).
  // Slight tangential width to make a visible ridge.
  tangential_w = max(0.18, thread_pitch * 0.35);

  translate([0,0,-length_under_head + thread_length/2])
    linear_extrude(height=thread_length, twist=turns*360, center=true, convexity=10, slices=max(ceil(turns*40), 80))
      polygon(points=[
        [core_r, -tangential_w/2],
        [core_r,  tangential_w/2],
        [core_r + thread_depth, 0]
      ]);
}

module drive_recess() {
  translate([0,0,head_h - drive_recess_h/2])
    cylinder(h=drive_recess_h + overlap*2, r=drive_recess_d/2, center=true, $fn=96);
}

module screw_solid() {
  union() {
    // Head (dome) + a thin base disk to ensure clean connection at z=0
    dome_head();
    translate([0,0,overlap/2])
      cylinder(h=overlap, r=head_r, center=true);

    // Underhead fillet (touches z=0 plane and shank)
    underhead_fillet();

    // Shank core + tip
    shank_core();
    tip_chamfer();

    // Threads (external ridge) connected to core
    helical_thread();
  }
}

difference() {
  screw_solid();
  if (drive_recess_enable == 1) drive_recess();
}