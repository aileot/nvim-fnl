(lambda contains? [xs ?a]
  "Check if `?a` is in `xs`."
  (accumulate [eq? false ;
               _ x (ipairs xs) ;
               &until eq?]
    (= ?a x)))

(fn nil? [x]
  "Check if `x` is nil."
  (= x nil))

(fn boolean? [x]
  "Check if `x` is boolean."
  (= (type x) :boolean))

(fn true? [x]
  (= (type x) true))

(fn false? [x]
  (= (type x) false))

(fn str? [x]
  "Check if `x` is string."
  (= (type x) :string))

(fn tbl? [x]
  "Check if `x` is table."
  (= (type x) :table))

(fn seq? [x]
  "Check if `x` is sequence."
  (and (tbl? x) (not= nil (. x 1))))

(fn empty? [tbl]
  "Check if `tbl` is empty."
  (assert (tbl? tbl)
          (-> "expected table, got %s: %s" (: :format (type tbl) (view tbl))))
  (not (next tbl)))

(fn fn? [x]
  "(Runtime time) Check if `x` is function."
  (= (type x) :function))

(fn function? [x]
  "(Compile time) Check if `x` is anonymous function defined by builtin
  constructor.
  @param x any
  @return boolean"
  (and (list? x) ;
       ;; Note: quote is unavailable because this file is also loaded at
       ;; runtime.
       (contains? [:fn :hashfn :lambda :partial] (. x 1 1))))

(fn num? [x]
  "Check if `x` is number."
  (= (type x) :number))

(fn even? [x]
  "Check if `x` is even number."
  (and (num? x) (= 0 (% x 2))))

(fn odd? [x]
  "Check if `x` is odd number."
  (and (num? x) (= 1 (% x 2))))

(lambda any? [pred xs]
  (accumulate [any? false ;
               _ x (ipairs xs) ;
               &until any?]
    (pred x)))

(lambda all? [pred xs]
  (accumulate [all? true ;
               _ x (ipairs xs) ;
               &until (= all? false)]
    (pred x)))

{: any?
 : all?
 : contains?
 : empty?
 : nil?
 : boolean?
 : true?
 : false?
 : str?
 : tbl?
 : seq?
 : num?
 : fn?
 : function?
 : odd?
 : even?}
