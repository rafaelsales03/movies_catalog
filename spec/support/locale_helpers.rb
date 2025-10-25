module LocaleHelpers
  def default_url_options
    { locale: I18n.locale }
  end
end
