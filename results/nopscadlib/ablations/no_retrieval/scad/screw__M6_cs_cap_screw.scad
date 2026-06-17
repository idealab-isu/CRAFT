$fn = 128;

// Requested dimensions
shank_d = 6.0;          // mm (major diameter)
length  = 10.0;         // mm (under-head length)
head_d  = 12.0;         // mm
head_h  = 6.0;          // mm (typical for M6 SHCS)

// Thread (visual)
thread_pitch = 1.0;     // mm
thread_depth = 0.35;    // mm (visual, not ISO-accurate)
thread_start_clear = 0.6; // mm unthreaded under head (visual)

// Socket
socket_af    = 5.0;     // mm across flats (typical for M6)
socket_depth = 4.0;     // mm

// Small edge details
tip_chamfer_h = 0.6;    // mm
tip_chamfer_r = 0.6;    // mm
head_top_chamfer_h = 0.5; // mm

// Placement: head sits on Z=0 plane, shank extends to negative Z
// Head: z in [0, head_h]
// Shank: z in [-length, 0]

module hex2d(af){
  // Regular hex with across-flats = af => circumradius = af / sqrt(3)
  r = af / sqrt(3);
  polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module external_thread(d_major, pitch, depth, len){
  // Simple helical ridge (visual thread)
  // Base cylinder at minor diameter + helical "tooth" added
  d_minor = d_major - 2*depth;
  turns = len / pitch;
  union() {
    cylinder(h=len, d=d_minor, center=false);
    linear_extrude(height=len, twist=-360*turns, slices=max(ceil(turns*24), 24), center=false)
      translate([d_minor/2, 0, 0])
        square([depth, pitch*0.55], center=true);
  }
}

module screw(){
  difference() {
    union() {
      // Head (with slight top chamfer)
      union() {
        cylinder(h=head_h - head_top_chamfer_h, d=head_d, center=false);
        translate([0,0,head_h - head_top_chamfer_h])
          cylinder(h=head_top_chamfer_h, d1=head_d, d2=head_d - 2*head_top_chamfer_h, center=false);
      }

      // Shank + threads (connected at z=0)
      // Small unthreaded relief under head for realism
      translate([0,0,-thread_start_clear])
        cylinder(h=thread_start_clear, d=shank_d, center=false);

      translate([0,0,-length])
        external_thread(shank_d, thread_pitch, thread_depth, max(length - thread_start_clear, 0.01));

      // Tip chamfer (keeps one connected solid)
      translate([0,0,-length])
        cylinder(h=tip_chamfer_h, d1=shank_d - 2*tip_chamfer_r, d2=shank_d, center=false);
    }

    // Hex socket recess (cut into head from top)
    translate([0,0,head_h - socket_depth])
      linear_extrude(height=socket_depth + 0.02, center=false)
        hex2d(socket_af);
  }
}

color("DimGray") screw();