# encoding: UTF-8
require 'sinatra'
require 'haml'
require 'mail'

set :haml, :format => :html5, :escape_html => true

configure :production do 
	before do 
		#redirect "http://www.sekura.nu#{request.path}", 301 if request.host != 'www.sekura.nu'
		#cache_control :public, :max_age => 24*3600 
		Mail.defaults do
			delivery_method :smtp, { 
				:address        => "smtp.sendgrid.net",
				:port           => "25",
				:authentication => :plain,
				:user_name      => ENV['SENDGRID_USERNAME'],
				:password       => ENV['SENDGRID_PASSWORD'],
				:domain         => ENV['SENDGRID_DOMAIN']
			}
		end
	end
end

configure :development do
	before do
		cache_control :no_store
		Mail.defaults do
			delivery_method :test
		end
	end
end

before do 
	content_type :html, :charset => 'utf-8'
	@title = "DMKS - Digitalt medlems kort system"
	@menu = [
		['/', 'DMKS'],
		['/funktioner', 'Funktioner'],
		['/anpassa', 'Anpassa'],
		['/testa', 'Testa'],
		['/faq', 'Frågor'],
		['/kontakt', 'Kontakt'],
	]
end

get '/' do
	last_modified File.mtime "./views/index.haml"
	haml :index
end

get '/:page' do |page|
	pass unless File.exists? "./views/#{page}.haml"
	last_modified File.mtime "./views/#{page}.haml"
	@title = page.capitalize.gsub(/_/, ' ') + " - " + @title
	haml page.to_sym
end

not_found do
	haml :not_found
end
