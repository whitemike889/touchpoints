class Admin::SiteController < AdminController
  def index
    @forms = Form.non_templates
    @agencies = Organization.all.order(:name)

    @days_since = params[:recent] && params[:recent].to_i <= 365 ? params[:recent].to_i : 3
    @dates = (@days_since.days.ago.to_date..Date.today).map{ |date| date }

    @response_groups = Submission.group("date(created_at)").count.sort.last(@days_since.days)
    @user_groups = User.group("date(created_at)").count.sort.last(@days_since.days)
    todays_submissions = Submission.where("created_at > ?", Time.now - @days_since.days)

    # Add in 0 count days to fetched analytics
    @dates.each do | date |
      @user_groups << [date, 0] unless @user_groups.detect{ | row | row[0].strftime("%m %d %Y") == date.strftime("%m %d %Y")}
      @response_groups << [date, 0] unless @response_groups.detect{ | row | row[0].strftime("%m %d %Y") == date.strftime("%m %d %Y")}
    end
    @user_groups = @user_groups.sort
    @response_groups = @response_groups.sort

    form_ids = todays_submissions.collect(&:form_id).uniq
    @recent_forms = Form.find(form_ids)
  end

  def events
    @events = Event.limit(500).order("created_at DESC").page params[:page]
  end

  def a11
  end

  def events_export
    ExportEventsJob.perform_later(params[:uuid])
    render json: { result: :ok }
  end

  def management
    ensure_admin
  end
end
