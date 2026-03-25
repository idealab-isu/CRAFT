// Heatshrink sleeving (tubing) with an internal core that is PHYSICALLY FUSED
// to the sleeve via small end-plugs (no floating/disconnected rod).

// Parameters
length = 15;                 //[8:30:1]
inner_diameter = 3;          //[1.5:6:0.1]
wall_thickness = 0.6;        //[0.3:1.2:0.05]
center = true;               //[0:1:1]
forced_id = 0;               //[0:10:0.1]
eps_overlap = 0.8;           //[0.5:2:0.1]

// Rendering quality
$fn = 96;

// Derived dimensions
id = (forced_id > 0 ? forced_id : inner_diameter);
ir = id/2;
or = ir + wall_thickness;

// Core (blue rod) size
core_r = max(0.05, min(ir * 0.12, 0.25));

// Connection geometry: small "end plugs" that overlap the sleeve wall
// so the core is merged to the tubing (guaranteed intersection).
plug_len = 1.2;                         // 1–2mm recommended
plug_r   = min(or, ir + wall_thickness); // reach into wall region
z_end    = (center ? length/2 : length); // top end z of sleeve

// Tubing (hollow sleeve)
module tubing() {
  color([0.85, 0.85, 0.8])  // off-white heatshrink
  difference() {
    cylinder(r=or, h=length, center=center);
    cylinder(r=ir, h=length + 2*eps_overlap, center=center);
  }
}

// Internal core + fused end-plugs (single connected solid with sleeve)
module internal_core_fused() {
  color([0.1, 0.3, 0.9]) {
    union() {
      // Central rod inside the bore (kept small)
      cylinder(r=core_r, h=length + 2*eps_overlap, center=center);

      // Top plug: overlaps sleeve wall by extending radius into [ir, or]
      translate([0, 0,  z_end - plug_len/2])  // inside the sleeve end
        cylinder(r=plug_r, h=plug_len, center=true);

      // Bottom plug: same, at the other end
      translate([0, 0, -z_end + plug_len/2])
        cylinder(r=plug_r, h=plug_len, center=true);
    }
  }
}

// Assembly: one connected solid
union() {
  tubing();
  internal_core_fused();
}