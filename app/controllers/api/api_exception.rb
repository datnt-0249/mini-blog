module Api
  module ApiException
    module Api::ApiException::Handler
      class BaseError < StandardError
        attr_reader :status_code
      end

      class AuthenticationError < BaseError
        def initialize msg = nil
          @status_code = 401
          msg ||= I18n.t("api.errors.authenticate")
          super
        end
      end

      class Forbidden < BaseError
        attr_reader :status_code

        def initialize msg = nil
          @status_code = 403
          msg ||= I18n.t("api.errors.forbidden")
          super
        end
      end
    end
  end
end
