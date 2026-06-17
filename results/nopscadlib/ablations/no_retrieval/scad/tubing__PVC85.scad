// PVC aquarium tubing (hollow flexible tube)
// Fix: avoid blank renders by using a sane default length (mm-scale),
// robust radii, connected/fused texture rings, and non-degenerate bevel cuts.

$fn = 96;

// Parameters (mm)
tube_length = 120;  //[50:500:5]     // was 1000; too large for many preview setups
tube_od     = 6;    //[3:12:0.1]
tube_id     = 4;    //[2:10:0.1]

// Safety / derived
epsilon  = 0.05;    //[0.01:0.2:0.01]
wall_min = 0.25;

od_r = max(tube_od/2, wall_min);
id_r = min(max(tube_id/2, 0), od_r - wall_min);

// End bevel (small, realistic)
chamfer_length = 1.2; //[0.5:3:0.1]
chamfer_radial = 0.6; //[0.2:1.5:0.1]

ch_len = min(chamfer_length, tube_length/4);
ch_rad = min(chamfer_radial, max(0, od_r - id_r - wall_min/2));

// Surface texture (subtle rings)
texture_depth          = 0.08; //[0.02:0.2:0.01]
texture_pitch          = 6;    //[3:15:0.5]
texture_ring_thickness = 0.6;  //[0.3:2:0.1]

ring_t = min(texture_ring_thickness, texture_pitch*0.9);
ring_r = od_r + texture_depth;

// Base tube (outer - inner)
module tube_shell() {
  difference() {
    cylinder(h=tube_length, r=od_r, center=true);
    cylinder(h=tube_length + 2*epsilon, r=id_r, center=true);
  }
}

// Bevel cut tool (removes a small wedge at each end; avoids degeneracy)
module end_bevel_cut(zsign=1) {
  // Ensure r2 stays > 0 and below r1
  r2 = max(id_r + wall_min, od_r - ch_rad);
  translate([0, 0, zsign*(tube_length/2 - ch_len/2)])
    cylinder(h=ch_len + 2*epsilon,
             r1=od_r + epsilon,
             r2=r2,
             center=true);
}

// Texture rings along length, clipped to avoid protruding past ends
module surface_texture() {
  safe_span = max(0, tube_length - 2*(ch_len + ring_t/2));
  n = max(0, floor(safe_span / texture_pitch));
  if (n > 0)
    for (i = [0:n-1]) {
      z0 = -safe_span/2 + (i + 0.5)*texture_pitch;
      translate([0, 0, z0])
        // Solid ring that intersects the tube OD so union becomes one connected solid
        cylinder(h=ring_t, r=ring_r, center=true);
    }
}

// Final model: one connected solid (tube + fused rings), then bevel cuts
module complete_model() {
  difference() {
    union() {
      tube_shell();
      surface_texture();
    }
    end_bevel_cut(+1);
    end_bevel_cut(-1);
  }
}

color([0.85, 0.85, 0.8])
complete_model();