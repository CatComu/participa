Rails.application.routes.draw do

  get '', to: redirect("/#{I18n.locale}")

  if Features.redsys_collaborations?
    # redsys MerchantURL 
    post '/orders/callback/redsys', to: 'orders#callback_redsys', as: 'orders_callback_redsys'
  end

  if Features.notifications?
    namespace :api do
      scope :v1 do 
        scope :gcm do 
          post 'registrars', to: 'v1#gcm_registrate'
          delete 'registrars/:registrar_id', to: 'v1#gcm_unregister'
        end
      end
    end
  end

  scope "/(:locale)", locale: /#{I18n.available_locales.join("|")}/ do 

    if Features.openid?
      get '/openid/discover', to: 'open_id#discover', as: "open_id_discover"
      get '/openid', to: 'open_id#index', as: "open_id_index"
      post '/openid', to: 'open_id#create', as: "open_id_create"
      get '/user/:id', to: 'open_id#user', as: "open_id_user"
      get '/user/xrds', to: 'open_id#xrds', as: "open_id_xrds"
    end

    get '/countvotes/:election_id', to: 'page#count_votes', as: 'page_count_votes'

    get '/privacy-policy', to: 'page#privacy_policy', as: 'page_privacy_policy'
    get '/inscription-policy', to: 'page#inscription_policy', as: 'page_inscription_policy'
    get '/legal', to: 'page#legal', as: 'page_legal'
    get '/cookie-policy', to: 'page#cookie_policy', as: 'page_cookie_policy'
    get '/preguntas-frecuentes', to: 'page#faq', as: 'faq'

    if Features.participation_teams?
      get '/equipos-de-accion-participativa', to: 'participation_teams#index', as: 'participation_teams'
      put '/equipos-de-accion-participativa/entrar(/:team_id)', to: 'participation_teams#join', as: 'participation_teams_join'
      put '/equipos-de-accion-participativa/dejar(/:team_id)', to: 'participation_teams#leave', as: 'participation_teams_leave'
      patch '/equipos-de-accion-participativa/actualizar', to: 'participation_teams#update_user', as: 'participation_teams_update_user'
    end

    if Features.proposals?
      get '/propuestas', to: 'proposals#index', as: 'proposals'
      get '/propuestas/info', to: 'proposals#info', as: 'proposals_info'
      get '/propuestas/:id', to: 'proposals#show', as: 'proposal'
      post '/apoyar/:proposal_id', to: 'supports#create', as: 'proposal_supports'
    end

    get :notices, to: 'notice#index', as: 'notices'

    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    get '/vote/create_token/:election_id', to: 'vote#create_token', as: :create_token_vote
    get '/vote/check/:election_id', to: 'vote#check', as: :check_vote
    
    get '/vote/sms_check/:election_id', to: 'vote#sms_check', as: :sms_check_vote
    get '/vote/send_sms_check/:election_id', to: 'vote#send_sms_check', as: :send_sms_check_vote
    
    devise_for :users, controllers: { registrations: 'registrations' }

    if Features.microcredits?
      get '/microcreditos', to: 'microcredit#index', as: 'microcredit'
      get '/microcréditos', to: redirect('/microcreditos')
      get '/microcreditos/provincias', to: 'microcredit#provinces'
      get '/microcreditos/municipios', to: 'microcredit#towns'
      get '/microcreditos/informacion', to: 'microcredit#info', as: 'microcredits_info'
      get '/microcreditos/:id', to: 'microcredit#new_loan', as: :new_microcredit_loan
      get '/microcreditos/:id/login', to: 'microcredit#login', as: :microcredit_login
      post '/microcreditos/:id', to: 'microcredit#create_loan', as: :create_microcredit_loan
      get '/microcreditos/:id/renovar(/:loan_id/:hash)', to: 'microcredit#loans_renewal', as: :loans_renewal_microcredit_loan
      post '/microcreditos/:id/renovar/:loan_id/:hash', to: 'microcredit#loans_renew', as: :loans_renew_microcredit_loan
    end

    authenticate :user do
      scope :verificaciodigital do
        get :pas1, to: 'sms_validator#step1', as: 'sms_validator_step1'
        get :pas2, to: 'sms_validator#step2', as: 'sms_validator_step2'
        get :pas3, to: 'sms_validator#step3', as: 'sms_validator_step3'
        post :documents, to: 'sms_validator#documents', as: 'sms_validator_documents'
        post :phone, to: 'sms_validator#phone', as: 'sms_validator_phone'
        post :valid, to: 'sms_validator#valid', as: 'sms_validator_valid'
      end
      
      if Features.collaborations?
        scope :colabora do
          delete 'baja', to: 'collaborations#destroy', as: 'destroy_collaboration'
          get 'ver', to: 'collaborations#edit', as: 'edit_collaboration'
          get '', to: 'collaborations#new', as: 'new_collaboration'
          get 'confirmar', to: 'collaborations#confirm', as: 'confirm_collaboration'
          post 'crear', to: 'collaborations#create', as: 'create_collaboration'
          post 'modificar', to: 'collaborations#modify', as: 'modify_collaboration'
          get 'OK', to: 'collaborations#OK', as: 'ok_collaboration'
          get 'KO', to: 'collaborations#KO', as: 'ko_collaboration'
        end
      end
    end
    
    if Features.blog?
      scope :brujula do
        get '', to: 'blog#index', as: 'blog'
        get ':id', to: 'blog#post', as: 'post'
        get 'categoria/:id', to: 'blog#category', as: 'category'
      end
    end
    
    # http://stackoverflow.com/a/8884605/319241 
    devise_scope :user do
      get '/registrations/regions/provinces', to: 'registrations#regions_provinces'
      get '/registrations/regions/municipies', to: 'registrations#regions_municipies'
      get '/registrations/vote/municipies', to: 'registrations#vote_municipies'

      authenticated :user do
        root 'tools#index', as: :authenticated_root
      end
      unauthenticated do
        root 'devise/sessions#new', as: :root
      end
    end
    
    scope '/verificadores' do 
      get '/', to: 'verification#step1', as: :verification_step1
      get '/nueva', to: 'verification#step2', as: :verification_step2
      get '/confirmar', to: 'verification#step3', as: :verification_step3
      post '/search', to: 'verification#search', as: :verification_search
      post '/confirm', to: 'verification#confirm', as: :verification_confirm
      get '/ok', to: 'verification#result_ok', as: :verification_result_ok
      get '/ko', to: 'verification#result_ko', as: :verification_result_ko
    end

    scope '/verificaciones' do 
      get '/', to: 'verification#show', as: :verification_show
    end

    %w(404 422 500).each do |code|
      get code, to: 'errors#show', code: code
    end
  end
  # /admin
  ActiveAdmin.routes(self)

  constraints CanAccessResque.new do
    mount Resque::Server.new, at: '/admin/resque', as: :resque
  end

end
