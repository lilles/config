set auto-solib-add off

define blinksym
  break main
  commands 1
    silent
    sharedlibrary blink
    sharedlibrary libbase.so
    continue
  end
end

