::  memory-action: mark for memory actions
::
/-  *memory
/+  mj=memory-json
|_  act=action
++  grab
  |%
  ++  noun  action
  ++  json  parse-action:mj
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
