# encoding: utf-8


class IssueBurndownChartController < ApplicationController
  include Redmine::I18n
  unloadable
  before_filter :find_project, :authorize
  menu_item :issue_burndown_chart
  
  layout 'issue_burndown_chart'
  
  def index
    @msg = params[:notice]
    start_of_week
  end

  def show
    params[:issue_id] = params[:id]
    params[:start_date] = ""
    params[:end_date] = ""
    create 
  end

  def create
    start_of_week

    begin

      issue = Issue.find_by_id(params[:issue_id])
      if issue
        @first_date = issue.start_date
        @last_date = issue.start_date
        @estimate = {}
        @estimate_total = 0
        @issue_ids = []
        id_with_children(issue)
        cf = IssueCustomField.find_by_name('RemainUmVtYWlu')

        @results = Journal.joins(:details).
          where(:journalized_type => 'Issue').
          where(:journalized_id => @issue_ids).
          where(:journal_details => {:property => 'cf', :prop_key => cf.id}).
          select("journalized_id as issue_id, DATE(created_on AT TIME ZONE 'UTC' AT TIME ZONE '#{Time.zone.name}') as created, journal_details.value as val").
          order("journalized_id, created_on asc")

        @max = @estimate_total
	      @data_ideal = []
	      @data_actual = []
        period = (@last_date - @first_date).to_i

        (@first_date..@last_date).each_with_index do |date, i|
          if (!params[:start_date].to_date || params[:start_date].to_date <= date) and (!params[:end_date].to_date || params[:end_date].to_date >= date)
            dispdate = date.strftime("%-m/%-d")
            @data_ideal << [dispdate, @estimate_total * (period - i) / period]
            if date <= Time.now
              @data_actual << [dispdate, get_remain(date)]
            end
          end
        end

        @chart_data = [
            { name: l(:ideal_remain), data: @data_ideal },
            { name: l(:actual_remain), data: @data_actual }
        ]
        #puts @chart_data
      else
        @msg = l(:msg_invalid_issue_id)
      end
    
    rescue Exception => e
      logger.fatal e
      logger.fatal e.backtrace.join("\n")
      @msg = e.to_s
    end
    render action: "index"
  end

private
  def start_of_week
    @start_of_week = Setting.start_of_week
    @start_of_week = 1 if @start_of_week.blank?
    @start_of_week = @start_of_week.to_i % 7
  end

  def get_remain(date)
    remain = 0
    @issue_ids.each do |id|
      latest = @estimate[id]
      @results.each do |result|
        if result.issue_id == id
          if result.created < date
            latest = result.val.to_i
          end
          if result.created.strftime("%-m/%-d") == date.strftime("%-m/%-d")
            latest = result.val.to_i
          end 
          if result.created > date
            break
          end
        end
      end 
      print id, " ",  date, " ", latest, "\n"
      remain += latest if latest
    end
    @max = remain if remain > @max
    remain
  end

  def id_with_children(issue)
    @estimate[issue.id] = issue.estimated_hours
    @estimate_total += issue.estimated_hours if issue.estimated_hours
    @issue_ids << issue.id
    @start_date = issue.start_date if issue.start_date < @first_date
    @last_date = issue.due_date if issue.due_date > @first_date
    if issue.children?
       issue.children.each {|i|
         id_with_children(i)
       }
    end 
  end

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

end
