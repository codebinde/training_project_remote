defmodule OnlineMockCookidoo.Router do
  @moduledoc false

  use OnlineMockCookidoo, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {OnlineMockCookidoo.Layouts, :root}
    plug :merge_assigns, body_attributes: []
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :json_api do
    plug :accepts, ["json"]
  end

  pipeline :json_hal_api do
    plug :accepts, ["json-hal"]
  end

  pipeline :root_home_document_device do
    plug :accepts, ["rhd-device"]
  end

  pipeline :verify_access_token do
    plug Plug.AccessTokenVerifier
  end

  pipeline :protection do
    plug :reject_client_cert
    plug Plug.CheckCookieEnforcement, endpoint: OnlineMockCookidoo.Endpoint
  end

  scope "/.well-known", OnlineMockCookidoo do
    pipe_through [:protection, :root_home_document_device]

    get "/device-home/:country", DeviceHomeController, :show
    get "/home/:country", HomeController, :show
  end

  scope "/notifications", OnlineMockCookidoo.Notifications, as: :notifications do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/notifications", OnlineMockCookidoo.Notifications, as: :notifications do
    pipe_through [:protection, :verify_access_token]

    resources "/:lang", NotificationController, only: [:index, :create]
  end

  scope "/notifications", OnlineMockCookidoo.Notifications, as: :notifications do
    pipe_through [:protection, :browser, :verify_access_token]

    resources "/:lang", NotificationController, only: [:show]
  end

  scope "/firmware", OnlineMockCookidoo.Firmware, as: :firmware do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
    get "/update", UpdateController, :show
    get "/tmd", TMDController, :show
  end

  scope "/auth", OnlineMockCookidoo.Auth, as: :auth do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/auth", OnlineMockCookidoo.Auth, as: :auth do
    pipe_through [:protection]

    resources "/authorization-code", AuthorizationCodeController,
      only: [:show, :create],
      singleton: true
  end

  scope "/auth", OnlineMockCookidoo.Auth, as: :auth do
    pipe_through [:protection, :json_api]

    get "/.well-known/openid-configuration", OpenIDConfigurationController, :show
    get "/jwks.json", JSONWebKeySetController, :show
    post "/token", TokenController, :create
    post "/resource-owner-password-credentials", TokenController, :create
    post "/device-authorization", DeviceAuthorizationController, :create
  end

  scope "/auth", OnlineMockCookidoo.Auth, as: :auth do
    pipe_through [:protection, :browser]

    resources "/sessions", SessionController, only: [:new, :create]
    get "/end_session", EndSessionController, :show
    post "/end_session", EndSessionController, :create
  end

  scope "/cadd", OnlineMockCookidoo.CADD, as: :cadd do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/cadd", OnlineMockCookidoo.CADD, as: :cadd do
    pipe_through [:protection, :json_api]

    get "/update/:minFirmware", UpdateController, :show
  end

  scope "/commerce", OnlineMockCookidoo.Commerce, as: :commerce do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/:lang/commerce", OnlineMockCookidoo.Commerce do
    pipe_through [:protection, :browser]

    get "/available-subscriptions", AvailableSubscriptionsController, :show
  end

  scope "/customer-devices", OnlineMockCookidoo.CustomerDevices, as: :"customer-devices" do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/customer-devices", OnlineMockCookidoo.CustomerDevices do
    pipe_through [:protection, :json_api]

    resources "/activation", ActivationController,
      only: [:show, :create, :delete],
      singleton: true
  end

  scope "/search", OnlineMockCookidoo.Search, as: :search do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/search", OnlineMockCookidoo.Search, as: :search do
    pipe_through [:protection, :browser]

    get "/home-with-filters-exploded", HomeWithFiltersExplodedController, :index
    get "/search-results", SearchResultsController, :index
    get "/search-config", SearchConfigController, :index
  end

  scope "/stolen-devices", OnlineMockCookidoo.StolenDevices do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/stolen-devices", OnlineMockCookidoo.StolenDevices do
    pipe_through [:protection, :json_api]

    get "/status", StatusController, :show
  end

  scope "/planning", OnlineMockCookidoo.Planning, as: :planning do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/planning", OnlineMockCookidoo.Planning, as: :planning do
    pipe_through [:protection, :json_api]

    get "/associated-recipe-list", AssociatedRecipeListController, :index

    resources "/my-week", MyWeekController, only: [:index, :show]

    resources "/my-day", MyDayController, only: [:index, :show, :update, :delete] do
      resources "/planned-recipes", PlannedRecipesController, only: [:index, :delete]
    end

    post "/my-day/move-recipe", MoveRecipeController, :create
  end

  scope "/planning", OnlineMockCookidoo.Planning, as: :planning do
    pipe_through [:protection, :browser]

    get "/planner", PlannerController, :index
  end

  scope "/customer-recipes", OnlineMockCookidoo.CustomerRecipes, as: :"customer-recipes" do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/customer-recipes", OnlineMockCookidoo.CustomerRecipes, as: :"customer-recipes" do
    pipe_through [:protection, :browser]

    get "/recipe-details/:id", CustomerRecipeController, :show
    get "/recipes-list", RecipesListController, :index
    get "/recipes-list/:recipe", RecipesListController, :show
    get "/recipes-list/:recipe/cook", RecipeCookController, :show
    get "/device-offline-recipes", OfflineRecipesController, :index
  end

  scope "/foundation", OnlineMockCookidoo.Foundation, as: :foundation do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/foundation", OnlineMockCookidoo.Foundation, as: :foundation do
    pipe_through [:protection, :browser]

    get "/explore", ExploreController, :index
    get "/browse-app", BrowseAppController, :index
  end

  scope "/profile", OnlineMockCookidoo.Profile, as: :profile do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/profile", OnlineMockCookidoo.Profile, as: :profile do
    pipe_through [:protection, :json_api]

    get "/device-consents", DeviceConsentsController, :index
    get "/usage-box-consent-menu", UsageBoxConsentMenuController, :index
    get "/usagebox-consents/:consent_type/:user_device_id", UsageBoxConsentsController, :show
  end

  scope "/profile", OnlineMockCookidoo.Profile, as: :profile do
    pipe_through [:protection, :browser]

    get "/consent", ConsentController, :index
    get "/data-usage", DataUsageController, :index
    get "/privacy-policy", PrivacyPolicyController, :index
  end

  scope "/ownership", OnlineMockCookidoo.Ownership, as: :ownership do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/ownership", OnlineMockCookidoo.Ownership do
    pipe_through [:protection, :json_api]

    get "/collections", CollectionsController, :index
    get "/subscriptions", SubscriptionsController, :index
    get "/recipes", RecipesController, :index
    get "/offline-recipes", OfflineRecipesController, :index
  end

  scope "/organize", OnlineMockCookidoo.Organize, as: :organize do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/organize", OnlineMockCookidoo.Organize do
    pipe_through [:protection, :json_api]

    resources "/managed-list", ManagedListController,
      only: [:show, :create, :index],
      as: :"api-managed-list"

    resources "/custom-list", CustomListController, only: [:index, :show], as: :"api-custom-list"
    get "/list-sync", ListSyncController, :index
    get "/associated-recipe-list", AssociatedRecipeListController, :index
    get "/bookmark", BookmarkController, :index, as: :"api-bookmark"
    post "/cooking-history-multiple", CookingHistoryMultipleController, :create
  end

  scope "/recipe-assets", OnlineMockCookidoo.RecipeAssets, as: :"recipe-assets" do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/recipe-assets", OnlineMockCookidoo.RecipeAssets do
    pipe_through [:protection, :json_api]

    resources "/recipes", RecipeController, only: [:show, :edit]
    resources "/macros", MacroController, only: [:show, :edit]
    get "/modes.tar.gz", ModesController, :index
    get "/icons.tar.gz", IconsController, :show
    get "/primary-categories.tar.gz", PrimaryCategoriesController, :index
  end

  scope "/recipe-details", OnlineMockCookidoo.RecipeDetails, as: :"recipe-details" do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/recipe-details", OnlineMockCookidoo.RecipeDetails do
    pipe_through [:protection, :json_api, :verify_access_token]

    resources "/cluster", RecipeVariantsController, only: [:show]
  end

  scope "/recommender", OnlineMockCookidoo.Recommender, as: :recommender do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/recommender", OnlineMockCookidoo.Recommender do
    pipe_through [:protection, :json_api]

    get "/offline-recipes", OfflineRecipesController, :index
  end

  scope "/usagebox", OnlineMockCookidoo.Usagebox, as: "usagebox" do
    pipe_through [:protection, :json_hal_api]

    get "/.well-known/home", HomeController, :show
  end

  scope "/usagebox", OnlineMockCookidoo.Usagebox, as: "usagebox" do
    pipe_through [:protection, :json_api]

    get "/device-config", DeviceConfigController, :show
    get "/upload-url", UploadURLController, :show
  end

  scope "/usagebox", OnlineMockCookidoo.Usagebox, as: "usagebox" do
    pipe_through :protection

    put "/upload", UploadController, :update
  end

  scope "/firmware", OnlineMockCookidoo.Firmware do
    pipe_through :protection

    get "/tmd/:name", DownloadTMDController, :show
  end

  scope "/firmware", OnlineMockCookidoo.Firmware do
    # This route not having cookie protection enabled is a workaround
    # due to the Software Download Manager not sending protection cookies
    # despite being a cookidoo URL. See NWOTSW-29359
    get "/:key", DownloadController, :show
  end
end
