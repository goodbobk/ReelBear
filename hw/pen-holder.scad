

e=0.02;
e2=e*2;

pen_neck_d1 = 8.5;
pen_neck_d2 = 8.8;
pen_neck_h = 8;
pen_tip_h_min = 5;
pen_tip_over = 3;
body_h=3;
body_d=80;
wall_w = 3;
fn=30;

hole_h = pen_tip_h_min + pen_neck_h - pen_tip_over;
echo(hole_h);
difference() {
    union() {
        cylinder(d = body_d, h = body_h, $fn = fn);
        cylinder(d = 2*wall_w + pen_neck_d2, h = hole_h, $fn = fn);
    }
    translate([0,0,-e]) {
        cylinder(d1 = pen_neck_d1, 
                 d2 = pen_neck_d2, 
                 h = hole_h + e2, $fn = fn);
        union() {
            for(a=[0:60:359]) rotate(a) {
                intersection() {
                    difference() {
                        cylinder( d = body_d - pen_neck_d1,
                                  h = body_h + e2);
                        cylinder( d = pen_neck_d1 + 2*wall_w,
                                  h = body_h + e2 );
                    }
                    linear_extrude(height = body_h + e2) {
                        polygon(points=[[0,0],
                                         [body_d, body_d * tan(10)],
                        [body_d, body_d * tan(60-10)]]);
                    }
                }
            }
        }
    }
    
}


