IcfpProxy::Application.routes.draw do

  root to: redirect('https://github.com/leastfixed/icfp2013-dividedmind/tree/proxy')
  
  get '/status' => 'status#show'
  get '/myproblems' => 'problem#index'
  
  match '*path' => 'upstream#proxy', via: [:get, :post]

end
