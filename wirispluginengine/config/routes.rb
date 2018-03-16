Wirispluginengine::Engine.routes.draw do
	get 'integration/:script' => 'application#integration'
	post  'integration/:script' => 'application#integration'
end
