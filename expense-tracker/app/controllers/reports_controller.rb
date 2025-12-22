# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    @current_month = params[:month]&.to_date || Time.zone.today.beginning_of_month
    @summary = Reports::MonthlySummaryService.new(
      current_user,
      start_date: @current_month.beginning_of_month,
      end_date: @current_month.end_of_month
    ).call
  end

  def monthly
    start_date = params[:start_date]&.to_date || Time.zone.today.beginning_of_month
    end_date = params[:end_date]&.to_date || Time.zone.today.end_of_month

    @summary = Reports::MonthlySummaryService.new(
      current_user,
      start_date: start_date,
      end_date: end_date
    ).call

    @start_date = start_date
    @end_date = end_date
  end

  def trends
    months = params[:months]&.to_i || 6
    @trends = Reports::TrendAnalyzerService.new(current_user, months: months).call
    @months = months
  end
end
