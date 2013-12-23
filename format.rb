#!/usr/bin/env ruby

require 'pp'

while s = gets
  begin
    pp eval(s)
  rescue Exception => exc
    print s
  end
end
