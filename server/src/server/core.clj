(ns server.core
  (:require [clojure.string :as str]
            [serial.core :as serial]
            [serial.util :as sutil])
  (:gen-class))

;;(def port (serial/open "cu.usbmodem1105671"))

(def TAU (* 2 (Math/PI)))

(defn pyth [x y]
  (Math/sqrt (+ (* x x) (* y y))))

(def steps-per-mm (/ 300.0 100.0))
(defn mm [mm] (* steps-per-mm mm))
(defn steps->mm [steps] (/ steps steps-per-mm))

(def motor-d (mm 1550))
(def x-max (mm 1000))
(def y-max (mm 500))

(def orig-lx (mm 430))
(def orig-rx (- motor-d orig-lx))
(def orig-y (mm 255))

(def orig-lr (pyth orig-lx orig-y ))
(def orig-rr (pyth orig-rx orig-y))

(defn xy->motors 
  ([[x y]]
   (xy->motors x y))
  ([x y]
   (let [lx (+ x orig-lx)
         y (+ y orig-y)
         left (pyth lx y)

         rx (- orig-rx x)
         right (pyth rx y)
         ]
     [(Math/round (- left orig-lr)) (Math/round (- orig-rr right))]))) ;; right motor needs reverse sense


(defn pen
  [port mode]
  (do-cmd port (if mode "D" "U")))

(defn move
  ([port x y] 
   (move port [[x y]]))
  ([port coords]
   (let [cmd (->> coords
                 (map xy->motors)
                 flatten
                 (str/join ",")
                 (str "M"))]
     (do-cmd port cmd))))

(defn do-cmd
  [port cmd]
  (serial/write port (map (comp byte int) (str cmd "\r"))))

(defn deg->rad [deg]
  (/ deg (/ 360 TAU)))

(defn circle
  ([port x y r steps]
   (circle x y r steps 0 TAU))
  ([port x y r steps a0 a1]
   (let [points (->> (range 0 (inc steps))
                     (map (fn [i] (* i (/ TAU steps))))
                     (filter #(and (>= % a0) (<= % a1)))
                     (map #(vector (+ x (* r (Math/cos %1))) (+ y (* r (Math/sin %1))))))]
     (apply move port (first points))
     (pen port true)
     (move port points))))

(defn gooddata
  [port x y r]

  (pen port false)

  (let [r-inner (/ r 3)
        cos-sin (fn [a r] [(+ x (* r (Math/cos a)))
                           (+ y (* r (Math/sin a)))])]
    (doseq [a (range 0 316 45)
            :let [a (deg->rad a)
                  inner (cos-sin a r-inner)
                  outer (cos-sin a r)]]
      (move port [inner])
      (pen port true)
      (move port [outer])
      (pen port false))


    ;; outer circle
    (circle port x y r 48 0 (deg->rad 315))
    (pen port false)

    ;; inner circle
    (circle port x y r-inner 48 0 (deg->rad 315))
    (pen port false)

    ;; arrow
    (circle port (+ x r) y r 48 (deg->rad 90) (deg->rad 180))
    (move port (+ x r) y)
    (move port (+ x r) (+ y r))
    (pen port false)
    (move port 0 0)))

(defn chart
  [port x0 y0 ps]
  (pen port false)
  (let [xsize (apply max (map first ps))
        ysize (apply max (map second ps))
        y0 (+ y0 ysize)
        tps (map (fn [[x y]] [(+ x0 x) (- y0 y)]) ps)]
    
    (move port x0 y0)
    (pen port true)
    (move port (- x0 60) y0)
    (move port x0 y0)
    (move port x0 (+ y0 60))
    (move port x0 y0)

    (doseq [x (map first tps)]
      (move port x y0)
      (move port x (+ 20 y0))
      (move port x y0))
    (pen port false)

    (move port x0 y0)
    (pen port true)
    (doseq [i (range 0 8)
            :let [y (- y0 (* i (/ ysize 8)))]]
      (move port x0 y)
      (move port (- x0 20) y)
      (move port x0 y))
    (pen port false)
    (move port x0 y0)
    (pen port true)
    (move port tps)
    (pen port false)
    (move port 0 0)))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!"))
