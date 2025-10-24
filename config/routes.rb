# config/routes.rb
Rails.application.routes.draw do
  root "movies#index"

  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do
    get "/", to: "movies#index", as: :locale_root

    devise_for :users

    resources :movies do
      resources :comments, only: [ :create ]
    end
    resources :categories
  end

  get "", to: redirect("/#{I18n.default_locale}", status: 302), constraints: { locale: nil }

  get "*path", to: redirect { |params, request|
    path = params[:path]
    is_internal_path = path.match?(%r{\A/?(rails/active_storage|assets|cable|up\z)})

    if is_internal_path
       nil
    else
      "/#{I18n.default_locale}/#{path.gsub(%r{\A/}, '')}"
    end
  }, constraints: lambda { |req|
    path_segments = req.path.split("/").reject(&:empty?)
    valid_locale_prefix = path_segments.first && I18n.available_locales.map(&:to_s).include?(path_segments.first)
    is_internal_path = req.path.match?(%r{\A/(rails/active_storage|assets|cable|up\z)})

    !valid_locale_prefix && !is_internal_path && path_segments.any?
  }
end
