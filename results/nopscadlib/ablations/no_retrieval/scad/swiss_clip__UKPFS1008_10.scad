// Swiss clip (binder-clip style) - ONE connected solid, recognizable geometry
$fn = 72;

// ---------------- Parameters ----------------
clip_W = 32; //[16:64:1]
clip_D = 22; //[11:44:1]
clip_H = 18; //[9:36:1]

sheet_t = 0.7; //[0.3:1.2:0.1]
jaw_gap = 2.6; //[1.25:5:0.1]
lip_len = 3.2; //[1.5:6:0.1]

hinge_loop_r = 2.2; //[1.1:4.4:0.1]
hinge_loop_L = 10; //[5:20:1]
hinge_offset_from_top = 3.8; //[2:8:0.1]

wire_d = 1.6; //[0.8:3.2:0.1]
handle_leg_L = 18; //[9:36:1]
pivot_clearance = 0.35; //[0.1:0.8:0.05]

overlap = 1.4; //[0.5:2:0.1]   // overlap for guaranteed solid connections
edge_r = 1.2; //[0.4:2.4:0.1]

// ---------------- Derived ----------------
eps = 0.01;
jaw_gap_eff = max(jaw_gap, sheet_t*1.2);
lip_len_eff = max(lip_len, sheet_t*2);
wire_r = max(wire_d/2, 0.25);

// Keep hinge hole smaller than wire so the model stays ONE connected solid
hinge_hole_r = max(wire_r - 0.25, 0.15);

// ---------------- Helpers ----------------
module rounded_box(size=[10,10,10], r=1, center=true){
  r2 = min(r, min(size[0], min(size[1], size[2]))/2 - eps);
  if (r2 <= 0)
    cube(size, center=center);
  else
    minkowski(){
      cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=center);
      sphere(r=r2);
    }
}

module capsule_x(len=10, r=1){
  hull(){
    translate([-len/2,0,0]) sphere(r=r);
    translate([ len/2,0,0]) sphere(r=r);
  }
}

// ---------------- Clip body (recognizable binder-clip shell) ----------------
module clip_body(){
  // Binder clip is a folded spring sheet: represent as a U-shell with a mouth opening.
  difference(){
    // Outer
    rounded_box([clip_W, clip_D, clip_H], r=min(edge_r, 1.6), center=true);

    // Inner cavity (leave walls)
    rounded_box([clip_W-2*sheet_t, clip_D-2*sheet_t, clip_H-2*sheet_t],
                r=max(min(edge_r,1.6)-sheet_t, 0.25), center=true);

    // Mouth opening from +Y side (creates jaws)
    // Recalculated so the cut fully reaches the outside and leaves a clear "clip mouth"
    mouth_center_y = clip_D/2 - jaw_gap_eff/2 + overlap;
    translate([0, mouth_center_y, 0])
      cube([clip_W + 2*overlap, jaw_gap_eff, clip_H + 2*overlap], center=true);

    // Undercut near bottom front to suggest curved clamp profile
    undercut_y = clip_D/2 - (jaw_gap_eff + lip_len_eff)*0.65;
    translate([0, undercut_y, -clip_H/2 + clip_H*0.35])
      rotate([0,90,0])
        cylinder(r=clip_H*0.35, h=clip_W + 2*overlap, center=true);
  }

  // Inner jaw pads (clamping faces) near bottom, front/back
  translate([0,  clip_D/2 - lip_len_eff/2 - sheet_t/2, -clip_H/2 + sheet_t/2])
    cube([clip_W - 2*sheet_t, lip_len_eff, sheet_t], center=true);

  translate([0, -clip_D/2 + lip_len_eff/2 + sheet_t/2, -clip_H/2 + sheet_t/2])
    cube([clip_W - 2*sheet_t, lip_len_eff, sheet_t], center=true);

  // Back spine thickening (binder clips have a stronger back)
  spine_t = sheet_t*2.2;
  translate([0, -clip_D/2 + spine_t/2 - overlap, 0])
    cube([clip_W - 2*sheet_t, spine_t + 2*overlap, clip_H - 2*sheet_t], center=true);
}

