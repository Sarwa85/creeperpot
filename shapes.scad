module rounded_cube(size, r, center = false) {
    s = is_list(size) ? size : [size, size, size];
    shift = center ? [-s[0]/2, -s[1]/2, -s[2]/2] : [0, 0, 0];

    translate(shift) {
        hull() {
            translate([r, r, r]) sphere(r = r);
            translate([s[0] - r, r, r]) sphere(r = r);
            translate([r, s[1] - r, r]) sphere(r = r);
            translate([s[0] - r, s[1] - r, r]) sphere(r = r);

            translate([r, r, s[2] - r]) sphere(r = r);
            translate([s[0] - r, r, s[2] - r]) sphere(r = r);
            translate([r, s[1] - r, s[2] - r]) sphere(r = r);
            translate([s[0] - r, s[1] - r, s[2] - r]) sphere(r = r);
        }
    }
}