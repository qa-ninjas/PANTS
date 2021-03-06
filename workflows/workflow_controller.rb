
require_relative "./workflow"
require_relative "./login"
require_relative "./create_corporate_event"
require_relative "./add_home"

require_relative "../users/user_builder"
require_relative "../pages/page_builder"

class WorkflowController
    include UserBuilder

    def initialize(workflows:)
        @commands = workflows[:commands]
        @hostname = workflows[:hostname]
        @page_builder = PageBuilder.new(@hostname)
    end

    def run_workflows
        current_user = nil

        @commands.each do |command|
            begin
                puts command[:workflow]
                workflow = find_workflow(command[:workflow])
                puts workflow

                # first command must have a user
                # subsequent commands will use previous user
                current_user = build_user_from_input user_info: command[:user], page_builder: @page_builder if command[:user]
                workflow.setup(user: current_user, input: command[:input])
                workflow.run

                puts "Post Run!"
                workflow.post_run
            end
        end
        
    ensure 
        @page_builder.tear_down
    end


    def find_workflow type
        puts "finding workflow type"

        types = {
            "login": Login.new,
            "add_home": AddHome.new,
            "create_corp_event": CreateCorporateEvent.new
        }

        return types[type.intern] || Workflow.new
    end


end
