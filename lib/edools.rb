require "edools/version"
require "edools/connection"

module Edools
    def get_courses
        connection = Connection.new
        courses = connection.get "/courses"
    end
end
