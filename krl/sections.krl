ruleset sections {
  rule addSection {
    select when section init
    pre {
      a = event:attrs{"line"}.split("\t")
.klog("a")
      id = a.head()
.klog("id")
      q = a[1]
.klog("q")
    }
  }
}
