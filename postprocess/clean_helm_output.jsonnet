local com = import 'lib/commodore.libjsonnet';

local dir = std.extVar('output_path');

local stem(elem) =
  local elems = std.split(elem, '.');
  std.join('.', elems[:std.length(elems) - 1]);

local filepath(file) = dir + '/' + file;

local fixup(file) =
  local contents = com.yaml_load_all(filepath(file));
  std.filter(function(it) it != null, contents);

{
  [stem(file)]: fixup(file)
  for file in com.list_dir(dir)
}