// ---------------- Hinge ears (connected, binder-clip style) ----------------
module hinge_ear(side=1){
  // Place ears so they overlap into the body by 'overlap' to guarantee connectivity.
  // Ear cylinder axis along Y.
  x_ear = side*(clip_W/2 + hinge_loop_r - overlap);
  z_ear = clip_H/2 - hinge_offset_from_top;
  y_ear = 0;

  difference(){
    union(){
      // Main ear cylinder
      translate([x_ear, y_ear, z_ear])
        rotate([90,0,0])
          cylinder(r=hinge_loop_r, h=hinge_loop_L, center=true);

      // Blend boss into body (explicit overlap into body)
      boss_w = hinge_loop_r*1.9;
      boss_h = hinge_loop_r*1.9;

      // Bridge from inside body face to ear center (guaranteed intersection)
      x0 = side*(clip_W/2 - overlap); // inside body by overlap
      x1 = x_ear;                    // ear center
      translate([(x0+x1)/2, 0, z_ear])
        hull(){
          translate([x0-(x0+x1)/2, 0, 0]) cube([overlap*2, boss_w, boss_h], center=true);
          translate([x1-(x0+x1)/2, 0, 0]) cube([overlap*2, boss_w, boss_h], center=true);
        }
    }

    // Small hole (kept small so ear remains a single solid mass overall)
    translate([x_ear, y_ear, z_ear])
      rotate([90,0,0])
        cylinder(r=hinge_hole_r, h=hinge_loop_L + 2*overlap, center=true);
  }
}

// ---------------- Wire handles (recognizable binder-clip arms) ----------------
module handle(side=1){
  // Build as a single solid "wire" that intersects the ear (connected).
  x_ear = side*(clip_W/2 + hinge_loop_r - overlap);
  z_ear = clip_H/2 - hinge_offset_from_top;

  // Ensure the legs pass through the ear thickness and also overlap slightly into the body region.
  y_out = handle_leg_L;
  y_in  = hinge_loop_L/2 + overlap; // passes through ear

  // Separation between the two legs in Z (kept within ear diameter)
  z_sep = min(hinge_loop_r*1.2, max(hinge_loop_r*0.9, wire_r*2.2));

  // Crossbar length along X (outside the ear), but still intersects the ear/bridge region
  cross_L = max(hinge_loop_r*2.6, wire_d*4.5);

  union(){
    // Upper leg (Y axis)
    translate([x_ear, (y_out - y_in)/2, z_ear + z_sep/2])
      rotate([90,0,0])
        cylinder(r=wire_r, h=(y_out + y_in), center=true);

    // Lower leg (Y axis)
    translate([x_ear, (y_out - y_in)/2, z_ear - z_sep/2])
      rotate([90,0,0])
        cylinder(r=wire_r, h=(y_out + y_in), center=true);

    // Far crossbar (X axis) at outward end; overlaps into legs by 'overlap'
    translate([x_ear, y_out - overlap, z_ear])
      rotate([0,90,0])
        cylinder(r=wire_r, h=cross_L, center=true);

    // Small flattened tip at the outer end (still connected)
    tip_t = wire_d*0.9;
    tip_w = wire_d*2.4;
    translate([x_ear + side*(cross_L/2 - tip_t/2), y_out - overlap, z_ear])
      cube([tip_t + overlap, tip_w, tip_w], center=true);

    // Inner keeper nub near ear (suggests bent wire detail) - ensure it intersects ear/bridge
    nub_r = wire_r*1.15;
    translate([x_ear, -y_in/2 + overlap, z_ear])
      rotate([0,90,0])
        capsule_x(len=wire_d*2.2 + overlap, r=nub_r);
  }
}

// ---------------- Subtle top grip ridge (connected) ----------------
module surface_features(){
  ridge_t = sheet_t*0.9;
  ridge_w = clip_W - 2*sheet_t;
  ridge_d = clip_D*0.35;

  // Ensure ridge intersects the top surface (not floating)
  translate([0, 0, clip_H/2 - ridge_t/2 - overlap*0.25])
    rounded_box([ridge_w, ridge_d, ridge_t + overlap], r=min(edge_r*0.6, ridge_t/2), center=true);
}

// ---------------- Final model (ONE connected solid) ----------------
union(){
  clip_body();
  hinge_ear(-1);
  hinge_ear( 1);
  handle(-1);
  handle( 1);
  surface_features();
}