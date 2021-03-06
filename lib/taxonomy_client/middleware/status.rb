module TaxonomyClient
  module Middleware
    class Status < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |env|
          handle_status(env[:status], env)
        end
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError
        raise Errors::ConnectionError, environment
      end

      protected

      def handle_status(code, env)
        case code
          when 200..299
          when 300..399
            raise Errors::Redirected, env
          when 401
            raise Errors::NotAuthorized, env
          when 403
            raise Errors::AccessDenied, env
          when 404
            raise Errors::NotFound, env[:url]
          when 409
            raise Errors::Conflict, env
          when 422
            raise Errors::UnprocessableEntity, env
          when 400..499
            raise Errors::BadRequest, env
          when 500..599
            raise Errors::ServerError, env
          else
            raise Errors::UnexpectedStatus.new(code, env[:url])
        end
      end
    end
  end
end