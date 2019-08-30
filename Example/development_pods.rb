#encoding: utf-8

require 'cocoapods'
require '/Users/wesley_chen/GitHub_Projcets/HelloProjects/HelloXcodeproj/02 - Ruby Helper/rubyscript_helper.rb'

# Tip: 
# Note: 重写pod的path属性, 但不影响git仓库的Podfile，因为本文件是被ignored
$development_pods = {
    'WCThemeManager' => '../',
}

puts "Test"

# dump_object(self)
# alias old_pod pod

def pod(*args)
  pod_name = args[0]
  path = $development_pods[pod_name]
  puts pod_name
  if path then
    puts "Using development pod `#{pod_name}`"
    self.pod pod_name, :path => path
  else
    puts 'asdfds'
    self.pod *args
  end
end