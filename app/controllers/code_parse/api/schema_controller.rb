module CodeParse
  module Api
    class SchemaController < ApplicationController
    def index
      data = Parsers::SchemaParser.new.parse

      render json: data
    rescue => e
      render json: { error: e.message }, status: 500
    end
    end
  end
end
