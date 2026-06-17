// HT 50 pipe 1500 mm (single connected solid)

// Parameters
nominal_size_label = 50; //[25:110:1]
length_mm = 1500;        //[750:3000:10]
pipe_od = 50;            //[25:110:1]
pipe_wall = 1.8;         //[0.9:3.6:0.1]
fitting_length = 35;     //[18:70:1]
fitting_od_scale = 1.18; //[1.05:1.4:0.01]
fitting_wall_extra = 1.2;//[0.5:3:0.1]
overlap = 1;             //[0.5:2:0.1]

$fn = 128;

// Derived radii (clamped for robustness)
pipe_or = pipe_od/2;
pipe_ir = max(0.01, pipe_or - pipe_wall);

fitting_or = (pipe_od * fitting_od_scale)/2;
fitting_ir = max(0.01, pipe_ir + fitting_wall_extra);

// Ensure fitting inner radius never exceeds its outer radius
fitting_ir2 = min(fitting_ir, fitting_or - 0.2);

// Small epsilon to avoid coplanar faces in boolean ops
eps = 0.05;

module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: main pipe + socket (overlapped so it's one connected solid)
    union() {
      cylinder(h=length_mm, r=pipe_or, center=false);
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length, r=fitting_or, center=false);
    }

    // INNER VOID: through-bore + enlarged socket bore
    union() {
      // Through bore (slightly extended to guarantee clean subtraction)
      translate([0, 0, -eps])
        cylinder(h=length_mm + 2*eps, r=pipe_ir, center=false);

      // Socket bore (slightly extended and aligned with socket)
      translate([0, 0, length_mm - overlap - eps])
        cylinder(h=fitting_length + 2*eps, r=fitting_ir2, center=false);
    }
  }
}

ht_pipe();