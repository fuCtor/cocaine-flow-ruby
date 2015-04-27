module API 
	Dir[File.join(APP_ROOT, 'app', 'api', '*.rb')].each do |file|
		autoload File.basename(file, '.rb').classify.to_sym , file
	end	
end
