(ns schema
    (:use clojure.test))

(defn- schema-type [schema data]
    (cond
        (and (vector? schema) (vector? (first schema))) :nested-vector
        (vector? schema) :vector
        (map? schema) :map
        (keyword? schema) :keyword
        :default (type schema)))

(defmulti apply-schema schema-type)

(defmethod apply-schema :keyword [schema data]
    {schema (data schema)})

(defmethod apply-schema :map [schema data]
    (let [[[k v]] (seq schema)]
        {k (apply-schema v (data k))}))

(defmethod apply-schema :vector [schema data]
    (apply merge (map #(apply-schema % data) schema)))

(defmethod apply-schema :nested-vector [schema data]
    (let [[schema] schema]
        (map #(apply-schema schema %) data)))

(with-test
    (def test-data {
        :aaa "22"
        :aaaa "New 22"
        :bbb "434"
        :ccc {:ddd "abc" :ddddd "Not needed" :ggg "Needed" :hard_to_believe []}
        :zzz [ {:hhh  126 :hhhh "Don't need" :kkk  "Existing key"} {:hhh  "DoobyDo" :kkk  "Needed" :mmm  "Existing key"} ]})

    (def test-schema [
        :aaa
        :bbb
        :ooo
        {:ccc [:ddd :ggg]}
        {:zzz [[:hhh :kkk :mmm]]}])
    (is (= (apply-schema :a {:a "Value"}) {:a "Value"}))
    (is (= (apply-schema [:a] {:a "Value"}) {:a "Value"}))
    (is (= (apply-schema {:a [:b :c]} {:a {:b 1 :c 2}}) {:a {:b 1 :c 2}}))
    (is (= (apply-schema {:a [[:b :c]]} {:a [{:b 1 :c 2} {:b 1 :c 2}]}) {:a [{:b 1 :c 2} {:b 1 :c 2}]}))
    (is (= (apply-schema test-schema test-data) { :zzz [{:mmm nil, :kkk "Existing key", :hhh 126} {:mmm "Existing key", :kkk "Needed", :hhh "DoobyDo"}]
        :ccc {:ggg "Needed", :ddd "abc"}
        :ooo nil
        :bbb "434"
        :aaa "22"})))
