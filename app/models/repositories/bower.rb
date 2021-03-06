module Repositories
  class Bower < Base
    HAS_VERSIONS = false
    HAS_DEPENDENCIES = false
    LIBRARIAN_SUPPORT = true
    SECURITY_PLANNED = true
    URL = 'http://bower.io'
    COLOR = '#563d7c'

    def self.project_names
      projects.keys
    end

    def self.projects
      @projects ||= begin
        projects = {}
        data = get("https://bower.herokuapp.com/packages")

        data.each do |hash|
          projects[hash['name'].downcase] = hash.slice('name', 'url')
        end

        projects
      end
    end

    def self.project(name)
      projects[name.downcase]
    end

    def self.mapping(project)
      bower_json = load_bower_json(project) || {}
      {
        :name => project["name"],
        :repository_url => repo_fallback(nil, project["url"]),
        :licenses => bower_json['license'],
        :keywords_array => bower_json['keywords'],
        :homepage => bower_json["homepage"],
        :description => bower_json["description"]
      }
    end

    def self.load_bower_json(mapped_project)
      return {} unless mapped_project['url']
      github_name_with_owner = GithubUrls.parse(mapped_project['url'])
      return {} unless github_name_with_owner
      get_json("https://raw.githubusercontent.com/#{github_name_with_owner}/master/bower.json") rescue {}
    end
  end
end
