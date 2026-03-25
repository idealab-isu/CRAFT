// Dimension-calibrated (target: 0.05 x 0.10 x 0.04 mm)
scale([0.842980, 0.980803, 0.878083])
{
// Low-poly armored vehicle / tank-like platform
// Fixed: non-empty geometry, connected parts, clearly cylindrical end pods,
// distinct faceted turret, visible barrel, fins connected.
// Note: A true 0.0mm thickness bounding box is not physically meaningful in 3D;
// this model uses a small but nonzero Z thickness while keeping overall size ~0.1mm.

$fn = 18;

// Target overall envelope (approx)
L = 0.1;
W = 0.1;
H = 0.04;

// Fit/connection
overlap = 0.001;

// Main hull (elongated along X)
hull_L = 0.072;
hull_W = 0.034;
hull_H = 0.018;

// Cylindrical end pods
pod_R   = 0.017;
pod_len = 0.016;

// Turret / roof (faceted)
turret_L = 0.040;
turret_W = 0.026;
turret_H = 0.016;

// Barrel (protruding from +X end)
barrel_R = 0.004;
barrel_L = 0.020;

// Mid fins / winglets
fin_L = 0.012;
fin_W = 0.010;
fin_H = 0.004;

// Small top greebles
greeble_R = 0.0012;
greeble_H = 0.0015;

// --- Helpers ---
module hull_main() {
  cube([hull_L, hull_W, hull_H], center=true);
}

module end_pod(sign=1) {
  // Centered on hull mid-height so it reads as cylindrical in ortho views
  translate([sign*(hull_L/2 + pod_len/2 - overlap), 0, 0])
    rotate([0, 90, 0])
      cylinder(r=pod_R, h=pod_len, center=true);
}

module turret_roof() {
  // Place turret on top of hull with overlap for connectivity
  zc = hull_H/2 + turret_H/2 - overlap;

  translate([0, 0, zc])
    linear_extrude(height=turret_H, center=true)
      polygon(points=[
        [-turret_L/2, -turret_W/2],
        [ turret_L/2, -turret_W/2],
        [ turret_L/2 - turret_L*0.22, 0],
        [ turret_L/2,  turret_W/2],
        [-turret_L/2,  turret_W/2],
        [-turret_L/2 + turret_L*0.22, 0]
      ]);
}

module barrel() {
  // Attach to front pod/hull end (+X) and protrude outward
  // Inner end slightly inside the front pod for a solid connection.
  x_center = (hull_L/2 + pod_len - overlap) + barrel_L/2 - overlap;
  z_center = 0; // centered vertically for visibility in side views

  translate([x_center, 0, z_center])
    rotate([0, 90, 0])
      cylinder(r=barrel_R, h=barrel_L, center=true);
}

module mid_fin(side=1) {
  // Side fins connected to hull sides
  y_center = side*(hull_W/2 + fin_W/2 - overlap);
  z_center = 0;

  translate([0, y_center, z_center])
    cube([fin_L, fin_W, fin_H], center=true);
}

module surface_greebles() {
  // Small cylinders on top of hull (connected)
  zc = hull_H/2 + greeble_H/2 - overlap;
  translate([-hull_L*0.18,  hull_W*0.18, zc])
    cylinder(r=greeble_R, h=greeble_H, center=true);
  translate([ hull_L*0.18, -hull_W*0.18, zc])
    cylinder(r=greeble_R, h=greeble_H, center=true);
}

// --- Final model (single connected solid) ---
union() {
  hull_main();
  end_pod( 1);
  end_pod(-1);
  turret_roof();
  barrel();
  mid_fin( 1);
  mid_fin(-1);
  surface_greebles();
}
}
