require 'bugsnag/api'

class Bugsnag
  attr_reader :errors, :dev_project_id, :prod_project_id

  def initalize
    @errors = errors
    @dev_project_id = dev_project_id
    @prod_project_id = prod_project_id
  end

  def retrieve_projects
    Bugsnag::Api.configure do |config|
      config.auth_token = "05c5e1b1-5e84-43c3-a696-10d2eef33c22"
      config.endpoint = "https://bugsnag-api.roostify.com"
    end

    organizations = Bugsnag::Api.organizations

    projects = Bugsnag::Api.projects(organizations.first.id)
    project_ids = projects.map{|x| [x.name, x.id]}
    @dev_project_id = project_ids.first[1]
    @prod_project_id = project_ids[1][1]
  end

  def project_event_fields(project)
    if project.downcase == "dev"
      fields = Bugsnag::Api.event_fields(@dev_project_id)
    elsif project.downcase == "prod"
      fields = Bugsnag::Api.event_fields(@prod_project_id)
    else
      puts "Invalid project"
    end

    fields.map {|f| f[:display_id]}
  end

  def query_bugsnag(project_id, input_json)
    input = JSON.parse(input_json)
    filter = {}

    input.each do |k, v|
      filter[k] = [{"type" => "eq", "value" => v.to_s}]
    end

    @errors = Bugsnag::Api.errors(project_id, nil, options = filters: filter)
  end
end
