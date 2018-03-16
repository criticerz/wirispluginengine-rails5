module Wiris
	p "Loadin WirisPlugin..."
	if !defined?(Quizzesproxy)
		Dir[File.dirname(__FILE__) + '/src-generic/**/*.rb'].each {|file| require file}
		Dir[File.dirname(__FILE__) + '/src-generic/**/*/*.rb'].each {|file| require file}
	else
		require 'src-generic/RubyConfigurationUpdater.rb'
	end

	p "WirisPlugin loaded."
  
end
