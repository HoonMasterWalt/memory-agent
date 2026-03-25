::  memory: persistent memory types
::
|%
+$  id  @uv
::
+$  entry
  $:  =id
      created=@da
      updated=@da
      tag=@tas
      key=(unit @t)
      content=@t
  ==
::
+$  action
  $%  [%put tag=@tas key=(unit @t) content=@t]
      [%del =id]
      [%del-key tag=@tas key=@t]
      [%wipe tag=@tas]
      [%import entries=(list [tag=@tas key=(unit @t) content=@t])]
  ==
::
+$  update
  $%  [%entry =entry]
      [%entries entries=(list entry)]
      [%tags tags=(set @tas)]
      [%del-entry =id]
  ==
--
