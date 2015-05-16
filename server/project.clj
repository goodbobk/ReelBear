(defproject server "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [clj-serial "2.0.3-SNAPSHOT"]]
  :main ^:skip-aot server.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
