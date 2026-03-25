// Threaded heat-set insert (visual model)
// Target: 30.0mm outer diameter, 22.0mm long, for 12.0mm screws (M12)

// ---------- Parameters ----------
outer_diameter = 30;                 // mm
length = 22;                         // mm
screw_diameter = 12;                 // mm (M12 major dia)
bore_clearance_mm = 0.4;             // mm (visual/fit clearance)

rib_count = 24;
rib_radial_height = 1.2;             // mm
rib_tangential_width = 2.2;          // mm
rib_axial_margin = 1.5;              // mm

stop_face_thickness = 1.5;           // mm
stop_face_overhang = 1.5;            // mm

chamfer_height = 2.5;                // mm

// Visual internal thread (approx)
thread_pitch = 1.75;                 // mm (M12 coarse)
thread_depth = 0.7;                  // mm (visual)
thread_start_margin = 1.0;           // mm (keep ends clean for chamfers)
thread_fn = 96;

eps = 0.05;                          // mm (small, for robust booleans)

// Derived
outer_r = outer_diameter/2;
bore_diameter = screw_diameter + bore_clearance_mm;
bore_r = bore_diameter/2;

// ---------- Helpers ----------
module internal_thread_visual(minor_r, major_r, pitch, h, fn=96) {
  // Creates a helical "ridge" to subtract from the bore, approximating internal threads.
  // One connected subtractive solid.
  turns = h / pitch;
  linear_extrude(height=h, twist=-360*turns, slices=max(ceil(turns*24), 24), convexity=10)
    translate([minor_r, 0, 0])
      circle(r=(major_r - minor_r), $fn=fn);
}

// ---------- Model ----------
module threaded_insert() {
  color([0.85, 0.85, 0.8])
  difference() {
    // ONE connected solid: body + ribs + stop face
    union() {
      // Main body
      cylinder(r=outer_r, h=length, center=true, $fn=128);

      // Outer ribs/knurl (connected by overlap into body)
      for (i = [0:rib_count-1]) {
        rotate([0, 0, i*360/rib_count])
          translate([outer_r + rib_radial_height/2 - eps, 0, 0])  // overlap into body by eps
            cube([rib_radial_height, rib_tangential_width, length - 2*rib_axial_margin],
                 center=true);
      }

      // Installation stop face (flange) connected to top
      translate([0, 0, length/2 + stop_face_thickness/2 - eps])
        cylinder(r=outer_r + stop_face_overhang, h=stop_face_thickness, center=true, $fn=128);
    }

    // Through bore (ensures visible hole in all orthographic views)
    cylinder(r=bore_r, h=length + stop_face_thickness + 6*eps, center=true, $fn=128);

    // Visual internal threading (subtract helical ridge from inside of bore)
    // Place within the insert length, leaving margins for chamfers.
    thread_h = max(length - 2*thread_start_margin, 0.1);
    translate([0, 0, -thread_h/2])  // center thread region around Z=0
      internal_thread_visual(
        minor_r = max(bore_r - thread_depth, 0.1),
        major_r = bore_r + eps,
        pitch   = thread_pitch,
        h       = thread_h,
        fn      = thread_fn
      );

    // Lead-in chamfer at bottom (subtract a frustum to open the bore)
    translate([0, 0, -length/2 + chamfer_height/2 + eps])
      cylinder(r1=bore_r + chamfer_height, r2=bore_r, h=chamfer_height + 2*eps, center=true, $fn=128);

    // Lead-in chamfer at top (also through flange area)
    translate([0, 0, length/2 - chamfer_height/2 - eps])
      cylinder(r1=bore_r, r2=bore_r + chamfer_height, h=chamfer_height + 2*eps, center=true, $fn=128);
  }
}

threaded_insert();