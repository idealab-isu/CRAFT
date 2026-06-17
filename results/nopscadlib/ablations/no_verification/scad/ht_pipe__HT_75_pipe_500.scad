// HT 75 pipe 500 mm (single connected solid)

// Parameters
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 500; //[250:1000:1]
outer_diameter_mm = 75; //[40:150:0.1]
wall_thickness_mm = 2.7; //[1.3:5.4:0.1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]

eps_mm = 0.2; //[0.05:1:0.05]
fitting_length_mm = 35; //[15:70:1]
fitting_od_extra_mm = 6; //[2:15:0.5]
fitting_bore_clearance_mm = 0.5; //[0.2:1.5:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.5]

$fn = 96;

// Derived
outer_r = outer_diameter_mm/2;
inner_r = max(0.01, outer_r - wall_thickness_mm);

fitting_outer_r = (outer_diameter_mm + fitting_od_extra_mm)/2;
fitting_bore_r  = inner_r + fitting_bore_clearance_mm;

// Z placement
z0 = center ? -length_mm/2 : 0;
pipe_z1 = z0 + length_mm;

// Ensure fitting overlaps pipe slightly so it's one connected solid
overlap_z = max(eps_mm, 0.5);

module ht_pipe() {
  // Clamp stop thickness to fitting length to avoid invalid geometry
  stop_t = min(fitting_stop_thickness_mm, fitting_length_mm);

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (pipe + optional fitting) as one union
    union() {
      // Main outer pipe
      translate([0, 0, z0])
        cylinder(h=length_mm, r=outer_r, center=false);

      // End fitting (socket) on +Z end, overlapping into pipe
      if (include_end_fitting)
        translate([0, 0, pipe_z1 - overlap_z])
          cylinder(h=fitting_length_mm + overlap_z, r=fitting_outer_r, center=false);
    }

    // INNER VOID (bore + socket bore with internal stop shoulder)
    union() {
      // Main bore through entire pipe length
      translate([0, 0, z0 - eps_mm])
        cylinder(h=length_mm + 2*eps_mm, r=inner_r, center=false);

      if (include_end_fitting) {
        // Socket bore (slightly larger) ONLY up to the stop shoulder
        translate([0, 0, pipe_z1 - overlap_z - eps_mm])
          cylinder(h=(fitting_length_mm - stop_t) + overlap_z + 2*eps_mm, r=fitting_bore_r, center=false);

        // Stop region: returns to normal bore for the last stop_t of the fitting
        translate([0, 0, pipe_z1 + (fitting_length_mm - stop_t) - eps_mm])
          cylinder(h=stop_t + 2*eps_mm, r=inner_r, center=false);
      }
    }
  }
}

ht_pipe();